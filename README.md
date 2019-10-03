# XPower - Brightness Power Management

`xpower` is a collection of scripts and rules to toggle the laptop screen brightness when the AC is (un-)plugged.

Adjusting the screen brightness at this point is a part of the power management.
The README shows hows to [install](#installation) and [configure](#configuration) `xpower`.
Read [the wiki](https://github.com/sebschlicht/xpower/wiki) for background information on `xpower` and power management.

## Installation

Clone the repository and run the installer:

    git clone git@github.com:sebschlicht/xpower.git
    cd xpower
    ./install

It installs `pm-utils`, the brightness script for `pm` and device rules to trigger `pm-powersave` when the AC is (un-)plugged.

## Configuration

By default, `xpower` toggles the screen brightness between 100 and 65 percent when plugging or unplugging the AC.
Edit the config file `~/config/xpower/brightness` to change this behavior.

For example, if you want the screen brightness to be 50 percent when on battery, use

    battery_brightness=50

Unplugging the AC does not increase the brightness, by default.
Analogously, plugging the AC only increases the brightness.
If you want `xpower` to apply the specified brightness in any case, use

    enforce_brightness=1
