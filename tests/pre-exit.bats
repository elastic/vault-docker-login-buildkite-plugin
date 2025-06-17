#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"
load '../lib/shared'
load '../lib/logout'

# NOTE: If you need to debug the docker and vault command output,
#             you can uncomment the code below:
#export DOCKER_STUB_DEBUG=/dev/tty
#export BUILDAH_STUB_DEBUG=/dev/tty

setup () {
  export REGISTRY_HOSTNAME="registry.example.com"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL=""
}

@test "docker logout" {
  stub docker \
    "--version : exit 0" \
    "logout registry.example.com : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with docker cli'
}

@test "No cli available (default case)" {
  stub rm \
    "exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'No cli is available to auth. Delete creds from /root/.docker/config.json'
}

@test "When disable logout is turned on" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_DISABLE_LOGOUT="true"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'WARNING: not logging out'
}

@test "buildah" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 0" \
    "logout registry.example.com : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with buildah'
}

@test "crane" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 1"

  stub crane \
    "version : exit 0" \
    "auth logout registry.example.com : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with crane'
}

@test "cosign" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 1"

  stub crane \
    "version : exit 1"

  stub cosign \
    "version : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'WARNING: logging out not supported for cosign cli'
}

@test "podman" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 1"

  stub crane \
    "version : exit 1"

  stub cosign \
    "version : exit 1"

  stub podman \
    "version : exit 0" \
    "logout registry.example.com : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with podman'
}

@test "skopeo" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 1"

  stub crane \
    "version : exit 1"

  stub cosign \
    "version : exit 1"

  stub podman \
    "version : exit 1"

  stub skopeo \
    "version : exit 0" \
    "logout registry.example.com : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with skopeo'
}

@test "tool buildah" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "logout registry.example.com : exit 0"

  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL="buildah"
  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with buildah cli'
}
