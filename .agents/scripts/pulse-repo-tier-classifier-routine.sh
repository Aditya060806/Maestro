#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
# pulse-repo-tier-classifier-routine.sh — Hourly tier-classifier routine (t2831)
#
# Standalone runner for the per-repo activity tier classification.
# Runs hourly under launchd (sh.maestro.repo-tier-classify plist).
# Calls pulse-repo-tier.sh classify to refresh ~/.maestro/cache/pulse-repo-tiers.json.
#
# Architecture: identical to complexity-scan-runner.sh — independent file-based
# lock so the classifier never overlaps itself and never blocks pulse dispatch.
#
# Usage:
#   pulse-repo-tier-classifier-routine.sh [run]   Run the classification (default)
#   pulse-repo-tier-classifier-routine.sh help     Show usage
#
# Lock:    ~/.maestro/.agent-workspace/locks/repo-tier-classify.lock
# Log:     ~/.maestro/logs/repo-tier-classify.log
# Cache:   ~/.maestro/cache/pulse-repo-tiers.json
#
# Part of maestro framework: https://maestro.sh

set -euo pipefail

# PATH normalisation for launchd/cron environments where PATH is minimal.
_maestro_path_prefix="/opt/homebrew/bin:/usr/local/bin:/bin:/usr/bin"
if [[ "$(uname -s 2>/dev/null || true)" != "Darwin" && -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
	_maestro_path_prefix="/opt/homebrew/bin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin:/bin:/usr/bin"
fi
export PATH="${_maestro_path_prefix}:${PATH}"
unset _maestro_path_prefix

# SCRIPT_DIR resolution — uses BASH_SOURCE[0]:-$0 for zsh portability (GH#3931).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

LOCK_DIR="${HOME}/.maestro/.agent-workspace/locks/repo-tier-classify.lock"
RUNNER_LOG="${HOME}/.maestro/logs/repo-tier-classify.log"
TIER_SCRIPT="${SCRIPT_DIR}/pulse-repo-tier.sh"

_usage() {
	cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]:-$0}") [run|help]

  run    Run the tier classification (default when called by launchd)
  help   Show this message

This script is normally invoked by launchd every hour. It acquires a
mkdir-based lock to prevent overlapping runs, then calls pulse-repo-tier.sh
classify to refresh the tier cache.
EOF
	return 0
}

cmd_run() {
	echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] repo-tier-classify: starting" >>"$RUNNER_LOG"

	# Ensure lock directory exists
	local lock_parent
	lock_parent="${LOCK_DIR%/*}"
	[[ -d "$lock_parent" ]] || mkdir -p "$lock_parent" 2>/dev/null || true

	# Acquire mkdir-based lock (POSIX atomic on local FS)
	if ! mkdir "$LOCK_DIR" 2>/dev/null; then
		echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] repo-tier-classify: already running (lock held), skipping" >>"$RUNNER_LOG"
		return 0
	fi

	# Register cleanup on exit
	# shellcheck disable=SC2064
	trap "rmdir '$LOCK_DIR' 2>/dev/null || true" EXIT

	if [[ ! -x "$TIER_SCRIPT" ]]; then
		echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] repo-tier-classify: ERROR: ${TIER_SCRIPT} not found or not executable" >>"$RUNNER_LOG"
		return 1
	fi

	local start_ts end_ts elapsed
	start_ts=$(date +%s)

	"$TIER_SCRIPT" classify >>"$RUNNER_LOG" 2>&1 || {
		echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] repo-tier-classify: classify exited non-zero (see above)" >>"$RUNNER_LOG"
	}

	end_ts=$(date +%s)
	elapsed=$((end_ts - start_ts))
	echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] repo-tier-classify: done in ${elapsed}s" >>"$RUNNER_LOG"
	return 0
}

main() {
	local cmd="${1:-run}"
	case "$cmd" in
		run)
			cmd_run
			;;
		help|--help|-h)
			_usage
			;;
		*)
			echo "[repo-tier-classify] Unknown command: ${cmd}" >&2
			_usage >&2
			return 1
			;;
	esac
	return 0
}

main "$@"
