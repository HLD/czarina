# Feature: Intelligent Project Analysis

**Date:** 2025-11-30
**Status:** Proposed
**Priority:** High
**Complexity:** Medium

---

## 🎯 Overview

Add `czarina analyze` command that reads an implementation plan and automatically suggests:
- Optimal worker count
- Worker types and roles
- Version breakdown with phases
- Token budgets per version/phase
- Generated worker prompts

## 💡 Motivation

**Current workflow:**
1. User has implementation plan
2. User manually decides team structure
3. User manually creates worker prompts
4. User manually estimates scope

**With `czarina analyze`:**
1. User provides implementation plan
2. Czarina analyzes and suggests optimal orchestration
3. User approves/modifies suggestions
4. Czarina generates config and worker prompts
5. Ready to launch

**This makes Czarina a project planning assistant, not just an orchestration tool.**

---

## 🏗️ Implementation

### 1. CLI Command

```bash
# Analyze implementation plan
czarina analyze implementation-plan.md

# Analyze with options
czarina analyze plan.md --output .czarina/analysis.json --interactive

# Analyze and auto-init
czarina analyze plan.md --init
```

### 2. Analysis Process

**Input:** Implementation plan (markdown, text, or JSON)

**Analysis steps:**
1. Parse implementation plan
2. Identify major features/components
3. Estimate complexity per component
4. Suggest worker allocation
5. Create version breakdown with phases
6. Estimate token budgets
7. Generate worker prompts

**Output:** Analysis JSON + generated config + worker prompts

### 3. Analysis Template

The AI uses a structured template to analyze:

```
ANALYSIS TEMPLATE:

1. PROJECT OVERVIEW
   - Type (web app, API, library, etc.)
   - Tech stack
   - Complexity (simple/medium/complex)

2. FEATURE BREAKDOWN
   - List all major features
   - Dependencies between features
   - Complexity estimate per feature

3. WORKER ALLOCATION
   - Recommended worker count
   - Worker types (backend, frontend, QA, docs, etc.)
   - Rationale for each worker

4. VERSION PLANNING
   - Version breakdown (v0.1.0, v0.2.0, etc.)
   - Phases for large features
   - Token budget per version
   - Completion criteria

5. GENERATED ARTIFACTS
   - config.json with workers
   - Worker prompt files
   - Version plan JSON
```

### 4. Integration with Init

```bash
# Option A: Analyze first, then init
czarina analyze plan.md
czarina init  # Uses analysis.json if present

# Option B: Combined
czarina analyze plan.md --init

# Option C: Interactive
czarina init --analyze plan.md  # Prompts for approval during init
```

---

## 📊 Example Usage

### Input: implementation-plan.md

```markdown
# Awesome App Implementation Plan

## Goal
Build a full-stack task management app with real-time collaboration.

## Features
1. User authentication (OAuth + JWT)
2. Task CRUD operations
3. Real-time updates (WebSocket)
4. Team collaboration
5. File attachments
6. Search and filtering
7. REST API
8. React frontend
9. Comprehensive testing
10. Documentation

## Tech Stack
- Backend: Node.js + Express + PostgreSQL
- Frontend: React + TypeScript
- Real-time: Socket.io
- Auth: Passport.js
```

### Command

```bash
czarina analyze implementation-plan.md --interactive
```

### Output (Terminal)

```
📊 Analyzing implementation plan...

Project: Awesome App
Type: Full-stack web application
Complexity: Medium-High

Recommended Orchestration:
  Workers: 7
  Versions: 5 main versions + 2 with phases
  Total Projected Tokens: ~2.3M

Version Breakdown:
  v0.1.0: Architecture & Database (1 worker, 180K tokens)
  v0.2.0: Authentication System (2 workers, 320K tokens)
  v0.3.0-phase1: Core Backend APIs (3 workers, 450K tokens)
  v0.3.0-phase2: Real-time Features (2 workers, 280K tokens)
  v0.4.0-phase1: Frontend Foundation (3 workers, 380K tokens)
  v0.4.0-phase2: Frontend Features (3 workers, 320K tokens)
  v0.5.0: Testing & QA (2 workers, 250K tokens)
  v0.6.0: Documentation (2 workers, 120K tokens)

Recommended Workers:
  ✅ architect     - System architecture and design (claude-code)
  ✅ backend-1     - Core backend services (aider)
  ✅ backend-2     - API development (aider)
  ✅ frontend-1    - React components (cursor)
  ✅ frontend-2    - State & real-time (cursor)
  ✅ qa            - Testing and quality (aider)
  ✅ docs          - Documentation (claude-code)

Generated Files:
  .czarina/config.json
  .czarina/workers/architect.md
  .czarina/workers/backend-1.md
  .czarina/workers/backend-2.md
  .czarina/workers/frontend-1.md
  .czarina/workers/frontend-2.md
  .czarina/workers/qa.md
  .czarina/workers/docs.md
  .czarina/analysis.json

Accept this analysis? (y/n/edit):
```

### Generated: .czarina/config.json

```json
{
  "project": {
    "name": "Awesome App",
    "slug": "awesome-app",
    "repository": "/home/you/awesome-app",
    "current_version": "v0.1.0"
  },

  "version_plan": {
    "v0.1.0": {
      "description": "Architecture & Database Setup",
      "token_budget": {
        "projected": 180000
      },
      "workers": ["architect"]
    },
    "v0.2.0": {
      "description": "Authentication System",
      "token_budget": {
        "projected": 320000
      },
      "workers": ["backend-1", "backend-2"]
    }
    // ... more versions
  },

  "workers": [
    {
      "id": "architect",
      "agent": "claude-code",
      "branch": "feat/v0.1.0-architecture",
      "description": "System Architect",
      "token_budget": {
        "projected": 180000
      }
    },
    {
      "id": "backend-1",
      "agent": "aider",
      "branch": "feat/v0.2.0-backend-core",
      "description": "Backend Core Developer",
      "token_budget": {
        "projected": 160000
      }
    }
    // ... more workers
  ],

  "daemon": {
    "enabled": true,
    "auto_approve": ["read", "write", "commit"]
  }
}
```

### Generated: .czarina/workers/backend-1.md

```markdown
# Backend Core Developer

## Role
Build the core backend services for Awesome App including database models,
authentication, and base API infrastructure.

## Version Assignment
- v0.2.0: Authentication system
- v0.3.0-phase1: Core CRUD APIs

## Responsibilities

### v0.2.0 (Authentication - 160K tokens projected)
- PostgreSQL database schema
- User model and migrations
- Passport.js OAuth integration
- JWT token generation/validation
- Session management
- Password hashing and security

### v0.3.0-phase1 (Core APIs - 200K tokens projected)
- Task CRUD endpoints
- RESTful API structure
- Input validation
- Error handling middleware
- Database queries and optimization

## Files
- src/models/
- src/auth/
- src/api/tasks/
- migrations/
- tests/unit/backend/

## Tech Stack
- Node.js + Express
- PostgreSQL + Sequelize
- Passport.js
- JWT
- bcrypt

## Token Budget
Total: 360K tokens
- v0.2.0: 160K tokens
- v0.3.0-phase1: 200K tokens

## Git Workflow
Branches by version:
- v0.2.0: feat/v0.2.0-backend-core
- v0.3.0-phase1: feat/v0.3.0-phase1-backend-core

When complete:
1. Commit changes
2. Push to branch
3. Create PR to main
4. Update token metrics in status

## Pattern Library
Review before starting:
- czarina-core/patterns/ERROR_RECOVERY_PATTERNS.md
- czarina-core/patterns/CZARINA_PATTERNS.md

## Version Completion Criteria

### v0.2.0 Complete When:
- [ ] User model with all fields
- [ ] OAuth providers configured (Google, GitHub)
- [ ] JWT tokens working
- [ ] Session management functional
- [ ] Tests passing (> 80% coverage)
- [ ] Token budget: ≤ 176K (110% of projected)

### v0.3.0-phase1 Complete When:
- [ ] All CRUD endpoints functional
- [ ] Input validation working
- [ ] Error handling comprehensive
- [ ] Database queries optimized
- [ ] API documentation complete
- [ ] Tests passing (> 80% coverage)
- [ ] Token budget: ≤ 220K (110% of projected)
```

### Generated: .czarina/analysis.json

```json
{
  "analysis": {
    "project_name": "Awesome App",
    "project_type": "full-stack web application",
    "complexity": "medium-high",
    "tech_stack": {
      "backend": ["Node.js", "Express", "PostgreSQL"],
      "frontend": ["React", "TypeScript"],
      "realtime": ["Socket.io"],
      "auth": ["Passport.js", "JWT"]
    },
    "total_tokens_projected": 2300000,
    "recommended_workers": 7,
    "recommended_versions": 8,
    "efficiency_factors": {
      "architecture_complexity": 1.2,
      "real_time_features": 1.3,
      "testing_requirements": 1.2,
      "documentation_needs": 1.1
    }
  },

  "feature_analysis": [
    {
      "feature": "User Authentication",
      "complexity": "medium",
      "tokens_estimated": 320000,
      "dependencies": [],
      "workers": ["backend-1", "backend-2"],
      "version": "v0.2.0"
    },
    {
      "feature": "Task CRUD Operations",
      "complexity": "medium",
      "tokens_estimated": 280000,
      "dependencies": ["User Authentication"],
      "workers": ["backend-1", "backend-2"],
      "version": "v0.3.0-phase1"
    },
    {
      "feature": "Real-time Updates",
      "complexity": "high",
      "tokens_estimated": 280000,
      "dependencies": ["Task CRUD Operations"],
      "workers": ["backend-2", "frontend-2"],
      "version": "v0.3.0-phase2"
    }
    // ... more features
  ],

  "version_plan": [
    {
      "version": "v0.1.0",
      "description": "Architecture & Database Setup",
      "features": ["Database schema", "Project structure"],
      "token_budget": 180000,
      "workers": ["architect"],
      "estimated_duration_description": "Foundation phase"
    }
    // ... more versions
  ],

  "worker_recommendations": [
    {
      "id": "architect",
      "agent": "claude-code",
      "rationale": "Best for high-level architecture and system design",
      "versions": ["v0.1.0"],
      "total_tokens": 180000
    },
    {
      "id": "backend-1",
      "agent": "aider",
      "rationale": "High autonomy for backend development",
      "versions": ["v0.2.0", "v0.3.0-phase1", "v0.3.0-phase2"],
      "total_tokens": 560000
    }
    // ... more workers
  ],

  "generated_files": [
    ".czarina/config.json",
    ".czarina/workers/architect.md",
    ".czarina/workers/backend-1.md",
    ".czarina/workers/backend-2.md",
    ".czarina/workers/frontend-1.md",
    ".czarina/workers/frontend-2.md",
    ".czarina/workers/qa.md",
    ".czarina/workers/docs.md"
  ],

  "analysis_metadata": {
    "analyzed_at": "2025-11-30T16:30:00Z",
    "analyzer_version": "czarina-0.1.0",
    "input_file": "implementation-plan.md",
    "analysis_tokens_used": 15420
  }
}
```

---

## 🔧 Technical Implementation

### Python Code Structure

```python
# In czarina CLI

def cmd_analyze(plan_file, output=None, interactive=False, auto_init=False):
    """
    Analyze implementation plan and generate orchestration setup

    Args:
        plan_file: Path to implementation plan
        output: Path to save analysis JSON
        interactive: Prompt for user approval
        auto_init: Automatically run init after analysis
    """
    # 1. Read plan file
    plan_content = read_plan_file(plan_file)

    # 2. Call AI analyzer (Claude API or local)
    analysis = analyze_with_ai(plan_content)

    # 3. Generate config and worker prompts
    config = generate_config(analysis)
    worker_prompts = generate_worker_prompts(analysis)

    # 4. Interactive approval if requested
    if interactive:
        approved = prompt_user_approval(analysis)
        if not approved:
            return

    # 5. Save generated files
    save_analysis(analysis, output)
    save_config(config)
    save_worker_prompts(worker_prompts)

    # 6. Auto-init if requested
    if auto_init:
        cmd_init(use_analysis=True)

    print_analysis_summary(analysis)

def analyze_with_ai(plan_content):
    """Use AI to analyze plan and generate recommendations"""
    # Use Claude API or local LLM
    # Template-based analysis
    # Return structured analysis JSON
    pass
```

### Analysis Template (AI Prompt)

```markdown
You are analyzing an implementation plan to recommend optimal Czarina orchestration.

INPUT PLAN:
{plan_content}

ANALYZE AND PROVIDE:

1. PROJECT OVERVIEW
   - Type (web app, API, library, tool, etc.)
   - Tech stack identified
   - Overall complexity (simple/medium/complex/very complex)

2. FEATURE BREAKDOWN
   List each major feature with:
   - Feature name
   - Complexity (simple/medium/high)
   - Token estimate (10K-500K based on complexity)
   - Dependencies on other features
   - Suggested workers

3. WORKER ALLOCATION
   For each recommended worker:
   - ID (e.g., "backend-1", "frontend-1")
   - Suggested agent (claude-code, aider, cursor based on task)
   - Role description
   - Versions assigned
   - Token budget
   - Rationale

4. VERSION PLANNING
   Create version breakdown following these rules:
   - Use semantic versioning: v0.1.0, v0.2.0, v1.0.0
   - Use phases for features > 300K tokens: v0.2.1-phase1, v0.2.1-phase2
   - Each version should have:
     * Clear description
     * Features included
     * Workers assigned
     * Token budget (100K-500K per version)
     * Dependencies on previous versions
   - NEVER use time estimates (weeks, days, sprints)
   - ALWAYS use token budgets

5. TOKEN BUDGETS
   Estimate tokens based on:
   - Simple task: 10K-30K
   - Medium task: 30K-100K
   - Complex task: 100K-300K
   - Major feature: 300K-500K
   - Factor in: testing (1.2x), docs (1.1x), integration (1.3x)

6. GENERATE WORKER PROMPTS
   For each worker, create a complete prompt with:
   - Role description
   - Version assignments
   - Responsibilities per version
   - Files to work on
   - Tech stack
   - Token budget per version
   - Git workflow
   - Completion criteria
   - Links to pattern library

OUTPUT FORMAT: JSON matching analysis.json schema
```

---

## 📋 Acceptance Criteria

- [ ] `czarina analyze` command implemented
- [ ] AI analysis working (Claude API integration)
- [ ] Generates complete config.json
- [ ] Generates worker prompts for all workers
- [ ] Produces analysis.json with metrics
- [ ] Interactive mode for user approval
- [ ] Auto-init integration
- [ ] Follows PROJECT_PLANNING_STANDARDS.md
- [ ] Token budgets calculated accurately
- [ ] Version breakdown follows semantic versioning + phases
- [ ] NO time-based estimates anywhere
- [ ] Documentation updated

---

## 🎯 Benefits

1. **Lowers Barrier to Entry**
   - Users don't need to understand optimal team structure
   - Czarina becomes their planning partner

2. **Optimizes Orchestration**
   - AI suggests optimal worker count and types
   - Better than human guessing

3. **Saves Setup Time**
   - Auto-generates all config and prompts
   - Minutes instead of hours to get started

4. **Ensures Best Practices**
   - Follows PROJECT_PLANNING_STANDARDS.md automatically
   - Token-based budgeting from day one

5. **Scales Intelligence**
   - Learn from successful projects
   - Improve recommendations over time

---

## 🚀 Future Enhancements

- **Learning from Results:** Track actual vs projected tokens, improve estimates
- **Multi-Plan Support:** Analyze multiple implementation approaches
- **Cost Estimation:** Show API cost projections
- **Team Optimization:** Suggest best agent for each worker based on task
- **Risk Analysis:** Identify potential bottlenecks or challenges

---

## 📚 Related

- [docs/PROJECT_PLANNING_STANDARDS.md](../../docs/PROJECT_PLANNING_STANDARDS.md)
- [QUICK_START.md](../../QUICK_START.md)
- [czarina-inbox/README.md](../README.md)

---

**Author:** Claude + User Collaboration
**Date:** 2025-11-30
**Status:** Ready for Implementation
