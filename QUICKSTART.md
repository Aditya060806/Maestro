<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Maestro in 2 minutes

The goal of this page: get you from zero to **watching Maestro do one real, useful thing** — fast. You need exactly two things: a terminal and one model provider key.

> Maestro runs on macOS and Linux. On Windows, use [WSL2](https://learn.microsoft.com/windows/wsl/install) (Ubuntu) — everything below works inside the WSL shell.

## 1. Install (30 seconds)

```bash
npm install -g @aditya060806/maestro && maestro update
```

No npm? Any of these also work:

```bash
bun install -g @aditya060806/maestro && maestro update          # Bun
brew install Aditya060806/tap/maestro && maestro update   # Homebrew
```

Check it landed:

```bash
maestro status
```

## 2. Connect one model (60 seconds)

You only need **one** provider to start. Pick whichever you already have:

```bash
maestro model-accounts-pool add openai      # recommended (GPT-5.5 / GPT-5.4 mini)
# or
maestro model-accounts-pool add anthropic   # uses your Claude Pro/Max via OAuth — no API key
```

That is the only hard prerequisite. Secrets (`gopass`), GitHub auth (`gh`), and extra services are **optional** — Maestro will offer to set them up later, only when a task actually needs them.

## 3. Your first win (30 seconds)

Open [OpenCode](https://opencode.ai/) in a project folder and run:

```text
/onboarding
```

The wizard explains what Maestro can do, shows what is configured, and ends by offering to run a small real task on your repo — so your very first session produces something you can see.

Prefer the CLI? Enable Maestro features in any git repo:

```bash
cd ~/your-project
maestro init            # planning, git-workflow, code-quality, time-tracking
```

## 4. Try a real prompt

In OpenCode, just ask for the outcome — Maestro handles the plan, the branch, the tests, and the PR:

```text
Find and fix the most obvious bug in this repo, add a test, and open a pull request.
```

or

```text
Summarise what this project does and write a short README intro.
```

## What to explore next

| You want to… | Do this |
|---|---|
| See everything Maestro can do | `/onboarding`, or `maestro features` |
| Find the right capability for a task | `/skills recommend "TASK"` |
| Run the autonomous supervisor loop | `/pulse` |
| Track tasks and dependencies | `maestro init beads`, then `/ready` |
| Manage secrets safely | `maestro secret set NAME` |
| Run a full security check | `maestro security` |

## If something goes wrong

- **`maestro: command not found`** — restart your shell, or ensure the global npm/bun bin is on your `PATH`.
- **No models available** — re-run `maestro model-accounts-pool add <provider>` and restart OpenCode.
- **Agents look out of date** — run `maestro update`.
- **Anything else** — open a [discussion](https://github.com/Aditya060806/Maestro/discussions) or [issue](https://github.com/Aditya060806/Maestro/issues).

Full docs live in [`README.md`](README.md) and the [`.wiki/`](.wiki/) guides.
