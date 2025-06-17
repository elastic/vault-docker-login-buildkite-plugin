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

login() {
  local tool="$1"
  local username="$2"
  local password="$3"
  local hostname="$4"

  if [[ "$tool" == "docker" ]]; then
    docker_login "$username" "$password" "$hostname"
  elif [[ "$tool" == "buildah" ]]; then
    buildah_login "$username" "$password" "$hostname"
  elif [[ "$tool" == "cosign" ]]; then
    cosign_login "$username" "$password" "$hostname"
  elif [[ "$tool" == "crane" ]]; then
    crane_login "$username" "$password" "$hostname"
  elif [[ "$tool" == "podman" ]]; then
      podman_login "$username" "$password" "$hostname"
  elif [[ "$tool" == "skopeo" ]]; then
      skopeo_login "$username" "$password" "$hostname"
  fi
}

docker_login() {
  local username="$1"
  local password="$2"
  local hostname=$(docker_registry "$3")
  echo "Logging in to $hostname as $username with docker cli"
  docker login \
    --username "$username" \
    --password "$password" \
    "$hostname"
}

buildah_login() {
  local username="$1"
  local password="$2"
  local hostname="$3"

  echo "Logging in to $hostname as $username with buildah cli"
  buildah login --username "$username" --password "$password" "$hostname"
}

cosign_login() {
  local username="$1"
  local password="$2"
  local hostname="$3"

  echo "Logging in to $hostname as $username with cosign cli"
  cosign login --username "$username" --password "$password" "$hostname"
}

crane_login() {
  local username="$1"
  local password="$2"
  local hostname="$3"

  echo "Logging in to $hostname as $username with crane cli"
  crane auth login --username "$username" --password "$password" "$hostname"
}

podman_login() {
  local username="$1"
  local password="$2"
  local hostname="$3"

  echo "Logging in to $hostname as $username with podman cli"
  podman login --username "$username" --password "$password" "$hostname"
}

skopeo_login() {
  local username="$1"
  local password="$2"
  local hostname="$3"

  echo "Logging in to $hostname as $username with skopeo cli"
  skopeo login --username "$username" --password "$password" "$hostname"
}