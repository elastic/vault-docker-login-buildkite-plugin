#!/usr/bin/env bash
set -euo pipefail

if ! vault -v >/dev/null 2>&1; then
  echo "Could not find a vault cli to retrieve docker login secrets"
  exit 1
fi

if [[ "$BUILDKITE_PLUGIN_VAULT_DOCKER_LOGIN_SECRET_PATH" == kv* ]]; then
  VAULT_METHOD="kv get"
else
  # shellcheck disable=SC2034
  VAULT_METHOD="read"
fi
