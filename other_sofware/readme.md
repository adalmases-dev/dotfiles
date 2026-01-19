# Other software
This module sets up additional software tools, such as useful apt packages of my preference or specific software like [mouseless](https://github.com/jbensmann/mouseless).

## 🚀 Tools & Usage

### Apt extra packages
* **🎬Peek:** A simple screen recorder to create short animated GIFS or MP4 (for single screen setups). Simply search for peek from your app launcher, resize the frame over the area to capture and hit record.

### 󰍾 Mouseless
A tool that allows you to control the mouse pointer entirely with your keyboard. It uses a "layer" approach to turn your keyboard home row into a high-precision navigation system.

Personal Key Bindings:
* Activation: `RightAlt+k` 
* Quitting: `Esc` or `q`
* Movement: `h,j,k,l` (vim-style) 
* Movement speed: `a` (accurate ~ slower), `s` (speed ~ faster) (keeping key pressed while moving)
* Scrolling : `shift+h,j,k,l` (keeping shift pressed) or `y,u,i,o`
* Clicking: `f` (left click), `g` (right click)

> The configuration is stored globally at /etc/mouseless/config.yaml. To update config, modify mouseless/config.yaml in this repository and rerun the installer.

## Installation

1. **Run the installer:**
   ```bash
   ./install.sh
   ```

