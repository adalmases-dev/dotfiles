# Tiling Window Manager

This section automates the installation and configuration of an i3-based desktop environment. It ensures modern features (like gaps) are available by checking version requirements before installation.

## 🚀 Components
* **i3**: Core window manager. Includes i3status.
* **rofi**: App launcher and custom power menu. Acts like dmenu, the common default alternative, replacement.
* **picom**: X11 compositor for shadows, transparency, blur, etc.
* **feh**: Image viewer used for wallpaper support.
* **i3lock-fancy**: Aesthetic blurred screen locker.
* **flameshot**: Feature-rich screenshot software.

##  Notes
- The installation targets i3 version **4.22** or higher for the native gaps support. If apt provides a system version high enough installs the package normally or builds latest i3 version from source.
- All subdirectories in the current folder (i3, i3status, picom, rofi) contain the specific configuration that will be symlinked automatically to `~/.config/<dir_name>`.
- The proposed setup relies heavily on **Nerd Fonts** (specifically *Hack Nerd Font*) for the status bar icons and system text. Before running the i3 installer, it is highly recommended to run the font installation script located at /fonts/ directory of the package.
- The proposed i3 configuration uses custom scripts that wraps some standard i3 commands to better handle multi-monitor setups gracefully with behaviours that prioritize work and focus on the primary monitor, where the **primary monitor is automatically determined to be the monitor with highest resolution!**
- The wallpaper will be randomly selected, on startup or reload, from any `.jpg` or `.png` images from `~/.config/i3/wallpapers/`.

## 🛠 Installation
1. **Run the installer:**
   ```bash
   ./install.sh
   ```

2. Refresh: Restart i3 with `Alt+Shift+r` to apply changes. 

## ⌨️ Keybindings Quick Reference
* **Move between windows/workspaces**: `Alt + hjkl` (vim motions like)
* **New Terminal**: `Alt + Enter` 
* **Kill Window**: `Alt + q`
* **App Launcher**: `Alt + m` 
* **Power Menu**: `Alt + p` 
* **Move to window**: `Alt + h,j,k,l` (Vim style to move between containers on the current workspace)
* **Prepare vertical/horizontal split**: `Alt + v` / `Alt + b` (New terminal or app will be opened vertically or besides, respectively)
* **Resize window**: `Alt + r` (Use `hjkl` to resize, `Esc/Enter` to quit)
* **Open workspace**: `Alt + [0-9]` (Opens and focus on the `[0-9]` workspace. **New empty workspace will always be on the primary monitor**)
* **Move window location in the current workspace**: `Alt + Cntrl + h,j,k,l` 
* **Move window to specific workspace:** `Alt + Shift + [0-9]` (Moves window to `[0-9]` workspace. Does not follow the movement) 

Some extra features for multiple monitor setup (useless for single monitor):
* **Move workspace to next monitor**: `Alt + n` (Follows the movement. Cannot move an empty workspace)
* **Cycle/Swap workspaces**: `Alt + Tab` (Rotates all visible workspaces across the physical monitors Left → Right (for dual monitor setup acts like a swap*). Keeps focus on the primary monitor.)
* **Move window to next/prev monitor's active workspace:** `Alt + Shift + l`/`Alt + Shift + h` (Does not follow the movement. Useless for single monitor)

