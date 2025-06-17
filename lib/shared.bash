#!/usr/bin/env bash
set -eo pipefail

# Checks whether a specific tool is available based on the current environment
# or configuration.
#
# Usage:
#   Call this function before executing commands that depend on the tool.
#
# Returns:
#   0 (success) if the tool should be used, 1 (failure) otherwise.
is_tool_available() {
  local tool_name="$1"
  local tool_version="$2"

  # If BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL is set and matches the tool, use it
  if [[ "${BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL:=}" == "$tool_name" ]]; then
    return 0  # true
  fi

  # If BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL is not set, check if tool exists and version check passes
  if [[ -z "$BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL" ]]; then
    # First check if the command exists
    if $tool_version >/dev/null 2>&1; then
      return 0  # true
    fi
  fi
  
  return 1  # false
}