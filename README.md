# xpower
`xpower` is a script to have multiple screen settings for the different power modes on a laptop.
It, for example, allows to have a higher screen brightness when AC is connected and a lower screen brightness when the laptop is running on battery.

The settings that `xpower` currently is supporting:
* backlight brightness (managed via `xbacklight`)
* screen idle delay (managed via `gsettings`)
* screen dimming flag (managed via `gsettings`)
* DPMS (managed via `xset`)

`xpower` will be available as a package for Ubuntu and may be ported to other Unix distributions as well.

