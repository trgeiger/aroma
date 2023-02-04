ARG FEDORA_MAJOR_VERSION=37

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

#COPY etc /etc

#COPY ublue-firstboot /usr/bin
#Copy udev rules
COPY --from=ghcr.io/ublue-os/udev-rules etc/udev/rules.d/* /etc/udev/rules.d

# Add Copr repo files
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo
RUN wget https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_bieszczaders-kernel-cachyos-fedora.repo
RUN wget https://copr.fedorainfracloud.org/coprs/hyperreal/better_fonts/repo/fedora-$(rpm -E %fedora)/hyperreal-better_fonts-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_hyperreal-better_fonts.repo

# Add VSCode repo
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo && rpm --import https://packages.microsoft.com/keys/microsoft.asc

RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter gnome-control-center gnome-control-center-filesystem
RUN rpm-ostree cliwrap install-to-root /
RUN rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-extra --install kernel-cachyos-bore-lto --install kernel-cachyos-bore-lto-modules --install kernel-cachyos-bore-lto-core

RUN rpm-ostree override remove firefox firefox-langpacks && \
    rpm-ostree install libratbag-ratbagd vim zsh distrobox fontconfig-font-replacements code && \
    rm -f /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    rm -f /etc/yum.repos.d/_copr_bieszczaders-kernel-cachyos-fedora.repo && \
    rm -f /etc/yum.repos.d/_copr_hyperreal-better_fonts.repo && \
    rm -f /etc/yum.repos.d/vscode.repo && \
    ostree container commit
