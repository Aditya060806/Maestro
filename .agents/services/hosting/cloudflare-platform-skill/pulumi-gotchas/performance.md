<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Performance

- Avoid storing large files in state; use `ignoreChanges` for frequently changing properties
- Pulumi automatically parallelizes independent resource updates
- `pulumi refresh --yes` — sync state with actual infrastructure
