# BMAD-Czarina Integration Implementation Plan

**Version:** 1.0
**Date:** 2026-01-19
**Phase:** Phase 1 - Foundation (Weeks 1-2)
**Status:** Ready for Execution

---

## EXECUTIVE SUMMARY

This implementation plan breaks down **Phase 1: Foundation** of the BMAD-Czarina integration into 10 logical workers. The goal is to create the foundational infrastructure for integrating BMAD methodology into Czarina's orchestration system.

**Phase 1 Objectives:**
- Create 6 BMAD agent templates for Czarina workers
- Design and implement enhanced configuration schema with BMAD fields
- Implement phase tracking system for multi-phase projects
- Deliver foundational components for BMAD-aware orchestration

**Timeline:** 2 weeks
**Workers:** 10 specialized agents
**Dependencies:** Managed through worker sequencing

---

## WORKER BREAKDOWN

### Worker 1: `bmad-research-analyst`
**Role:** Integration
**Agent:** Claude Code
**Branch:** cz1/feat/bmad-research-analyst
**Dependencies:** None

**Mission:** Research and document the 6 highest-value BMAD agent roles (Developer, Architect, Product Manager, Test Architect, UX Designer, Tech Writer) by analyzing BMAD methodology documentation, extracting specialized prompts, role responsibilities, and creating a comprehensive reference document that will inform the template creation process.

**First Action:** Search the BMAD_CZARINA_INTEGRATION_ANALYSIS.md file for all references to the 19 BMAD agent roles and create a detailed breakdown of the 6 priority roles with their characteristics, workflows, and integration requirements.

**Tasks:**
1. Extract BMAD agent role definitions for all 19 agents from the analysis document
2. Prioritize the 6 highest-value agents (Developer, Architect, Product Manager, Test Architect, UX Designer, Tech Writer) based on integration impact
3. Document each agent's responsibilities, specialized knowledge, workflows, and communication patterns
4. Identify BMAD-specific prompts, reasoning patterns, and quality gates for each role
5. Create reference document: `docs/bmad-agent-roles-reference.md` with structured role definitions
6. Document phase alignment for each agent (Planning, Solutioning, Implementation)
7. Identify file ownership patterns and tech stack requirements per role

**Deliverable:** BMAD Agent Roles Reference Document (`docs/bmad-agent-roles-reference.md`) containing comprehensive definitions for 6 priority BMAD agent roles with integration specifications

---

### Worker 2: `template-architect`
**Role:** Code
**Agent:** Claude Code
**Branch:** cz1/feat/template-architect
**Dependencies:** bmad-research-analyst

**Mission:** Design the BMAD worker template structure and format that will be used across all 6 agent templates, establishing consistent sections (Role, BMAD Phase, Responsibilities, Files, Tech Stack, Quality Gates, Communication), creating the template directory structure under `.czarina/workers/templates/bmad/`, and documenting the template specification for other workers to follow.

**First Action:** Read the BMAD agent roles reference document created by Worker 1, then create the directory structure `.czarina/workers/templates/bmad/` and design the standardized template format specification.

**Tasks:**
1. Read and analyze `docs/bmad-agent-roles-reference.md` from Worker 1
2. Design standardized BMAD worker template structure with required sections
3. Create directory structure: `.czarina/workers/templates/bmad/`
4. Define template sections: Role, BMAD Phase, Responsibilities, User Stories format, Files ownership, Tech Stack, Quality Gates, Definition of Done, Communication protocols
5. Create template specification document: `docs/bmad-template-specification.md`
6. Design template variables and placeholders for project-specific customization
7. Establish naming conventions for template files (e.g., `bmad-developer.md`)
8. Create example template using the specification for validation

**Deliverable:** Template specification document and directory structure (`.czarina/workers/templates/bmad/` + `docs/bmad-template-specification.md`) with standardized format for BMAD worker templates

---

### Worker 3: `developer-template-creator`
**Role:** Code
**Agent:** Aider
**Branch:** cz1/feat/developer-template
**Dependencies:** template-architect

**Mission:** Create the BMAD Developer agent template following the template specification, including specialized prompts for backend/frontend development, BMAD Implementation phase guidelines, code quality standards, testing requirements, and developer-specific workflows that will serve as the foundation for development workers in BMAD-integrated projects.

**First Action:** Read the template specification document (`docs/bmad-template-specification.md`) and the BMAD agent reference for the Developer role, then create `.czarina/workers/templates/bmad/bmad-developer.md` following the standardized format.

**Tasks:**
1. Read template specification and Developer role reference documentation
2. Create BMAD Developer template: `.czarina/workers/templates/bmad/bmad-developer.md`
3. Define Developer role with BMAD Implementation phase context
4. Document developer responsibilities: user story implementation, code quality, testing, documentation
5. Specify file ownership patterns for developers (src/, tests/, integration patterns)
6. Include BMAD quality gates: unit test coverage >80%, code review requirements, acceptance criteria validation
7. Add developer-specific communication protocols and status reporting
8. Include examples of backend vs frontend specialization within the template
9. Add BMAD workflow references: story-driven development, testing strategy

**Deliverable:** BMAD Developer template (`.czarina/workers/templates/bmad/bmad-developer.md`) with complete role definition, responsibilities, quality gates, and BMAD methodology integration

---

### Worker 4: `architect-template-creator`
**Role:** Code
**Agent:** Aider
**Branch:** cz1/feat/architect-template
**Dependencies:** template-architect

**Mission:** Create the BMAD Architect agent template with system design expertise, architecture patterns, BMAD Solutioning phase guidelines, design review responsibilities, and architectural quality gates that will guide architecture workers in creating scalable, maintainable system designs aligned with BMAD methodology.

**First Action:** Read the template specification and Architect role reference, then create `.czarina/workers/templates/bmad/bmad-architect.md` with comprehensive system design guidance.

**Tasks:**
1. Read template specification and Architect role reference documentation
2. Create BMAD Architect template: `.czarina/workers/templates/bmad/bmad-architect.md`
3. Define Architect role with BMAD Solutioning phase context
4. Document architect responsibilities: system design, architecture documentation, design reviews, technical leadership
5. Specify file ownership: architecture docs, design documents, system diagrams
6. Include architecture quality gates: design review approval, scalability analysis, security review
7. Add architectural patterns references (microservices, API design, database patterns)
8. Define communication protocols with developers and product managers
9. Include BMAD workflow references: architecture design workflow, technical specification review

**Deliverable:** BMAD Architect template (`.czarina/workers/templates/bmad/bmad-architect.md`) with system design methodology, quality gates, and BMAD Solutioning phase integration

---

### Worker 5: `pm-qa-designer-writer-templates`
**Role:** Code
**Agent:** Cursor
**Branch:** cz1/feat/remaining-bmad-templates
**Dependencies:** template-architect

**Mission:** Create the remaining 4 BMAD agent templates (Product Manager, Test Architect, UX Designer, Tech Writer) following the template specification, ensuring each template includes role-specific responsibilities, BMAD phase alignment, quality gates, and specialized workflows to complete the 6-template foundation set.

**First Action:** Read the template specification and create all 4 templates in parallel: Product Manager (Planning phase), Test Architect (Implementation phase), UX Designer (Solutioning phase), and Tech Writer (Implementation phase).

**Tasks:**
1. Create BMAD Product Manager template: `.czarina/workers/templates/bmad/bmad-product-manager.md`
   - Planning phase focus, PRD generation, requirements gathering, user stories
2. Create BMAD Test Architect template: `.czarina/workers/templates/bmad/bmad-test-architect.md`
   - Implementation phase focus, test strategy, QA standards, coverage requirements
3. Create BMAD UX Designer template: `.czarina/workers/templates/bmad/bmad-ux-designer.md`
   - Solutioning phase focus, UI/UX design, design systems, accessibility
4. Create BMAD Tech Writer template: `.czarina/workers/templates/bmad/bmad-tech-writer.md`
   - Implementation phase focus, documentation standards, API docs, user guides
5. Ensure all templates follow standardized format from template specification
6. Include role-specific quality gates and BMAD methodology integration
7. Cross-reference templates where collaboration is required
8. Validate consistency across all 4 templates

**Deliverable:** Four BMAD agent templates (Product Manager, Test Architect, UX Designer, Tech Writer) in `.czarina/workers/templates/bmad/` directory, completing the 6-template foundation set

---

### Worker 6: `config-schema-designer`
**Role:** Code
**Agent:** Claude Code
**Branch:** cz1/feat/config-schema-design
**Dependencies:** bmad-research-analyst

**Mission:** Design the enhanced configuration schema for `.czarina/config.json` that adds BMAD-specific fields (`bmad_enabled`, `bmad_role`, `bmad_phase`, `bmad_specialization`, `bmad_domain`, `bmad_scale`) while maintaining backward compatibility with existing Czarina configurations, documenting the schema specification and creating migration examples.

**First Action:** Read the current `.czarina/config.json` schema from existing Czarina projects, analyze BMAD requirements from the integration analysis, and design the enhanced schema specification document.

**Tasks:**
1. Analyze current Czarina config.json schema and identify extension points
2. Design BMAD-specific fields for project-level configuration: `bmad_enabled`, `bmad_phases`, `bmad_domain`, `bmad_scale`
3. Design BMAD-specific fields for worker-level configuration: `bmad_role`, `bmad_phase`, `bmad_specialization`, `template` field
4. Design phase configuration section with workflow assignments and artifact tracking
5. Ensure backward compatibility: all BMAD fields are optional
6. Create schema specification document: `docs/config-schema-specification.md`
7. Document field descriptions, allowed values, and validation rules
8. Create example configurations for BMAD-enabled and legacy projects
9. Design migration path from v1.0 config to BMAD-enhanced config

**Deliverable:** Enhanced configuration schema specification (`docs/config-schema-specification.md`) with BMAD field definitions, validation rules, backward compatibility guarantees, and migration examples

---

### Worker 7: `config-schema-implementer`
**Role:** Code
**Agent:** Aider
**Branch:** cz1/feat/config-schema-implementation
**Dependencies:** config-schema-designer

**Mission:** Implement the enhanced configuration schema by updating Czarina's configuration handling code to support BMAD fields, adding validation logic for new fields, maintaining backward compatibility, and creating utility functions for BMAD-aware configuration access that will be used by other integration components.

**First Action:** Read the config schema specification, identify all Czarina scripts that read/write config.json (likely in `czarina-core/`), and update them to support the enhanced schema.

**Tasks:**
1. Read `docs/config-schema-specification.md` and understand all new BMAD fields
2. Locate and analyze all scripts that read/write `.czarina/config.json` in czarina-core
3. Update configuration loading logic to support optional BMAD fields
4. Implement validation for BMAD fields (enum values, required field dependencies)
5. Create utility functions: `is_bmad_enabled()`, `get_worker_bmad_role()`, `get_current_phase()`
6. Add backward compatibility checks: validate both old and new config formats
7. Update config initialization (`czarina init`) to optionally include BMAD fields
8. Create example config files: `examples/config-bmad-enabled.json`, `examples/config-legacy.json`
9. Test configuration loading with both BMAD and legacy configs

**Deliverable:** Enhanced configuration handling implementation with BMAD field support, validation logic, utility functions, and example configuration files demonstrating both BMAD-enabled and legacy modes

---

### Worker 8: `phase-tracking-designer`
**Role:** Code
**Agent:** Claude Code
**Branch:** cz1/feat/phase-tracking-design
**Dependencies:** config-schema-designer

**Mission:** Design the phase tracking system that monitors BMAD project phases (Analysis, Planning, Solutioning, Implementation), tracks phase transitions, verifies artifact completion, and provides phase status reporting through `.czarina/status/current-phase.json` and related status files.

**First Action:** Create the design specification for the phase tracking system including file formats, phase transition logic, artifact verification requirements, and status reporting mechanisms.

**Tasks:**
1. Design phase tracking file structure: `.czarina/status/current-phase.json`
2. Define phase state schema: current phase, completed phases, artifacts generated, phase start/end timestamps
3. Design phase transition rules: artifact requirements, quality gate checks, approval workflows
4. Create artifact tracking specification per phase (Planning: PRD.md, TECH_SPEC.md; Solutioning: ARCHITECTURE.md)
5. Design phase status reporting format for `czarina status` command
6. Document phase transition workflow: validation → artifact check → phase update → worker notification
7. Create phase tracking specification: `docs/phase-tracking-specification.md`
8. Design API/interface for phase tracking: `update_phase()`, `get_current_phase()`, `verify_phase_artifacts()`
9. Include phase history tracking for audit and rollback capabilities

**Deliverable:** Phase tracking system design specification (`docs/phase-tracking-specification.md`) with file formats, transition logic, artifact verification rules, and status reporting mechanisms

---

### Worker 9: `phase-tracking-implementer`
**Role:** Code
**Agent:** Aider
**Branch:** cz1/feat/phase-tracking-implementation
**Dependencies:** phase-tracking-designer

**Mission:** Implement the phase tracking system by creating scripts for phase management, artifact verification, status tracking, and phase transition enforcement that will enable BMAD-aware Czarina projects to track their progress through the 4-phase methodology with automated quality gates.

**First Action:** Read the phase tracking specification, create the `.czarina/status/` directory structure, and implement the core phase tracking functions in a new script `czarina-core/phase-manager.sh`.

**Tasks:**
1. Read `docs/phase-tracking-specification.md` thoroughly
2. Create phase tracking initialization in `czarina init` command
3. Implement phase tracking script: `czarina-core/phase-manager.sh`
4. Create functions: `init_phase_tracking()`, `update_current_phase()`, `get_phase_status()`, `verify_phase_artifacts()`
5. Implement `.czarina/status/current-phase.json` read/write logic
6. Add artifact verification logic for each phase (check file existence, validate content)
7. Implement phase transition validation with quality gate checks
8. Create phase history log: `.czarina/status/phase-history.log`
9. Integrate phase status into `czarina status` command output
10. Add phase transition command: `czarina phase transition --to solutioning`
11. Test phase tracking with sample project through all 4 phases

**Deliverable:** Phase tracking system implementation (`czarina-core/phase-manager.sh`) with phase management functions, artifact verification, status tracking, and integration with Czarina CLI commands

---

### Worker 10: `integration-docs-qa`
**Role:** Docs + QA
**Agent:** Claude Code
**Branch:** cz1/feat/phase1-integration-docs
**Dependencies:** developer-template-creator, architect-template-creator, pm-qa-designer-writer-templates, config-schema-implementer, phase-tracking-implementer

**Mission:** Create comprehensive documentation for Phase 1 deliverables, validate all templates for consistency and completeness, test the enhanced configuration schema and phase tracking system with sample projects, and deliver a Phase 1 integration guide that enables users to start using BMAD templates in their Czarina projects.

**First Action:** Review all Phase 1 deliverables (6 BMAD templates, config schema, phase tracking system), create a testing checklist, and begin documenting the integration guide with getting started instructions.

**Tasks:**
1. Review all 6 BMAD templates for consistency with template specification
2. Validate template format, section completeness, and BMAD methodology alignment
3. Test enhanced config schema with both BMAD-enabled and legacy configurations
4. Validate phase tracking system with sample multi-phase project
5. Create Phase 1 integration guide: `docs/PHASE1_INTEGRATION_GUIDE.md`
6. Document how to use BMAD templates: `czarina worker init --template bmad-developer`
7. Document BMAD configuration fields and how to enable BMAD methodology
8. Create getting started tutorial with example BMAD-enabled project
9. Document phase tracking usage and phase transition workflow
10. Create troubleshooting section for common Phase 1 issues
11. Test complete workflow: init BMAD project → configure workers → track phases
12. Create Phase 1 completion report with deliverable checklist

**Deliverable:** Phase 1 Integration Guide (`docs/PHASE1_INTEGRATION_GUIDE.md`), validation report confirming all deliverables meet specifications, getting started tutorial, and Phase 1 completion documentation

---

## PHASE 1 DELIVERABLES CHECKLIST

### 1. BMAD Agent Templates (6 total)
- [ ] `.czarina/workers/templates/bmad/bmad-developer.md` - Worker 3
- [ ] `.czarina/workers/templates/bmad/bmad-architect.md` - Worker 4
- [ ] `.czarina/workers/templates/bmad/bmad-product-manager.md` - Worker 5
- [ ] `.czarina/workers/templates/bmad/bmad-test-architect.md` - Worker 5
- [ ] `.czarina/workers/templates/bmad/bmad-ux-designer.md` - Worker 5
- [ ] `.czarina/workers/templates/bmad/bmad-tech-writer.md` - Worker 5

### 2. Enhanced Configuration Schema
- [ ] `docs/config-schema-specification.md` - Worker 6
- [ ] Updated configuration handling code - Worker 7
- [ ] BMAD field validation logic - Worker 7
- [ ] Example configurations - Worker 7
- [ ] Backward compatibility verification - Worker 7

### 3. Phase Tracking System
- [ ] `docs/phase-tracking-specification.md` - Worker 8
- [ ] `czarina-core/phase-manager.sh` - Worker 9
- [ ] `.czarina/status/current-phase.json` format - Worker 9
- [ ] Phase transition logic - Worker 9
- [ ] Artifact verification - Worker 9
- [ ] Integration with `czarina status` - Worker 9

### 4. Documentation
- [ ] `docs/bmad-agent-roles-reference.md` - Worker 1
- [ ] `docs/bmad-template-specification.md` - Worker 2
- [ ] `docs/PHASE1_INTEGRATION_GUIDE.md` - Worker 10
- [ ] Getting started tutorial - Worker 10
- [ ] Troubleshooting guide - Worker 10

### 5. Testing & Validation
- [ ] Template consistency validation - Worker 10
- [ ] Configuration schema testing - Worker 10
- [ ] Phase tracking system testing - Worker 10
- [ ] End-to-end integration test - Worker 10

---

## DEPENDENCY GRAPH

```
Worker 1 (bmad-research-analyst)
    ├── Worker 2 (template-architect)
    │       ├── Worker 3 (developer-template-creator)
    │       ├── Worker 4 (architect-template-creator)
    │       └── Worker 5 (pm-qa-designer-writer-templates)
    │
    └── Worker 6 (config-schema-designer)
            ├── Worker 7 (config-schema-implementer)
            └── Worker 8 (phase-tracking-designer)
                    └── Worker 9 (phase-tracking-implementer)

Worker 10 (integration-docs-qa) depends on:
    - Workers 3, 4, 5 (all templates)
    - Worker 7 (config implementation)
    - Worker 9 (phase tracking implementation)
```

---

## EXECUTION TIMELINE

### Week 1: Research & Design + Template Creation
**Days 1-2:** Workers 1, 2, 6 (Foundation)
- Research BMAD agents
- Design template structure
- Design config schema

**Days 3-5:** Workers 3, 4, 5 (Template Implementation)
- Create all 6 BMAD templates in parallel
- Template validation

**Days 6-7:** Worker 8 (Phase Tracking Design)
- Design phase tracking system
- Artifact verification specs

### Week 2: Implementation & Integration
**Days 8-10:** Workers 7, 9 (Core Implementation)
- Implement config schema enhancements
- Implement phase tracking system

**Days 11-14:** Worker 10 (QA & Documentation)
- Integration testing
- Documentation creation
- Getting started guide
- Phase 1 completion report

---

## SUCCESS CRITERIA

Phase 1 is complete when:

1. **Templates Complete:** All 6 BMAD agent templates exist and follow standardized format
2. **Config Enhanced:** Configuration schema supports BMAD fields with backward compatibility
3. **Phase Tracking Works:** Phase tracking system can monitor projects through 4 BMAD phases
4. **Documentation Complete:** Users can follow integration guide to create BMAD-enabled projects
5. **Testing Passed:** All deliverables tested with sample projects
6. **Integration Validated:** End-to-end workflow works: init → configure → track phases

---

## NEXT STEPS (Post Phase 1)

After Phase 1 completion, proceed to:
- **Phase 2:** Workflow Integration (Weeks 3-4) - Connect BMAD workflows to Czarina task system
- **Phase 3:** Daemon Enhancement (Weeks 5-6) - Add BMAD awareness to auto-approval daemon
- **Phase 4:** Pattern Library Integration (Weeks 7-8) - Merge BMAD patterns with Czarina patterns

---

**Plan Status:** Ready for Execution
**Last Updated:** 2026-01-19
**Owner:** Czarina Integration Team
