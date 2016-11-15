# xpower
`xpower` is a script to have multiple screen settings for the different power modes on a laptop.
It, for example, allows to have a higher screen brightness when AC is connected and a lower screen brightness when the laptop is running on battery.
There is a full [list of features](#features) below.

`xpower` will be available as a package for Ubuntu and may be ported to other Unix distributions as well.

## Features

* allows to define screen settings per power mode (AC, battery) including
 * backlight brightness (managed via `xbacklight`)
 * screen idle delay (managed via `gsettings`)
 * screen dimming flag (managed via `gsettings`)
 * DPMS (managed via `xset`)
* maintains the screen settings across reboots

## Installation

In order to install the script before it becomes a package:

1. copy the script to an appropriate directory
  
        sudo cp xpower.sh /usr/local/bin/xpower
        sudo chmod +x /usr/local/bin/xpower

2. register calls to this script on power mode changes via `udev` rules that change to power mode to the new one

  **/etc/udev/rules.d/80-power-mode**:
  
      # full brightness when on AC
      ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/sebschlicht/.Xauthority", RUN+="/usr/local/bin/xpower -c ac"
      # reduce brightness when on battery
      ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/sebschlicht/.Xauthority", RUN+="/usr/local/bin/xpower -c battery"

3. register calls to this script on startup and shutdown to set the screen settings at startup and store changes on shutdown
  
  **/etc/systemd/system/xpower.service**:

      [Unit]
      Description=Synchronizes the screen settings with xpower.
      
      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/xpower
      ExecStop=/usr/local/bin/xpower -u
      
      [Install]
      WantedBy=multi-user.target
  
  activate it
  
      systemctl enable xpower
  
  and reboot.

## Open Questions

* Where to place the script and with which file permissions? It should be executable by all users.
* Will it be necessary to monitor `dconf` for screen setting changes in order to synchronize the settings if the system is powered off spontaneously?

