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
  local tool_version="$1"

  # If BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL is not set, check if tool exists and version check passes
  if [[ -z "$BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL" ]]; then
    # First check if the command exists
    if $tool_version >/dev/null 2>&1; then
      return 0  # true
    fi
  fi
  
  return 1  # false
}

docker_registry() {
  local hostname="$1"
  # For dockerhub we must unset the hostname argument during login
  # for credentials to be stored correctly in .docker/config.json
  # See: https://elasticco.atlassian.net/browse/REL-1195
  if [ "$hostname" == "index.docker.io" ]; then
    hostname=""
  fi
  echo "$hostname"
}
