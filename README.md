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

## Features

### Aroma
- Built on top of [ublue-os/main](https://github.com/ublue-os/main)
- Removes:
  - firefox and firefox-langpacks (in favor of Flatpak installation)
  - gnome-classic-session
  - gnome-tour
  - yelp
- Adds:
  - zsh
  - fish
  - Variable refresh rate patches for Gnome (from COPR)
  - tldr
  - system76-scheduler for desktop responsiveness
  - xrandr
  - Inter font for general interface
  - Intel One Mono patched Nerd Font (set as default monospace)
  - Cascadia Code patched Nerd Font
  - [yafti](https://github.com/ublue-os/yafti) with custom selection of suggested packages
    - yafti will also set all flatpaks to be installed as user
  - just with custom justfile
    - `just change-shell` to change to fish or zsh
    - `just hidpi-tty` to increase tty font size for hidpi screens
    - `just install-starship` to install [starship.rs](starship.rs/)
    - `just install-gnome-extensions` to install suggested gnome extensions
      - alphabetical app grid
      - scroll workspaces on top panel
      - s76-scheduler gnome integration
      - replace-activities-label gnome experiment

 
### Aroma Cloud Dev
- Built on top of Aroma
- Removes:
  - Variable refresh rate patches for Gnome
- Adds:
  - Gnome mutter triplebuffering patch
  - VSCode natively installed
  - qemu, libvirt, and virt-manager
  - awscli
  - OpenShift and Kubernetes tools:
    - oc
    - opm
    - kubectl
    - operator-sdk
    - odo
    - helm
    - crc / OpenShift Local
