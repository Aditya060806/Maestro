#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
# =============================================================================
# Generate OpenCode Commands -- Utility
# =============================================================================
# Setup, session, memory, and general utility command definitions for OpenCode.
#
# Usage: source "${SCRIPT_DIR}/generate-opencode-commands-utility.sh"
#
# Dependencies:
#   - shared-constants.sh (print_error, print_info, color vars)
#   - create_command() from the orchestrator
#   - AGENT_BUILD constant from the orchestrator
#
# Part of maestro framework: https://maestro.sh

# Apply strict mode only when executed directly (not when sourced)
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && set -euo pipefail

# Include guard
[[ -n "${_OPENCODE_CMDS_UTILITY_LOADED:-}" ]] && return 0
_OPENCODE_CMDS_UTILITY_LOADED=1

# --- Utility Commands ---
# Split into setup, session, and memory sub-groups.

define_setup_commands() {
	create_command "onboarding" \
		"Interactive onboarding wizard - discover services, configure integrations" \
		"" "" <<'BODY'
Read ${MAESTRO_DIR:-$HOME/.maestro}/agents/maestro/onboarding.md and follow its Welcome Flow instructions to guide the user through setup. Do NOT repeat these instructions -- go straight to the Welcome Flow conversation.

Arguments: $ARGUMENTS
BODY

	create_command "setup-maestro" \
		"Deploy latest maestro agent changes locally" \
		"$AGENT_BUILD" "" <<'BODY'
Run the maestro setup script to deploy the latest changes.

**Command:**
```bash
MAESTRO_REPO="${MAESTRO_REPO:-$(jq -r '.initialized_repos[]?.path | select(test("/maestro$"))' ~/.config/maestro/repos.json 2>/dev/null | head -n 1)}"
if [[ -z "$MAESTRO_REPO" ]]; then
	MAESTRO_REPO="$HOME/Git/maestro"
fi
[[ -f "$MAESTRO_REPO/setup.sh" ]] || {
	echo "Unable to find setup.sh. Set MAESTRO_REPO to your maestro clone path." >&2
	exit 1
}
cd "$MAESTRO_REPO" && ./setup.sh || exit
```

**What this does:**
1. Deploys agents to ${MAESTRO_DIR:-$HOME/.maestro}/agents/
2. Updates OpenCode commands in ~/.config/opencode/command/
3. Regenerates agent configurations
4. Copies VERSION file for version checks

**After setup completes:**
- Restart OpenCode to load new commands and config
- New/updated commands will be available

Arguments: $ARGUMENTS
BODY

	create_command "list-keys" \
		"List all API keys available in session with their storage locations" \
		"$AGENT_BUILD" "" <<'BODY'
Run the list-keys helper script and format the output as a markdown table:

!`${MAESTRO_DIR:-$HOME/.maestro}/agents/scripts/list-keys-helper.sh --json $ARGUMENTS`

Parse the JSON output and present as markdown tables grouped by source.

Format with padded columns for readability:

```
### ~/.config/maestro/credentials.sh

| Key                        | Status        |
|----------------------------|---------------|
| OPENAI_API_KEY             | ✓ loaded      |
| ANTHROPIC_API_KEY          | ✓ loaded      |
| TEST_KEY                   | ⚠ placeholder |
```

Status icons:
- ✓ loaded
- ⚠ placeholder (needs real value)
- ✗ not loaded
- ℹ configured

Pad key names to align columns. End with total count.

Security: Key values are NEVER displayed.
BODY

	return 0
}

define_session_commands() {
	create_command "log-time-spent" \
		"Log time spent on a task in TODO.md" \
		"$AGENT_BUILD" "" <<'BODY'
Log time spent on a task.

Arguments: $ARGUMENTS

**Format:** `/log-time-spent [task-id] [duration]`

**Examples:**
- `/log-time-spent "Add user dashboard" 2h30m`
- `/log-time-spent t001 45m`
- `/log-time-spent` (prompts for task and duration)

**Workflow:**
1. If no arguments, show in-progress tasks from TODO.md and ask which one
2. Parse duration (supports: 2h, 30m, 2h30m, 1.5h)
3. Update the task's `logged:` field with current timestamp
4. If task has `started:` but no `actual:`, calculate running total
5. Show updated task with time summary

**Duration formats:**
- `2h` - 2 hours
- `30m` - 30 minutes
- `2h30m` - 2 hours 30 minutes
- `1.5h` - 1.5 hours (converted to 1h30m)

**Task update:**
```markdown
# Before
- [ ] Add user dashboard #feature ~4h started:2025-01-15T10:30Z

# After (adds logged: with cumulative time)
- [ ] Add user dashboard #feature ~4h started:2025-01-15T10:30Z logged:2h30m
```

When task is completed, the `actual:` field is calculated from all logged time.
BODY

	create_command "context" \
		"Build token-efficient AI context for complex tasks" \
		"$AGENT_BUILD" "true" <<'BODY'
Read ${MAESTRO_DIR:-$HOME/.maestro}/agents/tools/context/context-builder.md and follow its instructions.

Context request: $ARGUMENTS

This generates optimized context for AI assistants including:
1. Relevant code snippets
2. Architecture overview
3. Dependencies and relationships
BODY

	create_command "session-review" \
		"Review session for completeness before ending" \
		"$AGENT_BUILD" "" <<'BODY'
Read ${MAESTRO_DIR:-$HOME/.maestro}/agents/scripts/commands/session-review.md and follow its instructions.

Review the current session for: $ARGUMENTS

**Checks performed:**
1. All objectives completed
2. Workflow best practices followed
3. Knowledge captured for future sessions
4. Clear next steps identified

**Usage:**
```bash
/session-review               # Review current session
/session-review --capture     # Also capture learnings to memory
```
BODY

	return 0
}

define_memory_commands() {
	create_command "remember" \
		"Store a memory for cross-session recall" \
		"$AGENT_BUILD" "" <<'BODY'
Read ${MAESTRO_DIR:-$HOME/.maestro}/agents/scripts/commands/remember.md and follow its instructions.

Remember: $ARGUMENTS

**Usage:**
```bash
/remember "User prefers worktrees over checkout"
/remember "The auth module uses JWT with 24h expiry"
/remember --type WORKING_SOLUTION "Fixed by adding explicit return"
```

**Memory types:**
- WORKING_SOLUTION - Solutions that worked
- FAILED_APPROACH - Approaches that didn't work
- CODEBASE_PATTERN - Patterns in this codebase
- USER_PREFERENCE - User preferences
- TOOL_CONFIG - Tool configurations
- DECISION - Decisions made
- CONTEXT - General context

**Storage:** ${MAESTRO_DIR:-$HOME/.maestro}/.agent-workspace/memory/memory.db
BODY

	create_command "recall" \
		"Search memories from previous sessions" \
		"$AGENT_BUILD" "" <<'BODY'
Read ${MAESTRO_DIR:-$HOME/.maestro}/agents/scripts/commands/recall.md and follow its instructions.

Search for: $ARGUMENTS

**Usage:**
```bash
/recall authentication        # Search for auth-related memories
/recall --recent              # Show 10 most recent memories
/recall --stats               # Show memory statistics
/recall --type WORKING_SOLUTION  # Filter by type
```

**Storage:** ${MAESTRO_DIR:-$HOME/.maestro}/.agent-workspace/memory/memory.db
BODY

	return 0
}

define_utility_commands() {
	define_setup_commands
	define_session_commands
	define_memory_commands
	return 0
}
