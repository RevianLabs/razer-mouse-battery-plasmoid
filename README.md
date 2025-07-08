# Razer Mouse Battery Widget
[![CI](https://github.com/revianlabs/razer-mouse-battery-plasmoid/actions/workflows/build.yml/badge.svg)](https://github.com/revianlabs/razer-mouse-battery-plasmoid/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

<a href='https://ko-fi.com/bogdans' target='_blank'><img height='35' style='border:0px;height:35px;' src='https://storage.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>


A KDE Plasma widget that displays the battery level of your Razer wireless mouse directly in the system tray.

## Description

This Plasma widget provides a convenient way to monitor the battery status of your Razer wireless mouse directly from your KDE panel. It integrates seamlessly with the Plasma desktop environment to give you at-a-glance information about your mouse's battery level.

## Features

- Real-time battery level display
- System tray integration
- Compatible with KDE Plasma 6.0 and above
- Minimal resource usage

## Installation

### Dependencies

- KDE Plasma 6.0 or higher
- Razer wireless mouse
- [OpenRazer](https://github.com/openrazer/openrazer) drivers
  - **Following the steps listed on this page for your distro of choice: https://openrazer.github.io/#download**


### Installing from source

1. Clone the repository:

```bash
  git clone [https://github.com/revianlabs/razer-mouse-battery-plasmoid.git](https://github.com/revianlabs/razer-mouse-battery-plasmoid.git)
```
2. Install the widget:

```bash
    cd razer-mouse-battery-plasmoid 
    plasmapkg2 -t plasmoid -i ./
```

### Updating

To update an existing installation:

```bash
  plasmapkg2 -t plasmoid -u ./
```

### Removing the plasmoid

To remove an existing installation:

```bash
  plasmapkg2 -t plasmoid -r ./
```

## Usage

1. Right-click on your Plasma panel
2. Select "Add Widgets"
3. Search for "Razer Mouse Battery"
4. Click and drag the widget to your panel

## Troubleshooting

Please refer to the [Troubleshooting wiki page](https://github.com/RevianLabs/razer-mouse-battery-plasmoid/wiki/Troubleshooting)

## Development

Aside for the commands listed in the [Installing from source](#Installing-from-source) section, you may test the plasmoid in test container by running
```bash
plasmoidviewer --applet com.github.revianlabs.razermousebatteryplasmoid
```

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.


## Version

Current version: 1.0.0
