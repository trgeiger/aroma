# vim: set ft=make :

# Set TTY font to a larger size for HiDPI monitors
hidpi-tty:
  rpm-ostree kargs --append="vconsole.font=latarcyrheb-sun32"

# Install the cross-shell Starship prompt
install-starship:
  curl -sS https://starship.rs/install.sh | sh

