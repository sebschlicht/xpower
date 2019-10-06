#!/bin/bash

# Checks whether a certain package is installed.
#
# Params:
# 1. (string) package name
# Returns: (int) non-zero value if the specified package is installed
fc_is_package_installed ()
{
  local STATUS=$( dpkg -s "$1" | grep '^Status' | grep 'ok installed' )
  if [ -z "$STATUS" ]; then
    return 1
  fi
}

# install tlp and supporting packages
#sudo apt-get install tlp tlp-rdw smartmontools ethtool

# install pm-utils
if ! fc_is_package_installed 'pm-utils'; then
  sudo apt-get install pm-utils
fi
# install brightnessctl
if ! fc_is_package_installed 'brightnessctl'; then
  sudo apt-get install brightnessctl
fi

# install related scripts to toggle screen brightness
sudo install pm/00-screen-brightness /etc/pm/sleep.d
sudo install pm/00-screen-brightness /etc/pm/power.d

# copy example configuration file
CFGDIR=~/.config/xpower
if [ ! -e "$CFGDIR" ]; then
  mkdir "$CFGDIR"
fi
cp config/brightness "$CFGDIR"/

# copy udev rules to execute pm-powersave when chainging the battery status
sudo cp udev/rules.d/99-powersave.rules /etc/udev/rules.d/
sudo udevadm control --reload
