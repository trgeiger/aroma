set-default-kargs:
  rpm-ostree kargs --append-if-missing="amd_pstate=active" --append-if-missing="modprobe.blacklist=sp5100_tco" --append-if-missing="modprobe.blacklist=iTCO_wdt" --append-if-missing="nowatchdog" --append-if-missing="preempt=full"

hidpi-tty:
  rpm-ostree kargs --append="vconsole.font=latarcyrheb-sun32"

install-starship:
  curl -sS https://starship.rs/install.sh | sh

change-shell:
  sudo lchsh -i
