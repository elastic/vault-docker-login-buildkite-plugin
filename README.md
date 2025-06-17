# Vault Docker Login Buildkite Plugin

Log into docker/buildah with credentials stored in vault.

## Properties

| Name             | Description                                                                         | Required | Default        |
|------------------|-------------------------------------------------------------------------------------|----------|----------------|
| `secret_path`    | The Vault secret path with the user/pass/registry fields.                           | `true`   | ``             |
| `disable_logout` | Whether to logout after running the command.                                        | `false`  | `false`        |
| `tool`           | What container login tool to use. If empty, then it will try docker and other tools | `false`  | ``             |

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: ls
    plugins:
      - elastic/vault-docker-login#v0.5.2:
          secret_path: 'secret/ci/elastic-<<your-repo>>/container-registry/<<credentials>>'
          disable_logout: true
          tool: 'docker' # leave it empty or remove it to keep the backward compatibility
```
