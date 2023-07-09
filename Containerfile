ARG FEDORA_MAJOR_VERSION=38

FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_MAJOR_VERSION}

COPY etc /etc

# Add/activate repo files
#RUN wget https://copr.fedorainfracloud.org/coprs/calcastor/gnome-patched/repo/fedora-$(rpm -E %fedora)/calcastor-gnome-patched-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_calcastor-gnome-patched.repo && \
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    wget https://copr.fedorainfracloud.org/coprs/hyperreal/better_fonts/repo/fedora-$(rpm -E %fedora)/hyperreal-better_fonts-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_hyperreal-better_fonts.repo && \
    wget https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_bieszczaders-kernel-cachyos-fedora.repo

# Install and override packages
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter gnome-control-center gnome-control-center-filesystem xorg-x11-server-Xwayland && \
    rpm-ostree override remove kernel-devel-matched gnome-classic-session && \
    rpm-ostree install zsh fontconfig-font-replacements xrandr

RUN rpm-ostree cliwrap install-to-root / && \
    rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-extra --install kernel-cachyos-bore-lto --install kernel-cachyos-bore-lto-modules --install kernel-cachyos-bore-lto-core

# Add inter font, update dconf db, clear font cache
RUN curl -sL $(curl -s https://api.github.com/repos/rsms/inter/releases | jq -r '.[0].assets[0].browser_download_url') -o /tmp/inter.zip && \
    mkdir -p /tmp/inter /usr/share/fonts/inter && \
    unzip /tmp/inter.zip -d /tmp/inter/ && \
    mv /tmp/inter/*.ttf /tmp/inter/*.ttc /tmp/inter/LICENSE.txt /usr/share/fonts/inter/ && \
    curl -sL $(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases | jq -r '.[0].assets | map(select(.name == "CascadiaCode.zip"))[0].browser_download_url') -o /tmp/cascadiacode-nerdfont.zip && \
    mkdir -p /tmp/cascadiacode-nerdfont /usr/share/fonts/cascadiacode-nerdfont && \
    unzip /tmp/cascadiacode-nerdfont.zip -d /tmp/cascadiacode-nerdfont/ && \
    mv /tmp/cascadiacode-nerdfont/*.ttf /tmp/cascadiacode-nerdfont/LICENSE /usr/share/fonts/cascadiacode-nerdfont/ && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    fc-cache -f /usr/share/fonts/inter && \
    rm -rf /tmp/* /var* && mkdir -p /var/tmp && chmod -R 1777 /var/tmp


# Cleanup and finishing touches
RUN rm -f /etc/yum.repos.d/_copr_*.repo && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-system-update.timer && \
    systemctl --global enable flatpak-user-update.timer && \
#    systemctl enable com.system76.Scheduler.service && \
    ostree container commit
