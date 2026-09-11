#!/usr/bin/env zsh
# SPDX-FileCopyrightText: Copyright (c) 2026 Maulik Mistry
# SPDX-License-Identifier: Apache-2.0
#
# resize_guest.zsh - Script to automatically synchronize display resolution for a CachyOS Wayland guest.
#
# Author: Maulik Mistry
# Please share support: https://www.paypal.com/paypalme/m1st0
#                       https://venmo.com/code?user_id=3319592654995456106&created=1753283702


SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/vendor/tput_shell_colorize/tput_shell_colorize.sh"

resize_guest() {
    mode=$(head -n1 /sys/class/drm/card1-Virtual-1/modes)
    [[ -n $mode ]] || return

    messenger_std 'Resize: %s\n' "$mode"
    hyprctl eval "hl.monitor({ output = \"Virtual-1\", mode = \"${mode}@60\", position = \"0x0\", scale = 1 })"
}

# Verify sync operation.
resize_guest

# Monitor for changes and apply sync.
sudo udevadm monitor --udev --subsystem-match=drm | while IFS= read -r line; do
    if [[ $line == UDEV*change*/drm/card1* ]]; then
        resize_guest
    fi
done

