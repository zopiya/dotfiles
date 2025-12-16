# Homeup 架构文档

**版本**: 2.0  
**定位**: 个人开发环境模块化配置系统架构与实施指南  
**设计理念**: 志存高远，实事求是  
**最后更新**: 2025-12-16

---

## 📋 目录

1. [设计哲学](#设计哲学)
2. [架构概览](#架构概览)
3. [分层设计](#分层设计)
4. [核心模块详解](#核心模块详解)
5. [工作流与最佳实践](#工作流与最佳实践)
6. [跨平台适配](#跨平台适配)
7. [安全架构](#安全架构)
8. [性能优化](#性能优化)
9. [故障排查](#故障排查)
10. [设计决策记录](#设计决策记录)

---

## 💭 设计哲学

### 核心理念

**"志存高远，实事求是"**

- **志存高远**: 架构设计保留扩展空间，未来可以优雅地添加功能
- **实事求是**: 当下只做必要的事，不过度设计

### 七大核心原则

#### 1. Brew as Single Source of Truth

Homebrew 是跨平台安装 CLI 工具和字体的唯一入口。无论 macOS、Linux、x86、ARM，统一通过 Brew 管理。

#### 2. Configuration as Code

配置文件即代码。通过 Chezmoi 管理，单一 Git 仓库，模板化处理平台差异。修改永远在 Source，单向同步到 Target。

#### 3. Modular by Choice

每个功能模块独立可选。在初始化时交互式选择需要的模块，不需要的就不安装。

#### 4. Runtime Isolation

语言运行时（Node/Python/Go/Rust）由 Mise 管理（如果启用）。项目级隔离，环境零污染。

#### 5. OS Agnostic, GUI Aware

屏蔽 macOS 与 Linux 的 CLI 层差异，仅在 GUI 应用层分流。通过 `headless` 变量控制。

#### 6. Pragmatic Security

安全工具按需选择。可以启用 YubiKey + GPG + 1Password，也可以不用，降级为基础配置。

#### 7. Minimal Viable Editor

Neovim 定位为 CLI 场景下 vim 的现代替代品。5-8 个核心插件即可，够用就好，不追求 IDE 级体验。

### 实用主义宣言

**我们相信**:

- ✅ 够用就行，不追求完美
- ✅ 主流优先，社区验证过的工具
- ✅ 出问题能 Google 到答案
- ✅ 15 分钟上手，不需要读完整份文档
- ✅ 模块化，不需要的就不装

**我们拒绝**:

- ❌ 追求最新最酷的工具（除非真的好用）
- ❌ 过度抽象和配置
- ❌ 为了炫技而配置
- ❌ 强制安装用不到的东西

---

## 🏗 架构概览

### 四层架构模型

```
┌─────────────────────────────────────────────────┐
│  Layer 3: 维护与可观测 [可选]                   │
│  Topgrade, Restic                               │
│  └─ 用户选择是否需要                             │
└─────────────────────────────────────────────────┘
                      ↑
┌─────────────────────────────────────────────────┐
│  Layer 2: 项目运行时 [可选]                     │
│  Mise, uv, pnpm, cargo                          │
│  └─ 用户选择是否需要                             │
└─────────────────────────────────────────────────┘
                      ↑
┌─────────────────────────────────────────────────┐
│  Layer 1: 用户环境 [模块化可选]                 │
│  ├─ Core Module [必选]                          │
│  │   Homebrew, Chezmoi, Git, Shell, Neovim      │
│  ├─ Security Module [可选]                      │
│  │   YubiKey, GPG, 1Password                    │
│  └─ GUI Module [可选]                           │
│      VSCode, Browser, Terminal Emulator         │
└─────────────────────────────────────────────────┘
                      ↑
┌─────────────────────────────────────────────────┐
│  Level 0: 系统引导 [必装]                       │
│  Bootstrap Script → Install Homebrew + Chezmoi  │
└─────────────────────────────────────────────────┘
```

### 配置文件策略

| 类型           | 策略            | 说明                                    |
| -------------- | --------------- | --------------------------------------- |
| **静态配置**   | 直接文件        | 如 `.gitignore`                         |
| **跨平台配置** | `.tmpl` 模板    | 使用 `{{ if eq .chezmoi.os "darwin" }}` |
| **机密信息**   | 密码管理器      | 通过 1Password/Bitwarden 注入           |
| **机器特定**   | `.chezmoi.toml` | 不提交到 Git                            |

### 工作流模型

```
Source (Git Repo)  →  Chezmoi Template Engine  →  Target ($HOME)
       ↑                                                  ✗
       └──── 所有修改必须从这里开始 ───────────────────────┘
              (禁止直接修改 Target)
```

---

## 🔷 分层设计

### Layer 0: 系统引导 (Bootstrap)

**职责**: 解决冷启动问题。在全新机器上，一行命令安装 Homebrew 和 Chezmoi。

**引导流程**:

```bash
# One-Liner 初始化
bash <(curl -fsSL https://your-repo.com/bootstrap.sh)
```

**脚本职责**:

1. 检测系统（macOS/Linux）和架构（x86/ARM）
2. Linux 系统安装基础依赖（git, curl, build-essential）
3. 安装 Homebrew（官方脚本）
4. 通过 Homebrew 安装 Chezmoi
5. 执行 `chezmoi init --apply`

**设计原则**:

- **极简**: 只做必要的事，不处理配置文件
- **幂等**: 可重复运行，已安装则跳过
- **通用**: 支持所有 macOS/Linux 发行版和架构

### Layer 1: 用户环境 (核心层)

这是架构的心脏。管理所有配置文件、软件安装、Shell 治理。

#### 模块划分

```
Layer 1: 用户环境
  │
  ├─ Core Module [必选]
  │   ├─ Homebrew (软件管理)
  │   ├─ Chezmoi (配置管理)
  │   ├─ Git (版本控制)
  │   ├─ Shell (Zsh + Sheldon + Starship)
  │   └─ Neovim (CLI 编辑器)
  │
  ├─ Security Module [可选]
  │   ├─ YubiKey (物理密钥)
  │   ├─ GPG (加密体系)
  │   └─ 1Password/Bitwarden (密码管理器)
  │
  └─ GUI Module [可选]
      ├─ VSCode (编辑器)
      ├─ Browser (Chrome/Firefox)
      └─ Terminal (iTerm2/Electerm)
```

#### 交互式配置

在 `chezmoi init` 时询问用户需要哪些模块：

```toml
# .chezmoi.toml.tmpl (交互式生成)

{{- $headless := false -}}
{{- $install_security := false -}}
{{- $install_gui := false -}}

# 检测环境
{{- if eq .chezmoi.os "linux" -}}
{{-   if not (stat "/usr/bin/X") -}}
{{-     $headless = true -}}
{{-   end -}}
{{- end -}}

# 询问用户
{{- $profile := promptInt "Select Profile" 1 -}}

[data]
    headless = {{ $headless }}
    install_security = {{ $install_security }}
    install_gui = {{ $install_gui }}
```

#### 目录架构

```
~/.local/share/chezmoi/
│
├── .chezmoi.toml.tmpl          # 交互式配置模板（不入 Git）
├── .chezmoiignore.tmpl         # 条件忽略
├── .gitignore
├── README.md
│
├── data/
│   └── Brewfile.tmpl           # 模块化软件清单
│
├── dot_config/                 # → ~/.config
│   ├── git/
│   │   ├── config.tmpl
│   │   ├── aliases.gitconfig
│   │   └── identity.gitconfig.tmpl
│   │
│   ├── zsh/
│   │   ├── aliases.zsh
│   │   ├── exports.zsh.tmpl
│   │   ├── functions.zsh
│   │   └── dot_zshrc.tmpl
│   │
│   ├── nvim/
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── core/
│   │       ├── plugins/
│   │       └── config/
│   │
│   ├── sheldon/
│   │   └── plugins.toml
│   │
│   ├── starship.toml
│   ├── topgrade.toml
│   │
│   ├── mise/                   # Layer 2
│   │   └── config.toml
│   │
│   └── security/               # Security Module
│       ├── yubikey.inc.tmpl
│       ├── gpg.inc.tmpl
│       └── 1password.inc.tmpl
│
├── private_dot_ssh/
│   └── config.tmpl
│
├── private_dot_gnupg/          # Security Module
│   ├── gpg.conf
│   └── gpg-agent.conf.tmpl
│
├── dot_local/
│   └── bin/
│       └── executable_restic_backup.sh.tmpl
│
└── .chezmoiscripts/            # 自动化脚本
    ├── run_once_before_10_check_prerequisites.sh.tmpl
    ├── run_once_20_install_system_packages.sh.tmpl
    ├── run_once_30_install_security_tools.sh.tmpl
    ├── run_once_40_install_runtimes.sh.tmpl
    ├── run_once_50_install_gui_apps.sh.tmpl
    ├── run_once_60_configure_shell.sh.tmpl
    ├── run_once_70_setup_maintenance.sh.tmpl
    └── run_after_99_finalize.sh.tmpl
```

### Layer 2: 项目运行时 (可选)

**启用条件**: 用户在初始化时选择 "Install Mise for runtime management"

**职责**: 项目级语言版本隔离。进入项目目录，自动切换 Node/Python/Go/Rust 版本。

**核心原则**:

- 禁止 `brew install python`, `brew install node`
- 全部由 Mise 管理
- 每个项目通过 `.mise.toml` 定义工具链

**使用示例**:

全局配置 (`~/.config/mise/config.toml`):

```toml
[tools]
# 非项目场景的默认版本
python = "3.12"
node = "lts"
rust = "stable"
```

项目配置 (`~/projects/my-app/.mise.toml`):

```toml
[tools]
python = "3.11.7"
node = "20.11.0"

[env]
PYTHONPATH = "{{config_root}}/src"
```

**现代包管理器**:

- **Python**: `uv` (极速虚拟环境)
- **Node**: `pnpm` (节省磁盘)
- **Rust**: `cargo` (内置)

### Layer 3: 维护工具 (可选)

**启用条件**: 用户在初始化时选择 "Install maintenance tools"

**组件**:

**Topgrade** - 一键更新所有工具

- 系统更新（macOS/Linux）
- Homebrew
- Flatpak（Linux GUI）
- Mise（如果启用）
- Sheldon（Shell 插件）
- Neovim 插件

**Restic** - 加密备份

- 备份 `~/Documents`, `~/projects`
- 增量备份，端到端加密
- 支持 S3/B2/NAS

---

## 🔧 核心模块详解

### Core Module (必选)

#### Homebrew - 包管理器

**跨平台路径适配**:

```bash
# 动态 Homebrew 路径检测
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  BREW_PREFIX="/opt/homebrew"          # Apple Silicon
elif [[ -f "/usr/local/bin/brew" ]]; then
  BREW_PREFIX="/usr/local"             # Intel Mac
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  BREW_PREFIX="/home/linuxbrew/.linuxbrew"  # Linux
fi

eval "$($BREW_PREFIX/bin/brew shellenv)"
```

**Brewfile 结构**:

```ruby
# Core Module [必选]
brew "git"
brew "zsh"
brew "neovim"
brew "starship"
brew "sheldon"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "bat"
brew "eza"

# 字体
cask "font-jetbrains-mono-nerd-font"

# GUI Module [可选]
{{ if .install_gui -}}
cask "visual-studio-code"
cask "google-chrome"
{{ end -}}

# Security Module [可选]
{{ if .install_security -}}
brew "gnupg"
brew "yubikey-manager"
brew "1password-cli"
{{ end -}}
```

#### Zsh + Sheldon + Starship - Shell 环境

**启动流程**:

```
~/.zshenv (always)
  ↓
~/.config/zsh/.zshrc (interactive)
  ↓
Load Sheldon plugins
  ↓
Initialize Starship
```

**Sheldon 配置** (`~/.config/sheldon/plugins.toml`):

```toml
shell = "zsh"

[templates]
defer = "{{ hooks?.pre | nl }}{% for file in files %}zsh-defer source \"{{ file }}\"\n{% endfor %}{{ hooks?.post | nl }}"

[plugins.zsh-defer]
github = "romkatv/zsh-defer"

[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
apply = ["defer"]
```

**性能优化**:

- 使用 `zsh-defer` 延迟加载非关键插件
- 目标启动时间: < 0.5 秒
- 测量方法: `time zsh -i -c exit`

#### Neovim - CLI 编辑器

**设计定位**:

- ✅ 替代 vim，提供语法高亮和基本补全
- ✅ 远程服务器临时编辑
- ✅ Git commit message 编辑
- ❌ 不用于长期开发（用 VSCode/IDE）
- ❌ 不追求 IDE 级体验

**核心插件（5 个）**:

1. **lazy.nvim** - 插件管理
2. **nvim-treesitter** - 语法高亮
3. **nvim-lspconfig** - LSP 支持
4. **nvim-cmp** - 代码补全
5. **telescope.nvim** - 文件查找

**配置结构**:

```lua
-- init.lua
require("core.options")
require("core.keymaps")
require("lazy").setup("plugins")
```

**键位设计**:

- Leader: `<Space>`
- 查找文件: `<Leader>ff`
- 全局搜索: `<Leader>fg`
- 定义跳转: `gd`
- 悬停文档: `K`

### Security Module (可选)

**启用时机**: 用户在初始化时选择 "Install security tools"

**组件**:

1. **YubiKey** - 物理密钥设备
2. **GPG** - 加密与签名（存储在 YubiKey）
3. **1Password/Bitwarden** - 密码管理器

**架构**:

```
YubiKey (硬件)
  └─ GPG Master Key
      ├─ Signing 子密钥 → Git 签名
      ├─ Encryption 子密钥 → 文件加密
      └─ Authentication 子密钥 → SSH 认证
```

**配置要点**:

```bash
# GPG Agent 启用 SSH 支持
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

# Git 配置
git config --global user.signingkey "YOUR_KEY_ID"
git config --global commit.gpgsign true
```

**1Password 集成示例**:

```toml
# dot_config/gh/config.yml.tmpl
github.com:
  user: {{ .github_username }}
  oauth_token: {{ onePasswordRead "op://Private/GitHub/token" }}
```

### GUI Module (可选)

**跨平台策略**:

- macOS: Homebrew Cask
- Linux: Flatpak

**应用清单**:

```toml
{{ if and .install_gui (eq .chezmoi.os "darwin") -}}
cask "visual-studio-code"
cask "iterm2"
cask "google-chrome"
cask "raycast"
cask "orbstack"
cask "1password"
{{ end -}}
```

---

## 🔄 工作流与最佳实践

### 标准操作流程 (SOP)

#### 日常修改流程

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Edit    │──▶│   Diff   │──▶│  Apply   │──▶│  Verify  │──▶│  Commit  │
│ (Source) │   │ (Preview)│   │ (Target) │   │  (Check) │   │   (Git)  │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
```

**命令序列**:

```bash
# 1. 编辑配置
chezmoi edit ~/.zshrc

# 2. 预览变更（必须步骤）
chezmoi diff

# 3. 应用到系统
chezmoi apply -v

# 4. 验证一致性
chezmoi verify

# 5. 提交到仓库
chezmoi cd
git add .
git commit -m "feat: update zsh aliases"
git push
```

### 五条核心禁忌

#### 1. ❌ 不要在 Target ($HOME) 直接修改配置

**正确**: `chezmoi edit ~/.zshrc`  
**错误**: `vim ~/.zshrc`

配置漂移会导致 Source 和 Target 不一致。

#### 2. ❌ 不要通过 Homebrew 安装语言运行时

**正确**: 通过 Mise 安装 Python/Node  
**错误**: `brew install python`, `brew install node`

会污染全局环境，导致版本冲突。

#### 3. ❌ 不要把 `.chezmoi.toml` 提交到 Git

这是机器特定的配置，每台机器都不同。应该被 `.gitignore` 忽略。

#### 4. ❌ 不要在模板中写死路径

**正确**: `{{ .chezmoi.homeDir }}/.config`  
**错误**: `/home/user/.config`

跨用户、跨系统无法通用。

#### 5. ❌ 不要过度配置 Neovim

Neovim 是 vim 的替代品，不是 IDE。保持 5-8 个核心插件即可。

### 版本控制策略

#### Git 分支模型

```
main (稳定版)
  ├── feature/nvim-lsp (功能分支)
  ├── fix/zsh-path (修复分支)
  └── experiment/wayland (实验分支)
```

#### 提交信息规范 (Conventional Commits)

```
<type>(<scope>): <subject>

Types:
- feat: 新功能
- fix: 修复
- refactor: 重构
- docs: 文档
- style: 格式
- chore: 构建/工具

示例:
feat(zsh): add fzf key bindings
fix(git): correct work email in gitconfig
refactor(nvim): modularize plugin config
```

---

## 🌐 跨平台适配

### 支持矩阵

| OS 类型            | 状态        | 优先级 | 典型场景      |
| ------------------ | ----------- | ------ | ------------- |
| macOS 13+          | ✅ 完全支持 | P0     | 主力开发机    |
| Linux (Debian 11+) | ✅ 完全支持 | P0     | 服务器/开发机 |
| Linux (Fedora 38+) | ✅ 完全支持 | P1     | 工作站        |
| Raspberry Pi OS    | ✅ 部分支持 | P2     | 边缘设备      |
| Windows WSL2       | ❌ 不支持   | -      | 已废弃        |

### CPU 架构兼容性

| 架构            | macOS            | Linux              | 关键考量                     |
| --------------- | ---------------- | ------------------ | ---------------------------- |
| x86_64 (AMD64)  | ✅ Intel Mac     | ✅ 服务器/桌面     | 传统架构，兼容性最好         |
| ARM64 (aarch64) | ✅ Apple Silicon | ✅ 树莓派/云服务器 | 性能优异，部分软件需源码编译 |

### 差异处理模板

```toml
# OS 检测
{{ if eq .chezmoi.os "darwin" }}
export HOMEBREW_PREFIX="/opt/homebrew"
{{ else if eq .chezmoi.os "linux" }}
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
{{ end }}

# 架构检测
{{ if eq .chezmoi.arch "arm64" }}
# ARM 特定配置
{{ else }}
# x86 配置
{{ end }}
```

### 环境适配表

| 环境           | OS         | GUI | 推荐模块选择                               |
| -------------- | ---------- | --- | ------------------------------------------ |
| **主力 macOS** | macOS      | ✅  | Core + Security + GUI + Mise + Maintenance |
| **远程服务器** | Ubuntu     | ❌  | Core only                                  |
| **Linux 桌面** | Fedora     | ✅  | Core + GUI + Mise                          |
| **树莓派**     | Debian ARM | ❌  | Core only                                  |
| **Codespace**  | Linux      | ❌  | Core + Mise                                |

---

## 🔒 安全架构

### 机密分类与存储策略

| 类型             | 示例                 | 存储方式  | 访问频率 |
| ---------------- | -------------------- | --------- | -------- |
| API Keys         | OpenAI, GitHub Token | 1Password | 高       |
| SSH Private Keys | `id_rsa`             | GPG 加密  | 中       |
| GPG Private Keys | `secring.gpg`        | 离线 USB  | 低       |
| 应用密码         | Email, VPN           | Bitwarden | 高       |

### 零明文原则

**禁止行为**:

- ❌ 在 Git 仓库中存储明文密钥（即使是加密分支）
- ❌ 在 `chezmoi.toml` 中写入敏感信息
- ❌ 使用环境变量存储长期密钥

**推荐做法**:

```bash
# 使用 1Password
{{ onePasswordRead "op://Private/GitHub/token" }}

# 使用 Bitwarden
{{ bitwardenFields "item-id" "password" }}

# 使用 GPG 加密文件
gpg --encrypt --recipient your@email.com secret.txt
```

### GPG 密钥管理

**密钥生命周期**:

```
生成 → 导出公钥 → 上传服务器 → 使用 → 吊销 → 归档
  ↓                                     ↑
私钥离线存储（USB）                    定期轮换
```

**实施标准**:

1. 私钥 **永不** 加入 chezmoi 管理
2. 通过 `gpg --import` 手动导入到新机器
3. 使用 Yubikey 等硬件密钥器（推荐）

---

## ⚡ 性能优化

### 性能基准

| 指标               | 目标值  | 测量方法                         |
| ------------------ | ------- | -------------------------------- |
| Zsh 启动时间       | < 500ms | `time zsh -i -c exit`            |
| Chezmoi apply 时间 | < 10s   | `time chezmoi apply`             |
| Neovim 启动时间    | < 100ms | `nvim --startuptime startup.log` |

### Zsh 启动优化

```zsh
# 延迟加载重量级插件
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # 使用缓存
fi

# 使用 zsh-defer
source ~/.zsh/zsh-defer/zsh-defer.plugin.zsh
zsh-defer source ~/.zsh/plugins/fzf-tab
zsh-defer source ~/.zsh/plugins/zsh-autosuggestions
```

### Chezmoi 优化

```gitignore
# .chezmoiignore - 忽略大型目录
.cache/
.local/share/nvim/lazy/
node_modules/
*.swp
*.tmp
```

---

## 🐛 故障排查

### 常见错误诊断

| 错误现象                      | 可能原因       | 诊断命令                               | 解决方案              |
| ----------------------------- | -------------- | -------------------------------------- | --------------------- |
| `template: syntax error`      | 模板语法错误   | `chezmoi execute-template < file.tmpl` | 修复 `{{ }}` 语法     |
| `permission denied`           | 文件权限错误   | `ls -la ~/.local/share/chezmoi`        | 添加 `private_` 前缀  |
| `command not found: brew`     | 路径未加载     | `echo $PATH`                           | 检查 Shell 初始化顺序 |
| `gpg: signing failed`         | GPG 密钥未导入 | `gpg --list-secret-keys`               | 导入私钥              |
| `mise: version not installed` | 运行时未安装   | `mise ls`                              | `mise install`        |

### 调试工具

```bash
# 健康检查
chezmoi doctor

# 查看模板渲染结果
chezmoi cat ~/.zshrc

# 验证数据源
chezmoi data

# 检查差异
chezmoi diff --verbose

# 模拟执行
chezmoi apply --dry-run --verbose

# 追踪脚本执行
chezmoi state dump
```

---

## 📊 设计决策记录 (ADR)

### ADR-001: 放弃 Windows 原生支持

**决策**: 放弃 Windows 原生支持，全面拥抱 Unix 生态

**理由**:

1. PowerShell 与 Bash 语法差异过大，模板复杂度呈指数增长
2. Windows 路径分隔符、权限模型与 Unix 完全不兼容
3. WSL2 作为过渡方案，维护成本超过收益

### ADR-002: 所有脚本必须支持跨架构运行

**决策**: 动态检测 CPU 架构和 Homebrew 路径

**关键挑战**:

- Homebrew 路径差异（Intel vs Apple Silicon vs Linux）
- 二进制下载需要检测 `uname -m`

### ADR-003: 使用 `headless` 变量控制 GUI 软件

**决策**: 通过单一变量控制所有 GUI 相关模块

**实施**:

```toml
{{ if not .headless }}
# 安装 GUI 应用
{{ end }}
```

### ADR-004: Git Conditional Includes 替代 Chezmoi 模板

**决策**: 多身份管理使用 Git 原生支持

**理由**: Git 原生支持更优雅，避免模板逻辑爆炸

### ADR-005: 绝不在临时机器上存储 GPG 私钥

**决策**: 临时机器的 `machine_role` 设为 "temporary"

### ADR-006: 使用 `run_once_` 脚本实现幂等安装

**命名规范**:

- `00-09`: 系统验证与前置条件
- `10-19`: Bootstrap 层
- `20-29`: CLI 工具层
- `30-39`: GUI 应用层
- `90-99`: 后置验证与清理

### ADR-007: 采用"零明文"原则管理机密

**决策**: 所有机密通过密码管理器注入，禁止明文存储

---

## 🎓 工具选择理由

| 工具          | 理由                           | 为什么不选 XX？                  |
| ------------- | ------------------------------ | -------------------------------- |
| **Chezmoi**   | 模板化强大，支持脚本，社区活跃 | GNU Stow 太简单，yadm 不支持模板 |
| **Homebrew**  | 跨平台，包最全，macOS 标配     | apt/dnf 不跨平台，Nix 学习曲线陡 |
| **Mise**      | 统一接口，速度快，支持所有语言 | asdf 慢，需要很多插件            |
| **Sheldon**   | Rust 编写，启动极快            | zinit 配置复杂，oh-my-zsh 慢     |
| **Starship**  | 跨 Shell，配置简单，速度快     | Powerlevel10k 只支持 Zsh         |
| **Neovim**    | Lua 配置，LSP 原生支持，性能好 | Vim 不支持 Lua，Emacs 太重       |
| **Delta**     | 最好的 Git diff 美化工具       | diff-so-fancy 功能少             |
| **1Password** | 与 macOS 集成最好，有 CLI      | Bitwarden 也不错，看个人偏好     |

---

## 📚 参考资源

### 官方文档

- **Chezmoi**: https://www.chezmoi.io/
- **Homebrew**: https://brew.sh/
- **Mise**: https://mise.jdx.dev/
- **Neovim**: https://neovim.io/
- **Starship**: https://starship.rs/

### 社区资源

- **YubiKey Guide**: https://github.com/drduh/YubiKey-Guide
- **Awesome Dotfiles**: https://github.com/webpro/awesome-dotfiles

---

## 🏁 总结

Homeup 是一个**模块化、实用主义**的个人开发环境架构：

✅ **快速**: 15 分钟初始化  
✅ **灵活**: 每个模块独立可选  
✅ **跨平台**: macOS/Linux 全支持  
✅ **够用**: 社区主流工具，不过度配置  
✅ **可控**: 单向同步，配置即代码

---

**架构设计**: Based on real-world usage  
**维护者**: Zopiya  
**License**: MIT
