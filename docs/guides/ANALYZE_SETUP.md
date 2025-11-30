# Setting Up `czarina analyze`

**The `czarina analyze` command uses Claude AI to analyze your implementation plans and automatically generate complete orchestration setups.**

---

## Prerequisites

### 1. Install Anthropic SDK

```bash
pip install anthropic
```

### 2. Get an Anthropic API Key

1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to "API Keys"
4. Create a new API key
5. Copy the key (starts with `sk-ant-...`)

### 3. Set Your API Key

**Option A: Environment Variable (Recommended)**

```bash
export ANTHROPIC_API_KEY=sk-ant-api03-your-key-here
```

Add to your `.bashrc` or `.zshrc` to make it permanent:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-api03-your-key-here' >> ~/.bashrc
source ~/.bashrc
```

**Option B: Config File**

```bash
mkdir -p ~/.anthropic
echo "sk-ant-api03-your-key-here" > ~/.anthropic/api_key
chmod 600 ~/.anthropic/api_key
```

---

## Usage

### Basic Analysis

Analyze an implementation plan without initializing:

```bash
czarina analyze implementation-plan.md
```

This will:
- Read your implementation plan
- Analyze it with Claude AI
- Show recommended worker count, types, and versions
- Display token budget breakdown
- Suggest next steps

### Analysis + Auto-Initialization

Analyze and automatically create `.czarina/` setup:

```bash
cd ~/my-new-project
czarina analyze implementation-plan.md --init
```

This will:
- Analyze the plan
- Create `.czarina/` directory structure
- Generate `config.json` with workers and version plan
- Generate worker prompt files (`.czarina/workers/*.md`)
- Create `.worker-init` script
- Update `.gitignore`

**Result:** Complete orchestration ready to launch!

### Save Analysis for Review

Save the analysis to a JSON file without initializing:

```bash
czarina analyze implementation-plan.md --output analysis.json
```

Review the analysis, then manually create `.czarina/` or re-run with `--init`.

---

## Example Implementation Plan

Create a markdown file describing your project:

```markdown
# My Web App - Implementation Plan

## Project Overview
Build a full-stack task management web application with real-time updates.

## Features

### 1. User Authentication
- JWT-based authentication
- Email/password login
- Password reset flow
- Role-based access control (admin, user)

### 2. Task Management
- Create, read, update, delete tasks
- Task assignment to users
- Task status tracking (todo, in-progress, done)
- Task priority (low, medium, high)
- Due dates and reminders

### 3. Real-Time Updates
- WebSocket connections for live task updates
- Notifications when tasks are assigned
- Live status changes visible to all users

### 4. API Documentation
- OpenAPI/Swagger documentation
- Example requests/responses

## Tech Stack
- Backend: Node.js + Express
- Frontend: React + TypeScript
- Database: PostgreSQL
- Real-time: Socket.io
- Authentication: JWT

## Testing Requirements
- Unit tests for all API endpoints
- Integration tests for workflows
- Real-time connection tests
- 80% code coverage target
```

Save this as `implementation-plan.md`, then run:

```bash
czarina analyze implementation-plan.md --init
```

---

## What Gets Generated

### `.czarina/config.json`

```json
{
  "project": {
    "name": "My Web App",
    "slug": "my-web-app",
    "repository": "/home/you/my-web-app",
    "orchestration_dir": ".czarina"
  },
  "workers": [
    {
      "id": "architect",
      "agent": "claude-code",
      "description": "System Architect",
      "total_token_budget": 200000,
      "versions_assigned": ["v0.1.0"]
    },
    {
      "id": "backend",
      "agent": "aider",
      "description": "Backend API Developer",
      "total_token_budget": 350000,
      "versions_assigned": ["v0.2.0", "v0.3.0"]
    },
    {
      "id": "frontend",
      "agent": "cursor",
      "description": "Frontend Developer",
      "total_token_budget": 300000,
      "versions_assigned": ["v0.2.0", "v0.3.0"]
    },
    {
      "id": "tests",
      "agent": "aider",
      "description": "QA Engineer",
      "total_token_budget": 180000,
      "versions_assigned": ["v0.4.0"]
    }
  ],
  "version_plan": {
    "v0.1.0": {
      "description": "Architecture and foundation",
      "token_budget": {"projected": 200000},
      "workers_assigned": ["architect"],
      "status": "planned"
    },
    "v0.2.0": {
      "description": "Authentication and user management",
      "token_budget": {"projected": 320000},
      "workers_assigned": ["backend", "frontend"],
      "status": "planned"
    },
    "v0.3.0": {
      "description": "Task management and real-time features",
      "token_budget": {"projected": 450000},
      "workers_assigned": ["backend", "frontend"],
      "status": "planned"
    },
    "v0.4.0": {
      "description": "Testing and documentation",
      "token_budget": {"projected": 180000},
      "workers_assigned": ["tests"],
      "status": "planned"
    }
  },
  "daemon": {
    "enabled": true,
    "auto_approve": ["read", "write", "commit"]
  }
}
```

### `.czarina/workers/*.md`

Each worker gets a complete prompt file with:
- Role description
- Version assignments
- Specific responsibilities per version
- Token budgets
- File ownership
- Git workflow
- Completion criteria

---

## After Analysis

### 1. Review Generated Files

```bash
ls -la .czarina/
cat .czarina/config.json
cat .czarina/workers/backend.md
```

### 2. Customize If Needed

Edit the generated files:
- Adjust worker assignments
- Update token budgets
- Modify version breakdown
- Change agent types

### 3. Commit to Git

```bash
git add .czarina/
git commit -m "Add Czarina orchestration"
```

### 4. Launch Workers

```bash
czarina launch
czarina daemon start
```

### 5. Act as Czar

Monitor the orchestration:

```bash
czarina status
tmux attach -t czarina-my-web-app
```

See [CZAR_ROLE.md](CZAR_ROLE.md) for complete Czar guide.

---

## Troubleshooting

### "ANTHROPIC_API_KEY not found"

**Solution:** Set your API key (see Prerequisites above)

### "ModuleNotFoundError: No module named 'anthropic'"

**Solution:**
```bash
pip install anthropic
```

### "Analysis failed"

**Possible causes:**
- API key invalid or expired
- Network connection issues
- Implementation plan too short (< 100 words)
- Implementation plan not in English

**Solution:**
- Check API key is valid
- Ensure internet connection
- Provide more detailed implementation plan

### Model Not Available

If you get a model error, the analyzer will automatically try claude-sonnet-3-5 as a fallback.

---

## Tips for Better Analysis

### 1. Be Specific

**❌ Bad:**
```markdown
Build a web app
```

**✅ Good:**
```markdown
Build a task management web app with:
- User authentication (JWT)
- REST API backend (Node.js + Express)
- React frontend
- PostgreSQL database
- Real-time updates via WebSocket
```

### 2. Include Technical Details

- List specific technologies
- Mention integrations
- Specify testing requirements
- Note performance targets

### 3. Break Down Features

Instead of "task management", specify:
- Create tasks
- Update tasks
- Delete tasks
- Assign tasks to users
- Track task status
- Set task priority
- Add due dates

### 4. Estimate Scope

Mention expected complexity:
- Small (< 500K tokens): 1-2 workers
- Medium (500K-1M): 2-4 workers
- Large (1M-2M): 4-7 workers
- Very Large (> 2M): 7-12 workers

---

## Cost Estimation

Analysis uses Claude Sonnet-4:
- Input: ~$3 per million tokens
- Output: ~$15 per million tokens

**Typical analysis:**
- Input: 10K-20K tokens (template + your plan)
- Output: 5K-15K tokens (generated config/prompts)
- **Cost: ~$0.20-$0.50 per analysis**

Once generated, you can reuse the `.czarina/` setup without re-analyzing.

---

## Advanced Usage

### Custom Output Location

```bash
czarina analyze plan.md --output /path/to/analysis.json
```

### Analyze Without Initializing

```bash
# Just see what would be generated
czarina analyze plan.md

# Review recommendations, then manually:
czarina init
# Edit .czarina/config.json manually
```

### Re-analyze Existing Project

```bash
# Save new analysis
czarina analyze new-plan.md --output analysis-v2.json

# Compare with current .czarina/config.json
# Manually merge changes
```

---

## See Also

- [CZAR_ROLE.md](CZAR_ROLE.md) - Orchestration coordination
- [PROJECT_PLANNING_STANDARDS.md](../PROJECT_PLANNING_STANDARDS.md) - Version planning
- [WORKER_SETUP_GUIDE.md](WORKER_SETUP_GUIDE.md) - Worker configuration
- [ANALYSIS_TEMPLATE.md](../../czarina-core/templates/ANALYSIS_TEMPLATE.md) - What Claude analyzes

---

**Version:** 1.0
**Status:** Production Ready
**Feature Added:** 2024-11-30
