<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Plugin System

Third-party agent plugins extend maestro with additional capabilities. Plugins are git repositories that deploy agents into namespaced directories, isolated from core agents.

## Schema

`.maestro.json` `plugins` array:

```json
{
  "plugins": [
    {
      "name": "pro",
      "repo": "https://github.com/Aditya060806/Maestro-pro.git",
      "branch": "main",
      "namespace": "pro",
      "enabled": true
    }
  ]
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Human-readable plugin name |
| `repo` | string | yes | Git repository URL (HTTPS or SSH) |
| `branch` | string | no | Branch to track (default: `main`) |
| `namespace` | string | yes | Directory name under `~/.maestro/agents/` |
| `enabled` | boolean | no | Whether the plugin is active (default: `true`) |

## Deployment

```text
~/.maestro/agents/
├── custom/          # User's private agents (tier: custom)
├── draft/           # Experimental agents (tier: draft)
├── pro/             # Example plugin namespace
│   ├── AGENTS.md    # Plugin's agent definitions
│   └── ...          # Plugin files
└── ...              # Core agents (tier: shared)
```

## Namespacing Rules

- Namespace must be lowercase, alphanumeric, hyphens only
- Must NOT collide with reserved names: `custom`, `draft`, `scripts`, `tools`, `services`, `workflows`, `templates`, `memory`, `plugins`
- Plugins are isolated to their namespace — cannot write outside it or overwrite core agents

## Lifecycle

```bash
# Add — validates namespace, clones repo, registers in subagent index
maestro plugin add https://github.com/Aditya060806/Maestro-pro.git --namespace pro

# Update — pull latest from tracked branch and redeploy
maestro plugin update           # all enabled plugins
maestro plugin update pro       # specific plugin

# Disable / Enable — disable removes deployed files, preserves config entry
maestro plugin disable pro
maestro plugin enable pro

# Remove — removes config entry and deployed files
maestro plugin remove pro

# Create — scaffold new plugin from template [directory] [name] [namespace]
# Generates: AGENTS.md, main agent file, example subagent, scripts/
maestro plugin init ./my-plugin my-plugin my-ns
```

`maestro update` auto-deploys enabled plugins not yet installed. Existing directories are preserved (not re-cloned). Disabled directories are cleaned up. Namespaces are protected during clean mode.

## Plugin Repository Structure

```text
plugin-repo/
├── plugin.json        # Plugin manifest (recommended)
├── AGENTS.md          # Plugin agent definitions (optional)
├── *.md               # Agent/subagent files
├── scripts/           # Helper scripts and lifecycle hooks (optional)
│   ├── on-init.sh     # Runs on install/update
│   ├── on-load.sh     # Runs on session load
│   └── on-unload.sh   # Runs on disable/remove
└── tools/             # Tool definitions (optional)
```

Entire repo contents deploy to `~/.maestro/agents/<namespace>/`.

## Plugin Manifest (plugin.json)

Optional — plugins without a manifest fall back to directory scanning for agent discovery.

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "min_maestro_version": "2.110.0",
  "agents": [
    {
      "file": "my-agent.md",
      "name": "my-agent",
      "description": "Agent purpose",
      "model": "sonnet"
    }
  ],
  "hooks": {
    "init": "scripts/on-init.sh",
    "load": "scripts/on-load.sh",
    "unload": "scripts/on-unload.sh"
  },
  "scripts": ["scripts/my-helper.sh"],
  "dependencies": []
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Plugin name (matches plugins.json entry) |
| `version` | string | yes | Semver version (X.Y.Z) |
| `description` | string | no | Human-readable description |
| `min_maestro_version` | string | no | Minimum maestro version required |
| `agents` | array | no | Agent definitions (file, name, description, model) |
| `hooks` | object | no | Lifecycle hook scripts (init, load, unload) |
| `scripts` | array | no | Additional helper scripts |
| `dependencies` | array | no | Required external tools or plugins |

### Agent Loader

```bash
plugin-loader-helper.sh discover   # Discover all installed plugins
plugin-loader-helper.sh load pro   # Load agents from a specific plugin
plugin-loader-helper.sh validate   # Validate plugin manifest(s)
plugin-loader-helper.sh agents     # List agents provided by plugins
plugin-loader-helper.sh index      # Generate subagent-index entries
plugin-loader-helper.sh hooks pro init  # Run a lifecycle hook
plugin-loader-helper.sh status     # Show plugin system status
```

Loading priority: (1) `plugin.json` `agents` array if present; (2) scan directory for `.md` files with YAML frontmatter.

The shared `subagent-index.toon` discovery file is regenerated after plugin add,
update, enable, and disable actions. `subagent-index-helper.sh generate` preserves
the core `subagents` TOON block and appends `plugin-loader-helper.sh index` output
as a lightweight `plugin_agents` block, so runtimes can discover plugin namespaces
from one startup index without reading every plugin file.

## Lifecycle Hooks

| Hook | When | Use Case |
|------|------|----------|
| `init` | Install, update, enable | One-time setup, dependency checks, config creation |
| `load` | Session start, agent loading | Environment setup, PATH additions |
| `unload` | Disable, remove | Cleanup temp files, revoke registrations |

Environment variables available to hooks:
- `MAESTRO_PLUGIN_NAMESPACE` — Plugin namespace
- `MAESTRO_PLUGIN_DIR` — Plugin directory path
- `MAESTRO_AGENTS_DIR` — Root agents directory
- `MAESTRO_HOOK` — Current hook name (init, load, unload)

Hooks are defined in the manifest under `hooks`, or discovered by convention at `scripts/on-{hook}.sh`.

## Security

- Plugins are user-installed and user-trusted — review source before installation
- Plugin scripts are NOT auto-executed; they must be explicitly invoked
- Plugin agents follow the same security rules as core agents (no credential exposure, pre-edit checks)

## Integration with Agent Tiers

| Tier | Location | Survives Update | Source |
|------|----------|-----------------|--------|
| Draft | `~/.maestro/agents/draft/` | Yes | Auto-created by orchestration |
| Custom | `~/.maestro/agents/custom/` | Yes | User-created |
| Plugin | `~/.maestro/agents/<namespace>/` | Yes (managed separately) | Third-party git repos |
| Shared | `.agents/` in repo | Overwritten on update | Open-source distribution |

## Configuration

Plugin state: `~/.config/maestro/plugins.json` (global, auto-created on first use). Per-project plugin awareness: `.maestro.json` `plugins` array. Run `maestro plugin help` for full CLI documentation.

## Official Plugins

| Plugin | Namespace | Repo | Description |
|--------|-----------|------|-------------|
| **maestro-pro** | `pro` | `https://github.com/Aditya060806/Maestro-pro.git` | Premium agents: advanced deployment, monitoring, cost optimisation |
| **maestro-anon** | `anon` | `https://github.com/Aditya060806/Maestro-anon.git` | Privacy agents: browser fingerprints, proxy rotation, identity isolation |

```bash
maestro plugin add https://github.com/Aditya060806/Maestro-pro.git --namespace pro
maestro plugin add https://github.com/Aditya060806/Maestro-anon.git --namespace anon
```

### maestro-pro Agents

| Agent | Purpose |
|-------|---------|
| `pro/advanced-deployment.md` | Blue-green, canary, and rolling deployment strategies |
| `pro/monitoring.md` | Prometheus/Grafana observability stack setup |
| `pro/cost-optimisation.md` | Cloud spend analysis and right-sizing recommendations |

### maestro-anon Agents

| Agent | Purpose |
|-------|---------|
| `anon/browser-profiles.md` | Browser fingerprint profile creation and management |
| `anon/proxy-rotation.md` | Proxy pool management and rotation strategies |
| `anon/identity-isolation.md` | Session isolation and identity separation |
