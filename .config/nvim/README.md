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

## Debug shortcuts (Go and Rust)

Press Space, then `d`, and pause to see the debug menu in WhichKey.

| Keys | Action |
|---|---|
| `<Space>dc` / F5 | Start debugging or continue. |
| `<Space>ds` | Open scopes (variables). |
| `<Space>dr` | Open the expression REPL. |
| `<Space>dt` | Open threads and stack frames. |
| `<Space>dv` / F7 | Toggle the debug view. |
| `<Space>dh` | Inspect the value under the cursor in a popup. |
| `<Space>dw` | Add a watch expression; the prompt starts with the expression under the cursor. |
| `<Space>dg` | Run to the cursor while paused. |
| `<Space>dl` | Set a logpoint on the current line; prompts for a message. |
| `<Space>dx` | Terminate the debugged program. |
| `<Space>dd` | Disconnect, requesting that the program remain running. |

Disconnect behavior depends on the adapter and how the process was launched.
For the manually started, single-client Delve server, disconnecting can also
close the server; restart Delve before attaching again. To close only Neovim's
connection without sending a disconnect request, use `:lua require('dap').close()`.
The existing `<Space>b` / `<Space>B` breakpoint shortcuts and F1/F2/F3 stepping
shortcuts remain available.

Logpoints print to debugger output without pausing or editing source code. On an
executable line, press `<Space>dl` and enter a message such as
`value = {value}`. Expressions inside braces are evaluated by the debug adapter.
Press `<Space>b` on that line to remove the logpoint. Canceling the prompt or
submitting an empty message leaves existing breakpoints unchanged.

## Debugging Go (Golang)

Go debugging uses Delve through nvim-dap-go. Mason installs Delve.

### Project debug profiles

For Go, F5 offers **Debug Package**, which launches the package containing the
current file. It must be a `main` package; use test debugging for library packages.
When a project needs specific arguments, build tags, or environment variables,
create `.vscode/launch.json` in that project's root, rather than in these dotfiles:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug myapp (development)",
      "type": "go",
      "request": "launch",
      "mode": "debug",
      "program": "${workspaceFolder}/cmd/myapp",
      "cwd": "${workspaceFolder}",
      "args": ["--config", "./dev.toml"],
      "buildFlags": "-tags=example_tag",
      "env": {
        "APP_ENV": "development"
      }
    }
  ]
}
```

Replace the package, flags, and environment with values your program supports.
Remove `args`, `buildFlags`, or `env` when unnecessary. `program` points to the
package directory, not just `main.go`. `cwd` sets the running program's working
directory, including how relative paths in arguments are resolved.

Open Neovim at the project root, or use `:cd /path/to/project` (check with `:pwd`).
With a Go buffer open, set a breakpoint with `<Space>b`, press F5, and select
**Debug myapp (development)**. nvim-dap reads `.vscode/launch.json` from Neovim's
current working directory. To change profiles during a session, terminate it with
`:lua require('dap').terminate()` before pressing F5 again.

Commit shared profiles to the project repository, but keep credentials out of
`env`; inherit them from the environment used to start Neovim instead.
These are F5 debugger profiles. The custom F6 runner has separate behavior and
does not implement every launch setting.

For programs requiring a controlling terminal, use **Attach to Delve** below;
pass build flags and application arguments when starting the external Delve
process, rather than on the attach profile.

### Attach to Delve

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

### Standard input

For interactive keyboard input (prompts, menus, or a TUI), use the terminal-pane
workflow above and select **Attach to Delve** with F5. Type application input in
the pane running Delve. The Neovim debugger REPL evaluates expressions; it does
not send input to the application.

Pass application arguments after `--` when starting Delve:

```sh
~/.local/share/nvim/mason/bin/dlv debug ./cmd/myapp \
  --headless --listen=127.0.0.1:38697 -- --config ./dev.toml
```

Replace the example package and arguments with your own. For this same-pane
workflow, omit `--tty`; the application inherits the pane's controlling terminal.

For repeatable input from a file, use a direct F5 launch profile with `stdinFrom`:

```json
"stdinFrom": "${workspaceFolder}/testdata/input.txt"
```

Add this field to the configuration object in the project's `.vscode/launch.json`.
It redirects the application's standard input from that file; it does not provide
an interactive terminal. Use a launch profile rather than **Attach to Delve** for
this setting, since an attach profile connects to an already launched process.

## Debugging Rust

Rust debugging uses CodeLLDB through rustaceanvim and nvim-dap. Mason installs
CodeLLDB; rust-analyzer provides code navigation and test discovery.
If the adapter is missing, run `:MasonInstall codelldb`, wait for installation,
and restart Neovim so rustaceanvim detects it.

### Run and debug tests

Open a Rust file containing a `#[test]` function and save it. With the cursor
inside that test:

| Keys | Action |
|---|---|
| `<Space>tr` | Run the nearest test. |
| `<Space>tl` | Rerun the last test. |
| `<Space>ts` | Toggle the test summary. |
| `<Space>to` | Show test output. |
| `<Space>b` | Toggle a breakpoint on the current line. |
| `<Space>td` | Debug the nearest test. |

This also works for unit tests in a `cdylib` crate: Cargo builds a host test
executable from the library code. The code exercised must support the host;
device-specific behavior needs a separate debugging setup. A library has no
application entry point for `cargo run`; use a test or example executable.

If a new test is missing from discovery, save and reload the file. Check
`:RustLsp testables` to see which tests rust-analyzer discovers. After updating
rust-analyzer, restart it with `:RustAnalyzer restart` and allow indexing to finish.

### Interactive Rust programs

CodeLLDB can launch an application in a Neovim terminal using
`"terminal": "integrated"`. This gives the application terminal input while the
debugger REPL remains available for expressions; a separate attach server is
not required for this workflow.

For a binary crate, build it with `cargo build`, then add a profile to the
project's `.vscode/launch.json` configuration list:

```json
{
  "name": "Debug Rust interactive app",
  "type": "codelldb",
  "request": "launch",
  "program": "${workspaceFolder}/target/debug/myapp",
  "cwd": "${workspaceFolder}",
  "args": [],
  "terminal": "integrated"
}
```

Replace `myapp` with the binary name and adjust the path for workspaces or
custom target directories. Open a Rust source file so rustaceanvim configures
the adapter, set a breakpoint, and select the profile with F5. Type application
input in the terminal window; use `i` to enter terminal input mode and
`Ctrl+\`, then `Ctrl+n` to return to normal mode.
If the program reads all of stdin (for example, Rust's `read_to_string`), it
waits for EOF before processing input. Type the input, press Enter, then press
Ctrl+D on an empty line on Unix. Enter alone does not finish stdin. Place a
breakpoint after the input read to inspect the completed input and subsequent
calculation; reaching that breakpoint requires sending EOF first.
Rebuild after source changes before launching again: this profile launches an
existing executable and does not automatically run Cargo. Use F5 for this
profile; the custom F6 Rust runner uses `cargo run` and does not preserve its
terminal settings.

### Connect to a Rust program started under a debugger

Integrated-terminal launch is a convenient default for local Rust CLI/TUI
development, but terminal-first launch and debugging remain useful when:

- The program must run in an existing terminal or a special environment.
- Another tool starts the process.
- You need to attach to an already running process.
- The target runs remotely or on a device.

The terminal-first workflow used with Go also has a Rust equivalent: start the
program under an LLDB remote debug server, such as `lldb-server gdbserver`, in
a dedicated terminal or tmux pane, then connect CodeLLDB from Neovim. Application
input stays in that pane; breakpoints, stepping, and inspection stay in Neovim.

This requires a CodeLLDB remote-debugging profile that creates the target from
the matching local executable and connects to the LLDB server. It is different
from attaching to an ordinary running process by PID, and from connecting to a
CodeLLDB DAP adapter's own listening port. An ordinary interactive `lldb` session
does not automatically expose a DAP endpoint for Neovim to connect to.

For a program already running outside a debugger, use a CodeLLDB attach profile
with a process ID instead of starting an LLDB server for a new process. Attaching
requires the OS to permit debugging that process; use matching binaries and
debug symbols for source-level inspection.

The **Attach to Delve** profile is Go-only. These dotfiles do not currently
provide a Rust remote-debugging profile; the server command, connection settings,
and symbol paths need to match the target. Keep local debug-server listeners on
loopback unless a remote connection is deliberately configured. The integrated
terminal launch above is the configured starting point for local interactive
Rust programs.

### Step and inspect

While paused, F1 steps into a function, F2 steps over a line, F3 steps out, and
F5 continues. F7 toggles the debug view.

- `:DapViewJump scopes` shows variables in the selected stack frame. Press Enter
  on a value to expand or collapse it.
- `:DapViewWatch variable_name` watches a value as you step.
- `:DapViewJump repl` opens the expression REPL; evaluation uses the selected
  frame and the debugger's supported expression syntax.

The **Attach to Delve** profile is Go-specific; Rust uses CodeLLDB instead.

## Layout

| Path | Contents |
|---|---|
| `init.lua` | Options, keymaps, LSP servers, Mason tool list, completion, treesitter. |
| `lua/kickstart/plugins/` | Kickstart's optional plugins: gitsigns keymaps, nvim-lint, autopairs, neo-tree, indent guides. |
| `lua/plugins/` | Everything added on top: DAP, neotest, oil, refactoring, rustaceanvim, nvim-jdtls, tmux, launch runner. |
| `lua/launch_run.lua` | Runs `.vscode/launch.json` configs in a tmux pane without the debugger. |
| `ftplugin/java.lua` | Starts jdtls through nvim-jdtls with debug and test bundles. |
| `lazy-lock.json` | Pinned plugin commits. Commit it after `:Lazy update`. |
