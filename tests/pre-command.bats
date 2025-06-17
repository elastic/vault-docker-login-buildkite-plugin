#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"
load '../lib/shared'

# NOTE: If you need to debug the docker and vault command output,
#             you can uncomment the code below:
export DOCKER_STUB_DEBUG=/dev/tty
#export VAULT_STUB_DEBUG=/dev/tty
#export BUILDAH_STUB_DEBUG=/dev/tty
export CRANE_STUB_DEBUG=/dev/tty
setup () {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
  stub vault \
    "exit 0" \
    "kv get -field=username \* : echo username" \
    "kv get -field=password \* : echo password" \
    "kv get -field=hostname \* : echo hostname"
}

@test "docker" {
  stub docker \
    "--version : exit 0" \
    "login --username username --password password hostname : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with docker cli'
}

@test "buildah" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 0" \
    "login --username username --password password hostname : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with buildah'
}

@test "crane" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 1"

  stub crane \
    "version : exit 0" \
    "auth login --username username --password password hostname : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with crane'
}

@test "cosign" {
  stub docker \
    "--version : exit 1"

  stub buildah \
    "--version : exit 1"

  stub crane \
    "version : exit 1"

  stub cosign \
    "version : exit 0" \
    "login --username username --password password hostname : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with cosign'
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
    "login --username username --password password hostname : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with podman'
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
    "login --username username --password password hostname : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with skopeo'
}

@test "no cli available" {
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
    "version : exit 1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'No cli is available to auth'
}
