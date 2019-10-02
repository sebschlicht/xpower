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
Edit `~/config/xpower/brightness` to change this behavior.

For example, if you want the screen brightness to be 50 percent when on battery, use

    battery_brightness=50

If you don't want the brightness to change when plugging the AC in, use

    ac_brightness=

Unplugging the AC can only reduce the brightness, by default.
If you want `xpower` to set the battery brightness even if it's higher than the current one, use

    force_brightness=1


