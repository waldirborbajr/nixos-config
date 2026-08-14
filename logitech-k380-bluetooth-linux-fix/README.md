# Logitech K380 - Linux Bluetooth Pairing Solution

Complete guide to pair the Logitech K380 keyboard with Linux via Bluetooth, including automated script to capture and display the PIN code.

## Problem

The Logitech K380 keyboard requires a PIN code during Bluetooth pairing, but the standard `bluetoothctl`:
- Doesn't display the PIN clearly
- Has a very short timeout (10 seconds)
- Doesn't give enough time to type the code on the keyboard

## Solution

Automated script using `expect` that:
- Automatically captures the PIN code
- Displays the code prominently
- Gives 60 seconds for typing
- Completes pairing automatically

## Prerequisites

```bash
sudo apt update
sudo apt install -y expect bluetooth bluez
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/your-username/logitech-k380-linux.git
cd logitech-k380-linux
```

2. Make the script executable:
```bash
chmod +x pair_k380.exp
```

## How to use

1. **Prepare the K380 keyboard:**
   - Turn on the keyboard
   - Press and hold key **1**, **2** or **3** for 5-10 seconds
   - The blue light should blink rapidly (pairing mode)

2. **Run the script:**
```bash
./pair_k380.exp
```

3. **Type the PIN code:**
   - The script will show the PIN code on screen
   - Type the code on the K380 keyboard
   - Press Enter on the keyboard

4. **Done!** The keyboard will be paired and connected.

## Example output

```
========================================
TYPE THIS CODE ON K380 KEYBOARD:
>>> 615452 <<<
You have 60 seconds to type it!
========================================

Pairing successful!
```

## Troubleshooting

### Keyboard not detected
- Make sure the blue light is blinking rapidly
- Try reset: hold Fn + P for 3 seconds, then key 1 again

### Bluetooth not working
```bash
sudo systemctl restart bluetooth
```

### Check paired devices
```bash
bluetoothctl devices
```

### Connect manually
```bash
bluetoothctl connect F4:73:35:94:F2:0B
```

## Manual alternatives

If you prefer to do it manually without the script:

```bash
bluetoothctl
agent KeyboardDisplay
default-agent
scan on
pair [KEYBOARD_MAC_ADDRESS]
# Type the PIN when it appears
connect [KEYBOARD_MAC_ADDRESS]
quit
```

## Compatibility

Tested on:
- Ubuntu 24.04 (Noble)
- Linux Mint
- Other Ubuntu/Debian based distributions

## Contributing

1. Fork the project
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created during troubleshooting session with Amazon Q Developer.

---

## Português (Portuguese)

Este repositório também funciona em português. O script detecta automaticamente o idioma do sistema e funciona em ambos os idiomas.

**Problema:** O teclado Logitech K380 precisa de código PIN no pareamento Bluetooth, mas o bluetoothctl padrão não mostra o código claramente.

**Solução:** Script automatizado que captura e exibe o código PIN com 60 segundos para digitação.
