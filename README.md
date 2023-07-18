# Aroma

[![build-aroma](https://github.com/trgeiger/aroma/actions/workflows/build.yml/badge.svg)](https://github.com/trgeiger/aroma/actions/workflows/build.yml)

Silverblue customized with my personal base image preferences.

## Usage

    rpm-ostree rebase ostree-unverified-registry:ghcr.io/trgeiger/aroma:latest

The `latest` tag will automatically point to the latest build. 

## Features

- Start with a base Fedora Silverblue image
- Removes Firefox from the base image
- Adds the following packages to the base image:
  - zsh
  - Gnome with variable refresh rate patch (from COPR)

NEEDS UPDATE
