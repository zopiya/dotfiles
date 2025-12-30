# Homeup

**Automated, opinionated dotfiles management.**
Powered by [chezmoi](https://www.chezmoi.io/) and [Homebrew](https://brew.sh/).

## Philosophy

*   **Zero Interaction**: Run one command and walk away. No prompts, no questions.
*   **Cross-Platform**: Works on macOS and Linux (Debian, Fedora, Arch, Alpine).
*   **Adaptive**:
    *   **macOS**: Installs everything (CLI + GUI Apps + Fonts).
    *   **Linux Desktop**: Installs CLI tools + Flatpak GUI Apps.
    *   **Linux Server (Headless)**: Installs CLI tools only (auto-detects absence of GUI).

## Installation

### One-Liner

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zopiya/homeup/main/bootstrap.sh)"
```

### Manual Install

1.  **Clone & Apply**:
    ```bash
    chezmoi init --apply https://github.com/zopiya/homeup.git
    ```

2.  **Verify**:
    ```bash
    chezmoi verify
    ```

## What's Included?

*   **Core Tools**: `zsh`, `starship`, `fzf`, `bat`, `eza`, `ripgrep`, `jq`, `yq`.
*   **Development**: `neovim`, `tmux`, `git`, `gh`, `lazygit`.
*   **Runtimes**: `mise` (managing Node.js, Python, etc.), `uv`, `pnpm`.
*   **Security**: `gnupg`, `age`, `ssh` config.
*   **GUI Apps (macOS/Linux)**: Browsers, VSCode, 1Password, Obsidian, etc.

## Customization

*   **Packages**: Edit `packages/Brewfile.macos` or `packages/Brewfile.linux`.
*   **Flatpaks**: Edit `packages/flatpak.txt`.
*   **Git Identity**: Edit `dot_config/git/identity.gitconfig.tmpl`.

## Directory Structure

```text
├── bootstrap.sh              # Initial setup script
├── .chezmoiscripts/          # Installation logic (Brew, Flatpak, Shell)
├── packages/                 # Package lists
│   ├── Brewfile.macos        # macOS packages (CLI + GUI)
│   ├── Brewfile.linux        # Linux packages (CLI only)
│   └── flatpak.txt           # Linux GUI applications
├── dot_config/               # Config files (nvim, zsh, git, etc.)
└── .chezmoi.toml.tmpl        # System detection logic
```