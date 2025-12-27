# Enhancement: Kilocode CLI Agent Support

**Priority:** Medium
**Complexity:** Low
**Tags:** agent-support, cli-integration, tooling
**Status:** Backlog
**Created:** 2025-12-26

---

## Summary

Add support for Kilocode CLI as an alternative agent option alongside Claude Code in czarina orchestration.

## Background

Currently, czarina supports Claude Code as the primary CLI agent for workers. Users may want to use alternative agents like Kilocode for various reasons:
- Different pricing models
- Specialized capabilities
- Experimentation with different AI coding assistants
- Cost optimization

## Proposal

Extend the agent system to support multiple CLI agent types, starting with Kilocode.

### Configuration Changes

Update worker config to support agent specification:

```json
{
  "workers": [
    {
      "id": "worker1",
      "agent": "claude",  // or "kilocode"
      "branch": "feat/worker1"
    }
  ]
}
```

### Implementation Steps

1. **Update agent launcher** (`czarina-core/agent-launcher.sh`)
   - Add conditional logic to detect agent type
   - Launch `kilocode` instead of `claude` when specified
   - Pass appropriate flags for bypass permissions (if available)

2. **Update config validation**
   - Add "kilocode" to allowed agent values
   - Validate agent is installed before launch

3. **Documentation**
   - Document kilocode usage in README
   - Add example configs with kilocode agents
   - Note any differences in behavior

### Example Agent Launcher Logic

```bash
# Get agent type from config
agent_type=$(jq -r ".workers[$i].agent" "$CONFIG_FILE")

# Launch appropriate agent
case "$agent_type" in
    "claude")
        claude --permission-mode bypassPermissions "$prompt"
        ;;
    "kilocode")
        kilocode --auto-approve "$prompt"  # adjust flags as needed
        ;;
    *)
        echo "❌ Unknown agent type: $agent_type"
        exit 1
        ;;
esac
```

## Benefits

- **Flexibility**: Users can choose their preferred agent
- **Cost optimization**: Mix expensive/cheap agents based on task complexity
- **Experimentation**: Try different agents for different worker types
- **Vendor independence**: Not locked into single provider

## Risks & Considerations

- **Maintenance burden**: Need to keep up with multiple CLIs
- **Feature parity**: Different agents may have different capabilities
- **Testing complexity**: Need to test with multiple agents

## Acceptance Criteria

- [ ] Config accepts "kilocode" as valid agent value
- [ ] Agent launcher correctly invokes kilocode CLI
- [ ] Bypass/auto-approve permissions work with kilocode
- [ ] Documentation updated with kilocode examples
- [ ] Works with both local and github orchestration modes

## Related

- Agent auto-launch (E#10 from v0.5.1)
- Multi-agent orchestration architecture

---

**Next Steps:**
1. Research kilocode CLI flags and capabilities
2. Update agent-launcher.sh with conditional logic
3. Test with sample kilocode installation
4. Document usage patterns
