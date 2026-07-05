#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
# =============================================================================
# maestro Version Library
# =============================================================================
# Shared version-finding logic used by maestro-update-check.sh and
# log-issue-helper.sh. Source this file rather than duplicating the logic.
#
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/version.sh"
#        local ver; ver=$(maestro_find_version)

# VERSION file locations - checked in order of preference:
# 1. Deployed agents directory (setup.sh copies here for all install methods)
# 2. Legacy location (some older installs)
# 3. Source repo containing this library (CI / secondary checkout friendly)
# 4. Source repo for developers working from a Git clone
MAESTRO_VERSION_FILE_AGENTS="${HOME}/.maestro/agents/VERSION"
MAESTRO_VERSION_FILE_LEGACY="${HOME}/.maestro/VERSION"
MAESTRO_VERSION_FILE_DEV="${HOME}/Git/maestro/VERSION"
MAESTRO_UNKNOWN_VERSION="${MAESTRO_UNKNOWN_VERSION:-unknown}"

maestro_repo_version_file() {
	local lib_dir
	lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || {
		printf '%s' ""
		return 0
	}
	local repo_version="${lib_dir}/../../../VERSION"
	if [[ -r "$repo_version" ]]; then
		printf '%s' "$repo_version"
	else
		printf '%s' ""
	fi
	return 0
}

maestro_read_version_file() {
	local version_file="$1"
	local version=""
	if [[ -r "$version_file" ]]; then
		IFS= read -r version <"$version_file" || version=""
		version=$(printf '%s' "$version" | tr -d '[:space:]')
	fi
	printf '%s' "$version"
	return 0
}

# maestro_find_version - print the local maestro version string, or "unknown"
#
# Checks three locations in priority order. Uses -r (readable) rather than -f
# (exists) so that cat never fails under set -e on permission-denied files.
maestro_find_version() {
	local version_file version
	for version_file in \
		"$MAESTRO_VERSION_FILE_AGENTS" \
		"$MAESTRO_VERSION_FILE_LEGACY" \
		"$(maestro_repo_version_file)" \
		"$MAESTRO_VERSION_FILE_DEV"; do
		[[ -n "$version_file" ]] || continue
		version=$(maestro_read_version_file "$version_file")
		if [[ -n "$version" ]]; then
			printf '%s\n' "$version"
			return 0
		fi
	done
	printf '%s\n' "$MAESTRO_UNKNOWN_VERSION"
	return 0
}

maestro_display_version() {
	local version="$1"
	if [[ -n "$version" && "$version" != "$MAESTRO_UNKNOWN_VERSION" ]]; then
		printf 'v%s' "$version"
	else
		printf '%s' "$MAESTRO_UNKNOWN_VERSION"
	fi
	return 0
}

# maestro_signature_footer - generate the signature footer for GitHub content
#
# Usage: body="${body}$(maestro_signature_footer)"
#        body="${body}$(maestro_signature_footer --issue owner/repo#42)"
#        body="${body}$(maestro_signature_footer --issue owner/repo#42 --solved)"
#
# Passes all arguments through to gh-signature-helper.sh footer.
# Auto-detects model from ANTHROPIC_MODEL / CLAUDE_MODEL env vars.
# Returns empty string if the helper is not available (graceful degradation).
maestro_signature_footer() {
	local helper_dir
	helper_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." 2>/dev/null && pwd)"
	local helper="${helper_dir}/gh-signature-helper.sh"

	# Fallback to deployed location
	if [[ ! -x "$helper" ]]; then
		helper="${HOME}/.maestro/agents/scripts/gh-signature-helper.sh"
	fi

	if [[ ! -x "$helper" ]]; then
		return 0
	fi

	# Auto-detect model from environment
	local model_arg=""
	local model="${ANTHROPIC_MODEL:-${CLAUDE_MODEL:-}}"
	if [[ -n "$model" ]]; then
		model_arg="--model ${model}"
	fi

	# shellcheck disable=SC2086
	"$helper" footer $model_arg "$@" 2>/dev/null || true
	return 0
}
