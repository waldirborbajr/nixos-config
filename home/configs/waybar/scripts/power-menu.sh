#!/usr/bin/env bash
# Power menu for waybar, driven by fuzzel dmenu mode.

options="  Lock\n  Logout\n  Reboot\n  Shutdown\n  Suspend"

chosen=$(echo -e "$options" | fuzzel --dmenu --prompt "Power: ")

case "$chosen" in
    *Lock)
        swaylock
        ;;
    *Logout)
        niri msg action quit
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Shutdown)
        systemctl poweroff
        ;;
    *Suspend)
        systemctl suspend
        ;;
esac
