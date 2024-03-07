ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH}"
#ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME}"
ARG BASE_IMAGE="quay.io/fedora-ostree-desktops/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS aroma

ARG IMAGE_NAME="${IMAGE_NAME:-aroma}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

COPY etc /etc
COPY usr /usr
COPY tmp /tmp
COPY rpms /tmp/rpms

# Add custom repos
RUN wget https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-$(rpm -E %fedora)/ublue-os-staging-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_ublue-os-staging.repo && \
    wget https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_kylegospo-system76-scheduler.repo && \
    wget https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/repo/fedora-$(rpm -E %fedora)/sentry-switcheroo-control_discrete-fedora-$(rpm -E %fedora).repo -O /etc/yum.repos.d/_copr_sentry-switcheroo-control_discrete.repo

RUN rpm-ostree install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Update packages that commonly cause build issues
RUN rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        vulkan-loader \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        alsa-lib \
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
        gtk3 \
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
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libdecor \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libtirpc \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libuuid \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libblkid \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libmount \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        cups-libs \
        || true && \
    rpm-ostree override remove \
        glibc32 \
        || true

# Install Valve's patched Mesa
# Install patched switcheroo control with proper discrete GPU support
RUN rpm-ostree install \
        mesa-va-drivers-freeworld \
        mesa-vdpau-drivers-freeworld.x86_64 && \
    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:sentry:switcheroo-control_discrete \
        switcheroo-control

# removals
RUN rpm-ostree override remove \
        firefox \
        firefox-langpacks && \
    rpm-ostree override remove \
        power-profiles-daemon \
        || true && \
    rpm-ostree override remove \
        tlp \
        tlp-rdw \
        || true

# additions in ublue-os main
RUN rpm-ostree override remove \
        default-fonts-cjk-sans \
        google-noto-sans-cjk-vf-fonts \
        libavcodec-free \
        libavfilter-free \
        libavformat-free \
        libavutil-free \
        libpostproc-free \
        libswresample-free \
        libswscale-free \
        mesa-va-drivers && \
    rpm-ostree install \
        bootc \
        distrobox \
        vim \
        zsh \
        alsa-firmware \
        ffmpeg \
        ffmpeg-libs \
        ffmpegthumbnailer \
        fzf \
        grub2-tools-extra \
        heif-pixbuf-loader \
        htop \
        just \
        kernel-tools \
        libheif-freeworld \
        libheif-tools \
        libratbag-ratbagd \
        lshw \
        mesa-va-drivers-freeworld.x86_64 \
        net-tools \
        nvme-cli \
        nvtop \
        openssl \
        pipewire-codec-aptx \
        smartmontools \
        solaar-udev \
        symlinks \
        zstd  \
        adw-gtk3-theme \
        gnome-epub-thumbnailer \
        gnome-tweaks \
        gvfs-nfs \

# additions
        tuned \
        tuned-ppd \
        tuned-utils \
        tuned-gtk \
        tuned-profiles-atomic \
        tuned-profiles-cpu-partitioning \
        powertop \
        jq \
        edid-decode \
        zsh \
        patch \
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
        mesa-libGLU \
        vulkan-tools && \
    mkdir -p /usr/share/ublue-os && \
    pip install --prefix=/usr topgrade && \
    rpm-ostree install \
        ublue-update && \
    sed -i '1s/^/[include]\npaths = ["\/etc\/ublue-os\/topgrade.toml"]\n\n/' /usr/share/ublue-update/topgrade-user.toml && \
    sed -i 's/min_battery_percent.*/min_battery_percent = 20.0/' /usr/etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_cpu_load_percent.*/max_cpu_load_percent = 100.0/' /usr/etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_mem_percent.*/max_mem_percent = 90.0/' /usr/etc/ublue-update/ublue-update.toml && \
    sed -i 's/dbus_notify.*/dbus_notify = false/' /usr/etc/ublue-update/ublue-update.toml && \
    # Install patched fonts from Terra then remove repo
    wget https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -O /etc/yum.repos.d/terra.repo && \
    rpm-ostree install \
        cascadiacode-nerd-fonts \
        maple-fonts && \
    rm -rf /etc/yum.repos.d/terra.repo

# gnome stuff
RUN rpm-ostree install \
        gnome-epub-thumbnailer \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-system76-scheduler && \
    rpm-ostree override remove \
        gnome-software-rpm-ostree \
        gnome-tour \
        gnome-classic-session \
        gnome-terminal-nautilus \
        yelp && \
    rpm-ostree override replace \
        /tmp/rpms/*.rpm

# Gaming-specific changes
RUN if [[ "${IMAGE_NAME}" == "aroma" ]]; then \
    rpm-ostree override remove \
        glibc32 && \
    rpm-ostree install \
        clinfo \
        gamescope \
        vkBasalt \
        mangohud \
        steam \
        mesa-vulkan-drivers.i686 \
        mesa-va-drivers-freeworld.i686 && \
    rpm-ostree override remove \
        gamemode \
    ; fi

# run post-install tasks and clean up
RUN /tmp/post-install.sh && \
    /tmp/image-info.sh && \
    sed -i 's@Name=tuned-gui@Name=TuneD Manager@g' /usr/share/applications/tuned-gui.desktop && \
    systemctl enable com.system76.Scheduler.service && \
    systemctl enable tuned.service && \
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
