<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Batched Execution

```javascript
async function batched(items, batchSize) {
  const results = [];
  for (let i = 0; i < items.length; i += batchSize)
    results.push(...await Promise.all(items.slice(i, i + batchSize).map(processItem)));
  return results;
}
```
