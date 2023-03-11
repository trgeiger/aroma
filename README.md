# Taydora

[![build-taydora](https://github.com/trgeiger/taydora/actions/workflows/build.yml/badge.svg)](https://github.com/trgeiger/taydora/actions/workflows/build.yml)

Silverblue customized with my personal base image preferences.

## Usage

    rpm-ostree rebase ostree-unverified-registry:ghcr.io/trgeiger/taydora:latest

The `latest` tag will automatically point to the latest build. 

## Features

- Start with a base Fedora Silverblue 37 image
- Removes Firefox from the base image
- Adds the following packages to the base image:
  - distrobox
  - vim
  - zsh
  - libratbag-ratbagd (for Piper mouse configuration app)
  - VSCode from the official Microsoft repo
  - fontconfig-font-replacements (from COPR)
  - Gnome with variable refresh rate patch (from COPR)
