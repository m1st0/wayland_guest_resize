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

ensure_wayland_vdagent() {
    if ! command -v wayland-vdagent >/dev/null 2>&1; then
        messenger_std 'ERROR: wayland-vdagent is not installed.'
        messenger_end 'FAILED'
        return 1
    fi

    if ! systemctl --user cat wayland-vdagent.service >/dev/null 2>&1; then
        messenger_std 'ERROR: wayland-vdagent.service is not installed.'
        messenger_end 'FAILED'
        return 1
    fi

    if systemctl --user is-active --quiet wayland-vdagent.service; then
        messenger_std 'wayland-vdagent is already running.'
        return 0
    fi

    messenger_std 'Starting or restarting wayland-vdagent.service...'

    if ! systemctl --user restart wayland-vdagent.service; then
        messenger_std 'ERROR: Unable to start or restart wayland-vdagent.service.'
        messenger_end 'FAILED'
        return 1
    fi

    if ! systemctl --user is-active --quiet wayland-vdagent.service; then
        messenger_std 'ERROR: wayland-vdagent.service is not active after restart.'
        messenger_end 'FAILED'
        return 1
    fi

    messenger_std 'wayland-vdagent.service is running.'
    return 0
}

resize_guest() {
    mode=$(head -n1 /sys/class/drm/card1-Virtual-1/modes)
    [[ -n $mode ]] || return

    messenger_std 'Resize: %s\n' "$mode"
    hyprctl eval "hl.monitor({ output = \"Virtual-1\", mode = \"${mode}@60\", position = \"0x0\", scale = 1 })"
}

# Ensure wayland-vdagent is installed and running
ensure_wayland_vdagent || exit 1
resize_guest

# Monitor for changes and apply sync.
sudo udevadm monitor --udev --subsystem-match=drm | while IFS= read -r line; do
    if [[ $line == UDEV*change*/drm/card1* ]]; then
        resize_guest
    fi
done

