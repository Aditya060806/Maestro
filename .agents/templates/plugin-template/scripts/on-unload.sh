#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
# =============================================================================
# Plugin Unload Hook — {{PLUGIN_NAME}}
# =============================================================================
# Runs when the plugin is disabled or removed.
# Use this for cleanup: removing temp files, revoking registrations, etc.
#
# Environment variables available:
#   MAESTRO_PLUGIN_NAMESPACE  Plugin namespace
#   MAESTRO_PLUGIN_DIR        Plugin directory path
#   MAESTRO_AGENTS_DIR        Root agents directory
#   MAESTRO_HOOK              "unload"
# =============================================================================

set -euo pipefail

main() {
    # shellcheck disable=SC2034  # plugin_dir available for user's hook logic
    local plugin_dir="${MAESTRO_PLUGIN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
    local namespace="${MAESTRO_PLUGIN_NAMESPACE:-{{NAMESPACE}}}"

    echo "[${namespace}] Unload hook running..."

    # Example: clean up temp files
    # rm -rf "$HOME/.maestro/.agent-workspace/tmp/${namespace}-*" 2>/dev/null || true

    echo "[${namespace}] Unload complete"
    return 0
}

main "$@"
