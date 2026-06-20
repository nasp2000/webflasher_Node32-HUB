# Node32-HUB WebFlasher

WebSerial-based firmware flasher for ESP32-S3 (N16R8) and ESP32-P4 boards.
No Python or esptool needed in the browser — just Chrome/Edge and a USB cable.

## Features

- **Flash firmware** via WebSerial (Update or Full Install)
- **WiFi config** — save SSID/password to LittleFS via local backend
- **Board auto-detect** — reads chip info over serial
- **Auto IP detection** — captures the board's IP from boot output after flashing
- **LAN access** — the backend binds to all interfaces so you can flash from another machine on the network

## Usage

### Quick start
```bat
start-dual.bat
```

Opens `http://localhost:8765/` in your browser. The server also listens on your LAN IP — check the console output.

> [!TIP]
> **For firmware updates, use the OTA page on Node32‑HUB** (`http://node32-hub/update`) whenever the board is already running and connected to the network. The web interface at `http://node32-hub/` also has an OTA option under Settings. The USB WebFlasher is intended for **initial flash** or when OTA is unavailable.

### Manual
1. Connect the ESP32 via USB
2. Open `start-dual.bat` (or serve the HTML via any HTTP server on port 8765)
3. Click **Connect** and select the serial port
4. Pick a firmware `.bin` file (or a build folder with `bootloader.bin` + `partitions.bin`)
5. Click **Flash Update** or **Full Install**

### WiFi config
The backend uses **esptool.py** + **mklittlefs** (from PlatformIO) to write WiFi credentials to the board's LittleFS partition. The board reads `config.json` on boot.

## Files

| File | Description |
|------|-------------|
| `start-dual.bat` | HTTP server (embedded PowerShell) + browser launcher |
| `node32-hub_webflash.html` | WebSerial flash UI |
| `lib/esptool-js-bundle.js` | ESP32 flash logic ported to JavaScript (ESPLoader) |

## License

MIT — feel free to use, share, and modify.
