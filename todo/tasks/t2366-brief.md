<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->
# t2366: add r914 daily repo-maestro-health-keeper routine

## Origin

- **Created:** 2026-04-19
- **Session:** claude-code:maestro-interactive (continuation of t2265 / #19809 planning session)
- **Created by:** ai-interactive (Aditya060806)
- **Parent task:** none (sibling of t2265; see "Blocked by" below)
- **Conversation context:** Interactive session on 2026-04-19 added four new private Jersey websites to `repos.json`, then audited the wider registry. Found (a) repos with stale `.maestro.json` version fields (v3.8.65 when framework is v3.8.72; one at v3.1.266); (b) repos.json entries referring to deleted folders (MISSING-FOLDER class); (c) active git repos with no `.maestro.json` at all (NO-INIT class). These three drift classes are invisible until you audit by hand. User asked for a daily routine that keeps `.maestro.json` versions current and surfaces drift for human triage.

## What

Add a new framework-level core routine `r914 repo-maestro-health-keeper` that runs daily at 03:30 local time and:

1. **Version bump (autonomous, safe).** For every entry in `~/.config/maestro/repos.json` where the repo directory exists and has a `.maestro.json` file whose `maestro_version` is older than the currently-installed framework version: rewrite `.maestro.json` with the current version, commit on the repo's default branch (or via the established planning-file main-branch exception for headless sessions), and push. Skip local-only repos for the push step. Skip repos with uncommitted changes (safety).
2. **Missing-folder detection (human-gated).** For every entry in `repos.json` where the `path` does not exist and the entry is not tagged `archived: true`: file a `needs-maintainer-review`-labelled issue on `Aditya060806/Maestro` with the entry JSON inline, asking the maintainer to either re-clone, remove from `repos.json`, or set `archived: true`. Rate-limited: one issue per entry per 7 days. Idempotent — if an open issue for the same repo already exists, update its body with the latest snapshot and bump its timestamp; do not file a duplicate.
3. **No-init detection (human-gated).** For every git repo in the `git_parent_dirs[]` expanded list that is NOT already tracked in `initialized_repos[]` and does NOT have a `.maestro.json`: file a `needs-maintainer-review`-labelled issue on `Aditya060806/Maestro` suggesting either `maestro init <scope>` (scope inferred from repo metadata — see blocked-by section) or explicit opt-out via a `.maestro-skip` marker file. Same rate-limit and idempotence rules as #2.

Routine integrates with the existing core-routines pipeline so that `maestro update` propagates the r914 description to downstream `routines/core/r914.md` files in consumer repos (e.g., `Aditya060806/Maestro-routines`).

## Why

**Observed drift** across 32 `repos.json` entries on 2026-04-19:

- 1 entry pointing at a deleted folder (stale legacy `maestro.sh-chore-maestro-init` — cleaned up in this session but the class is recurring)
- Multiple `.maestro.json` files at v3.8.65 when framework is v3.8.72 (bump via `maestro init` requires user intervention today)
- 1 entry at v3.1.266 (very stale — `propertyservicesdirectory.com`)
- At least 7 active git repos with no `.maestro.json` (internal tools and external FOSS repos where TODO.md authorship would leak to public)

Manual audit took ~30 min of interactive time and was only triggered because the user explicitly asked. Without a routine, these drift classes accumulate silently until someone hits a "version too old" error or notices orphan entries in the dashboard. The pulse, dashboard, and session-time tools already iterate `repos.json` — they deserve accurate data.

## Tier

### Tier checklist (verify before assigning)

- [ ] **2 or fewer files to modify?** — No. 5 files (see Files to Modify below).
- [ ] **Every target file under 500 lines?** — No. `schedulers.sh` is ~1992 lines and `core-routines.sh` is ~748 lines.
- [ ] **Exact `oldString`/`newString` for every edit?** — No. Adding new sections, not literal string replacements.
- [x] **No judgment or design decisions?** — Mostly no. One design decision: rate-limit window for issue filing (default 7 days, document as env var).
- [ ] **No error handling or fallback logic to design?** — No. Offline/no-network handling, partial failure handling, and the "skip if uncommitted changes" safety rail are part of this task.
- [x] **No cross-package or cross-module changes?** — All changes within the maestro repo.
- [ ] **Estimate 1h or less?** — No. 3-4h estimate.
- [ ] **4 or fewer acceptance criteria?** — No. 7 criteria below.

Most checkboxes unchecked → **`tier:standard`** (default). Not `tier:thinking`: this follows the well-established `r906` repo-sync routine pattern line-for-line. A standard-tier worker with the reference patterns pointed at can execute it.

**Selected tier:** `tier:standard`
**Tier rationale:** Multiple files, non-trivial error handling, but close structural parallel to existing `r906` repo-sync routine — a worker can model on that pattern. Not simple-tier because >2 files and the files are large.

## Blocked by

- **t2265 / #19809** — `init_scope` field. The no-init issue template (item 3 above) must be able to suggest a specific scope (`minimal` for `local_only: true` entries, `standard` otherwise). Without `init_scope`, the issue body would either be wrong (always suggesting full scope) or incomplete (refusing to suggest at all). Safe to implement r914 with a TEMPORARY fallback ("suggest `maestro init standard`") and upgrade the suggestion logic once t2265 merges — record this as a follow-up comment on the merge.

## PR Conventions

Leaf (non-parent) task. PR body uses `Resolves #NNN` where `NNN` is the issue number created for this task.

## How (Approach)

### Worker Quick-Start

```bash
# Reference pattern — r906 repo-sync routine (closest structural parallel).
# Read these three files end-to-end before starting:
cat ~/Git/maestro/.agents/scripts/repo-sync-helper.sh            # ~700 lines — helper with enable/disable/check/run
cat ~/Git/maestro/setup-modules/schedulers.sh | sed -n '1954,1992p'  # setup_repo_sync function
cat ~/Git/maestro/.agents/scripts/routines/core-routines.sh | sed -n '370,420p'  # describe_r906 function

# Key structural facts:
# 1. Each core routine is { helper.sh, setup_<name>() in schedulers.sh, describe_rNNN() in core-routines.sh, entry in get_core_routine_entries() }
# 2. Plist install lives INSIDE the helper (enable subcommand), not in setup.sh
# 3. setup_<name>() only checks if already installed and invokes helper's enable
# 4. Feature flag is checked via is_feature_enabled <name> and respects maestro config set orchestration.<name> false
```

### Files to Modify

- `NEW: .agents/scripts/repo-maestro-health-helper.sh` — main routine script. Model line-for-line on `.agents/scripts/repo-sync-helper.sh` (same shape: enable/disable/check/status/run/install/uninstall subcommands; launchd plist on darwin; systemd user unit on linux; respects `is_feature_enabled repo_maestro_health`).
- `EDIT: .agents/scripts/routines/core-routines.sh` — add new line to `get_core_routine_entries()` near line 31 (`r914|x|Repo maestro health — bump stale .maestro.json, detect drift|repeat:daily(@03:30)|~2m|scripts/repo-maestro-health-helper.sh run|script`), and add new `describe_r914()` function modelled on `describe_r906()` around line 370-420.
- `EDIT: setup-modules/schedulers.sh` — add `setup_repo_maestro_health()` function modelled on `setup_repo_sync()` at line 1954-1992. Call it from the main setup flow (find where `setup_repo_sync` is called and add adjacent).
- `EDIT: .agents/configs/features.json` (or wherever feature flags are registered — verify location during implementation) — add `repo_maestro_health` feature key, default `true`.
- `NEW: .agents/scripts/tests/test-repo-maestro-health.sh` — shellcheck + unit tests for dry-run mode, stale-version detection, missing-folder detection, no-init detection, and rate-limit idempotence.

### Implementation Steps

1. **Clone and adapt `repo-sync-helper.sh`** into `repo-maestro-health-helper.sh`. Keep the enable/disable/check/install/uninstall plumbing verbatim; replace the `run` subcommand body with the three drift checks. Launchd label: `sh.maestro.repo-maestro-health`. Schedule: StartCalendarInterval Hour=3 Minute=30.

2. **Drift check #1 — version bump.** Read `~/.config/maestro/repos.json`, iterate `initialized_repos[]`. For each entry: resolve `$path`; if it exists and contains `.maestro.json`; read `maestro_version`; if older than `$HOME/.maestro/agents/VERSION`: rewrite the JSON with the new version using `jq --argjson` (NEVER with sed/awk — JSON corruption risk, see session lesson mem_20260419012142_0aa16fa7); commit on `main` with message `chore: bump .maestro.json to v<new> (r914)`; push with `--force-with-lease` safety (or skip push for `local_only: true` entries). Skip if `git status --porcelain` is non-empty (uncommitted changes present).

3. **Drift check #2 — missing folder.** For each `initialized_repos[]` entry where `$path` does NOT exist and entry is not `archived: true`: check for an existing open issue via `gh issue list --repo Aditya060806/Maestro --label repos-drift --search "repos.json entry: $slug"`; if an open issue exists, comment with the latest snapshot and timestamp; otherwise file a new issue via `gh_create_issue` with labels `repos-drift,needs-maintainer-review,framework`. Rate limit: skip if the entry was flagged in the last `REPOS_DRIFT_FLAG_INTERVAL_DAYS` days (default 7, env override).

4. **Drift check #3 — no-init.** Expand `git_parent_dirs[]` (each entry may use `~` and trailing `/*`). For each git repo in the expanded list: if slug is NOT in `initialized_repos[]` AND no `.maestro-skip` marker AND no `.maestro.json`: file/update an issue the same way as step 3 with labels `no-init,needs-maintainer-review,framework`. Include suggested scope in the body using `init_scope` semantics from t2265 (with temporary fallback to `standard` until t2265 ships — see Blocked by section).

5. **Add `describe_r914()` to `core-routines.sh`** modelled on `describe_r906`. Include per-platform scheduler row via `_scheduler_row_calendar` with `StartCalendarInterval: Hour=3, Minute=30`. Diag commands via `_diag_commands`. Sections: Overview, Schedule, What it does, What to check, Safety rails (list the "skip if uncommitted changes" and rate-limit rules explicitly).

6. **Add `r914` to `get_core_routine_entries()`** — pipe-delimited line as shown in Files to Modify.

7. **Add `setup_repo_maestro_health()` to `schedulers.sh`** modelled on `setup_repo_sync()`. Call it from the same caller site as `setup_repo_sync`.

8. **Feature flag registration.** Find existing `orchestration.repo_sync` flag declaration (likely `.agents/configs/features.json` or a registry file); add `orchestration.repo_maestro_health` with default `true`.

9. **Tests.** `test-repo-maestro-health.sh`: harness a temporary `repos.json` with fixture entries covering all three drift classes; run helper's `run --dry-run`; assert correct detections and counts; assert NO writes happen in dry-run; then run without `--dry-run` in a sandbox and assert the expected side effects (version bump commit, issue creation call via mock `gh`).

### Verification

```bash
# Syntax
shellcheck .agents/scripts/repo-maestro-health-helper.sh
shellcheck .agents/scripts/tests/test-repo-maestro-health.sh

# Unit tests
bash .agents/scripts/tests/test-repo-maestro-health.sh

# Integration — dry-run against real repos.json
.agents/scripts/repo-maestro-health-helper.sh run --dry-run

# Describe propagation — after merge, next maestro update should generate routines/core/r914.md downstream
maestro update && ls -la ~/Git/maestro-routines/routines/core/r914.md

# launchd install
.agents/scripts/repo-maestro-health-helper.sh enable
launchctl list | grep sh.maestro.repo-maestro-health
```

## Acceptance Criteria

- [ ] `repo-maestro-health-helper.sh` exists, is executable, passes shellcheck, and supports enable/disable/check/status/run/install/uninstall subcommands.
  ```yaml
  verify:
    method: bash
    run: "shellcheck .agents/scripts/repo-maestro-health-helper.sh && bash .agents/scripts/repo-maestro-health-helper.sh help | grep -qE 'enable|disable|run'"
  ```
- [ ] `r914` appears in `get_core_routine_entries()` output of `core-routines.sh` with correct schedule (`repeat:daily(@03:30)`) and script path.
  ```yaml
  verify:
    method: bash
    run: "bash -c 'source .agents/scripts/routines/core-routines.sh && get_core_routine_entries | grep -qE \"^r914\\|x\\|Repo maestro health\"'"
  ```
- [ ] `describe_r914 darwin` outputs valid markdown with Overview / Schedule / What it does / What to check sections.
  ```yaml
  verify:
    method: bash
    run: "bash -c 'source .agents/scripts/routines/core-routines.sh && describe_r914 darwin | grep -qE \"^## Schedule\"'"
  ```
- [ ] `setup_repo_maestro_health()` exists in `schedulers.sh` and is called from the main setup flow.
  ```yaml
  verify:
    method: codebase
    pattern: "setup_repo_maestro_health"
    path: "setup-modules/schedulers.sh"
  ```
- [ ] Dry-run mode detects drift without making any writes (version bump, commit, push, issue create are all mocked/skipped).
  ```yaml
  verify:
    method: bash
    run: "bash .agents/scripts/tests/test-repo-maestro-health.sh"
  ```
- [ ] Idempotent issue filing — running twice against the same drift state does not produce duplicate issues (second run updates existing issue instead).
  ```yaml
  verify:
    method: bash
    run: "bash .agents/scripts/tests/test-repo-maestro-health.sh 2>&1 | grep -qE 'idempotent|no-duplicate'"
  ```
- [ ] After merge + `maestro update`, the downstream `maestro-routines` repo's `routines/core/r914.md` file exists with content matching `describe_r914` output.
  ```yaml
  verify:
    method: bash
    run: "ls ~/Git/maestro-routines/routines/core/r914.md 2>/dev/null"
  ```

## Context

- **Related PR (sibling task):** `#19813` t2265 plan for `init_scope` field. r914's no-init issue template depends on `init_scope` semantics.
- **Reference pattern:** `r906` repo-sync routine — structurally the closest existing core routine (daily, iterates `repos.json`, per-entry git operations).
- **Session lesson (mem_20260419012142_0aa16fa7):** when writing to `repos.json`, NEVER interleave Edit tool writes with `register_repo`/`jq` writes — use a single atomic write per step. This routine uses `jq` exclusively for `.maestro.json` bumps, no Edit/sed.
- **Safety precedent:** the existing `.maestro.json` write path in `cmd_init` (see `/usr/local/bin/maestro` at ~2199-2243) shows the canonical merge-preserving jq pattern.
- **Public-repo privacy:** issue bodies filed against `Aditya060806/Maestro` must NOT include private slugs — use the existing sanitizer in `issue-sync-helper.sh` or an equivalent mask before composing the body (cross-repo privacy rule in `.agents/AGENTS.md`).
