install-gnome-extensions:
  pip install --upgrade gnome-extensions-cli
  gext install replace-activities-label@leleat-on-github
  gext install AlphabeticalAppGrid@stuarthayhurst
  gext install io.github.mreditor.gnome-shell-extensions.scroll-panel

set-default-kargs:
  rpm-ostree kargs --append="amd_pstate=active" --append="modprobe.blacklist=sp5100_tco" --append="modprobe.blacklist=iTCO_wdt" --append="nowatchdog" --append="vconsole.font=latarcyrheb-sun32"
