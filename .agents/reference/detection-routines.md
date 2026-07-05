<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Detection Routines

Proactive detection routines are scheduled scans that catch framework misbehaviour
before a human has to notice it. They complement the audit log (reactive, records
what happened) with a forward-looking sweep (proactive, detects symptoms of what
went wrong).

## Architecture

Detection routines follow a common pattern:

1. **Enumerate** pulse-enabled repos from `~/.config/maestro/repos.json`.
2. **Scan** each repo for a specific symptom via the GitHub API.
3. **Dedup** against a 24h seen-cache to avoid filing duplicate incidents.
4. **File** incident issues on the framework repo (`Aditya060806/Maestro` by default)
   using the `gh_create_issue` wrapper (auto-labelled, auto-signed).
5. **Log** all findings to a dedicated log file with rotation.

All routines are non-blocking per-repo — a failure in one repo (network, auth,
API limit) is logged and skipped, not fatal.

## Registered Scanners

### r006 — Stub-Title Issue Scanner

**Script:** `custom/scripts/r-stub-title-scan.sh`
**Schedule:** `cron(15 * * * *)` — every hour at minute :15
**Runtime:** ~2 minutes (API-bound, no LLM tokens)

**What it detects:** Issues whose title is a stub — just a task-ID prefix and colon
with no description (e.g. `t2377:`, `GH#19778:`, or plain `:`). This is the
signature of the t2377 data-loss bug class, where the `enrich-path` overwrites the
issue title/body with empty or truncated data.

**Why it exists:** GH#19847 (t2377) was discovered because the maintainer happened
to notice empty titles in the issue list. This scanner removes the dependency on
human vigilance by running hourly.

**Stub-title regex:** `^(t[0-9]+|GH#[0-9]+)?:\s*$` (anchored — the entire title
is just the prefix + colon + optional whitespace).

**Dedup:** A JSON cache at `~/.maestro/cache/stub-title-seen.json` tracks
`slug#number → unix_timestamp` entries. Entries older than 24h are pruned on each
run. First detection files a new incident issue; repeated detection within 24h
updates the existing incident with a timestamp comment.

**Log:** `~/.maestro/logs/stub-title-incidents.log` — rotated at 1 MB, 5 copies kept.

**Environment tunables:**

| Variable | Default | Purpose |
|----------|---------|---------|
| `STUB_SCAN_REPOS` | *(all pulse repos)* | Comma-separated slug allowlist |
| `STUB_SCAN_INCIDENT_REPO` | `Aditya060806/Maestro` | Where to file incident issues |
| `STUB_SCAN_DRY_RUN` | `0` | Set to `1` for scan-and-log-only mode |

**Incident issue format:** Filed with labels `automation`, `monitoring`, `incident`
and a `<!-- maestro:generator=r-stub-title-scan -->` marker for pre-dispatch
validator recognition. Body includes the affected issue reference, detected title,
recommended remediation steps, and links to the root-cause issue (GH#19847).

**Manual invocation:**

```bash
# Dry run — scan and log without filing issues
~/.maestro/agents/custom/scripts/r-stub-title-scan.sh --dry-run

# Normal run — scan and file incident issues
~/.maestro/agents/custom/scripts/r-stub-title-scan.sh
```

## Adding a New Detection Routine

1. Create the script in `custom/scripts/r-<name>.sh` following the pattern in
   `r-stub-title-scan.sh`.
2. Add a routine entry under `TODO.md ## Routines` with the next available `r`-ID.
3. Document the scanner in this file under "Registered Scanners".
4. Key requirements:
   - Source `shared-constants.sh` for `gh_create_issue` wrapper and colour constants.
   - Use a 24h dedup cache to avoid filing duplicate incidents.
   - Log to a dedicated file with rotation (1 MB, 5 copies).
   - Support `--dry-run` flag and `*_DRY_RUN` environment variable.
   - Include `<!-- maestro:generator=<script-name> -->` marker in filed issues.
   - Non-blocking per-repo — log and continue on individual repo failures.

## Why Independent from the Audit Log

The audit log (`audit-log-helper.sh`) records *what happened* — a reactive record
of operations. Detection routines scan for *symptoms of what went wrong* — a
proactive check that surfaces incidents even when the audit log missed the causal
event (e.g. the enrich-path didn't log the empty-data overwrite that caused the
stub title). The two systems are complementary, not overlapping.
