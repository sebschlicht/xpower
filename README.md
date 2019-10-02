# XPower Setup

`xpower` is a collection of scripts and rules to toggle the laptop screen brightness when the AC is (un-)plugged.

Adjusting the screen brightness at this point is a part of the power management.
The README shows hows to [install](#installation) and [configure](#configuration) `xpower`.
Read [the wiki](https://github.com/sebschlicht/xpower/wiki) for background information on `xpower` and power management.

## Installation

Clone the repository and run the installer:

    git clone git@github.com:sebschlicht/xpower.git
    cd xpower
    ./install

It installs `pm-utils`, related scripts and device rules.

## Configuration

By default, `xpower` toggles the screen brightness between 100 and 65 percent when running on AC or battery, respectively.

To change these values, you can only edit the [brightness script](https://github.com/sebschlicht/xpower/tree/develop/pm/00-screen-brightness) directly for now.

## Resources

* [1] https://askubuntu.com/questions/285434/is-there-a-power-saving-application-similar-to-jupiter
* [2] https://help.ubuntu.com/community/PowerManagement/ReducedPower
* [3] https://askubuntu.com/questions/765840/does-pm-powersave-start-automatically-when-running-on-battery
* [4] https://wiki.archlinux.org/index.php/Udev
* [5] https://askubuntu.com/questions/149054/how-to-change-lcd-brightness-from-command-line-or-via-script

