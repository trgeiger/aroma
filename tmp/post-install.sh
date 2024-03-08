#!/bin/sh

set -ouex pipefail

# install Starship shell prompt
curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz" && \
tar -xzf /tmp/starship.tar.gz -C /tmp && \
install -c -m 0755 /tmp/starship /usr/bin && \
echo 'eval "$(starship init bash)"' >> /etc/bashrc && \
echo 'eval "$(starship init zsh)"' >> /etc/zshrc

# modify and remove .desktop files, remove copr repos
rm -f /usr/share/applications/htop.desktop && \
rm -f /usr/share/applications/nvtop.desktop && \
rm -f /usr/share/applications/shredder.desktop && \
# TODO can't hide this until Ptyxis is back on system
#sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.Terminal.desktop  && \
sed -i 's@Name=tuned-gui@Name=TuneD Manager@g' /usr/share/applications/tuned-gui.desktop && \
rm -rf /etc/yum.repos.d/_copr*

# add Flathub repo
mkdir -p /usr/etc/flatpak/remotes.d && \
wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /usr/etc/flatpak/remotes.d

# duperemove
wget https://gitlab.com/popsulfr/steamos-btrfs/-/raw/11114e4ff791eb2c385814c2fcbac6a83f144f35/files/usr/lib/systemd/system/btrfs-dedup@.service -O /usr/lib/systemd/system/btrfs-dedup@.service && \
wget https://gitlab.com/popsulfr/steamos-btrfs/-/raw/11114e4ff791eb2c385814c2fcbac6a83f144f35/files/usr/lib/systemd/system/btrfs-dedup@.timer -O /usr/lib/systemd/system/btrfs-dedup@.timer