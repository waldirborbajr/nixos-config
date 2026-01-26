# modules/desktops/niri/waybar.nix
# Waybar status bar configuration
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  term = "alacritty";
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [ waybar ];

  xdg.configFile."waybar/config.jsonc".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 32,
      "spacing": 4,
      "margin-top": 6,
      "margin-left": 10,
      "margin-right": 10,
      
      "modules-left": [
        "niri/workspaces",
        "niri/window"
      ],
      
      "modules-center": [
        "clock"
      ],
      
      "modules-right": [
        "tray",
        "idle_inhibitor",
        "pulseaudio",
        "network",
        "cpu",
        "memory",
        "temperature",
        "backlight",
        "battery"
      ],

      "niri/workspaces": {
        "format": "{icon}",
        "format-icons": {
          "1": "󰮺",
          "2": "󰯻",
          "3": "󰯼",
          "4": "󰯽",
          "5": "󰯾",
          "6": "󰯿",
          "7": "󰰀",
          "8": "󰰁",
          "9": "󰰂",
          "active": "",
          "default": ""
        },
        "on-scroll-up": "niri msg action focus-workspace-down",
        "on-scroll-down": "niri msg action focus-workspace-up"
      },

      "niri/window": {
        "format": "{}",
        "max-length": 50,
        "icon": true,
        "icon-size": 16,
        "rewrite": {
          "(.*) — Mozilla Firefox": " $1",
          "(.*)Mozilla Firefox": " Firefox",
          "(.*) - Alacritty": " $1",
          "Alacritty": " Terminal"
        }
      },

      "clock": {
        "interval": 1,
        "format": "{:%a %d %b  %H:%M:%S}",
        "format-alt": "{:%Y-%m-%d %H:%M:%S}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>",
        "calendar": {
          "mode": "month",
          "mode-mon-col": 3,
          "weeks-pos": "right",
          "on-scroll": 1,
          "format": {
            "months": "<span color='#cba6f7'><b>{}</b></span>",
            "days": "<span color='#cdd6f4'><b>{}</b></span>",
            "weeks": "<span color='#a6adc8'><b>W{}</b></span>",
            "weekdays": "<span color='#f9e2af'><b>{}</b></span>",
            "today": "<span color='#f38ba8'><b><u>{}</u></b></span>"
          }
        }
      },

      "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
          "activated": "",
          "deactivated": ""
        },
        "tooltip-format-activated": "Idle inhibitor active",
        "tooltip-format-deactivated": "Idle inhibitor inactive"
      },

      "tray": {
        "icon-size": 16,
        "spacing": 8,
        "show-passive-items": true
      },

      "cpu": {
        "interval": 2,
        "format": "󰃴 {usage}%",
        "tooltip": true,
        "on-click": "${term} -e htop"
      },

      "memory": {
        "interval": 2,
        "format": " {}%",
        "tooltip-format": "RAM: {used:0.1f}G / {total:0.1f}G\\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G",
        "on-click": "${term} -e htop"
      },

      "temperature": {
        "thermal-zone": 1,
        "critical-threshold": 80,
        "interval": 2,
        "format": "{icon} {temperatureC}°C",
        "format-icons": ["", "", "", "", ""],
        "tooltip": true
      },

      "backlight": {
        "device": "intel_backlight",
        "format": "{icon} {percent}%",
        "format-icons": ["", "", ""],
        "on-scroll-up": "brightnessctl set 5%+",
        "on-scroll-down": "brightnessctl set 5%-",
        "tooltip": false
      },

      "battery": {
        "interval": 10,
        "states": {
          "warning": 30,
          "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-full": " {capacity}%",
        "format-icons": ["", "", "", "", "", "", "", "", "", "", ""],
        "tooltip-format": "{timeTo}\\nPower: {power}W"
      },

      "network": {
        "interval": 2,
        "format-wifi": " {signalStrength}%",
        "format-ethernet": " {ipaddr}",
        "format-linked": " {ifname} (No IP)",
        "format-disconnected": " Disconnected",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}\\nUp: {bandwidthUpBytes} Down: {bandwidthDownBytes}",
        "tooltip-format-wifi": "{essid} ({signalStrength}%)\\n{ipaddr}/{cidr}\\nUp: {bandwidthUpBytes} Down: {bandwidthDownBytes}",
        "on-click": "nm-connection-editor"
      },

      "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " Muted",
        "format-icons": {
          "headphone": "",
          "hands-free": "",
          "headset": "",
          "phone": "",
          "portable": "",
          "car": "",
          "default": ["", "", ""]
        },
        "scroll-step": 5,
        "on-click": "pavucontrol",
        "on-click-right": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "tooltip-format": "{desc}\\nVolume: {volume}%"
      }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 12px;
      font-weight: 500;
      border: none;
      border-radius: 0;
      min-height: 0;
    }

    window#waybar {
      background: transparent;
      color: #cdd6f4;
    }

    /* ========================================
       WORKSPACES
       ======================================== */
    #workspaces {
      background: rgba(30, 30, 46, 0.9);
      padding: 0 4px;
      margin: 0 8px 0 0;
      border-radius: 12px;
    }

    #workspaces button {
      padding: 0 10px;
      margin: 4px 2px;
      background: transparent;
      color: #a6adc8;
      border-radius: 8px;
      transition: all 0.2s ease-in-out;
    }

    #workspaces button.active {
      color: #1e1e2e;
      background: linear-gradient(45deg, #cba6f7, #f5c2e7);
      font-weight: 700;
    }

    #workspaces button.urgent {
      color: #1e1e2e;
      background: #f38ba8;
    }

    #workspaces button:hover {
      background: #45475a;
      color: #cdd6f4;
    }

    /* ========================================
       WINDOW TITLE
       ======================================== */
    #window {
      background: rgba(30, 30, 46, 0.9);
      padding: 4px 14px;
      margin: 0 8px 0 0;
      border-radius: 12px;
      color: #cdd6f4;
      font-weight: 600;
    }

    /* ========================================
       CLOCK
       ======================================== */
    #clock {
      background: rgba(30, 30, 46, 0.9);
      padding: 4px 16px;
      border-radius: 12px;
      color: #cba6f7;
      font-weight: 700;
    }

    /* ========================================
       MODULES (RIGHT SIDE)
       ======================================== */
    #tray,
    #idle_inhibitor,
    #pulseaudio,
    #network,
    #cpu,
    #memory,
    #temperature,
    #backlight,
    #battery {
      background: rgba(30, 30, 46, 0.9);
      padding: 4px 12px;
      margin: 0 0 0 8px;
      border-radius: 12px;
      color: #cdd6f4;
    }

    #tray {
      padding: 4px 8px;
    }

    #idle_inhibitor.activated {
      color: #f9e2af;
    }

    #cpu {
      color: #89b4fa;
    }

    #memory {
      color: #a6e3a1;
    }

    #temperature {
      color: #f9e2af;
    }

    #temperature.critical {
      color: #f38ba8;
      animation: blink 1s ease-in-out infinite;
    }

    #backlight {
      color: #fab387;
    }

    #battery {
      color: #a6e3a1;
    }

    #battery.warning {
      color: #f9e2af;
    }

    #battery.critical {
      color: #f38ba8;
      animation: blink 1s ease-in-out infinite;
    }

    #battery.charging {
      color: #a6e3a1;
    }

    #network {
      color: #89dceb;
    }

    #network.disconnected {
      color: #f38ba8;
    }

    #pulseaudio {
      color: #cba6f7;
    }

    #pulseaudio.muted {
      color: #6c7086;
    }

    @keyframes blink {
      50% {
        opacity: 0.5;
      }
    }

    /* ========================================
       TOOLTIPS
       ======================================== */
    tooltip {
      background: rgba(30, 30, 46, 0.95);
      border: 2px solid #cba6f7;
      border-radius: 12px;
      padding: 8px;
    }

    tooltip label {
      color: #cdd6f4;
    }
  '';
}
