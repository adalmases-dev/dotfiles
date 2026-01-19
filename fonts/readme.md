# Fonts 

Automatic installation of **Nerd Fonts** required for other system tools such as the tiling window manager or the terminal. 

## 🛠 Installation

The provided script scans the system to avoid installing fonts if already installed. Fonts should be directly usable by the user right after running the script without requiring a reboot. 

By default, it installs 'Hack' and 'JetBrainsMono' fonts.

1. **Run the installer:**
   ```bash
   ./install.sh
   ```

> The script install fonts for the local user only (if not already part of the system). 
> Optionally, you can parse extra fonts as argument to try to install them (e.g. `./install.sh FiraCode Meslo 0xProto`). Check extra fonts at: [nerd-fonts](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts)

