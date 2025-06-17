#!/usr/bin/env bash
set -eo pipefail

logout() {
  local tool="$1"
  local hostname="$2"

  if [[ "$tool" == "docker" ]]; then
    docker_logout "$hostname"
  elif [[ "$tool" == "buildah" ]]; then
    buildah_logout "$hostname"
  elif [[ "$tool" == "cosign" ]]; then
    cosign_logout "$hostname"
  elif [[ "$tool" == "crane" ]]; then
    crane_logout "$hostname"
  elif [[ "$tool" == "podman" ]]; then
    podman_logout "$hostname"
  elif [[ "$tool" == "skopeo" ]]; then
    skopeo_logout "$hostname"
  fi
}

docker_logout() {
  local hostname
hostname=$(docker_registry "$1")
  echo "Logging out to $hostname with docker cli"
  docker logout "$hostname"
}

buildah_logout() {
  local hostname
hostname=$(docker_registry "$1")
  echo "Logging out to $hostname with buildah cli"
  buildah logout "$hostname"
}

cosign_logout() {
  local hostname
hostname=$(docker_registry "$1")
  echo 'WARNING: logging out not supported for cosign cli'
}

crane_logout() {
  local hostname
hostname=$(docker_registry "$1")
  echo "Logging out to $hostname with crane cli"
  crane auth logout "$hostname"
}

podman_logout() {
  local hostname
hostname=$(docker_registry "$1")
  echo "Logging out to $hostname with podman cli"
  podman logout "$hostname"
}

skopeo_logout() {
  local hostname
hostname=$(docker_registry "$1")
  echo "Logging out to $hostname with skopeo cli"
  skopeo logout "$hostname"
}
