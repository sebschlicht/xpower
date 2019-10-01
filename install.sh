#!/bin/bash

# install tlp and supporting packages
sudo apt-get install tlp tlp-rdw smartmontools ethtool

# install pm-utils
sudo apt-get install pm-utils
# install related scripts to toggle screen brightness
sudo install pm-utils/00-screen-brightness /etc/pm/sleep.d
sudo install pm-utils/00-screen-brightness /etc/pm/power.d

