# t1881: Supply Chain Signature Verification + maestro signing Command

## Session Origin

Interactive session, continuation of t1880 (attribution protection).

## What

1. Supply chain verification during `maestro update` — verify pulled code is signed
2. `maestro signing` CLI subcommand (setup/check/verify-tag/verify-update)
3. Signing status in `maestro status` output
4. Startup nudge when signing is not configured
5. Fix: force-add `signing-setup.sh` that was gitignored in t1880

## Why

The t1880 attribution work added commit signing capability but the update flow did not verify signatures. A compromised repo or MITM could serve unsigned commits and `maestro update` would apply them blindly. This closes the supply chain verification gap.

## How

- **Trusted key**: Aditya Pandey and Harvest's SSH public key embedded as `TRUSTED_KEY` and `TRUSTED_FINGERPRINT` in `signing-setup.sh`
- **Verification strategy**: GitHub API first (handles GPG squash-merge signatures), local git verification fallback
- **`_update_verify_signature()`**: New function in `maestro.sh` called after `git pull` in `cmd_update()`
- **`maestro signing`**: Dispatches to `signing-setup.sh` (setup/check/verify-tag/verify-update)
- **Status check**: Commit signing section in `cmd_status()` output
- **Startup nudge**: `_check_signing()` in `maestro-update-check.sh`, dismissible after setup

### Key files

- `.agents/scripts/signing-setup.sh` — signing helper with verification logic
- `maestro.sh` — `_update_verify_signature()`, `cmd_status()`, `signing` subcommand
- `.agents/scripts/maestro-update-check.sh` — `_check_signing()` startup nudge

## Acceptance Criteria

1. `maestro signing check` shows current signing configuration
2. `maestro signing verify-update` returns VERIFIED for signed HEAD on main
3. `maestro update` shows verification result after pulling
4. `maestro status` shows commit signing section
5. Startup check nudges once when signing not configured, dismisses after setup
6. ShellCheck clean on all modified files
