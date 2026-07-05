#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
# =============================================================================
# Plugin Init Hook — {{PLUGIN_NAME}}
# =============================================================================
# Runs once when the plugin is first installed or updated.
# Use this for one-time setup: creating config files, checking dependencies, etc.
#
# Environment variables available:
#   MAESTRO_PLUGIN_NAMESPACE  Plugin namespace
#   MAESTRO_PLUGIN_DIR        Plugin directory path
#   MAESTRO_AGENTS_DIR        Root agents directory
#   MAESTRO_HOOK              "init"
# =============================================================================

set -euo pipefail

main() {
    # shellcheck disable=SC2034  # plugin_dir available for user's hook logic
    local plugin_dir="${MAESTRO_PLUGIN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
    local namespace="${MAESTRO_PLUGIN_NAMESPACE:-{{NAMESPACE}}}"

    echo "[${namespace}] Init hook running..."

    # Example: ensure config directory exists
    # local config_dir="$HOME/.config/maestro"
    # mkdir -p "$config_dir"

    # Example: check for required tools
    # if ! command -v some-tool &>/dev/null; then
    #     echo "[${namespace}] Warning: some-tool not found"
    # fi

    echo "[${namespace}] Init complete"
    return 0
}

main "$@"
