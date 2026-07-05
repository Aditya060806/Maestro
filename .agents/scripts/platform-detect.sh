#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
# platform-detect.sh — OS/platform detection and abstraction layer
#
# Usage (source this file):
#   source "$(dirname "${BASH_SOURCE[0]}")/platform-detect.sh"
#   echo "$MAESTRO_PLATFORM"   # macos | linux | wsl2 | windows-native
#   echo "$MAESTRO_SCHEDULER"  # launchd | systemd | cron
#
# Exported variables:
#   MAESTRO_PLATFORM         — macos | linux | wsl2 | windows-native
#   MAESTRO_SCHEDULER        — launchd | systemd | cron
#   MAESTRO_CLIPBOARD_COPY   — command to copy stdin to clipboard
#   MAESTRO_CLIPBOARD_PASTE  — command to paste clipboard to stdout
#   MAESTRO_OPEN_CMD         — command to open a URL or file
#   MAESTRO_FILE_SEARCH      — preferred file search command
#   MAESTRO_PKG_INSTALL      — package install command prefix (e.g. "brew install")
#
# Part of t1748: Linux/WSL2 platform support

# Shell safety baseline (guard against sourcing in strict-mode scripts)
# shellcheck disable=SC2034  # Variables are used by callers

_detect_linux_platform() {
	# Distinguish WSL2 from native Linux
	if grep -qi 'microsoft\|wsl' /proc/version 2>/dev/null; then
		MAESTRO_PLATFORM="wsl2"
	else
		MAESTRO_PLATFORM="linux"
	fi
	return 0
}

_detect_linux_scheduler() {
	# Scheduler: prefer systemd user services; fall back to cron
	if command -v systemctl >/dev/null 2>&1 && systemctl --user status >/dev/null 2>&1; then
		MAESTRO_SCHEDULER="systemd"
	else
		MAESTRO_SCHEDULER="cron"
	fi
	return 0
}

_detect_linux_clipboard() {
	# Clipboard: prefer xclip, then xsel, then wl-copy (Wayland), then clip.exe (WSL2)
	# Uses early-return pattern to avoid elif chains (reduces awk nesting depth count)
	MAESTRO_CLIPBOARD_COPY=""
	MAESTRO_CLIPBOARD_PASTE=""
	if command -v xclip >/dev/null 2>&1; then
		MAESTRO_CLIPBOARD_COPY="xclip -selection clipboard"
		MAESTRO_CLIPBOARD_PASTE="xclip -selection clipboard -o"
		return 0
	fi
	if command -v xsel >/dev/null 2>&1; then
		MAESTRO_CLIPBOARD_COPY="xsel --clipboard --input"
		MAESTRO_CLIPBOARD_PASTE="xsel --clipboard --output"
		return 0
	fi
	if command -v wl-copy >/dev/null 2>&1; then
		MAESTRO_CLIPBOARD_COPY="wl-copy"
		MAESTRO_CLIPBOARD_PASTE="wl-paste"
		return 0
	fi
	if [[ "$MAESTRO_PLATFORM" == "wsl2" ]] && command -v clip.exe >/dev/null 2>&1; then
		MAESTRO_CLIPBOARD_COPY="clip.exe"
		MAESTRO_CLIPBOARD_PASTE="powershell.exe -c Get-Clipboard"
		return 0
	fi
	return 0
}

_detect_linux_open_cmd() {
	# Open URL/file: prefer xdg-open, then wslview (WSL2 bridge)
	MAESTRO_OPEN_CMD=""
	if command -v xdg-open >/dev/null 2>&1; then
		MAESTRO_OPEN_CMD="xdg-open"
		return 0
	fi
	if [[ "$MAESTRO_PLATFORM" == "wsl2" ]] && command -v wslview >/dev/null 2>&1; then
		MAESTRO_OPEN_CMD="wslview"
		return 0
	fi
	return 0
}

_detect_linux_file_search() {
	# File search: prefer fd, then locate, then find
	MAESTRO_FILE_SEARCH="find"
	if command -v fd >/dev/null 2>&1; then
		MAESTRO_FILE_SEARCH="fd"
		return 0
	fi
	if command -v locate >/dev/null 2>&1; then
		MAESTRO_FILE_SEARCH="locate"
		return 0
	fi
	return 0
}

_detect_linux_pkg_manager() {
	# Package manager — early-return pattern to avoid elif chains
	MAESTRO_PKG_INSTALL=""
	if command -v apt-get >/dev/null 2>&1; then
		MAESTRO_PKG_INSTALL="sudo apt-get install -y"
		return 0
	fi
	if command -v brew >/dev/null 2>&1; then
		MAESTRO_PKG_INSTALL="brew install"
		return 0
	fi
	if command -v dnf >/dev/null 2>&1; then
		MAESTRO_PKG_INSTALL="sudo dnf install -y"
		return 0
	fi
	if command -v pacman >/dev/null 2>&1; then
		MAESTRO_PKG_INSTALL="sudo pacman -S --noconfirm"
		return 0
	fi
	if command -v apk >/dev/null 2>&1; then
		MAESTRO_PKG_INSTALL="sudo apk add"
		return 0
	fi
	return 0
}

_detect_macos() {
	MAESTRO_PLATFORM="macos"
	MAESTRO_SCHEDULER="launchd"
	MAESTRO_CLIPBOARD_COPY="pbcopy"
	MAESTRO_CLIPBOARD_PASTE="pbpaste"
	MAESTRO_OPEN_CMD="open"
	MAESTRO_FILE_SEARCH="mdfind"
	MAESTRO_PKG_INSTALL="brew install"
	return 0
}

_detect_windows() {
	MAESTRO_PLATFORM="windows-native"
	MAESTRO_SCHEDULER="cron"
	MAESTRO_CLIPBOARD_COPY="clip"
	MAESTRO_CLIPBOARD_PASTE="powershell -c Get-Clipboard"
	MAESTRO_OPEN_CMD="start"
	MAESTRO_FILE_SEARCH="find"
	MAESTRO_PKG_INSTALL=""
	return 0
}

_detect_unknown() {
	MAESTRO_PLATFORM="unknown"
	MAESTRO_SCHEDULER="cron"
	MAESTRO_CLIPBOARD_COPY=""
	MAESTRO_CLIPBOARD_PASTE=""
	MAESTRO_OPEN_CMD=""
	MAESTRO_FILE_SEARCH="find"
	MAESTRO_PKG_INSTALL=""
	return 0
}

_maestro_detect_platform() {
	local _kernel
	_kernel="$(uname -s 2>/dev/null || echo "unknown")"

	case "$_kernel" in
	Darwin)
		_detect_macos
		;;
	Linux)
		_detect_linux_platform
		_detect_linux_scheduler
		_detect_linux_clipboard
		_detect_linux_open_cmd
		_detect_linux_file_search
		_detect_linux_pkg_manager
		;;
	MINGW* | MSYS* | CYGWIN*)
		_detect_windows
		;;
	*)
		_detect_unknown
		;;
	esac

	export MAESTRO_PLATFORM MAESTRO_SCHEDULER
	export MAESTRO_CLIPBOARD_COPY MAESTRO_CLIPBOARD_PASTE
	export MAESTRO_OPEN_CMD MAESTRO_FILE_SEARCH MAESTRO_PKG_INSTALL
	return 0
}

# Run detection immediately on source
_maestro_detect_platform

# Clipboard helper: copy stdin to clipboard (platform-agnostic)
# Usage: echo "text" | maestro_clipboard_copy
# Returns 0 on success, 1 if no clipboard tool available
maestro_clipboard_copy() {
	if [[ -z "$MAESTRO_CLIPBOARD_COPY" ]]; then
		return 1
	fi
	# shellcheck disable=SC2086  # intentional word splitting for multi-word commands
	$MAESTRO_CLIPBOARD_COPY
	return $?
}

# Clipboard helper: paste clipboard to stdout (platform-agnostic)
# Usage: maestro_clipboard_paste
# Returns 0 on success, 1 if no clipboard tool available
maestro_clipboard_paste() {
	if [[ -z "$MAESTRO_CLIPBOARD_PASTE" ]]; then
		return 1
	fi
	# shellcheck disable=SC2086  # intentional word splitting for multi-word commands
	$MAESTRO_CLIPBOARD_PASTE
	return $?
}

# Open a URL or file (platform-agnostic)
# Usage: maestro_open "https://example.com"
# Returns 0 on success, 1 if no open command available
maestro_open() {
	local target="$1"
	if [[ -z "$MAESTRO_OPEN_CMD" ]]; then
		return 1
	fi
	# shellcheck disable=SC2086  # intentional word splitting for multi-word commands
	$MAESTRO_OPEN_CMD "$target"
	return $?
}

# When run directly (not sourced), print detected platform info
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "MAESTRO_PLATFORM=$MAESTRO_PLATFORM"
	echo "MAESTRO_SCHEDULER=$MAESTRO_SCHEDULER"
	echo "MAESTRO_CLIPBOARD_COPY=$MAESTRO_CLIPBOARD_COPY"
	echo "MAESTRO_CLIPBOARD_PASTE=$MAESTRO_CLIPBOARD_PASTE"
	echo "MAESTRO_OPEN_CMD=$MAESTRO_OPEN_CMD"
	echo "MAESTRO_FILE_SEARCH=$MAESTRO_FILE_SEARCH"
	echo "MAESTRO_PKG_INSTALL=$MAESTRO_PKG_INSTALL"
fi
