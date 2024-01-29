ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS aroma

ARG IMAGE_NAME="${IMAGE_NAME:-aroma}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

COPY etc /etc
COPY usr /usr
COPY tmp /tmp
COPY usr/etc/ublue-update/ublue-update.toml /tmp/ublue-update.toml

# Add custom repos
RUN wget https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-$(rpm -E %fedora)/ublue-os-staging-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ublue-os-staging.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-$(rpm -E %fedora)/kylegospo-gnome-vrr-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/prompt/repo/fedora-$(rpm -E %fedora)/kylegospo-prompt-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-prompt.repo && \
    wget https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-$(rpm -E %fedora)/che-nerd-fonts-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_che-nerd-fonts-$(rpm -E %fedora).repo

# Install kernel-fsync
RUN wget https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/repo/fedora-$(rpm -E %fedora)/sentry-kernel-fsync-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_sentry-kernel-fsync.repo && \
    rpm-ostree cliwrap install-to-root / && \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:sentry:kernel-fsync \
        kernel \
        kernel-core \
        kernel-modules \
        kernel-modules-core \
        kernel-modules-extra

# Add ublue akmods, add needed negativo17 repo and then immediately disable due to incompatibility with RPMFusion
COPY --from=ghcr.io/ublue-os/akmods:fsync-${FEDORA_MAJOR_VERSION} /rpms /tmp/akmods-rpms
RUN sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    wget https://negativo17.org/repos/fedora-multimedia.repo -O /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    rpm-ostree install \
        /tmp/akmods-rpms/kmods/*xpadneo*.rpm \
        /tmp/akmods-rpms/kmods/*xone*.rpm \
        /tmp/akmods-rpms/kmods/*openrazer*.rpm \
        /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm \
        /tmp/akmods-rpms/kmods/*wl*.rpm \
        /tmp/akmods-rpms/kmods/*gcadapter_oc*.rpm \
        /tmp/akmods-rpms/kmods/*nct6687*.rpm \
        /tmp/akmods-rpms/kmods/*evdi*.rpm \
        /tmp/akmods-rpms/kmods/*wl*.rpm \
        /tmp/akmods-rpms/kmods/*zenergy*.rpm \
        /tmp/akmods-rpms/kmods/*ryzen-smu*.rpm && \
    rm -rf /etc/yum.repos.d/negativo*

# removals
RUN rpm-ostree override remove \
        firefox \
        firefox-langpacks \
        ublue-os-update-services

# additions
RUN rpm-ostree install \
        jq \
        edid-decode \
        zsh \
        python3-pip \
        libadwaita \
        duperemove \
        xrandr \
        rmlint \
        system76-scheduler \
        unrar \
        vulkan-tools \
        setools \
        rsms-inter-fonts \
        jetbrains-mono-fonts \
        fira-code-fonts \
        cascadia-code-fonts \
        nerd-fonts

# gnome stuff
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:prompt \
        vte291 \
        vte-profile && \
    rpm-ostree install \
        prompt && \
    rpm-ostree install \
        nautilus-open-any-terminal \
        gnome-epub-thumbnailer \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-system76-scheduler \
        gnome-shell-extension-just-perfection && \
    rpm-ostree override remove \
        gnome-software-rpm-ostree \
        gnome-extensions-app \
        gnome-tour \
        gnome-classic-session \
        gnome-terminal-nautilus \
        yelp

# Gaming-specific changes
RUN if [[ "${IMAGE_NAME}" == "aroma" ]]; then \
        # Gnome VRR
        rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr \
            mutter \
            mutter-common \
            gnome-control-center \
            gnome-control-center-filesystem && \

        rpm-ostree install \
            steam \
            gamescope \
            mangohud \
            vkBasalt && \
        rpm-ostree override remove \
            gamemode \
            gnome-shell-extension-gamemode \
    ; fi

# run post-install tasks and clean up
RUN mkdir -p /usr/share/ublue-os && \
    pip install --prefix=/usr topgrade && \
    rpm-ostree install ublue-update && \
    /tmp/post-install.sh && \
    /tmp/image-info.sh && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
    cp /tmp/ublue-update.toml /usr/etc/ublue-update/ublue-update.toml && \
    cp /tmp/80-aroma.just /usr/share/ublue-os/just/80-aroma.just && \
    systemctl enable com.system76.Scheduler.service && \
    systemctl enable dconf-update.service && \
    systemctl enable ublue-system-flatpak-manager.service && \
    systemctl --global enable ublue-user-flatpak-manager.service && \
    systemctl enable btrfs-dedup@var-home.timer && \
    systemctl disable rpm-ostreed-automatic.timer && \
    systemctl enable ublue-update.timer && \
    systemctl --global enable podman.socket && \
    echo "import \"/usr/share/ublue-os/just/80-aroma.just\"" >> /usr/share/ublue-os/justfile && \
    sed -i '/^PRETTY_NAME/s/Silverblue/Aroma/' /usr/lib/os-release && \
    rm -rf /tmp/* /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    ostree container commit


# cloud development build
FROM aroma as aroma-cloud-dev

ARG IMAGE_NAME="${IMAGE_NAME:-aroma-cloud-dev}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

# Gnome patched with triple buffering
RUN if [[ "${IMAGE_NAME}" == "aroma-cloud-dev" ]]; then \
        wget https://copr.fedorainfracloud.org/coprs/trixieua/mutter-patched/repo/fedora-$(rpm -E %fedora)/trixieua-mutter-patched-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_gnome-triplebuffering.repo && \
        rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:trixieua:mutter-patched \
        gnome-shell \
        mutter \
        mutter-common \
        xorg-x11-server-Xwayland \
    ; fi

# Install Openshift tools -- oc, opm, kubectl, operator-sdk, odo, helm, crc
RUN export VER=$(curl --silent -qI https://github.com/operator-framework/operator-sdk/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}') && \
  wget https://github.com/operator-framework/operator-sdk/releases/download/$VER/operator-sdk_linux_amd64 -O /usr/bin/operator-sdk && \
  chmod +x /usr/bin/operator-sdk
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar xvzf - -C /usr/bin
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/opm-linux.tar.gz | tar xvzf - -C /usr/bin
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/latest/helm-linux-amd64 -o /usr/bin/helm && chmod +x /usr/bin/helm
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/odo/latest/odo-linux-amd64 -o /usr/bin/odo && chmod +x /usr/bin/odo
RUN curl -SL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/crc/latest/crc-linux-amd64.tar.xz | tar xfJ - --strip-components 1 -C /usr/bin

# Install awscli
RUN curl -SL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/bin --install-dir /usr/bin

# VSCode repo
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo && rpm --import https://packages.microsoft.com/keys/microsoft.asc

RUN rpm-ostree install \
        code \
        qemu \
        libvirt \
        virt-manager && \
        rm -f /var/lib/unbound/root.key

RUN rm -f /etc/yum.repos.d/vscode.repo && \
    rm -f /etc/yum.repos.d/_copr_* && \
    rm -f get_helm.sh && \
    rm -rf aws && \
    rm -f awscliv2.zip && \
    rm -f /usr/bin/README.md && \
    rm -f /usr/bin/LICENSE && \
    rm -rf /tmp/* /var/* && \
    sed -i '/^PRETTY_NAME/s/Aroma/Aroma Cloud Dev/' /usr/lib/os-release && \
    ostree container commit
