#!/usr/bin/env bats

setup () {
  load "${BATS_PLUGIN_PATH}/load.bash"
  # export DOCKER_STUB_DEBUG=/dev/tty
}

@test "Clean logout execution" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_DISABLE_LOGOUT='false'

  stub docker \
    "echo got \$# args \$@"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'got 1 args logout'

  unstub docker
}

@test "Server can be set" {
  export REGISTRY_HOSTNAME="my-server"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_DISABLE_LOGOUT='false'

  stub docker \
    "echo got \$# args \$@"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'got 2 args logout my-server'

  unstub docker
}

@test "When disable logout is turned on, file is not removed" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_DISABLE_LOGOUT='true'

  stub docker \
    "echo got \$# args \$@"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'WARNING: not logging out'
  refute_output --partial 'got 1 args logout'
}
