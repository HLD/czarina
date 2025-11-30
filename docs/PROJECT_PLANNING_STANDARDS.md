# Czarina Project Planning Standards

**Version-Based Planning with Token Metrics**

---

## 🎯 Core Principles

### 1. Plan in Versions, Not Time

**❌ NEVER:**
- "This will take 2 weeks"
- "Sprint 1, Sprint 2"
- "Phase 1: Week 1-2"
- "Q1 2025"

**✅ ALWAYS:**
- `v0.1.0` - Initial foundation
- `v0.1.1` - First iteration complete
- `v0.2.0` - Feature set expanded
- `v0.2.1-phase1` - Large feature, first phase
- `v0.2.1-phase2` - Large feature, second phase
- `v1.0.0` - Production ready

### 2. Measure Progress in Tokens

**Project metrics are token-based:**
- **Projected tokens** - Estimated token usage for completion
- **Recorded tokens** - Actual tokens consumed
- **Efficiency ratio** - Recorded / Projected (target: < 1.2)

**Why tokens?**
- ✅ Objective, measurable metric
- ✅ Directly correlates to agent work
- ✅ Independent of calendar time
- ✅ Accounts for complexity accurately
- ✅ Enables real cost tracking

---

## 📊 Version Numbering Scheme

### Semantic Versioning with Phases

```
MAJOR.MINOR.PATCH[-phase]

Examples:
- v0.1.0          Basic functionality
- v0.1.1          Bug fixes and improvements
- v0.2.0          New feature set
- v0.2.1-phase1   Large feature, part 1
- v0.2.1-phase2   Large feature, part 2
- v0.2.1-phase3   Large feature, part 3
- v0.3.0          Phase integration complete
- v1.0.0          Production ready
```

### When to Use Phases

**Use `-phase1`, `-phase2`, etc. when:**
- Single version would exceed 500K tokens
- Feature requires multiple integration points
- Dependencies require sequential work
- Testing needs staged approach

**Each phase should:**
- Be independently testable
- Have clear completion criteria
- Target 100K-300K tokens
- Produce mergeable PR

---

## 💰 Token Estimation

### Project-Level Token Budgets

```json
{
  "project": {
    "name": "Awesome App",
    "current_version": "v0.2.1-phase2",
    "token_metrics": {
      "total_projected": 2500000,
      "total_recorded": 1850000,
      "efficiency": 0.74,
      "remaining_projected": 650000
    }
  }
}
```

### Version-Level Token Budgets

```json
{
  "version": "v0.2.1-phase2",
  "workers": [
    {
      "id": "backend",
      "token_budget": {
        "projected": 150000,
        "recorded": 142000,
        "remaining": 8000,
        "efficiency": 0.95
      }
    },
    {
      "id": "frontend",
      "token_budget": {
        "projected": 120000,
        "recorded": 135000,
        "remaining": -15000,
        "efficiency": 1.13,
        "overrun_reason": "Additional state management complexity"
      }
    }
  ]
}
```

### Estimation Guidelines

**Per worker token estimates:**
- **Simple task** (bug fix, small feature): 10K-30K tokens
- **Medium task** (new component, API endpoint): 30K-100K tokens
- **Complex task** (architecture change, integration): 100K-300K tokens
- **Major feature** (multi-phase): 300K-500K tokens per phase

**Factor in:**
- Code complexity (1x-3x multiplier)
- Testing requirements (1.2x-1.5x multiplier)
- Documentation needs (1.1x-1.3x multiplier)
- Integration complexity (1.2x-2x multiplier)
- Refactoring needs (1.5x-3x multiplier)

---

## 📋 Version Planning Template

### config.json Structure

```json
{
  "project": {
    "name": "Awesome App",
    "current_version": "v0.2.1-phase2",
    "repository": "/path/to/repo"
  },

  "version_plan": {
    "v0.2.1-phase1": {
      "status": "completed",
      "description": "Backend API foundation",
      "token_budget": {
        "projected": 250000,
        "recorded": 235000,
        "efficiency": 0.94
      },
      "completed_date": "2025-11-28"
    },

    "v0.2.1-phase2": {
      "status": "in_progress",
      "description": "Frontend integration",
      "token_budget": {
        "projected": 280000,
        "recorded": 142000,
        "remaining": 138000
      },
      "workers": [
        {
          "id": "frontend-1",
          "agent": "cursor",
          "branch": "feat/v0.2.1-phase2-frontend-1",
          "token_budget": {
            "projected": 120000,
            "recorded": 65000,
            "tasks": [
              {"task": "Component library", "tokens": 40000},
              {"task": "State management", "tokens": 35000},
              {"task": "API integration", "tokens": 45000}
            ]
          }
        },
        {
          "id": "frontend-2",
          "agent": "aider",
          "branch": "feat/v0.2.1-phase2-frontend-2",
          "token_budget": {
            "projected": 100000,
            "recorded": 52000,
            "tasks": [
              {"task": "UI components", "tokens": 50000},
              {"task": "Routing", "tokens": 30000},
              {"task": "Authentication UI", "tokens": 20000}
            ]
          }
        }
      ]
    },

    "v0.2.1-phase3": {
      "status": "planned",
      "description": "Testing and polish",
      "token_budget": {
        "projected": 150000
      }
    },

    "v0.3.0": {
      "status": "planned",
      "description": "Integration and deployment",
      "token_budget": {
        "projected": 200000
      }
    }
  }
}
```

---

## 🎯 Version Completion Criteria

### Each version must have:

1. **Clear deliverables**
   - Specific features/functionality
   - Acceptance criteria
   - Test coverage requirements

2. **Token metrics**
   - Projected budget
   - Recorded usage
   - Efficiency ratio
   - Variance explanation (if > 20%)

3. **Git artifacts**
   - Feature branch per worker
   - Pull request with review
   - Merged to main
   - Tagged with version number

4. **Documentation**
   - Updated README/docs
   - API documentation (if applicable)
   - Migration guide (if breaking changes)

---

## 📈 Token Tracking

### During Development

**Workers report token usage:**
```bash
# In worker prompt or status updates
Token usage: 45,231 / 120,000 (37% of budget)
```

**Czar monitors token budgets:**
```bash
czarina status

# Output:
Project: Awesome App v0.2.1-phase2
Token Budget: 142,000 / 280,000 (51%)

Workers:
  frontend-1: 65,000 / 120,000 (54%) ✅
  frontend-2: 52,000 / 100,000 (52%) ✅
  qa:         25,000 /  60,000 (42%) ✅

Status: ON BUDGET
```

### After Completion

**Version retrospective:**
```json
{
  "version": "v0.2.1-phase2",
  "status": "completed",
  "token_metrics": {
    "projected": 280000,
    "recorded": 265000,
    "efficiency": 0.95,
    "variance": -15000,
    "variance_percent": -5.4
  },
  "learnings": [
    "Frontend state management was simpler than expected (-15K tokens)",
    "API integration testing needed more tokens than planned (+8K tokens)",
    "Overall efficiency excellent due to pattern library reuse"
  ]
}
```

---

## 🔄 Version Flow

### Standard Version Progression

```
v0.1.0 (Foundation)
  ↓
v0.1.1 (Refinements)
  ↓
v0.2.0 (Feature Set 1)
  ↓
v0.2.1-phase1 (Large Feature - Part 1)
  ↓
v0.2.1-phase2 (Large Feature - Part 2)
  ↓
v0.2.1-phase3 (Large Feature - Part 3)
  ↓
v0.3.0 (Integration)
  ↓
v1.0.0 (Production Ready)
```

### Git Workflow

```bash
# Version tag after merge
git tag -a v0.2.1-phase2 -m "Frontend integration complete"
git push --tags

# Branch naming
feat/v0.2.1-phase2-worker-id

# PR naming
[v0.2.1-phase2] Frontend Component Library (frontend-1)
```

---

## 🎯 Czarina Analysis Integration

### When Running `czarina analyze`

**Input:** Implementation plan or project spec

**Output:** Version breakdown with token estimates

```json
{
  "analysis": {
    "project_complexity": "medium-high",
    "total_tokens_projected": 2500000,
    "recommended_versions": 8,
    "recommended_workers": 7
  },

  "version_plan": [
    {
      "version": "v0.1.0",
      "description": "Project foundation and architecture",
      "token_budget": 200000,
      "workers": [
        {"id": "architect", "tokens": 200000}
      ]
    },
    {
      "version": "v0.2.0",
      "description": "Core backend services",
      "token_budget": 450000,
      "workers": [
        {"id": "backend-1", "tokens": 250000},
        {"id": "backend-2", "tokens": 200000}
      ]
    },
    {
      "version": "v0.2.1-phase1",
      "description": "Frontend - Component library",
      "token_budget": 300000,
      "workers": [
        {"id": "frontend-1", "tokens": 180000},
        {"id": "frontend-2", "tokens": 120000}
      ]
    }
    // ... more versions
  ]
}
```

---

## 📊 Example: Real Project Planning

### SARK v2.0 (Actual Project)

**Version breakdown:**
```
v0.1.0: Architecture and patterns (250K tokens)
v0.2.0-phase1: HTTP adapter foundation (350K tokens)
v0.2.0-phase2: Protocol adapters (400K tokens)
v0.2.0-phase3: Message handling (300K tokens)
v0.3.0-phase1: Integration layer (350K tokens)
v0.3.0-phase2: Event system (300K tokens)
v0.4.0: Testing and QA (400K tokens)
v0.5.0: Documentation (150K tokens)
v1.0.0: Production hardening (200K tokens)

Total: ~2.7M tokens projected
```

**Worker allocation by version:**
- v0.1.0: 1 architect
- v0.2.0-phase1: 2 backend engineers
- v0.2.0-phase2: 3 backend engineers (parallel adapters)
- v0.2.0-phase3: 2 backend engineers
- v0.3.0-phase1: 2 integration engineers
- v0.3.0-phase2: 2 event engineers
- v0.4.0: 2 QA engineers
- v0.5.0: 2 docs writers
- v1.0.0: 1 architect + 2 engineers

---

## 🚫 Anti-Patterns

### Don't Do This:

**❌ Time-based planning:**
```json
{
  "sprint_1": {
    "duration": "2 weeks",
    "tasks": [...]
  }
}
```

**❌ Vague versioning:**
```json
{
  "version": "alpha",
  "version": "beta",
  "version": "release-candidate"
}
```

**❌ No token tracking:**
```json
{
  "version": "v0.2.0",
  "status": "in_progress"
  // Missing: token_budget, metrics
}
```

### Do This Instead:

**✅ Version-based with tokens:**
```json
{
  "version": "v0.2.1-phase1",
  "token_budget": {
    "projected": 300000,
    "recorded": 285000,
    "efficiency": 0.95
  },
  "status": "in_progress"
}
```

---

## 🎯 Benefits of This Approach

1. **Predictable:** Token estimates are reliable
2. **Measurable:** Exact progress tracking
3. **Scalable:** Works for any project size
4. **Cost-aware:** Direct correlation to API costs
5. **Calendar-independent:** No deadline pressure
6. **Quality-focused:** Done when done, not when time runs out
7. **Efficient:** Learn from token efficiency ratios

---

## 📚 Related Documentation

- **[QUICK_START.md](../QUICK_START.md)** - Getting started with Czarina
- **[czarina-core/patterns/](../czarina-core/patterns/)** - Development patterns
- **[PRODUCTION_READINESS.md](../PRODUCTION_READINESS.md)** - Production checklist

---

**Version:** 1.0
**Status:** Standard - All projects must follow
**Enforcement:** `czarina analyze` and project configuration

---

> **Remember:** Versions, not sprints. Tokens, not days. Quality, not deadlines. 🎯
