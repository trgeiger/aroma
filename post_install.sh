#!/bin/sh

set -ouex pipefail

# install yafti
pip install --prefix=/usr yafti && \

# install fonts
curl -sL $(curl -s https://api.github.com/repos/rsms/inter/releases | jq -r '.[0].assets[0].browser_download_url') -o /tmp/inter.zip && \
mkdir -p /tmp/inter /usr/share/fonts/inter && \
unzip /tmp/inter.zip -d /tmp/inter/ && \
mv /tmp/inter/*.ttf /tmp/inter/*.ttc /tmp/inter/LICENSE.txt /usr/share/fonts/inter/ && \
curl -sL $(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases | jq -r '.[0].assets | map(select(.name == "CascadiaCode.zip"))[0].browser_download_url') -o /tmp/cascadiacode-nerdfont.zip && \
mkdir -p /tmp/cascadiacode-nerdfont /usr/share/fonts/cascadiacode-nerdfont && \
unzip /tmp/cascadiacode-nerdfont.zip -d /tmp/cascadiacode-nerdfont/ && \
mv /tmp/cascadiacode-nerdfont/*.ttf /tmp/cascadiacode-nerdfont/LICENSE /usr/share/fonts/cascadiacode-nerdfont/ && \
fc-cache -f /usr/share/fonts/inter && \
fc-cache -f /usr/share/fonts/intelonemono-nerdfont && \

# install Starship shell prompt
curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz" && \
  tar -xzf /tmp/starship.tar.gz -C /tmp && \
  install -c -m 0755 /tmp/starship /usr/bin && \
  echo 'eval "$(starship init bash)"' >> /etc/bashrc

# remove CLI app .desktop files and copr repos
rm -f /usr/share/applications/fish.desktop && \
rm -f /usr/share/applications/htop.desktop && \
rm -f /usr/share/applications/nvtop.desktop && \
rm -rf /etc/yum.repos.d/_copr_*

# enable systemd units
systemctl unmask dconf-update.service && \
systemctl enable dconf-update.service && \
systemctl enable rpm-ostreed-automatic.timer && \
systemctl enable flatpak-system-update.timer && \
systemctl --global enable flatpak-user-update.timer && \
systemctl enable com.system76.Scheduler.service
