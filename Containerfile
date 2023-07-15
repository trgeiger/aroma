ARG BASE_IMAGE="quay.io/fedora-ostree-desktops/silverblue"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS taydora
#FROM quay.io/fedora-ostree-desktops/silverblue:38 as taydora
# ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

COPY etc /etc
COPY usr /usr

ADD packages.json /tmp/packages.json
ADD install.sh /tmp/install.sh
ADD post_install.sh /tmp/post_install.sh

COPY --from=ghcr.io/ublue-os/config:latest /rpms /tmp/rpms

RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    wget https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_cachyos.repo && \
    wget https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-addons/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-addons-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_cachy_os_addons.repo

# Overrides
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter gnome-control-center gnome-control-center-filesystem xorg-x11-server-Xwayland
RUN rpm-ostree cliwrap install-to-root / && \
    rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra --install kernel-cachyos-bore

RUN /tmp/install.sh
RUN /tmp/post_install.sh
RUN rm -rf /tmp/* /var/*
RUN ostree container commit
RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp
