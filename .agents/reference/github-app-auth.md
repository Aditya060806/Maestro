# GitHub App Auth and API Budget Routing

## Goal

User-owned GitHub Apps give maestro a separate GitHub auth principal per installation. The framework uses that principal for REST-equivalent reads/searches while preserving PAT/`gh` auth for native GitHub CLI operations and GraphQL-only semantics.

## Configuration

Copy `.agents/configs/github-app-auth.json.txt` to `~/.config/maestro/github-app-auth.json` and fill only non-secret identifiers:

```json
{
  "enabled": true,
  "app_id": "123456",
  "installation_id": "987654",
  "private_key_path": "$HOME/.config/maestro/keys/github-app.pem"
}
```

Private key material must never be committed. Store the PEM outside repositories with `chmod 600`, or store only the key path with `maestro secret set GITHUB_APP_PRIVATE_KEY_PATH` and set `private_key_path_secret` in the JSON template.

Environment overrides are available for automation:

- `MAESTRO_GITHUB_APP_ENABLED=1`
- `MAESTRO_GITHUB_APP_ID=<app-id>`
- `MAESTRO_GITHUB_APP_INSTALLATION_ID=<installation-id>`
- `MAESTRO_GITHUB_APP_PRIVATE_KEY_PATH=<pem-path>`
- `MAESTRO_GITHUB_APP_REST_FIRST=0|1`

## Permission matrix

Use least privilege and add scopes only when a workflow proves it needs them.

| Permission | Minimum | Used for |
| --- | --- | --- |
| Metadata | Read | Repository identity and installation lookup |
| Issues | Read/write | Issue list/view/comment/edit/status label routes |
| Pull requests | Read/write | PR list/view/create metadata routes |
| Contents | Read by default; write only for app-scoped push automation | Repository metadata, future app-scoped content writes |
| Checks | Read | Check suites and check runs |
| Commit statuses | Read | Status contexts |
| Actions | Read when enabled | Workflow run/check log inspection |

## Routing policy

`github-app-auth-helper.sh` classifies operations by semantics before choosing a pool:

| Operation class | Examples | Pool | Auth preference |
| --- | --- | --- | --- |
| GraphQL-only | node IDs, sub-issue mutation, Project v2 | GraphQL | `gh`/PAT unless a caller explicitly uses an app token |
| REST core | issue/pr view/list, labels, comments, statuses, checks | REST core | GitHub App when configured; otherwise `gh`/PAT REST fallback |
| REST search | issue search/list with `--search` | REST search | GitHub App when configured; otherwise `gh`/PAT search fallback |
| Native `gh` fallback | high-level create/edit/merge flows | `gh`/PAT | Existing `gh` auth first, REST fallback on GraphQL exhaustion |

Default policy is REST-first for REST-equivalent operations when app auth is configured. Set `MAESTRO_GITHUB_APP_REST_FIRST=0` to route through REST only when the live GraphQL budget is below `MAESTRO_GH_REST_FALLBACK_THRESHOLD`.

## Runtime behavior

- Installation tokens are cached under `~/.maestro/cache/github-app/` with `0600` files and refreshed before expiry.
- Rate-limit snapshots are cached per auth principal and pool for `MAESTRO_GITHUB_APP_RATE_LIMIT_CACHE_TTL` seconds.
- `gh-api-instrument.sh` records path, caller, auth mode, API pool, route decision, and remaining budget.
- When no app is configured, all existing PAT/`gh` behavior remains unchanged.

## Commands

```bash
maestro github-app-auth status --json
maestro github-app-auth route issue-list --json
maestro github-app-auth rate-limit --json
```

Status and route commands never print tokens or private key material. The `token` subcommand refuses to print an installation token unless `MAESTRO_GITHUB_APP_ALLOW_TOKEN_STDOUT=1` is set for an automation context that captures stdout.

## Verification

Run the focused tests after changing this area:

```bash
bash .agents/scripts/tests/test-github-app-auth-helper.sh
bash .agents/scripts/tests/test-gh-api-instrument.sh
bash .agents/scripts/tests/test-gh-wrapper-rest-fallback.sh
shellcheck .agents/scripts/github-app-auth-helper.sh .agents/scripts/gh-api-instrument.sh .agents/scripts/shared-gh-wrappers.sh .agents/scripts/shared-gh-wrappers-rest-fallback.sh .agents/scripts/shared-gh-wrappers-status.sh
```
