<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# CLI Reference

The `maestro` command provides a unified interface for managing your Maestro installation.

## Installation

The CLI is installed automatically by setup.sh:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Aditya060806/Maestro/main/setup.sh)
```text

**Location:** `/usr/local/bin/maestro` (or `~/.local/bin/maestro` if no sudo)

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `maestro status` | | Check installation status of all components |
| `maestro update` | `upgrade` | Update to the latest version |
| `maestro uninstall` | | Remove maestro from your system |
| `maestro version` | `-v`, `--version` | Show version information |
| `maestro help` | `-h`, `--help` | Show help message |

## Command Details

### `maestro status`

Displays comprehensive status of your installation:

```bash
maestro status
```text

**Checks performed:**

| Category | Items Checked |
|----------|---------------|
| **Version** | Current vs latest, update notification |
| **Installation Paths** | Repository location, agents directory |
| **Required Dependencies** | git, curl, jq, ssh |
| **Optional Dependencies** | sshpass |
| **Recommended Tools** | Tabby terminal, Zed editor + OpenCode extension |
| **Git CLI Tools** | gh (GitHub), glab (GitLab), tea (Gitea) |
| **AI Tools & MCPs** | OpenCode CLI, Augment Context Engine, osgrep |
| **Development Environments** | DSPy, DSPyGround |
| **AI Assistant Configs** | OpenCode, Cursor, Claude, Continue.dev, Windsurf, Gemini, Warp, Codex, Kiro |
| **SSH Configuration** | Ed25519 key presence |

**Example output:**

```text
Maestro Framework Status
==========================

Version: 2.12.0
  Latest: 2.12.0 (up to date)

Installation:
  Repository: ~/Git/maestro
  Agents: ~/.maestro/agents/

Required Dependencies:
  [OK] git
  [OK] curl
  [OK] jq
  [OK] ssh

Recommended Tools:
  [OK] Tabby
  [OK] Zed
  [OK] OpenCode extension

AI Assistants:
  [OK] OpenCode (~/.config/opencode/AGENTS.md)
  [OK] Cursor (.cursorrules)
  ...
```text

### `maestro update`

Updates to the latest version:

```bash
maestro update
# or
maestro upgrade
```text

**What it does:**

1. Pulls latest changes from the repository
2. Re-runs setup.sh to update configurations
3. Updates the CLI command itself

### `maestro uninstall`

Removes maestro from your system:

```bash
maestro uninstall
```text

**What gets removed:**

| Item | Path |
|------|------|
| Agents directory | `~/.maestro/` |
| AI assistant references | Various config files |
| Shell aliases | `.bashrc`, `.zshrc`, etc. |
| AI memory files | `CLAUDE.md`, `GEMINI.md`, `WINDSURF.md`, etc. |
| CLI command | `/usr/local/bin/maestro` |
| Repository | `~/Git/maestro` (asks separately) |

**What is NOT removed:**

- Installed tools (Tabby, Zed, gh, glab)
- SSH keys
- Python/Node environments
- API keys in `~/.config/maestro/`

### `maestro version`

Shows version information:

```bash
maestro version
# or
maestro -v
maestro --version
```text

### `maestro help`

Shows help message:

```bash
maestro help
# or
maestro -h
maestro --help
```text

## Shell Integration

Setup detects your shell and configures aliases appropriately:

| Shell | Config File |
|-------|-------------|
| bash | `~/.bashrc` or `~/.bash_profile` |
| zsh | `~/.zshrc` |
| fish | `~/.config/fish/config.fish` |
| ksh | `~/.kshrc` |

## Package Manager Support

Setup auto-detects and uses your system's package manager:

| Manager | Systems |
|---------|---------|
| brew | macOS, Linux (Homebrew) |
| apt | Debian, Ubuntu |
| dnf | Fedora, RHEL 8+ |
| yum | CentOS, RHEL 7 |
| pacman | Arch Linux |
| apk | Alpine Linux |

## Examples

### Fresh Install

```bash
# Install everything
bash <(curl -fsSL https://raw.githubusercontent.com/Aditya060806/Maestro/main/setup.sh)

# Check what was installed
maestro status
```text

### Update Existing Installation

```bash
# Quick update
maestro update

# Or re-run the one-liner (same effect)
bash <(curl -fsSL https://raw.githubusercontent.com/Aditya060806/Maestro/main/setup.sh)
```text

### Check if Update Available

```bash
maestro status
# Look for "Update available" message
```text

### Clean Uninstall

```bash
maestro uninstall
# Follow prompts to remove components
```text

## Troubleshooting

### Command Not Found

If `maestro` command is not found after installation:

```bash
# Check if it's in PATH
which maestro

# If using ~/.local/bin, ensure it's in PATH
export PATH="$HOME/.local/bin:$PATH"

# Or run directly
~/.local/bin/maestro status
```text

### Permission Denied

If you get permission errors:

```bash
# The installer will fall back to ~/.local/bin automatically
# Or manually move:
sudo mv ~/.local/bin/maestro /usr/local/bin/
```text

### Update Fails

If update fails, try a fresh install:

```bash
# Remove and reinstall
maestro uninstall
bash <(curl -fsSL https://raw.githubusercontent.com/Aditya060806/Maestro/main/setup.sh)
```text
