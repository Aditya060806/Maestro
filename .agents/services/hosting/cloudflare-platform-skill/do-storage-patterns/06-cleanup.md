<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Cleanup

```typescript
async cleanup() {
  await this.ctx.storage.deleteAlarm(); // Separate from deleteAll
  await this.ctx.storage.deleteAll();
}
```
