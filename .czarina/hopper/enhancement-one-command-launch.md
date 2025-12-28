# Enhancement: One-Command Launch from Plan

**Priority:** High
**Complexity:** Medium
**Value:** Very High - Core UX Improvement
**Tags:** ux, cli, workflow, automation
**Status:** Proposed
**Created:** 2025-12-28

## User Feedback

**Direct Quote:** "I'd also like a much cleaner transition to start...literally, czarina analyze [markdownfile] and it just goes."

## Current Workflow (Too Many Steps)

```bash
# Step 1: Analyze plan
czarina analyze INTEGRATION_PLAN_v0.7.0.md --interactive

# Step 2: Claude launches to help create config/workers
# [User collaborates with Claude to create files]

# Step 3: Close Claude session
# [Manual action]

# Step 4: Verify config created
ls .czarina/config.json
ls .czarina/workers/*.md

# Step 5: Close previous phase
czarina phase close

# Step 6: Initialize new phase
czarina init --from-config .czarina/config-v0.7.0.json

# Step 7: Fix config issues
# [Edit config to fix branch naming, etc.]

# Step 8: Actually launch
czarina launch
```

**Pain Points:**
- **8 separate steps** from plan to running orchestration
- Multiple manual interventions required
- Config issues discovered late
- Friction kills momentum

## Desired Workflow (One Command)

```bash
# One command, done
czarina analyze INTEGRATION_PLAN_v0.7.0.md --go
```

**Or even simpler:**

```bash
czarina go INTEGRATION_PLAN_v0.7.0.md
```

**What should happen:**
1. Analyze plan → Extract workers, config
2. Close previous phase (if exists)
3. Generate config.json with correct naming
4. Generate all worker identity files
5. Validate config
6. Initialize branches
7. Create worktrees
8. Launch tmux session
9. Start all workers
10. **Done!**

All in one command, fully automated.

## Implementation Design

### Option A: Extend `analyze` Command

```bash
czarina analyze <plan.md> [--go|--launch|--auto]
```

**Behavior:**
```bash
# Without --go: Interactive mode (current)
czarina analyze plan.md --interactive

# With --go: Fully automated
czarina analyze plan.md --go
```

**Flags:**
- `--go` / `--launch` / `--auto`: Skip approval, launch immediately
- `--interactive`: Current behavior (for safety)
- `--dry-run`: Show what would happen, don't execute

### Option B: New `go` Command

```bash
czarina go <plan.md> [options]
```

Dedicated command for "analyze and launch in one shot"

**Pros:**
- Clearer intent
- Memorable command
- Separate from multi-step analyze

**Cons:**
- Yet another command
- Analyze + go overlap

### Option C: Smart `launch` Command

```bash
czarina launch --plan <plan.md>
```

**Behavior:**
- If `.czarina/config.json` exists → launch normally
- If `--plan` provided → analyze, generate, launch

**Pros:**
- Single command for launching
- Context-aware

**Cons:**
- Overloads `launch` semantics
- Less obvious

## Recommended: Option A (Extended Analyze)

**Command:**
```bash
czarina analyze <plan.md> --go
```

**Rationale:**
- `analyze` is already the entry point
- `--go` flag is clear intent
- Maintains backward compatibility with `--interactive`
- Future: Make `--go` the default, `--interactive` for safety

## Detailed Implementation

### Phase 1: Automated Config Generation

**Challenge:** Current analyze requires human-in-loop via Claude

**Solution:** Implement plan parsing + config generation

```python
def analyze_plan_automated(plan_file):
    """Parse plan and generate config automatically"""

    # Parse markdown plan
    plan = parse_markdown_plan(plan_file)

    # Extract workers
    workers = extract_workers(plan)

    # Generate config.json
    config = {
        "project": {
            "name": infer_project_name(plan),
            "slug": slugify(name),
            "phase": 1,
            ...
        },
        "omnibus_branch": f"cz1/release/v{version}",
        "workers": [
            {
                "id": worker.id,
                "role": worker.role,
                "agent": worker.agent or "claude",
                "branch": f"cz1/feat/{worker.id}",
                "description": worker.description,
                "dependencies": worker.dependencies
            }
            for worker in workers
        ]
    }

    return config
```

**Plan Parsing Heuristics:**

```python
def extract_workers(plan_content):
    """Extract worker definitions from plan"""

    # Look for patterns:
    # - "Worker 1: worker-id"
    # - "### Worker: worker-id"
    # - Bullet lists with worker info

    # Example from INTEGRATION_PLAN_v0.7.0.md:
    # #### Worker 1: `rules-integration`
    # - **Role:** Code
    # - **Agent:** Claude Code
    # - **Branch:** feat/v0.7.0-rules-integration
    # - **Dependencies:** None

    workers = []
    for section in find_worker_sections(plan_content):
        worker = {
            "id": extract_worker_id(section),
            "role": extract_role(section),
            "agent": extract_agent(section),
            "description": extract_description(section),
            "dependencies": extract_dependencies(section),
            "tasks": extract_tasks(section)
        }
        workers.append(worker)

    return workers
```

### Phase 2: Automated Worker Identity Generation

```python
def generate_worker_identity(worker, plan_context):
    """Generate worker identity file from plan"""

    template = f"""# Worker Identity: {worker.id}

**Role:** {worker.role}
**Agent:** {worker.agent}
**Branch:** cz1/feat/{worker.id}
**Phase:** {worker.phase}
**Dependencies:** {", ".join(worker.dependencies) or "None"}

## Mission

{worker.mission or infer_mission(worker)}

## Objectives

{format_objectives(worker.tasks)}

## 🚀 YOUR FIRST ACTION

**Step 1:** {worker.first_action or infer_first_action(worker)}

## Deliverable

{worker.deliverable}

## Success Criteria

{format_success_criteria(worker)}
"""

    return template
```

### Phase 3: Automated Launch Sequence

```python
def auto_launch_orchestration(plan_file, options):
    """Fully automated orchestration launch"""

    # 1. Parse plan
    print("🔍 Analyzing plan...")
    config = analyze_plan_automated(plan_file)

    # 2. Close previous phase if exists
    if czarina_exists():
        if not options.get('force'):
            confirm = input("Close existing orchestration? [Y/n]: ")
            if confirm.lower() == 'n':
                return

        print("📦 Closing previous phase...")
        phase_close()

    # 3. Generate configuration
    print("⚙️  Generating configuration...")
    write_config(config)

    # 4. Generate worker identities
    print("👷 Generating worker identities...")
    for worker in config['workers']:
        identity = generate_worker_identity(worker, plan_context)
        write_worker_identity(worker['id'], identity)

    # 5. Validate
    print("✅ Validating configuration...")
    if not validate_config(config):
        print("❌ Validation failed")
        return False

    # 6. Initialize branches
    print("🌿 Initializing git branches...")
    init_branches(config)

    # 7. Launch orchestration
    print("🚀 Launching orchestration...")
    launch_orchestration(config)

    # 8. Done!
    print("\n✅ Orchestration launched successfully!")
    print(f"   Attach: tmux attach -t czarina-{config['project']['slug']}")

    return True
```

## Plan Format Requirements

For automated parsing to work, plans should follow structure:

```markdown
# Project Plan: [Name]

## Workers

### Worker 1: worker-id
- **Role:** code / qa / documentation / architect
- **Agent:** claude / aider / cursor
- **Dependencies:** worker1, worker2 (or None)
- **Tasks:**
  - Task 1
  - Task 2

### Worker 2: another-worker
...
```

**Alternative:** Use YAML frontmatter

```markdown
---
project: czarina-v0.7.0
version: 0.7.0
workers:
  - id: rules-integration
    role: code
    agent: claude
    dependencies: []
---

# Plan Content
...
```

## Migration Strategy

### Phase 1: Implement (v0.7.1)
- Add `--go` flag to `czarina analyze`
- Implement automated plan parsing
- Implement automated config/identity generation
- Keep `--interactive` as safe fallback

### Phase 2: Test (v0.7.1)
- Test with v0.7.0 plan
- Test with Hopper plan
- Test with SARK plan
- Refine parsing heuristics

### Phase 3: Make Default (v0.8.0)
- `czarina analyze plan.md` → auto-launch (with confirmation)
- `czarina analyze plan.md --interactive` → old behavior
- `czarina analyze plan.md --yes` → skip confirmation

### Phase 4: Simplify (v0.9.0)
- Add `czarina go plan.md` alias
- Marketing: "One command to rule them all"

## User Experience Goals

**Before (current):**
```bash
$ czarina analyze plan.md --interactive
# [Wait for Claude]
# [Collaborate with Claude]
# [Exit Claude]
$ czarina phase close
$ czarina init --from-config config.json
# [Fix config issues]
$ czarina launch
# [8 steps, 10+ minutes]
```

**After (goal):**
```bash
$ czarina analyze plan.md --go
🔍 Analyzing plan...
📦 Closing previous phase...
⚙️  Generating configuration...
👷 Generating worker identities (9 workers)...
✅ Validating configuration...
🌿 Initializing git branches...
🚀 Launching orchestration...

✅ Orchestration launched successfully!
   Attach: tmux attach -t czarina-czarina-v0_7_0

# [1 command, <60 seconds]
```

## Success Metrics

**Quantitative:**
- Launch time: 10+ min → <60 sec
- Steps required: 8 → 1
- Manual interventions: 5+ → 0
- Config errors: Common → Rare (validated upfront)

**Qualitative:**
- User feedback: "So much faster!"
- Adoption: Users actually use analyze more
- Onboarding: New users launch first orchestration in minutes
- Momentum: No friction to start

## Related Enhancements

- Issue #1: Worker Onboarding (auto-generated identities need "first action")
- Issue #2: Czar Autonomy (auto-launched orchestrations need autonomous coordination)
- Enhancement: Plan Templates (standardize format for parsing)
- Enhancement: Plan Validation (check plan before launch)

## Implementation Checklist

- [ ] Plan parser (Markdown → structured data)
- [ ] Config generator (from parsed plan)
- [ ] Worker identity generator (from parsed plan)
- [ ] Branch name validator (ensure cz<N>/feat/<id> format)
- [ ] Phase close automation
- [ ] Full launch automation
- [ ] `--go` flag implementation
- [ ] Comprehensive error handling
- [ ] Dry-run mode (`--dry-run`)
- [ ] Documentation update
- [ ] Test with real plans
- [ ] User acceptance testing

## Breaking Changes

None - fully backward compatible:
- `czarina analyze plan.md --interactive` still works
- `czarina analyze plan.md --go` is new, opt-in
- Existing workflows unaffected

---

**Status:** Ready for implementation
**Priority:** High (major UX improvement)
**Complexity:** Medium (plan parsing + automation)
**Value:** Very High (eliminates primary friction point)
**Target:** v0.7.1 or v0.8.0
