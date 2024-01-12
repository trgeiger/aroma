# Aroma

[![build-aroma](https://github.com/trgeiger/aroma/actions/workflows/build.yml/badge.svg)](https://github.com/trgeiger/aroma/actions/workflows/build.yml)

Silverblue customized with my personal base image preferences.

## Usage
To rebase to either Aroma or Aroma Cloud Dev:
```console
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/trgeiger/aroma:latest
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/trgeiger/aroma-cloud-dev:latest
```

The `latest` tag will automatically point to the latest build. 