# Node32-HUB WebFlasher

WebSerial-based firmware flasher for ESP32-S3 (N16R8) and ESP32-P4 boards.
No Python or esptool needed in the browser — just Chrome/Edge and a USB cable.

## Features

- **Flash firmware** via WebSerial (Update or Full Install)
- **Serial Monitor** — view live board output, with Connect/Disconnect/Clear/Copy controls
- **WiFi config** — send WiFi credentials to the board over serial (`WIFIADD` command) with automatic reboot
- **Board auto-detect** — reads chip info over serial; also auto-detects board from build folder name
- **Board IP display** — captures the board's IP from boot output and shows a clickable link
- **Build folder picker** — select an entire build folder at once (Chrome/Edge 86+)
- **Erase option** — optionally erase flash before full install
- **LAN access** — the server binds to all interfaces so you can flash from another machine on the network

## Usage

### Quick start
```bat
start-dual.bat
```

Opens `http://localhost:8765/` in your browser. The server also listens on your LAN IP — check the console output.

> [!TIP]
> **For firmware updates, use the OTA page on Node32‑HUB** (`http://node32-hub/ota`) whenever the board is already running and connected to the network. The USB WebFlasher is intended for **initial flash** or when OTA is unavailable.

### First flash
1. Connect the ESP32 via USB
2. Open `start-dual.bat` (or serve the HTML via any HTTP server on port 8765)
3. Click **Connect** and select the serial port — the chip is auto-detected
4. Choose the flash mode:
   - **Update** — flashes `firmware.bin` only (keeps bootloader, partitions, and config)
   - **Full Install** — writes `bootloader.bin` + `partitions.bin` + `firmware.bin` (optionally erase first)
5. Select files: either pick individual `.bin` files or click **Select build folder…** to load all at once
6. Click **Flash Update** or **Full Install** / **Erase + Full Install**
7. **Wait for the board to reboot** — the serial monitor shows the boot process and the board's IP

### Serial Monitor
After connecting, the **Serial Monitor** at the bottom of the page automatically shows live board output. You can also:
- Click **Connect** to start monitoring without flashing
- Click **Clear** to clear the output
- Click **Copy** to copy the log to clipboard

### WiFi config (after flash)
After the board reboots:
1. The board starts its own AP or connects to a configured network
2. Scroll to **WiFi Config**, enter SSID and password
3. Click **Save WiFi & Reboot** — this sends the credentials via the `WIFIADD` serial command, waits briefly, then **automatically reboots** the board via hardware reset (DTR/RTS)
4. The board connects to your network after reboot — you can see its IP in the serial monitor

> WiFi config is a **one-time** step (unless you change networks). A valid serial connection to the board is required.

## Files

| File | Description |
|------|-------------|
| `start-dual.bat` | HTTP server (embedded PowerShell) + browser launcher |
| `node32-hub_webflash.html` | WebSerial flash UI with serial monitor |
| `lib/esptool-js-bundle.js` | ESP32 flash logic ported to JavaScript (ESPLoader) |

## License

MIT — feel free to use, share, and modify.
