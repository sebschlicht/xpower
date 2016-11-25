# xpower
`xpower` is a tool (shell script) for laptops running Ubuntu (15.04 and above, I guess) that enables users to maintain independent screen setting sets for the two power modes _AC_ and _battery_ via the _System Settings_.

The tool automatically recovers the appropriate screen settings on startup and swaps the two screen setting sets whenever the power cable is plugged or unplugged.

For example, it allows to have a high screen brightness when the power cable is connected and a low screen brightness when the laptop is running on battery.
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

1. clone the repository

1. switch into the repository
   
        cd xpower

1. execute the installer
   
        chmod u+x install.sh
        ./install.sh
       
   Note: The installer has to use `sudo` in order to make necessary changes to the udev rules, for example.
   For more details concerning the steps of the installer, refer to the [manual installation instructions](manual-installation.md).

## Usage

Once installed, you can change the screen settings in the _System Settings_ of Ubuntu as you're used to.
However, these settings are now separated for the two power modes _AC_ and _battery_.

Set a high brightness when your power cable is connected and exit the _System Settings_.  
Unplug the power cable, re-open the _System Settings_ and set a low brightness.  
Plug in the power cable again and the screen will be lightened up.  
Unplug the power cable again and the screen will darken.

Please note that the swapping of the screen settings will require you to close and re-open the _System Settings_ in order to see the changes in the GUI.

## Open Questions


* How to integrate that into the unity settings?
* Will it be necessary to monitor `dconf` for screen setting changes in order to synchronize the settings if the system is powered off spontaneously?

