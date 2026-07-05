#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
# =============================================================================
# Shared GitHub collaborator permission lookup helper
# =============================================================================

[[ -n "${_SHARED_GH_COLLABORATOR_PERMISSION_LOADED:-}" ]] && return 0
_SHARED_GH_COLLABORATOR_PERMISSION_LOADED=1

_MAESTRO_GH_PERMISSION_UNKNOWN_VALUE="unknown"

#######################################
# Look up a repository collaborator permission through App-aware REST routing.
#
# Auth selection stays in _rest_api_call/github_app_api_call: GitHub App
# installation auth is preferred when configured, with normal gh/PAT fallback.
# Callers can inspect the status globals after a non-zero return to distinguish
# transient lookup failures from confirmed non-collaborators.
#
# Globals written:
#   MAESTRO_GH_COLLAB_PERMISSION_HTTP
#   MAESTRO_GH_COLLAB_PERMISSION_REASON
#
# Args: $1=repo_slug owner/repo, $2=user login, $3=optional output variable
# Output: permission value (admin|maintain|write|triage|read|none) on lookup success.
# Returns: 0=lookup succeeded (404 maps to none), 2=lookup/API/parse failure.
#######################################
_gh_collaborator_permission_lookup() {
	local repo_slug="$1"
	local user="$2"
	local out_var="${3:-}"
	local perm_url="/repos/${repo_slug}/collaborators/${user}/permission"
	local api_response=""
	local rc=0
	local http_status=""
	local line=""
	local body=""
	local in_body=0
	local permission_value=""

	MAESTRO_GH_COLLAB_PERMISSION_HTTP="$_MAESTRO_GH_PERMISSION_UNKNOWN_VALUE"
	MAESTRO_GH_COLLAB_PERMISSION_REASON="$_MAESTRO_GH_PERMISSION_UNKNOWN_VALUE"
	export MAESTRO_GH_COLLAB_PERMISSION_HTTP MAESTRO_GH_COLLAB_PERMISSION_REASON

	if [[ -z "$repo_slug" || -z "$user" ]]; then
		MAESTRO_GH_COLLAB_PERMISSION_REASON="missing-argument"
		export MAESTRO_GH_COLLAB_PERMISSION_REASON
		return 2
	fi

	api_response=$(_rest_api_call read gh api -i "$perm_url" 2>&1)
	rc=$?
	while IFS= read -r line; do
		line="${line%$'\r'}"
		case "$line" in
		HTTP/*)
			http_status="${line#* }"
			http_status="${http_status%% *}"
			;;
		"")
			in_body=1
			;;
		\{* | \[* )
			in_body=1
			body="${body}${line}"$'\n'
			;;
		*)
			if [[ "$in_body" -eq 1 ]]; then
				body="${body}${line}"$'\n'
			fi
			;;
		esac
	done <<<"$api_response"

	[[ -n "$http_status" ]] && MAESTRO_GH_COLLAB_PERMISSION_HTTP="$http_status"
	export MAESTRO_GH_COLLAB_PERMISSION_HTTP

	if [[ "$http_status" == "404" ]]; then
		MAESTRO_GH_COLLAB_PERMISSION_REASON="not-collaborator"
		export MAESTRO_GH_COLLAB_PERMISSION_REASON
		if [[ -n "$out_var" ]]; then
			printf -v "$out_var" '%s' "none"
		else
			printf '%s\n' "none"
		fi
		return 0
	fi

	if [[ "$rc" -ne 0 ]]; then
		MAESTRO_GH_COLLAB_PERMISSION_REASON="api-failure"
		export MAESTRO_GH_COLLAB_PERMISSION_REASON
		return 2
	fi

	if [[ "$http_status" != "200" ]]; then
		MAESTRO_GH_COLLAB_PERMISSION_REASON="unexpected-http"
		export MAESTRO_GH_COLLAB_PERMISSION_REASON
		return 2
	fi

	permission_value=$(printf '%s' "$body" | jq -r '.permission // .role_name // ""' 2>/dev/null) || permission_value=""
	if [[ -z "$permission_value" ]]; then
		permission_value=$(printf '%s' "$api_response" | sed -nE 's/^[[:space:]]*\{?[[:space:]]*"(permission|role_name)"[[:space:]]*:[[:space:]]*"(admin|maintain|write|triage|read|none)".*/\2/p' | tail -1) || permission_value=""
	fi
	case "$permission_value" in
	admin | maintain | write | triage | read | none)
		MAESTRO_GH_COLLAB_PERMISSION_REASON="ok"
		export MAESTRO_GH_COLLAB_PERMISSION_REASON
		if [[ -n "$out_var" ]]; then
			printf -v "$out_var" '%s' "$permission_value"
		else
			printf '%s\n' "$permission_value"
		fi
		return 0
		;;
	*)
		MAESTRO_GH_COLLAB_PERMISSION_REASON="malformed-response"
		export MAESTRO_GH_COLLAB_PERMISSION_REASON
		return 2
		;;
	esac
}

#######################################
# Verify the authenticated GitHub user may write repo state.
#
# Public issue comments can succeed for non-collaborators, so callers must not
# infer authorization from a successful write. This guard checks the current
# auth identity against the collaborator permission API before any automated
# comment, close, label, approval, merge, or dispatch claim.
#
# Globals written:
#   MAESTRO_GH_WRITE_PERMISSION_USER
#   MAESTRO_GH_WRITE_PERMISSION_LEVEL
#   MAESTRO_GH_WRITE_PERMISSION_REASON
#
# Args: $1=repo_slug owner/repo
# Returns: 0=admin/maintain/write, 1=read/triage/none/unknown/failure.
#######################################
_gh_current_user_allows_repo_write() {
	local repo_slug="$1"
	local current_user=""
	local current_permission=""

	MAESTRO_GH_WRITE_PERMISSION_USER=""
	MAESTRO_GH_WRITE_PERMISSION_LEVEL="$_MAESTRO_GH_PERMISSION_UNKNOWN_VALUE"
	MAESTRO_GH_WRITE_PERMISSION_REASON="$_MAESTRO_GH_PERMISSION_UNKNOWN_VALUE"
	export MAESTRO_GH_WRITE_PERMISSION_USER MAESTRO_GH_WRITE_PERMISSION_LEVEL MAESTRO_GH_WRITE_PERMISSION_REASON

	if [[ -z "$repo_slug" ]]; then
		MAESTRO_GH_WRITE_PERMISSION_REASON="missing-repo"
		export MAESTRO_GH_WRITE_PERMISSION_REASON
		return 1
	fi

	# #maestro:trust-boundary — do not cache this lookup. Long-running pulse
	# sessions can rotate GH_TOKEN/OAuth accounts between writes; a stale owner
	# login would authorize a later non-collaborator token.
	current_user=$(gh api user --jq '.login // ""') || current_user=""
	MAESTRO_GH_WRITE_PERMISSION_USER="$current_user"
	export MAESTRO_GH_WRITE_PERMISSION_USER
	if [[ -z "$current_user" ]]; then
		MAESTRO_GH_WRITE_PERMISSION_REASON="current-user-lookup-failed"
		export MAESTRO_GH_WRITE_PERMISSION_REASON
		return 1
	fi

	if ! _gh_collaborator_permission_lookup "$repo_slug" "$current_user" current_permission; then
		MAESTRO_GH_WRITE_PERMISSION_LEVEL="$_MAESTRO_GH_PERMISSION_UNKNOWN_VALUE"
		MAESTRO_GH_WRITE_PERMISSION_REASON="permission-lookup-failed:${MAESTRO_GH_COLLAB_PERMISSION_REASON:-$_MAESTRO_GH_PERMISSION_UNKNOWN_VALUE}"
		export MAESTRO_GH_WRITE_PERMISSION_LEVEL MAESTRO_GH_WRITE_PERMISSION_REASON
		return 1
	fi

	MAESTRO_GH_WRITE_PERMISSION_LEVEL="$current_permission"
	export MAESTRO_GH_WRITE_PERMISSION_LEVEL
	case "$current_permission" in
	admin | maintain | write)
		MAESTRO_GH_WRITE_PERMISSION_REASON="allowed"
		export MAESTRO_GH_WRITE_PERMISSION_REASON
		return 0
		;;
	*)
		MAESTRO_GH_WRITE_PERMISSION_REASON="insufficient-permission:${current_permission:-none}"
		export MAESTRO_GH_WRITE_PERMISSION_REASON
		return 1
		;;
	esac
}
