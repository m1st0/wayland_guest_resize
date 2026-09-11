# TODO Possibilities

## Installation

- [ ] Add installation script
- [ ] Add uninstall script
- [ ] Install `sync_guest_display.zsh` to a standard user location
- [ ] Install required udev rule
- [ ] Document required CachyOS/Hyprland configuration

## Automatic Event Handling

- [ ] Replace the persistent `udevadm monitor` proof-of-concept with a
      proper udev rule
- [ ] Determine the safest way for a udev-triggered process to communicate
      with the user's Hyprland session
- [ ] Investigate whether systemd can provide a cleaner event-triggered
      service
- [ ] Compare udev-rule and systemd-based implementations
- [ ] Avoid unnecessary polling or permanently running processes

## Future Features

- [ ] Detect the DRM connector instead of assuming `card1-Virtual-1`
- [ ] Detect the Hyprland output instead of assuming `Virtual-1`
- [ ] Handle refresh rates dynamically
- [ ] Handle multiple virtual displays
- [ ] Add logging/debug mode
- [ ] Add systemd user-service option if useful
- [ ] Update `sync_guest_display.zsh` to run from event handles rather than monitoring.
