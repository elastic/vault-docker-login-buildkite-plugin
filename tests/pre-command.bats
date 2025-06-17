#!/usr/bin/env bats

setup () {
  load "${BATS_PLUGIN_PATH}/load.bash"
  # NOTE: If you need to debug the docker and vault command output,
  #             you can uncomment the code below:
  # export DOCKER_STUB_DEBUG=/dev/tty
  # export VAULT_STUB_DEBUG=/dev/tty
  export COMMAND_STUB_DEBUG=/dev/tty

  stub vault \
    "exit 0" \
    "kv get -field=username \* : echo username" \
    "kv get -field=password \* : echo password" \
    "kv get -field=hostname \* : echo hostname"

  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
}

@test "Clean login execution with kv" {
  stub docker \
    "exit 0" \
    "login \* : exit 0"

  stub command \
    "\* : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with docker cli'
}

@test "buildah" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"

  stub buildah \
    "login \* : exit 0" \
    "\* : exit 0"

  stub command \
    "-v docker : exit 1" \
    "-v buildah : exit 0" \
    "\* : exit 1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with buildah'
}
