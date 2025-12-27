# Enhancement: Example Enhancement Template

**Priority:** Medium
**Complexity:** Low
**Tags:** example, template
**Status:** Backlog
**Created:** 2025-12-26

---

## Summary

This is an example enhancement file showing the recommended format for hopper items.

## Background

Provide context about why this enhancement is needed:
- What problem does it solve?
- What use case does it enable?
- How was it discovered? (dogfooding, user request, etc.)

## Proposal

Describe what should be implemented:

### Changes Required

1. **File modifications**
   - `file1.sh` - Add feature X
   - `file2.py` - Update logic Y

2. **New files**
   - `new-file.sh` - Implements Z

3. **Documentation**
   - Update README with new feature
   - Add migration guide if breaking change

### Example Code

```bash
# Show what the implementation might look like
function new_feature() {
    echo "Example implementation"
}
```

## Benefits

- Benefit 1: Improves X
- Benefit 2: Enables Y
- Benefit 3: Reduces Z

## Risks & Considerations

- Risk 1: Might break compatibility
- Risk 2: Requires user migration
- Mitigation: Do X to avoid issues

## Acceptance Criteria

- [ ] Feature X implemented and working
- [ ] Tests added for new functionality
- [ ] Documentation updated
- [ ] Backward compatibility maintained (or migration guide provided)
- [ ] E2E testing passes

## Related

- Links to related enhancements
- GitHub issues
- Previous work

---

**Metadata for Hopper System:**

The hopper uses these fields for prioritization:
- **Priority:** How urgent (High/Medium/Low)
- **Complexity:** Effort required (High/Medium/Low)
- **Tags:** Categorization for filtering
- **Status:** Current state (Backlog/In Progress/Done)
- **Dependencies:** Other enhancements that must complete first

**Next Steps:**
1. Step 1
2. Step 2
3. Step 3
