#!/usr/bin/env bats

setup () {
  load "${BATS_PLUGIN_PATH}/load.bash"
  # NOTE: If you need to debug the docker and vault command output,
  #             you can uncomment the code below:
  # export DOCKER_STUB_DEBUG=/dev/tty
  # export VAULT_STUB_DEBUG=/dev/tty

  stub vault \
    "exit 0" \
    "kv get -field=username \* : echo username" \
    "kv get -field=password \* : echo password" \
    "kv get -field=hostname \* : echo hostname"

  stub docker \
    "--version : exit 0" \
    "login --username username --password password hostname : exit 0"
}

@test "Clean login execution with kv" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with docker cli'
}
