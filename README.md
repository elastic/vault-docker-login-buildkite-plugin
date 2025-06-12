# Vault Docker Login Buildkite Plugin

Log into docker/buildah with credentials stored in vault.

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: ls
    plugins:
      - elastic/vault-docker-login#v0.5.2:
          secret_path: 'secret/ci/elastic-<<your-repo>>/container-registry/<<credentials>>'
          tool: 'docker' # leave it empty or remove it to keep the backward compatibility
```
