#!/usr/bin/env python3
"""
Czarina Dashboard - Live Multi-Agent Orchestration Monitor
Real-time monitoring of all workers, daemon, and git status
"""

import json
import os
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

try:
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.layout import Layout
    from rich.live import Live
    from rich import box
    from rich.text import Text
except ImportError:
    print("📦 Installing rich library...")
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "rich"], check=True)
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.layout import Layout
    from rich.live import Live
    from rich import box
    from rich.text import Text


class CzarinaDashboard:
    def __init__(self, czarina_dir: Path):
        self.czarina_dir = czarina_dir
        self.config_file = czarina_dir / "config.json"
        self.status_dir = czarina_dir / "status"
        self.console = Console()

        if not self.config_file.exists():
            raise FileNotFoundError(f"Config not found: {self.config_file}")

        with open(self.config_file) as f:
            self.config = json.load(f)

        self.project_name = self.config["project"]["name"]
        self.project_slug = self.config["project"]["slug"]
        self.project_root = Path(self.config["project"]["repository"])
        self.workers = self.config["workers"]

        # Find session names
        self.sessions = self._find_sessions()

    def _find_sessions(self) -> List[str]:
        """Find all active czarina tmux sessions for this project"""
        result = subprocess.run(
            ["tmux", "list-sessions", "-F", "#{session_name}"],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return []

        sessions = []
        for line in result.stdout.strip().split('\n'):
            if line and ('czarina' in line.lower() or self.project_slug in line):
                sessions.append(line)

        return sessions

    def _get_worker_status(self, worker_id: str, session: str) -> Tuple[str, str]:
        """Get current status of a worker from tmux"""
        # Try to find the window for this worker
        # Look for both old naming (worker_id) and new naming (workerN)
        result = subprocess.run(
            ["tmux", "list-windows", "-t", session, "-F", "#{window_name}"],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return "❓ Unknown", ""

        windows = result.stdout.strip().split('\n')

        # Try to find worker window by ID or by number
        target_window = None
        if worker_id in windows:
            target_window = worker_id
        else:
            # Try finding by worker number (worker1, worker2, etc)
            for i, worker in enumerate(self.workers):
                if worker["id"] == worker_id:
                    worker_num = i + 1
                    candidate = f"worker{worker_num}"
                    if candidate in windows:
                        target_window = candidate
                        break

        if not target_window:
            return "❓ Not Found", ""

        # Capture the pane content
        result = subprocess.run(
            ["tmux", "capture-pane", "-t", f"{session}:{target_window}", "-p"],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return "❌ Error", ""

        output = result.stdout

        # Analyze output to determine status
        if "aider" in output.lower() and ("add" in output.lower() or "edit" in output.lower()):
            return "🟢 Active", "Working with Aider"
        elif "error" in output.lower() or "failed" in output.lower():
            return "🔴 Error", "Error detected"
        elif "waiting" in output.lower() or "do you want" in output.lower():
            return "🟡 Waiting", "Needs input"
        elif "ready for claude code" in output.lower():
            return "⚪ Ready", "Waiting to start"
        elif output.strip().endswith('$'):
            return "⚪ Idle", "At prompt"
        else:
            return "🟢 Active", "Running"

    def _get_git_status(self, worker_id: str) -> str:
        """Check git status for worker's worktree"""
        worktree_dir = self.project_root / ".czarina" / "worktrees" / worker_id

        if not worktree_dir.exists():
            return "❌ No worktree"

        result = subprocess.run(
            ["git", "-C", str(worktree_dir), "status", "--short"],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return "❌ Git error"

        status = result.stdout.strip()
        if not status:
            return "✅ Clean"

        lines = status.split('\n')
        modified = len([l for l in lines if l.startswith(' M') or l.startswith('M ')])
        added = len([l for l in lines if l.startswith('A ') or l.startswith('??')])

        return f"📝 {modified}M {added}A"

    def _get_daemon_status(self) -> Tuple[str, str]:
        """Check if daemon is running"""
        daemon_session = f"{self.project_slug}-daemon"

        result = subprocess.run(
            ["tmux", "has-session", "-t", daemon_session],
            capture_output=True
        )

        if result.returncode == 0:
            # Get latest daemon activity
            result = subprocess.run(
                ["tmux", "capture-pane", "-t", daemon_session, "-p"],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                output = result.stdout
                if "Iteration" in output:
                    # Extract iteration number
                    for line in output.split('\n'):
                        if "=== Iteration" in line:
                            return "🟢 Running", line.strip()

                return "🟢 Running", "Active"

            return "🟢 Running", "Monitoring"

        return "❌ Stopped", "Not running"

    def create_dashboard(self) -> Layout:
        """Create the dashboard layout"""
        layout = Layout()

        layout.split_column(
            Layout(name="header", size=3),
            Layout(name="body"),
            Layout(name="footer", size=3)
        )

        layout["body"].split_row(
            Layout(name="workers"),
            Layout(name="status", ratio=1)
        )

        return layout

    def generate_header(self) -> Panel:
        """Generate header panel"""
        text = Text()
        text.append(f"🎭 Czarina Dashboard - {self.project_name}\n", style="bold cyan")
        text.append(f"📁 {self.project_root}\n", style="dim")
        text.append(f"⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", style="dim")

        return Panel(text, box=box.DOUBLE, style="cyan")

    def generate_workers_table(self) -> Table:
        """Generate workers status table"""
        table = Table(title="👷 Workers", box=box.ROUNDED, show_header=True, header_style="bold magenta")

        table.add_column("Worker", style="cyan", width=25)
        table.add_column("Status", width=12)
        table.add_column("Git", width=12)
        table.add_column("Details", style="dim")

        for worker in self.workers:
            worker_id = worker["id"]

            # Try to find worker in any session
            status = "❓ Unknown"
            details = ""
            for session in self.sessions:
                if 'daemon' not in session:
                    s, d = self._get_worker_status(worker_id, session)
                    if s != "❓ Not Found":
                        status = s
                        details = d
                        break

            git_status = self._get_git_status(worker_id)

            table.add_row(worker_id, status, git_status, details)

        return table

    def generate_status_panel(self) -> Panel:
        """Generate overall status panel"""
        daemon_status, daemon_info = self._get_daemon_status()

        # Count worker statuses
        active = sum(1 for w in self.workers if self._get_worker_status(w["id"], self.sessions[0] if self.sessions else "")[0] == "🟢 Active")
        idle = sum(1 for w in self.workers if "Idle" in self._get_worker_status(w["id"], self.sessions[0] if self.sessions else "")[0])

        text = Text()
        text.append("📊 System Status\n\n", style="bold yellow")
        text.append(f"Sessions: {len([s for s in self.sessions if 'daemon' not in s])}\n", style="cyan")
        text.append(f"Workers: {len(self.workers)}\n", style="cyan")
        text.append(f"  Active: {active}\n", style="green")
        text.append(f"  Idle: {idle}\n", style="dim")
        text.append(f"\n{daemon_status} Daemon\n", style="bold")
        text.append(f"  {daemon_info}\n", style="dim")

        # Git worktrees
        worktrees_dir = self.project_root / ".czarina" / "worktrees"
        if worktrees_dir.exists():
            worktree_count = len(list(worktrees_dir.iterdir()))
            text.append(f"\n📁 Worktrees: {worktree_count}\n", style="cyan")

        return Panel(text, title="Status", box=box.ROUNDED, style="yellow")

    def generate_footer(self) -> Panel:
        """Generate footer with commands"""
        text = Text()
        text.append("Commands: ", style="bold")
        text.append("Press Ctrl+C to exit  |  ", style="dim")
        text.append(f"Sessions: {', '.join([s for s in self.sessions if 'daemon' not in s])}", style="dim")

        return Panel(text, box=box.ROUNDED, style="dim")

    def update_display(self, layout: Layout):
        """Update the dashboard display"""
        layout["header"].update(self.generate_header())
        layout["workers"].update(self.generate_workers_table())
        layout["status"].update(self.generate_status_panel())
        layout["footer"].update(self.generate_footer())

    def run(self, refresh_interval: int = 5):
        """Run the live dashboard"""
        layout = self.create_dashboard()

        try:
            with Live(layout, console=self.console, refresh_per_second=0.5) as live:
                while True:
                    self.update_display(layout)
                    time.sleep(refresh_interval)
        except KeyboardInterrupt:
            self.console.print("\n\n👋 Dashboard stopped", style="yellow")


def find_czarina_dir() -> Optional[Path]:
    """Find .czarina directory in current or parent directories"""
    current = Path.cwd()

    while current != current.parent:
        czarina_dir = current / ".czarina"
        if czarina_dir.exists() and czarina_dir.is_dir():
            return czarina_dir
        current = current.parent

    return None


def main():
    console = Console()

    # Try to find .czarina directory
    czarina_dir = find_czarina_dir()

    if not czarina_dir:
        console.print("❌ No .czarina directory found", style="bold red")
        console.print("💡 Run this from a Czarina project directory", style="yellow")
        sys.exit(1)

    console.print(f"🎭 Starting dashboard for: {czarina_dir.parent}", style="bold cyan")
    console.print("📊 Loading...\n", style="dim")

    try:
        dashboard = CzarinaDashboard(czarina_dir)
        dashboard.run(refresh_interval=3)
    except FileNotFoundError as e:
        console.print(f"❌ {e}", style="bold red")
        sys.exit(1)
    except Exception as e:
        console.print(f"❌ Error: {e}", style="bold red")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
