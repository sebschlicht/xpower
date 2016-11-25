# Manual Installation

In order to install the `xpower` script manually:

1. install the dependencies

        sudo apt-get install xbacklight

1. copy the script to an appropriate directory
  
        sudo cp xpower.sh /usr/local/bin/xpower
        sudo chmod +x /usr/local/bin/xpower

1. register calls to this script on power mode changes via `udev` rules that change to power mode to the new one

  **/etc/udev/rules.d/80-power-mode.rules**:
  
      # power cable plugged in
      ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", ENV{DISPLAY}=":0", RUN+="/usr/local/bin/xpower -c ac"
      # running on battery
      ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", ENV{DISPLAY}=":0", RUN+="/usr/local/bin/xpower -c battery"

1. register calls to this script on startup and shutdown to set the screen settings at startup and store changes on shutdown
  
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
