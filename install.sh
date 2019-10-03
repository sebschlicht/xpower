#!/bin/bash

# ask user whether to proceed if display type unknown
source pm/00-screen-brightness
if ! fc_detect_display_type 1>/dev/null; then
  echo 'Unknown display type detected, xpower will not work with your system.'
  read -p 'Proceed anyway? [y]es, [n]o: ' XPOWER_ENFORCE_INSTALLATION
  case "$XPOWER_ENFORCE_INSTALLATION" in
    y|Y)
      ;;
    *)
      echo 'Aborting installation on user behalf.'
      exit 1
      ;;
  esac
fi

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
