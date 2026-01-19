# Project Plan Examples

This directory contains example project plans that can be used with `czarina plan` to generate implementation plans.

## Available Examples

### 1. REST API Project (Medium Complexity)
**File:** `01-rest-api-project.md`

A task management REST API built with Node.js, Express, and PostgreSQL. Includes authentication, CRUD operations, and comprehensive testing.

**Best for:** Backend developers, API-first projects

**Recommended style:** Balanced or Agile

**Usage:**
```bash
czarina plan docs/examples/project-plans/01-rest-api-project.md
# Or with style:
czarina plan docs/examples/project-plans/01-rest-api-project.md --style agile
```

---

### 2. CLI Tool Project (Low-Medium Complexity)
**File:** `02-cli-tool-project.md`

A DevOps automation CLI built with Python, featuring container management, log analysis, and beautiful terminal UI with Rich library.

**Best for:** DevOps tools, Python developers, single-purpose utilities

**Recommended style:** Lean

**Usage:**
```bash
czarina plan docs/examples/project-plans/02-cli-tool-project.md --style lean
```

---

### 3. Full-Stack E-Commerce (High Complexity)
**File:** `03-fullstack-app-project.md`

A complete e-commerce platform with React frontend, Node.js backend, Stripe payments, and admin dashboard.

**Best for:** Full-stack projects, complex applications with multiple components

**Recommended style:** Waterfall or Balanced

**Usage:**
```bash
czarina plan docs/examples/project-plans/03-fullstack-app-project.md --style waterfall
```

---

## How to Use These Examples

### 1. Generate Implementation Plan
```bash
# Basic usage (balanced style)
czarina plan docs/examples/project-plans/01-rest-api-project.md

# With specific style
czarina plan docs/examples/project-plans/01-rest-api-project.md --style agile

# Custom output file
czarina plan docs/examples/project-plans/01-rest-api-project.md --output MY_PLAN.md
```

### 2. Validate Generated Plan
```bash
czarina plan validate IMPLEMENTATION_PLAN.md
```

### 3. Initialize Czarina Project
```bash
czarina init IMPLEMENTATION_PLAN.md
```

### 4. Launch Workers
```bash
czarina launch
```

## Planning Styles

### Agile
- **Workers:** 5-8 small, iterative workers
- **Focus:** MVPs, incremental delivery, flexibility
- **Dependencies:** Loose, maximizes parallel work
- **Best for:** Projects with evolving requirements

### Waterfall
- **Workers:** 8-12 sequential, phase-based workers
- **Focus:** Complete each phase before next begins
- **Dependencies:** Strong, clear handoffs
- **Best for:** Projects with stable, well-defined requirements

### Lean
- **Workers:** 4-6 highly focused workers
- **Focus:** Minimize waste, maximum value with minimum effort
- **Dependencies:** Minimal, fast delivery
- **Best for:** Small projects, prototypes, focused features

### Balanced (Default)
- **Workers:** 6-10 mixed parallel and sequential
- **Focus:** Pragmatic approach, balance speed and planning
- **Dependencies:** Based on actual constraints
- **Best for:** Most projects, general purpose

## Creating Your Own Project Plans

Use these examples as templates. A good project plan should include:

### Required Sections
- **Project Overview** - What are you building?
- **Core Features** - List of features to implement
- **Technical Requirements** - Stack, architecture, tools
- **Quality Requirements** - Testing, documentation, security
- **Deliverables** - What will be produced?
- **Success Criteria** - How do you know it's done?
- **Milestones** - High-level timeline

### Optional Sections
- API Endpoints (for APIs)
- Database Schema (for data-driven apps)
- UI/UX Requirements (for user-facing apps)
- Infrastructure Requirements (for deployments)
- Integration Requirements (for systems with external deps)

### Tips for Good Project Plans
1. **Be specific** - "User authentication" not just "auth"
2. **Include technical details** - What frameworks, libraries, versions?
3. **Define scope clearly** - What's included vs. excluded?
4. **Specify quality** - Test coverage, performance, security requirements
5. **Break down features** - Detailed enough for AI to understand
6. **Include examples** - API endpoints, commands, schemas help clarity

## Workflow Example

```bash
# 1. Create your project plan (or use an example)
vim my-project-plan.md

# 2. Generate implementation plan
czarina plan my-project-plan.md --style agile

# 3. Validate the generated plan
czarina plan validate IMPLEMENTATION_PLAN.md

# 4. Review and edit if needed
vim IMPLEMENTATION_PLAN.md

# 5. Re-validate after edits
czarina plan validate IMPLEMENTATION_PLAN.md

# 6. Initialize Czarina project
czarina init IMPLEMENTATION_PLAN.md

# 7. Review generated workers
ls -la .czarina/workers/

# 8. Launch the workers
czarina launch

# 9. Monitor progress
czarina status
czarina dashboard
```

## Validation Checklist

A valid implementation plan should have:
- [ ] Project title and overview
- [ ] At least 2 workers (preferably 4-12)
- [ ] Worker IDs are lowercase-with-dashes
- [ ] Each worker has all required fields
- [ ] Dependencies reference actual worker IDs
- [ ] Specific missions (not vague)
- [ ] Concrete First Actions
- [ ] Deliverables defined
- [ ] Success criteria included

## Common Issues

### Too Few Workers
**Problem:** Plan only has 1-2 workers
**Solution:** Break down features into smaller, focused workers

### Too Many Workers
**Problem:** Plan has 15+ workers
**Solution:** Combine related tasks into cohesive workers

### Vague Tasks
**Problem:** Tasks like "implement feature" or "build backend"
**Solution:** Be specific about WHAT and HOW

### Bad Dependencies
**Problem:** Worker depends on non-existent worker
**Solution:** Ensure dependency worker IDs match actual workers

### Generic First Actions
**Problem:** "Read the docs" or "Start working"
**Solution:** Specific action like "Read src/api/routes.ts and create auth/ subdirectory"

## Getting Help

- Read the main Czarina docs: `docs/`
- Check example plans in this directory
- Run `czarina plan --help`
- Run `czarina plan validate --help`

---

**Ready to build!** 🚀
