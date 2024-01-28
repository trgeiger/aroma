#!/bin/sh

set -ouex pipefail

# Install non-packaged fonts
curl -sL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CommitMono.zip -o /tmp/commitmono-nerdfont.zip && \
mkdir -p /usr/share/fonts/commitmono-nerdfont && \
unzip /tmp/commitmono-nerdfont.zip -d /usr/share/fonts/commitmono-nerdfont && \
curl -sL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Monaspace.zip -o /tmp/monaspace-nerdfont.zip && \
mkdir -p /usr/share/fonts/monaspace-nerdfont && \
unzip /tmp/monaspace-nerdfont.zip -d /usr/share/fonts/monaspace-nerdfont && \
fc-cache -f /usr/share/fonts/commitmono-nerdfont && \
fc-cache -f /usr/share/fonts/monaspace-nerdfont

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