# Taydora

[![build-taydora](https://github.com/trgeiger/taydora/actions/workflows/build.yml/badge.svg)](https://github.com/trgeiger/taydora/actions/workflows/build.yml)

A base image with a (mostly) stock Fedora Silverblue. Help us make a sweet base image: Pull requests and improvements appreciated and encouraged!   

## Usage

Warning: This is an experimental feature and should not be used in production, try it in a VM for a while, you have been warned!

    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/trgeiger/taydora:latest
    
We build date tags as well, so if you want to rebase to a particular day's release:
  
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/trgeiger/taydora:20221217 

The `latest` tag will automatically point to the latest build. 

## Features

- Start with a base Fedora Silverblue 37 image
- Removes Firefox from the base image
- Adds the following packages to the base image:
  - distrobox and gnome-tweaks

## Applications


## Further Customization
  
## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/ublue-os/base
    
If you're forking this repo you should [read the docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets) on keeping secrets in github. You need to [generate a new keypair](https://docs.sigstore.dev/cosign/overview/) with cosign. The public key can be in your public repo (your users need it to check the signatures), and you can paste the private key in Settings -> Secrets -> Actions.
