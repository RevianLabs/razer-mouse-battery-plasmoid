
## Troubleshooting

For changes to take effect right away you might need to reload the plasma shell by running
```bash
killall plasmashell; kstart5 plasmashell
```

### Common Issues and Solutions

#### Widget Shows "ERR" Instead of Battery Level

If your widget is displaying "ERR" instead of the battery percentage, click on the widget to see a detailed error message. Here are the most common issues and how to fix them:

##### 1. "No such file or directory" Error

**Symptoms:**
- Widget shows "ERR"
- Error message mentions "No such file or directory"

**Possible Causes:**
- [OpenRazer](https://github.com/openrazer/openrazer) drivers are not installed
- Razer device is not connected
- Razer device is not recognized by the system

**Solutions:**
1. Ensure OpenRazer drivers are installed by following the steps here for your distro of choice: https://openrazer.github.io/#download

2. Verify your device is connected and powered on.

##### 2. "Permission denied" Error

**Symptoms:**
- Widget shows "ERR"
- Error message mentions "Permission denied" when accessing device files
- You can't read from files in `/sys/bus/hid/drivers/razermouse/`

**Possible Causes:**
- Current user doesn't have permission to access the device files
- User is not a member of the `plugdev` group
- File permissions are too restrictive
- SELinux or AppArmor may be blocking access

**Solutions:**
1. **Manual Fix - Add User to Group:**
   ```bash
   # Add current user to plugdev group
   sudo usermod -aG plugdev $(whoami)
   
   # Log out and log back in for changes to take effect
   # Or refresh group membership in current session
   newgrp plugdev
   ```

2. **Check if Group Exists:**
   If the plugdev group doesn't exist, create it:
   ```bash
   sudo groupadd plugdev
   sudo usermod -aG plugdev $(whoami)
   ```

3. **Fix File Permissions:**
   ```bash
   # Make device files readable
   sudo chmod -R a+r /sys/bus/hid/drivers/razermouse/
   ```

4. **Check SELinux/AppArmor:**
   If using SELinux or AppArmor, you may need to adjust policies:
   ```bash
   # Temporarily disable SELinux to test
   sudo setenforce 0
   
   # For AppArmor
   sudo aa-complain /etc/apparmor.d/*
   ```

   If this fixes the issue, create proper policy exceptions.

##### 3. Incorrect Battery Reading

**Symptoms:**
- Widget shows an unexpected value (e.g., "NaN" or "0%")
- Battery percentage doesn't match actual battery level

**Possible Causes:**
- Device battery information isn't being properly read
- Incompatible device model

**Solutions:**
1. Ensure your device is fully supported by OpenRazer. Check the [OpenRazer compatibility list](https://openrazer.github.io/#devices).

2. Update OpenRazer to the latest version.

3. Restart your mouse or reconnect it.

##### 4. Widget Disappears or Crashes

**Symptoms:**
- Widget disappears from the panel
- Widget crashes when clicking on it

**Solution:**

Reinstall the widget:
```bash
plasmapkg2 -r com.github.revianlabs.razerbatterytray
plasmapkg2 -i /path/to/plasmoid-razerbatterytray
```

##### 5. Unknown or Unresolved Errors

**Symptoms:**
- Widget shows "ERR" with an error message not covered above
- Solutions above don't resolve the issue

**What to Do:**
1. Check the [existing issues](https://github.com/revianlabs/razer-mouse-battery-plasmoid/issues) to see if your problem is already reported
2. [Create a new issue](https://github.com/revianlabs/razer-mouse-battery-plasmoid/issues/new) with detailed information about:
    - Your Linux distribution and version
    - Your KDE Plasma version
    - Your Razer device model
    - The exact error message shown
    - Steps you've already tried

### Advanced Troubleshooting

#### Checking Device Files

You can manually check if your device files exist and are readable:

```bash
ls -la /sys/bus/hid/drivers/razermouse/
```

Look for a directory with a name like `0003:1532:00XX.XXXX`. Inside this directory, check for the files `charge_level` and `charge_status`.

#### Checking Logs

Check system logs for errors related to OpenRazer:

```bash
journalctl -b | grep -i razer
```

#### Manual Device Detection

To see if your system can detect your Razer device:

```bash
lsusb | grep -i razer
```
