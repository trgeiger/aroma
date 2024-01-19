# vim: set ft=make :

hidpi-tty:
  rpm-ostree kargs --append="vconsole.font=latarcyrheb-sun32"

install-starship:
  curl -sS https://starship.rs/install.sh | sh

