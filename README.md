# Vault Docker Login Buildkite Plugin

Log into docker/buildah with credentials stored in vault.

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: ls
    plugins:
      - elastic/vault-docker-login#v0.3.0:
          secret_path: 'secret/ci/elastic-<<your-repo>>/container-registry/<<credentials>>'
```
