#!/usr/bin/env bats

setup () {
  load "${BATS_PLUGIN_PATH}/load.bash"
  # NOTE: If you need to debug the docker and vault command output,
  #             you can uncomment the code below:
  #export DOCKER_STUB_DEBUG=/dev/tty
  export BUILDAH_STUB_DEBUG=/dev/tty

  export REGISTRY_HOSTNAME="registry.example.com"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_TOOL=""
}

@test "Clean logout execution" {
  unstub docker
  stub docker \
    "exit 0" \
    "logout \* : exit 0" \
    "--version : exit 0"

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

  unstub rm
}

@test "Buildah" {
  stub docker \
    " \* : exit 1" \
    "--version : exit 1"

  stub buildah \
    "--version : exit 0" \
    "logout \* : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with buildah cli'

  unstub buildah
}

@test "When disable logout is turned on" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_DISABLE_LOGOUT="true"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'WARNING: not logging out'
}
