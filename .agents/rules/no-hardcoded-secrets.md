---
id: no-hardcoded-secrets
ttsr_trigger: (api[_-]?key|password|secret|token)[[:space:]]*[:=][[:space:]]*['"][A-Za-z0-9+/=_-]{16,}
severity: error
repeat_policy: always
tags: [security]
enabled: true
---

<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

STOP: You are about to hardcode a secret value. This violates security rules.

- Never expose credentials in output, logs, or code
- Store secrets via `maestro secret set NAME` (gopass encrypted)
- Or use `~/.config/maestro/credentials.sh` (plaintext fallback, 600 permissions)
- Use environment variable references or placeholder values in code
