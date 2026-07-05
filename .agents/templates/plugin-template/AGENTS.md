<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# {{PLUGIN_NAME}} Plugin

> This is an [maestro](https://maestro.sh) plugin. Install with:
>
> ```bash
> maestro plugin add {{REPO_URL}} --namespace {{NAMESPACE}}
> ```

## Agents

| Agent | Purpose |
|-------|---------|
| `{{NAMESPACE}}.md` | Main agent for {{PLUGIN_NAME}} |

## Setup

1. Install the plugin: `maestro plugin add {{REPO_URL}} --namespace {{NAMESPACE}}`
2. Configure any required credentials: `maestro secret set {{PLUGIN_NAME_UPPER}}_API_KEY`
3. Use the agent: reference `{{NAMESPACE}}/` agents in your workflow

## Configuration

This plugin reads configuration from:

- `~/.config/maestro/credentials.sh` (API keys)
- `.maestro.json` in your project root (project-level settings)
