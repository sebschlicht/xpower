#!/bin/bash

# install tlp and supporting packages
#sudo apt-get install tlp tlp-rdw smartmontools ethtool

# install pm-utils
sudo apt-get install pm-utils
# install related scripts to toggle screen brightness
sudo install pm/00-screen-brightness /etc/pm/sleep.d
sudo install pm/00-screen-brightness /etc/pm/power.d

# copy udev rules to execute pm-powersave when chainging the battery status
sudo cp udev/rules.d/99-powersave.rules /etc/udev/rules.d/
sudo udevadm control --reload

