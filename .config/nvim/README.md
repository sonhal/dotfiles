# Neovim config

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), extended for
Go, Python, Rust, Java, TypeScript/Vue and Lua. Plugins are managed by lazy.nvim,
language servers and tools by Mason. Both install themselves on first start.

Requires Neovim 0.12 or newer.

## Install

The files in this directory are symlinked into `~/.config/nvim` one entry at a
time (`init.lua`, `lua/`, `ftplugin/`, `lazy-lock.json`, ...). When a new
top-level entry is added here, add a matching symlink.

Then start `nvim`. lazy.nvim clones the plugins pinned in `lazy-lock.json` and
Mason installs every server and tool listed in `init.lua`. Run `:checkhealth`
if something looks off.

## System dependencies

Mason only downloads language servers and tools. Everything below must come from
the system package manager.

### Arch Linux one-liner

```sh
sudo pacman -S --needed neovim git curl tar unzip base-devel tree-sitter-cli ripgrep fd \
  tmux wl-clipboard nodejs npm python go jdk-openjdk rustup lldb
```

Drop the last five language packages you do not need on that machine. Mason will
then fail to install the matching servers, which is harmless.

### What each one is for

Core, needed for the config to build at all:

| Package | Why |
|---|---|
| `neovim` | 0.12+. Treesitter main branch and `vim.lsp.config` need it. |
| `git`, `curl`, `tar`, `unzip` | lazy.nvim clones plugins, Mason downloads and unpacks archives. |
| `base-devel` | `gcc` and `make`. Compiles treesitter parsers, telescope-fzf-native and LuaSnip's regex helper. |
| `tree-sitter-cli` | nvim-treesitter main branch generates parsers with it. Must be the distro package, not the npm one. |
| `ripgrep` | Telescope live grep and grep-under-cursor. |
| Nerd Font symbols | Icons in the statusline, file trees, diagnostics and which-key (`vim.g.have_nerd_font = true`). They come from the terminal: kitty ships them built in; other terminals need `ttf-nerd-fonts-symbols-mono`. |

Workflow:

| Package | Why |
|---|---|
| `tmux` | The launch runner (vimux) and pane navigation and resizing (smart-splits.nvim) run inside tmux. |
| `wl-clipboard` | System clipboard on Wayland for `clipboard = unnamedplus`. Use `xclip` on X11. |
| `fd` | Optional. Faster file listing for Telescope's find-files. |

Language runtimes. Mason needs these to install and run the servers for each language:

| Package | Why |
|---|---|
| `nodejs`, `npm` | vtsls, vue-language-server, markdownlint-cli2. |
| `python` | basedpyright, ruff, debugpy. Mason creates its own venvs. |
| `go` | gopls, delve, goimports, gofumpt, gotestsum, golangci-lint and the gopher.nvim helpers. |
| `jdk-openjdk` | jdtls, the Java debug adapter and test runner are all JVM programs. |
| `rustup` | rust-analyzer comes from Mason but is useless without a toolchain. Run `rustup default stable` after install. |
| CodeLLDB (Mason) | Rust debug adapter, installed by mason-tool-installer and detected by rustaceanvim. |

Not needed: `luarocks`. lazy.nvim mentions it in `:checkhealth` but no plugin here uses it.

## Attach to Delve

For interactive Go programs, start Delve in a dedicated terminal or tmux pane
from the project's root. Replace `./cmd/myapp` with the package containing your
program's `main` function (use `.` if it is at the root). Append program arguments
after `--` when needed:

```sh
~/.local/share/nvim/mason/bin/dlv debug ./cmd/myapp \
  --headless --listen=127.0.0.1:38697
```

In Neovim, set a breakpoint with `<Space>b`, then press F5 and select
**Attach to Delve**. Press F5 to continue if the process is initially paused.
The profile connects to an existing server on `127.0.0.1:38697`.
To restart, close the Neovim connection with `:lua require('dap').close()`,
stop/restart Delve in its terminal, and attach again.

## Layout

| Path | Contents |
|---|---|
| `init.lua` | Options, keymaps, LSP servers, Mason tool list, completion, treesitter. |
| `lua/kickstart/plugins/` | Kickstart's optional plugins: gitsigns keymaps, nvim-lint, autopairs, neo-tree, indent guides. |
| `lua/plugins/` | Everything added on top: DAP, neotest, oil, refactoring, rustaceanvim, nvim-jdtls, tmux, launch runner. |
| `lua/launch_run.lua` | Runs `.vscode/launch.json` configs in a tmux pane without the debugger. |
| `ftplugin/java.lua` | Starts jdtls through nvim-jdtls with debug and test bundles. |
| `lazy-lock.json` | Pinned plugin commits. Commit it after `:Lazy update`. |
