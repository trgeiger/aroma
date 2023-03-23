ARG FEDORA_MAJOR_VERSION=37

#FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

COPY etc /etc

# Add/activate repo files
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \ 
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    wget https://copr.fedorainfracloud.org/coprs/hyperreal/better_fonts/repo/fedora-$(rpm -E %fedora)/hyperreal-better_fonts-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_hyperreal-better_fonts.repo && \
    wget https://copr.fedorainfracloud.org/coprs/nickavem/adw-gtk3/repo/fedora-$(rpm -E %fedora)/nickavem-adw-gtk3-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_nickavem-adw-gtk3.repo

# Add VSCode repo
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo && rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Install and override packages
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter gnome-control-center gnome-control-center-filesystem && \
    rpm-ostree override remove gnome-classic-session && \
    rpm-ostree install libratbag-ratbagd zsh distrobox fontconfig-font-replacements code adw-gtk3 system76-scheduler

# Cleanup and finishing touches
RUN rm -f /etc/yum.repos.d/_copr_*.repo && \
    rm -f /etc/yum.repos.d/vscode.repo && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-system-update.timer && \
    systemctl --global enable flatpak-user-update.timer && \
    systemctl enable com.system76.Scheduler.service && \
    ostree container commit
