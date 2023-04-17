ARG FEDORA_MAJOR_VERSION=38

FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_MAJOR_VERSION}

COPY etc /etc

# Add/activate repo files
RUN wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \ 
    wget https://copr.fedorainfracloud.org/coprs/calcastor/gnome-patched/repo/fedora-$(rpm -E %fedora)/calcastor-gnome-patched-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_calcastor-gnome-patched.repo && \
    wget https://copr.fedorainfracloud.org/coprs/hyperreal/better_fonts/repo/fedora-$(rpm -E %fedora)/hyperreal-better_fonts-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_hyperreal-better_fonts.repo && \
    wget https://copr.fedorainfracloud.org/coprs/nickavem/adw-gtk3/repo/fedora-$(rpm -E %fedora)/nickavem-adw-gtk3-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_nickavem-adw-gtk3.repo

# Install and override packages
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:calcastor:gnome-patched mutter && \
    rpm-ostree override remove gnome-classic-session && \
    rpm-ostree install libratbag-ratbagd zsh fontconfig-font-replacements adw-gtk3 system76-scheduler

# Cleanup and finishing touches
RUN rm -f /etc/yum.repos.d/_copr_*.repo && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-system-update.timer && \
    systemctl --global enable flatpak-user-update.timer && \
    systemctl enable com.system76.Scheduler.service && \
    ostree container commit
