#!/bin/sh

set -ouex pipefail

# install fonts
curl -sL $(curl -s https://api.github.com/repos/rsms/inter/releases | jq -r '.[0].assets[0].browser_download_url') -o /tmp/inter.zip && \
mkdir -p /tmp/inter /usr/share/fonts/inter && \
unzip /tmp/inter.zip -d /tmp/inter/ && \
mv /tmp/inter/*.ttf /tmp/inter/*.ttc /tmp/inter/LICENSE.txt /usr/share/fonts/inter/ && \
curl -sL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CommitMono.zip -o /tmp/commitmono-nerdfont.zip && \
mkdir -p /usr/share/fonts/commitmono-nerdfont && \
unzip /tmp/commitmono-nerdfont.zip -d /usr/share/fonts/commitmono-nerdfont && \
fc-cache -f /usr/share/fonts/inter && \
fc-cache -f /usr/share/fonts/commitmono-nerdfont

# install Starship shell prompt
curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz" && \
tar -xzf /tmp/starship.tar.gz -C /tmp && \
install -c -m 0755 /tmp/starship /usr/bin && \
echo 'eval "$(starship init bash)"' >> /etc/bashrc

# remove CLI app .desktop files and copr repos
rm -f /usr/share/applications/fish.desktop && \
rm -f /usr/share/applications/htop.desktop && \
rm -f /usr/share/applications/nvtop.desktop && \
rm -f /usr/share/applications/shredder.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.Terminal.desktop 
rm -rf /etc/yum.repos.d/_copr*

# add Flathub repo
mkdir -p /usr/etc/flatpak/remotes.d && \
wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /usr/etc/flatpak/remotes.d

# duperemove
wget https://gitlab.com/popsulfr/steamos-btrfs/-/raw/11114e4ff791eb2c385814c2fcbac6a83f144f35/files/usr/lib/systemd/system/btrfs-dedup@.service -O /usr/lib/systemd/system/btrfs-dedup@.service && \
wget https://gitlab.com/popsulfr/steamos-btrfs/-/raw/11114e4ff791eb2c385814c2fcbac6a83f144f35/files/usr/lib/systemd/system/btrfs-dedup@.timer -O /usr/lib/systemd/system/btrfs-dedup@.timer

# systemd
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
systemctl enable com.system76.Scheduler.service && \
systemctl enable dconf-update.service && \
systemctl enable ublue-system-flatpak-manager.service && \
systemctl --global enable ublue-user-flatpak-manager.service
systemctl enable btrfs-dedup@var-home.timer && \
systemctl disable rpm-ostreed-automatic.timer && \
systemctl enable ublue-update.timer && \
systemctl --global enable podman.socket && \
sed -i '/^PRETTY_NAME/s/Silverblue/Aroma/' /usr/lib/os-release
