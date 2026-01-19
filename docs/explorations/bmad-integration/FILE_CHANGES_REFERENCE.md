# Czarina ↔ BMAD Integration: Key Files & Changes

## Overview
This document maps the 5 integration opportunities to specific file paths and required changes.

---

## Integration #1: BMAD Agent Templates → Worker Definitions

### Files to Create

```
.czarina/workers/templates/bmad/
├── developer.md              # Developer with backend/frontend specialization
├── architect.md              # System architect
├── ux-designer.md           # UX/UI designer
├── test-architect.md        # QA architect
├── tech-writer.md           # Technical writer
├── product-manager.md       # Product manager
├── scrum-master.md          # Scrum master (optional)
└── README.md                # Template guide

agents/profiles/
├── bmad-developer.json      # BMAD developer profile
├── bmad-architect.json      # BMAD architect profile
└── bmad-designer.json       # BMAD designer profile
```

### Files to Modify

**File:** `.czarina/config.json` (Schema Enhancement)
```json
{
  "workers": [
    {
      "id": "backend",
      "agent": "aider",
      "branch": "feat/backend",
      
      // NEW FIELDS:
      "template": "bmad-developer",        // NEW
      "bmad_role": "developer",            // NEW
      "bmad_specialization": "backend",    // NEW
      "bmad_phase": "implementation"       // NEW
    }
  ]
}
```

**File:** `agents/profile-loader.py`
- Add support for loading BMAD profiles
- Validate BMAD profile schema
- Generate BMAD-specific instructions

---

## Integration #2: BMAD Workflows → Czarina Task Pipeline

### Files to Create

```
czarina-core/workflows/
├── workflow-runner.sh              # Main workflow executor
├── workflow-config.json            # Workflow definitions
│
├── analysis/
│   ├── brainstorm.sh
│   ├── research.sh
│   └── feasibility.sh
│
├── planning/
│   ├── prd-generation.sh
│   ├── tech-spec-generation.sh
│   ├── estimation.sh
│   └── timeline-planning.sh
│
├── solutioning/
│   ├── architecture-design.sh
│   ├── ux-design.sh
│   ├── test-strategy.sh
│   └── component-design.sh
│
└── implementation/
    ├── story-generation.sh
    ├── development.sh
    ├── testing.sh
    ├── documentation.sh
    └── deployment.sh

.czarina/status/
├── current-phase.json              # Phase tracking
├── workflow-progress.json          # Workflow execution status
└── artifacts/                      # Generated artifacts
    ├── PRD.md
    ├── TECH_SPEC.md
    ├── ARCHITECTURE.md
    └── TEST_STRATEGY.md
```

### Files to Modify

**File:** `czarina` (Main CLI)
```bash
# Add workflow commands
czarina workflow run <phase>
czarina workflow run <workflow-name>
czarina workflow status
czarina workflow list
```

**File:** `czarina-core/README.md`
- Add workflow system documentation
- Link to workflow examples
- Workflow best practices

---

## Integration #3: BMAD-Aware Daemon & Quality Gates

### Files to Create

```
czarina-core/daemon/
├── bmad-aware-daemon.sh            # BMAD-enhanced daemon
├── phase-validator.sh              # Phase transition validation
├── quality-gates.sh                # Quality gate checker
└── bmad-daemon-README.md           # Documentation

.czarina/status/
├── phase-requirements.json         # Phase completion requirements
├── quality-gates-status.json       # Quality gate status
└── daemon-decisions.log            # Decision audit trail
```

### Files to Modify

**File:** `.czarina/config.json` (Daemon Enhancement)
```json
{
  "daemon": {
    "enabled": true,
    "bmad_aware": true,              // NEW
    "check_interval": 120,
    
    "auto_approve_by_phase": {       // NEW
      "analysis": ["brainstorm", "research"],
      "planning": ["prd_writing", "spec_generation"],
      "solutioning": ["design_creation", "architecture"],
      "implementation": ["code_commits", "test_execution"]
    },
    
    "quality_gates": {               // NEW
      "planning": ["prd_complete", "tech_spec_complete"],
      "solutioning": ["architecture_approved", "design_complete"],
      "implementation": ["tests_passing", "coverage_80_plus"]
    }
  }
}
```

**File:** `czarina-core/daemon/czar-daemon.sh`
- Enhance with phase awareness
- Add quality gate checks
- Implement smart approval rules
- Improve logging

**File:** `czarina-core/daemon/README.md`
- Document BMAD-aware features
- Phase-specific approval rules
- Quality gate examples

---

## Integration #4: Enhanced Pattern Library

### Files to Create

```
czarina-core/patterns/bmad-patterns/
├── ARCHITECTURE_PATTERNS.md         # Microservices, APIs, databases
├── DEVELOPMENT_PATTERNS.md          # Clean code, testing, performance
├── UX_PATTERNS.md                   # Design systems, accessibility
├── TESTING_PATTERNS.md              # Unit, integration, UAT
├── SECURITY_PATTERNS.md             # Auth, encryption, validation
│
└── domain-patterns/
    ├── legal-patterns.md
    ├── medical-patterns.md
    ├── finance-patterns.md
    ├── education-patterns.md
    └── startup-patterns.md

czarina-core/patterns/
├── pattern-search.py                # Search implementation
├── pattern-suggestions.py           # Smart suggestions
└── pattern-index.json               # Pattern catalog & metadata
```

### Files to Modify

**File:** `czarina-core/patterns/README.md`
- Add BMAD pattern section
- Link to new pattern libraries
- Pattern usage examples

**File:** `czarina` (Main CLI)
```bash
# Add pattern search commands
czarina patterns search --domain architecture
czarina patterns list --phase implementation
czarina patterns suggest --error "merge-conflict"
```

**File:** `.cursorrules`
- Add pattern library references
- Include BMAD pattern guidance
- Link to domain-specific patterns

---

## Integration #5: Multi-Phase Project Configuration

### Files to Modify

**File:** `.czarina/config.json` (Major Enhancement)
```json
{
  "project": {
    "name": "Awesome App",
    "slug": "awesome-app",
    "bmad_enabled": true,                    // NEW
    "bmad_phases": ["planning", "solutioning", "implementation"],  // NEW
    "bmad_domain": "saas",                   // NEW
    "bmad_scale": "standard"                 // NEW (quick|standard|enterprise)
  },
  
  "phases": {                                // NEW
    "planning": {
      "workflows": ["prd-generation", "tech-spec"],
      "workers": ["product-manager"],
      "artifacts": ["PRD.md", "TECH_SPEC.md"],
      "duration_minutes": 30
    },
    "solutioning": {
      "workflows": ["architecture-design", "ux-design"],
      "workers": ["architect"],
      "artifacts": ["ARCHITECTURE.md", "DESIGN_DOCS/"],
      "duration_minutes": 45
    },
    "implementation": {
      "workflows": ["development", "testing"],
      "workers": ["backend", "frontend", "qa"],
      "artifacts": ["Code", "Tests", "Docs"],
      "duration_minutes": 1440  // 1 day
    }
  },
  
  "workers": [
    {
      "id": "product-manager",
      "agent": "claude-code",
      "bmad_role": "product-manager",         // NEW
      "bmad_phase": "planning",               // NEW
      "branch": "feat/planning",
      "template": "bmad-product-manager"      // NEW
    }
    // ... more workers
  ]
}
```

**File:** `czarina init` (Enhancement)
```bash
# New workflow
czarina init --bmad-method

Prompts user for:
- BMAD domain (saas, mobile, game, custom)
- Scale (quick, standard, enterprise)
- Initial phase (analysis, planning, solutioning, implementation)
- Worker template preference
```

**File:** `.czarina/README.md`
- Add BMAD workflow documentation
- Phase-based setup guide
- Multi-phase examples

---

## Additional Files to Create

### Documentation Files

```
docs/guides/
├── BMAD_INTEGRATION_GUIDE.md         # How to use BMAD with Czarina
├── BMAD_WORKFLOW_EXAMPLES.md         # Concrete workflow examples
├── PHASE_BASED_SETUP.md              # Setup for each phase
└── BMAD_AGENTS_REFERENCE.md          # Agent roles & specializations

examples/
├── bmad-saas-example/                # Complete SaaS example
│   ├── .czarina/config.json
│   ├── .czarina/workers/
│   └── SETUP.md
├── bmad-mobile-example/              # Mobile app example
├── bmad-game-example/                # Game example
└── README.md
```

### Testing Files

```
tests/integration/
├── test_bmad_templates.sh
├── test_workflow_runner.sh
├── test_phase_transitions.sh
├── test_quality_gates.sh
├── test_bmad_daemon.sh
└── test_pattern_library.sh

tests/fixtures/
├── sample-config-bmad.json
├── sample-workflow-output.json
└── sample-artifacts/
```

---

## Schema Extensions

### agents/profiles/schema.json (New Section)

```json
{
  "properties": {
    "bmad_metadata": {
      "type": "object",
      "properties": {
        "bmad_role": {"type": "string"},
        "specializations": {"type": "array"},
        "domain_expertise": {"type": "array"},
        "phase_preference": {"type": "string"},
        "related_workflows": {"type": "array"}
      }
    }
  }
}
```

### .czarina/config.json Schema (New)

```json
{
  "phases": {
    "type": "object",
    "properties": {
      "[phase-name]": {
        "type": "object",
        "properties": {
          "workflows": {"type": "array"},
          "workers": {"type": "array"},
          "artifacts": {"type": "array"},
          "duration_minutes": {"type": "integer"},
          "quality_gates": {"type": "array"}
        }
      }
    }
  }
}
```

---

## Summary: Key File Changes by Phase

### Phase 1 (Weeks 1-2): Foundation
- Create: `workers/templates/bmad/` (6 files)
- Create: `agents/profiles/bmad-*.json` (3 files)
- Modify: `.czarina/config.json` schema
- Modify: `agents/profile-loader.py`

### Phase 2 (Weeks 3-4): Workflows
- Create: `czarina-core/workflows/` (8 directories + 25+ scripts)
- Create: `.czarina/status/artifacts/`
- Modify: Main `czarina` CLI
- Modify: `czarina-core/README.md`

### Phase 3 (Weeks 5-6): Daemon
- Create: `czarina-core/daemon/bmad-aware-daemon.sh`
- Create: `czarina-core/daemon/phase-validator.sh`
- Create: `czarina-core/daemon/quality-gates.sh`
- Modify: `czarina-core/daemon/czar-daemon.sh`
- Modify: `.czarina/config.json` schema

### Phase 4 (Weeks 7-8): Patterns
- Create: `czarina-core/patterns/bmad-patterns/` (50+ files)
- Create: `czarina-core/patterns/pattern-search.py`
- Modify: `czarina-core/patterns/README.md`
- Modify: `.cursorrules`

### Phase 5 (Weeks 9-10): Testing & Docs
- Create: `docs/guides/BMAD_INTEGRATION_GUIDE.md`
- Create: `examples/bmad-saas-example/`
- Create: `tests/integration/` (6 test files)
- Modify: All documentation

### Phase 6 (Weeks 11-12): Release
- Update: Version in `czarina` CLI
- Create: `CHANGELOG.md` entry
- Create: Migration guide
- Update: All README files

---

## File Count Summary

**Files to Create:** ~120 files
- Worker templates: 6
- Workflow scripts: 25+
- Pattern files: 50+
- Documentation: 15+
- Examples: 10+
- Tests: 10+
- Config files: 4

**Files to Modify:** ~15 files
- Main CLI: 1
- Config schema: 1
- Daemon: 3
- Profile loader: 1
- Documentation: 9

**Total Changes:** ~135 files

---

## Git Workflow for Integration

```bash
# Create feature branch for integration
git checkout -b feat/bmad-integration

# Phase 1: Templates (commit weekly)
git add .czarina/workers/templates/bmad/
git add agents/profiles/bmad-*.json
git commit -m "feat: Add BMAD agent templates"

# Phase 2: Workflows
git add czarina-core/workflows/
git commit -m "feat: Add BMAD workflow runner"

# Phase 3: Daemon
git add czarina-core/daemon/bmad-aware-*
git commit -m "feat: Add BMAD-aware daemon"

# Phase 4: Patterns
git add czarina-core/patterns/bmad-patterns/
git commit -m "feat: Add BMAD domain patterns"

# Phase 5: Testing & Docs
git add docs/ examples/ tests/
git commit -m "docs: Add BMAD integration guides"

# Phase 6: Release
git add CHANGELOG.md VERSION
git commit -m "release: v1.1.0 with BMAD integration"
git tag v1.1.0
git push origin feat/bmad-integration
git push origin v1.1.0
```

---

**Last Updated:** December 2, 2025
**Status:** File mapping complete, ready for implementation
