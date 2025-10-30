#!/usr/bin/env bats

setup () {
  load "${BATS_PLUGIN_PATH}/load.bash"
  # export DOCKER_STUB_DEBUG=/dev/tty

  # Add vault stub for pre-exit tests
  stub vault \
    "-v : exit 0" \
    "kv get -field=hostname \* : echo registry.example.com"

  export REGISTRY_HOSTNAME="registry.example.com"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
}

@test "Clean logout execution" {
  stub docker \
    "exit 0" \
    "logout \* : exit 0"

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

@test "Skopeo" {
  stub skopeo \
    "exit 0" \
    "logout \* : exit 0"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'Logging out to registry.example.com with skopeo cli'
}

@test "When disable logout is turned on" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_DISABLE_LOGOUT="true"

  run "$PWD/hooks/pre-exit"

  assert_success
  assert_output --partial 'WARNING: not logging out'
}
