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
}

teardown() {
  unstub vault || true
  unstub docker || true
  unstub sleep || true
}

@test "Clean login execution with kv" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"

  stub docker \
    "--version : exit 0" \
    "login --username username --password-stdin hostname : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with docker cli'
}

@test "Login retries on failure and eventually succeeds" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRIES="2"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRY_DELAY="0"

  stub docker \
    "--version : exit 0" \
    "login --username username --password-stdin hostname : exit 1" \
    "login --username username --password-stdin hostname : exit 0"

  stub sleep "0 : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Login attempt 1/3 failed, retrying in 0 seconds...'
}

@test "Login fails after all retries exhausted" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRIES="2"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRY_DELAY="0"

  stub docker \
    "--version : exit 0" \
    "login --username username --password-stdin hostname : exit 1" \
    "login --username username --password-stdin hostname : exit 1" \
    "login --username username --password-stdin hostname : exit 1"

  stub sleep \
    "0 : exit 0" \
    "0 : exit 0"

  run "$PWD/hooks/pre-command"

  assert_failure
  assert_output --partial 'Login failed after 3 attempt(s)'
}

@test "No retries when retries is set to 0" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRIES="0"

  stub docker \
    "--version : exit 0" \
    "login --username username --password-stdin hostname : exit 1"

  run "$PWD/hooks/pre-command"

  assert_failure
  assert_output --partial 'Login failed after 1 attempt(s)'
}
