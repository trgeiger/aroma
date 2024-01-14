ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"
ARG TARGET_BASE="${TARGET_BASE:-aroma}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS aroma

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"
ARG PACKAGE_LIST="aroma"

COPY etc /etc
COPY usr /usr
COPY just /tmp/just
COPY packages.json /tmp/packages.json
COPY build.sh /tmp/build.sh
COPY post-install.sh /tmp/post-install.sh



RUN rpm-ostree cliwrap install-to-root / && \
    wget https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_cachyos-kernel.repo && \
    rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra --install kernel-cachyos

# Add custom repos
RUN wget https://copr.fedorainfracloud.org/coprs/ublue-os/bling/repo/fedora-$(rpm -E %fedora)/ublue-os-bling-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ublue-os-bling.repo && \
    wget https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/repo/fedora-$(rpm -E %fedora)/kylegospo-bazzite-multilib-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-gnome-vrr-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/prompt/repo/fedora-$(rpm -E %fedora)/kylegospo-prompt-fedora-$(rpm -E %fedora).repo?arch=x86_64 -O /etc/yum.repos.d/_copr_kylegospo-prompt.repo

RUN rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        vulkan-loader \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gnutls \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        glib2 \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        atk \
        at-spi2-atk \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libaom \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gstreamer1 \
        gstreamer1-plugins-base \
        gstreamer1-plugins-bad-free-libs \
        gstreamer1-plugins-good-qt \
        gstreamer1-plugins-good \
        gstreamer1-plugins-bad-free \
        gstreamer1-plugin-libav \
        gstreamer1-plugins-ugly-free \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        python3 \
        python3-libs \
        || true && \
    rpm-ostree override remove \
        glibc32 \
        || true

# Install gamescope-limiter patched Mesa
RUN rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
        mesa-filesystem \
        mesa-dri-drivers \
        mesa-libEGL \
        mesa-libEGL-devel \
        mesa-libgbm \
        mesa-libGL \
        mesa-libglapi \
        mesa-vulkan-drivers \
        mesa-libOSMesa \
        bluez \
        bluez-cups \
        bluez-libs \
        bluez-obexd

# power-profiles-daemon temporary fix and Gnome VRR
RUN rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging power-profiles-daemon && \
    rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr \
        mutter \
        mutter-common \
        gnome-control-center \
        gnome-control-center-filesystem && \
    rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:prompt \
        vte291 \
        vte-profile && \
    rpm-ostree install \
        prompt

RUN rpm-ostree override remove \
    firefox \
    firefox-langpacks \
    gnome-classic-session \
    gnome-tour \
    gnome-software-rpm-ostree \
    yelp \
    ublue-os-update-services

RUN rpm-ostree install \
    zsh \
    duperemove \
    xrandr \
    glibc.i686 \
    vulkan-tools \
    glibc.i686 \
    unrar \
    setools \
    gnome-shell-extension-system76-scheduler \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-just-perfection

RUN rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        pipewire \
        pipewire-alsa \
        pipewire-gstreamer \
        pipewire-jack-audio-connection-kit \
        pipewire-jack-audio-connection-kit-libs \
        pipewire-libs \
        pipewire-pulseaudio \
        pipewire-utils \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gnutls \
        || true && \
    rpm-ostree install \
        vulkan-loader.i686 \
        alsa-lib.i686 \
        fontconfig.i686 \
        gtk2.i686 \
        libICE.i686 \
        libnsl.i686 \
        libxcrypt-compat.i686 \
        libpng12.i686 \
        libXext.i686 \
        libXinerama.i686 \
        libXtst.i686 \
        libXScrnSaver.i686 \
        NetworkManager-libnm.i686 \
        nss.i686 \
        pulseaudio-libs.i686 \
        libcurl.i686 \
        systemd-libs.i686 \
        libva.i686 \
        libvdpau.i686 \
        libdbusmenu-gtk3.i686 \
        libatomic.i686 \
        pipewire-alsa.i686 \
        clinfo && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree-steam.repo && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree.repo && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/fedora-updates.repo && \
    rpm-ostree install \
        steam && \
    sed -i '0,/enabled=1/s//enabled=0/' /etc/yum.repos.d/rpmfusion-nonfree-steam.repo && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree.repo && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo && \
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/fedora-updates.repo && \
    rpm-ostree install \
        wxGTK \
        libFAudio \
        wine-core.x86_64 \
        wine-core.i686 \
        wine-pulseaudio.x86_64 \
        wine-pulseaudio.i686 \
        winetricks \
        protontricks \
        vkBasalt.x86_64 \
        vkBasalt.i686 \
        mangohud.x86_64 \
        mangohud.i686 \
        gamescope.x86_64 \
        gamescope-libs.i686 \
        gperftools-libs.i686

RUN /tmp/post-install.sh
RUN rm -rf /tmp/* /var/*
RUN ostree container commit
RUN mkdir -p /var/tmp && chmod -R 1777 /var/tmp

# cloud development build
FROM aroma as aroma-cloud-dev

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-39}"

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
RUN curl -SL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && unzip awscliv2.zip && ./aws/install --bin-dir /usr/bin --install-dir /usr/bin

# VSCode repo
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo && rpm --import https://packages.microsoft.com/keys/microsoft.asc

RUN rpm-ostree install code qemu libvirt virt-manager && rm -f /var/lib/unbound/root.key && \
    rpm-ostree override remove \
        steam \
        vkBasalt.x86_64 \
        vkBasalt.i686 \
        mangohud.x86_64 \
        mangohud.i686 \
        gamescope.x86_64 \
        gamescope-libs.i686 && \
    rm -f /etc/yum.repos.d/vscode.repo && \
    rm -f /etc/yum.repos.d/_copr_* && \
    rm -f get_helm.sh && \
    rm -rf aws && \
    rm -f awscliv2.zip && \
    rm -f /usr/bin/README.md && \
    rm -f /usr/bin/LICENSE && \
    rm -rf /tmp/* /var/* && \
    ostree container commit
