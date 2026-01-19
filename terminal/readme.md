# Terminal

This module sets up the Alacritty terminal, the Starship prompt, and a suite of modern Rust-based CLI tools designed to replace traditional Unix commands with faster, more feature-rich alternatives.

## 🚀 Tools & Usage

### 🖥️ Terminal & Shell
* **Alacritty**: A GPU-accelerated terminal emulator. It uses the graphics card to render text, providing significantly lower latency.

* **Starship**: A fast, customizable, and universal shell prompt.
  * *Note: Requires `eval "$(starship init bash)"` in your bashrc file.*

### 🔍 Search & Navigation
* **zoxide (Smarter `cd`)**: Remembers frequently used paths.
  * Usage: `z <part-of-path>` to jump. `zi` for interactive fuzzy jump.

* **fzf (Fuzzy Finder)**: 
  * Usage: `Ctrl+T` to find files, `Ctrl+R` for history search, `Alt+C` to jump to subdirectories.

* **ripgrep (rg)**: A faster `grep` that respects your `.gitignore`.
  * Usage: `rg "pattern"`

* **fd**: A simple, fast, and user-friendly alternative to `find` (goodbye complex `-name` flags!).
  * Usage: `fd pattern` 

### 📄 File & System Management
* **bat (Better `cat`)**: A `cat` clone with syntax highlighting and git integration.
  * Usage: `bat <file>`

* **eza (Modern `ls`)**: An improved `ls` with colors, icons, and grid views.
  * Usage: `eza --long --icons --git`

* **dust (Better du)**: A more intuitive version of du for disk usage.
  * Usage: `dust`

* **tmux (Multiplexer)**: Manage multiple terminal sessions and split panes.
  * Usage: `tmux` to start. `Ctrl+b` is the default prefix.
    * New session: `tmux new -s <session_name>`
    * Attach session: `tmux a -t <session_name>` 
    * Kill session: `tmux kill-session -t <session_name>`
    * Detach session: `Prefix+D`
    * Check active sessions: `tmux ls` 
    * New window: `Prefix+C`
    * Kill window: `Prefix+&`
    * Split Pane: `Prefix+&`/`Prefix+"`
    * Switch Pane (vim-style): `Prefix+h,j,k,l"` *(explicitly set on tmux.conf)*
    * Enter Copy mode (vim-style): `Prefix+[` *(`Prefix+]` to paste tmux internal buffer)*
    * Kill Pane: `Prefix+X`
    * Next/Prev Window: `Prefix+n`/`Prefix+p`
    * Switch window by number: `Prefix+0,1,...,9`
    * Zoom Pane: `Prefix+Z`

> 💡 Note on aliases
> To provide a seamless experience, many of these tools are aliased to replace their traditional Unix counterparts defined inside the repo bash/ section. For example, typing ls actually runs eza, and grep actually runs rg, if installed.

## Installation

1. **Run the installer:**
   ```bash
   ./install.sh
   ```


