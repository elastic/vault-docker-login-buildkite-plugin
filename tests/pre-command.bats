#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031  # export inside bats @test subshells is intentional

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
  unstub buildah || true
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
  assert_output --partial 'Login attempt 1/3 failed, retrying in 0 second(s)...'
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

@test "Exponential backoff doubles the delay on each retry" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRIES="3"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRY_DELAY="1"

  # 4 total attempts (1 initial + 3 retries); login succeeds on the 4th
  stub docker \
    "--version : exit 0" \
    "login --username username --password-stdin hostname : exit 1" \
    "login --username username --password-stdin hostname : exit 1" \
    "login --username username --password-stdin hostname : exit 1" \
    "login --username username --password-stdin hostname : exit 0"

  # Delays: 1*2^0=1s, 1*2^1=2s, 1*2^2=4s
  stub sleep \
    "1 : exit 0" \
    "2 : exit 0" \
    "4 : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Login attempt 1/4 failed, retrying in 1 second(s)...'
  assert_output --partial 'Login attempt 2/4 failed, retrying in 2 second(s)...'
  assert_output --partial 'Login attempt 3/4 failed, retrying in 4 second(s)...'
}

@test "Retry logic applies to buildah cli" {
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH="kv/data/docker-login"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRIES="1"
  export BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_RETRY_DELAY="0"

  stub buildah \
    "--version : exit 0" \
    "login --username username --password-stdin hostname : exit 1" \
    "login --username username --password-stdin hostname : exit 0"

  stub sleep "0 : exit 0"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial 'Logging in to hostname as username with buildah cli'
  assert_output --partial 'Login attempt 1/2 failed, retrying in 0 second(s)...'
}
