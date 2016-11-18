#!/bin/bash

print_error_exit () {
  local msg="$1"
  local code=1
  if [ ! -z "$2" ]; then
    local code="$2"
  fi
  echo "[ERROR] $msg" >&2
  exit "$code"
}

# copy xpower to unmanaged script directory and set permissions
f_script_src='xpower.sh'
f_script_dest='/usr/local/bin/xpower'
sudo cp "$f_script_src" "$f_script_dest" && sudo chmod +x "$f_script_dest"
if [ "$?" != '0' ]; then
  print_error_exit 'Failed to copy script or to set its permissions!'
fi

# copy udev rule into configuration folder and set permissions
fname_rule='80-xpower_power-mode.rules'
f_rule_src="resources/$fname_rule"
f_rule_dest="/etc/udev/rules.d/$fname_rule"
sudo cp "$f_rule_src" "$f_rule_dest" && sudo chmod 644 "$f_rule_dest"
if [ "$?" != '0' ]; then
  print_error_exit 'Failed to copy udev rule or to set its permissions!'
fi
# restart udev to circument reboot
sudo service udev restart

# copy systemd service config into configuration folder and enable it
fname_systemd='xpower.service'
f_systemd_src="resources/$fname_systemd"
f_systemd_dest="/etc/systemd/system/$fname_systemd"
sudo cp "$f_systemd_src" "$f_systemd_dest"
sudo systemctl enable "$fname_systemd"
if [ "$?" != '0' ]; then
  print_error_exit 'Failed to copy systemd config or to enable it!'
fi
# start systemd service to circument reboot
sudo systemctl restart "$fname_systemd"

