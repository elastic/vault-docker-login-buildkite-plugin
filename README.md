# Vault Docker Login Buildkite Plugin

Log into docker/buildah with credentials stored in vault.

## Properties

| Name             | Description                                               | Required | Default        |
|------------------|-----------------------------------------------------------|----------|----------------|
| `secret_path`    | The Vault secret path with the user/pass/registry fields. | `true`   | ``             |
| `disable_logout` | Whether to logout after running the command.              | `false`  | `false`        |
| `retries`        | Number of times to retry a failed login attempt.          | `false`  | `3`            |
| `retry_delay`    | Base delay in seconds between retries; doubles with each retry (exponential backoff). | `false`  | `5`            |

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: ls
    plugins:
      - elastic/vault-docker-login#v0.7.0:
          secret_path: 'secret/ci/elastic-<<your-repo>>/container-registry/<<credentials>>'
          disable_logout: true
          retries: 3
          retry_delay: 5
```
