#!/usr/bin/env bash
set -eo pipefail

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
  local hostname
hostname=$(docker_registry "$3")
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