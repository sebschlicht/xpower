#!/bin/bash
program_name='xpower'
program_title='xPower (Extended Power Management)'

# constants
XP_POWER_MODE_BATTERY=battery
XP_POWER_MODE_AC=ac
XP_DEFAULT_POWER_MODE="$XP_POWER_MODE_BATTERY"

# variable initialization section
change_power_mode=false
update_settings=false
new_power_mode="$XP_DEFAULT_POWER_MODE"

# Prints the usage of the script in case of using the help command.
printUsage () {
  echo 'Usage: '"$program_name"' [-u] [-c POWER_MODE]'
  echo
  echo "$program_title"' is a tool to store multiple screen settings (including backlight brightness, dimming flag and idle delay) dependent on the system power mode.'
  echo
  echo 'This tool can either'
  echo "* apply the xpower settings to the system (no options)"
  echo "* update the xpower settings from the system ('-u' option)"
  echo "* apply the settings of an other power mode to the system ('-c' option)"
  echo
  echo 'Valid power modes: [ac|battery]'
  echo
  echo 'Options:'
  echo "-c, --change-mode  Change the power mode to the new power mode specified. The current screen settings are stored before the new settings are applied to the system."
  echo "-u, --update       Update the screen settings of the current power mode according to the system settings."
  echo "-h, --help         Display this help message and exit."
}

# Parses the startup arguments into variables.
parseArguments () {
  while [[ $# > 0 ]]; do
    key="$1"
    case "$key" in
      # help
      -h|--help)
      printUsage
      exit 0
      ;;
      # change power mode
      -c|--change-mode)
      shift
      change_power_mode=true
      new_power_mode="$1"
      ;;
      # update settings
      -u|--update)
      update_settings=true
      ;;
      # unknown option
      -*)
      echo "$program_name"': Unknown option '"'$key'"'!'
      return 2
      ;;
      # parameter
      *)
      if ! handleParameter "$1"; then
        echo "$program_name"': Too many arguments!'
        return 2
      fi
      ;;
    esac
    shift
  done
  
  # check parameter validity
  ##########################
  
  # fall back to default power mode if new power mode invalid
  if [ -n "$new_power_mode" ]; then
    if ! is_valid_power_mode "$new_power_mode"; then
      new_power_mode="$XP_DEFAULT_POWER_MODE"
    fi
  fi
}

# Handles the parameters (arguments that aren't an option) and checks if their count is valid.
handleParameter () {
  # 1. parameter: power mode
  if [ -z "$new_power_mode" ]; then
    new_power_mode="$1"
  else
    # too many parameters
    return 1
  fi
}

# Prints prefixed warnings to stderr.
print_warning () {
  (echo '[WARNING] '"$@" >&2)
  return $?
}

# Logs a message to the active logging appenders.
log () {
  echo "$@"
  echo "$@" >> /tmp/xpower.log
}

# Checks if the given power mode is valid.
is_valid_power_mode () {
  local power_mode="$1"
  if [ "$power_mode" == "$XP_POWER_MODE_AC" ] || \
     [ "$power_mode" == "$XP_POWER_MODE_BATTERY" ]; then
    return 0
  fi
  return 1
}

# Builds the path to the file storing the backlight brightness of the given mode.
get_backlight_file () {
  local pm="$1"
  echo "$d_xpower_config"/backlight-"$pm"
}
# Builds the path to the file storing the screen idle delay of the given mode.
get_idle_delay_file () {
  local pm="$1"
  echo "$d_xpower_config"/idle-delay-"$pm"
}

# main script function section
##############################

detect_local_user() {
  local username=$( who | grep '\(\:0\)' | cut -d' ' -f1 | sort | uniq )
  log "$username"
}

# Detects the current power mode.
detect_power_mode() {
  on_ac_power
  if [ "$?" == '0' ]; then
    echo "$XP_POWER_MODE_AC"
    return
  fi
  echo "$XP_POWER_MODE_BATTERY"
}

# Retrieves the current screen brightness.
get_screen_brightness () {
  local brightness=$( xbacklight )
  # brightness is precise float, use Banker's rounding
  # http://unix.stackexchange.com/questions/240112/weird-float-rounding-behavior-with-printf
  echo "$brightness" | xargs printf '%.0f'
}

# Stores current backlight brightness for the given power mode.
store_backlight () {
  local pm="$1"
  local f_backlight=$( get_backlight_file "$pm" )
  local backlight=$( get_screen_brightness )
  echo "$backlight" > "$f_backlight"
}

# Restores backlight brightness of the given power mode.
restore_backlight () {
  local pm="$1"
  local f_backlight=$( get_backlight_file "$pm" )
  local backlight=100
  if [ -f "$f_backlight" ]; then
    local backlight=$( cat "$f_backlight" )
  fi
  xbacklight -set "$backlight"
}

# Gets the current idle delay.
get_idle_delay() {
  sudo -u "$user" dbus-launch --exit-with-session gsettings get org.gnome.desktop.session idle-delay 2>/dev/null | cut -d' ' -f 2
}

# Sets the current screen idle delay.
set_idle_delay() {
  local screen_idle_delay="$1"
  #TODO do we need to use dconf to make the changes persist?
  sudo -u "$user" dbus-launch --exit-with-session gsettings set org.gnome.desktop.session idle-delay "$screen_idle_delay" 2>/dev/null
}

# Stores the current idle delay for the given power mode.
store_idle_delay () {
  local pm="$1"
  local f_idle_delay=$( get_idle_delay_file "$pm" )
  local idle_delay=$( get_idle_delay )
  echo "$idle_delay" > "$f_idle_delay"
}

# Restores the idle delay of the given power mode.
restore_idle_delay () {
  local pm="$1"
  local f_idle_delay=$( get_idle_delay_file "$pm" )
  local idle_delay=0
  if [ -f "$f_idle_delay" ]; then
    local idle_delay=$( cat "$f_idle_delay" )
  fi
  set_idle_delay "$idle_delay"
}

# Enables/disables DPMS.
set_dpms() {
  local enabled="$1"
  local flag=-
  if "$enabled"; then
    local flag=+
  fi
  xset "$flag"dpms
}

# Sets the idle dim flag.
set_idle_dim () {
  local idle_dim="$1"
  sudo -u "$user" dbus-launch --exit-with-session gsettings set org.gnome.settings-daemon.plugins.power idle-dim "$idle_dim"
}

# entry point
#############
parseArguments "$@"
SUCCESS=$?
if [ "$SUCCESS" -ne 0 ]; then
  echo 'Use the '"'-h'"' switch for help.'
  exit "$SUCCESS"
fi

# execute main script functions
###############################

user=$( detect_local_user )
d_xpower_user=/home/"$user"
d_xpower_config="$d_xpower_user"/.xpower
f_xpower_mode=/tmp/xpower-mode

# check if user has a home directory to write to
if [ ! -d "$d_xpower_user" ]; then
  echo 'Failed to retrieve user automatically!'
  echo "Retrieved user '$user' but its home directory '$d_xpower_user' is missing."
  exit 1
fi
# set the Xauthority file
export XAUTHORITY="$d_xpower_user"/.Xauthority

# create the config folder if missing
if [ ! -d "$d_xpower_config" ]; then
  mkdir -p "$d_xpower_config"
  sudo chown -R "$user":"$user" "$d_xpower_config"
fi

crr_power_mode=$( detect_power_mode )
if ! "$change_power_mode"; then
  new_power_mode="$crr_power_mode"
fi

# logging
log "changing power mode: $change_power_mode"
log "setting power mode: $set_power_mode"
log "actual power mode: $crr_power_mode"
log "new power mode: $new_power_mode"

if [ -f "$f_xpower_mode" ]; then
  # ignore changing if power mode hasn't changed
  if "$change_power_mode"; then
    stored_power_mode=$( cat "$f_xpower_mode" )
    if "$change_power_mode" && [ "$stored_power_mode" == "$new_power_mode" ]; then
      log 'Power mode is up-to-date, exiting.'
      exit 0
    fi
    update_settings=true
  fi
else
  # prohibit unintended update of settings
  update_settings=false
fi
echo "$new_power_mode" > "$f_xpower_mode"

if "$change_power_mode"; then
  if [ "$crr_power_mode" != "$new_power_mode" ]; then
    print_warning "The specified power mode is incorrect, exiting."
    exit 0
  fi
  # the current power mode is the other one
  if [ "$new_power_mode" == "$XP_POWER_MODE_BATTERY" ]; then
    crr_power_mode="$XP_POWER_MODE_AC"
  else
    crr_power_mode="$XP_POWER_MODE_BATTERY"
  fi
  log "assuming previous power mode: $crr_power_mode"
fi

# store the current settings for the current power mode
if "$update_settings"; then
  log "storing current settings for $crr_power_mode mode..."
  store_backlight "$crr_power_mode"
  store_idle_delay "$crr_power_mode"
fi

if ! "$update_settings" || "$change_power_mode"; then
  # restore the settings of the enabled power mode
  log "restoring settings from $new_power_mode mode..."
  restore_backlight "$new_power_mode"
  restore_idle_delay "$new_power_mode"
  #TODO make this configurable
  dpms_enabled=false
  if [ "$new_power_mode" = "$XP_POWER_MODE_BATTERY" ]; then
    dpms_enabled=true
  fi
  set_dpms "$dpms_enabled"
  #TODO make this configurable
  set_idle_dim "$dpms_enabled"
fi

