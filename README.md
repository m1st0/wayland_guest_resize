<!--
SPDX-FileCopyrightText: Copyright (c) 2026 Maulik Mistry
SPDX-License-Identifier: Apache-2.0
-->
# Wayland Guest Resize

Project to automatically synchronize the display resolution of a CachyOS Wayland guest with the size of its virtual display.

Copyright © 2026 Maulik Mistry

This project is licensed under Apache License 2.0. See the [LICENSE.txt](LICENSE.txt) file for details.

Please share support: 
- [PayPal](https://www.paypal.com/paypalme/m1st0)
- [Venmo](https://venmo.com/code?user_id=3319592654995456106&created=1753280522)

## Overview

When CachyOS is running as a Wayland guest under QEMU/KVM with a Virtio GPU, resizing the VM display window updates the virtual GPU's EDID information and DRM mode list. Hyprland does not automatically apply the new mode.

`sync_guest_display.zsh` watches for the resulting DRM change event, reads the current mode exposed by the Virtio GPU, and tells Hyprland to apply it.

```text
VM display window resize
        ↓
QEMU / virtual display
        ↓
Virtio GPU EDID update
        ↓
DRM change event
        ↓
/sys/class/drm/card1-Virtual-1/modes
        ↓
sync_guest_display.zsh
        ↓
hyprctl eval
        ↓
Hyprland applies the new resolution
```

## Requirements

- CachyOS guest
- Wayland session
- Hyprland
- QEMU/KVM virtual machine
- Virtio GPU
- udevadm
- hyprctl

The script currently assumes the guest display is exposed as:

```text
/sys/class/drm/card1-Virtual-1`
```

and the Hyprland output is:

```text
Virtual-1`
```

These may need to be adjusted for a different VM configuration.

## Installation

1. Clone the repository:

    ```bash
    git clone --recurse-submodules https://github.com/m1st0/wayland_guest_resize.git
    
    cd wayland_guest_resize
    ```

2. Make the script executable:

    ```bash
    chmod +x ./sync_guest_display.zsh
    ```

## Usage

Run the script from the CachyOS Wayland session:

```bash
./sync_guest_display.zsh
```

The script monitors DRM events and applies the first mode reported by the Virtio GPU.

For example, resizing the VM window may produce:

```text
Resize: 2560x1440
Resize: 1920x1080
Resize: 1600x900
```

The script then applies the corresponding mode to the Hyprland `Virtual-1` output.

## How It Works

The important part of the solution is that the new window size is already reaching the guest.

The Virtio GPU exposes the updated preferred mode through:

```text
/sys/class/drm/card1-Virtual-1/modes
```

A DRM `change` uevent is generated when the virtual display information changes. `sync_guest_display.zsh` listens for that event using:

```bash
sudo udevadm monitor --udev --subsystem-match=drm
```

When a DRM change event occurs, the script reads the first available mode:

```bash
mode=$(head -n1 /sys/class/drm/card1-Virtual-1/modes)
```

It then asks Hyprland to apply that mode:

```bash
hyprctl eval "hl.monitor({ output = \"Virtual-1\", mode = \"${mode}@60\", position = \"0x0\", scale = 1 })"
```

The sudo applies only to `udevadm`. `hyprctl` continues to run as the logged-in Wayland user so it can communicate with the user's Hyprland session.

## Why This Is Needed

The virtual display is capable of receiving the new resolution, but Hyprland does not automatically switch to the newly reported DRM mode in this configuration.

This script provides the missing connection between the DRM mode change and Hyprland's monitor configuration.
