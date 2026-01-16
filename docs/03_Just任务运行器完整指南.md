# Just Task Runner Complete Guide: Modern Make Alternative for Homeup

> Homeup's central command hub: 20+ tasks orchestrating packages, setup, configuration, and validation

**版本**: 1.0
**目标受众**: DevOps 工程师、系统管理员、开发人员
**前置知识**: Bash/Shell 基础、Homebrew 基础、命令行操作

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [任务架构](#任务架构)
- [常见任务详解](#常见任务详解)
- [高级用法](#高级用法)
- [与其他工具集成](#与其他工具集成)
- [常见问题](#常见问题)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### 什么是 Just？

**Just** 是 Makefile 的现代替代品：

```
Makefile (1970s):
  - Bash 友好性差
  - 空格/Tab 敏感
  - 跨平台不友好

Just (现代):
  ✅ 清晰的 Bash 语法
  ✅ 一致的缩进规则
  ✅ 跨平台支持（macOS/Linux/Windows）
  ✅ 内置参数处理
  ✅ 条件执行和确认机制
```

### Homeup 的任务层级

Homeup justfile (747 行) 采用 **4 层架构**：

```
Layer 1: Installation (包管理)
├── install-bootstrap    → 基础工具 (zsh, git, starship)
├── install-core         → CLI 工具集 (neovim, tmux, mise)
├── install-profile      → 平台特定 (macOS GUI / Linux server)
└── install              → 元任务（依次执行三层）

Layer 2: Setup (环境配置)
├── setup-shell          → 默认 shell 为 Zsh
├── setup-runtimes       → Mise + 运行时版本
├── setup-security       → GPG / YubiKey
├── setup-tools          → FZF / Atuin / Sheldon
└── setup                → 元任务（依次执行四层）

Layer 3: Orchestration (编排)
├── bootstrap            → install + setup（完整初始化）
├── check                → 前置条件验证
├── doctor               → 健康检查

Layer 4: Validation & Maintenance (验证和维护)
├── ci                   → 完整 CI 检查
├── validate-all         → 快速验证
├── upgrade / clean      → 维护任务
```

### 关键概念

| 术语 | 含义 | 例子 |
|------|------|------|
| **Justfile** | 任务定义文件（类似 Makefile） | 位置: `./justfile` |
| **Recipe** | Just 中的"任务"（类似 Make target） | `bootstrap`, `install` |
| **Meta Recipe** | 包含其他 recipe 的任务 | `bootstrap: install setup` |
| **@前缀** | 声明任务为私有/不在列表中显示 | `@apply`, `@diff` |
| **[private]** | 标记为私有任务 | `[private] check-brew` |
| **[confirm(...)]** | 执行前要求确认 | `init`, `reset`, `reinit` |
| **PROFILE** | 平台标识 (macos/linux) | `export HOMEUP_PROFILE=macos` |

> 💡 **提示**: 运行 `just --list` 查看所有可用任务，`just --choose` 交互式选择

---

## 快速开始

### ⚡ 5 分钟新机器初始化

```bash
# 1. 克隆 Homeup
git clone https://github.com/yourusername/homeup.git
cd homeup

# 2. 检查前置条件
just check

# 3. 一键完整初始化（安装 + 配置）
just bootstrap

# 4. 重启 shell
exec zsh -l

# 5. 验证
just doctor
```

### ✅ 验证安装

```bash
# 显示当前平台
just profile

# 显示所有任务
just --list

# 交互式任务选择器
just --choose
```

### 🔧 日常使用

```bash
# 应用配置更改
just apply

# 查看差异
just diff

# 健康检查
just doctor

# 升级所有包
just upgrade
```

---

## 任务架构

### 第 1 层：安装层（Package Management）

#### 3 层 Brewfile 策略

```
Brewfile.bootstrap (22 包)
├─ Minimal: zsh, git, homebrew
└─ 目的: 新机器的最小依赖

Brewfile.core (92 包)
├─ Cross-platform: neovim, tmux, mise, just
├─ CLI tools: ripgrep, fd, bat, fzf, zoxide
└─ 目的: 所有机器都需要的工具

Brewfile.macos / Brewfile.linux
├─ macOS: wezterm, gpg, yubikey-manager
├─ Linux: openssh-server, build-essential
└─ 目的: 平台特定的工具和库
```

#### 任务详解

**`just install-bootstrap`** - 安装基础工具

```bash
# 内部执行
brew bundle --file=packages/Brewfile.bootstrap

# 安装内容: zsh, git, starship, homebrew
```

**`just install-core`** - 安装核心工具

```bash
# 安装内容（92 个包）：
#   编辑器: neovim, vim
#   终端多路: tmux, zellij
#   版本管理: mise, docker, git
#   开发: just, ripgrep, fd, bat, fzf
#   系统: bottom, htop, ncdu
#   Shell: sheldon, starship, zoxide, atuin
```

**`just install-profile`** - 安装平台特定工具

```bash
# 自动检测 PROFILE（macos / linux）
# 并安装对应的 Brewfile

# macOS example:
#   GUI: wezterm, ghostty, visual-studio-code
#   Security: gpg, pinentry-mac, yubikey-manager
#   Dev: llvm, cmake, build-essential

# Linux example:
#   SSH: openssh-server, openssh-client
#   Build: build-essential, pkg-config
#   Dev: python3-dev, nodejs
```

**`just install`** - 完整安装（元任务）

```bash
# 自动执行三层安装，顺序为：
just install-bootstrap    # 1. 基础
just install-core         # 2. 核心
just install-profile      # 3. 平台特定

# 相当于：
# just install-bootstrap && just install-core && just install-profile
```

**`just install-no-upgrade`** - 不升级已有包

```bash
# 用于 CI/CD，避免版本冲突
brew bundle --no-upgrade

# 场景: 容器构建、自动化测试环境
```

---

### 第 2 层：配置层（Setup）

#### 任务详解

**`just setup-shell`** - 配置 Zsh 为默认 shell

```bash
# 步骤：
# 1. 在 Homebrew 安装的 Zsh 和系统 Zsh 中选择
# 2. 添加到 /etc/shells
# 3. 使用 chsh -s 设置为默认
# 4. 跳过 CI/Docker 环境

# 目的: 统一使用 Homebrew 管理的 Zsh（最新版本）
```

**`just setup-runtimes`** - 配置 Mise 和运行时版本

```bash
# 步骤：
# 1. 验证 Mise 安装
# 2. mise trust --all（信任所有 .tool-versions）
# 3. mise install（安装配置的版本）
# 4. 如果无全局配置，设置默认值
#    - python@3.12
#    - node@lts

# 使用 mise 而不是 nvm/pyenv：
#   ✅ 单一工具管理所有版本
#   ✅ .tool-versions 统一配置
#   ✅ Direnv 自动激活
```

**`just setup-security`** - 配置 GPG 和 YubiKey（仅 macOS）

```bash
# 步骤：
# 1. 检查平台（仅 macOS）
# 2. 重启 GPG Agent
# 3. 检测 YubiKey Manager 可用性

# 跳过条件：
#   - Linux 平台
#   - CI/Docker 环境

# 目的: 为 Git 签名和 SSH 准备 YubiKey
```

**`just setup-tools`** - 配置 FZF、Atuin、Sheldon、Starship

```bash
# 1. FZF: 安装 Zsh 按键绑定
# 2. Atuin: 初始化历史同步
# 3. Sheldon: 锁定插件版本
# 4. Starship: 验证 prompt 可用

# 相关文件：
#   ~/.fzf.zsh
#   ~/.config/sheldon/plugins.toml
#   ~/.config/starship.toml
```

**`just setup`** - 完整配置（元任务）

```bash
# 自动执行四个子任务：
just setup-shell
just setup-runtimes
just setup-security
just setup-tools
```

---

### 第 3 层：编排层（Orchestration）

**`just bootstrap`** - 一键完整初始化

```bash
# 核心命令：
just install    # 安装所有包（3 层）
just setup      # 配置环境（4 层）

# 最后输出：
# Bootstrap complete!
# Please restart your shell: exec zsh -l

# 使用场景:
#   ✅ 新机器从零开始
#   ✅ 虚拟机/容器初始化
#   ✅ CI/CD 初始化
```

**`just check`** - 前置条件检查

```bash
# 检查内容：
# 1. Homebrew 是否安装
# 2. Git 是否可用
# 3. SSH 版本（必须 8.2+ 支持 FIDO）
# 4. 平台判断（macos / linux）

# 输出示例：
# [OK] Homebrew: /opt/homebrew
# [OK] git found
# [OK] OpenSSH 8.2 (FIDO supported)
# [OK] Valid profile: macos
#
# Environment check passed
# Next: just bootstrap
```

**`just doctor`** - 系统健康检查

```bash
# 检查三类工具：

# Required（必需）:
#   [OK] brew
#   [OK] chezmoi
#   [OK] git
#   [OK] just

# Optional（可选）:
#   [OK] zsh
#   [OK] starship
#   [--] mise (not installed)

# Infrastructure:
#   [OK] Brewfile.bootstrap
#   [OK] Brewfile.core
#   [OK] Brewfile.macos / linux

# 输出 OK 时：
# All checks passed
```

---

### 第 4 层：Chezmoi 操作

这些任务是 Chezmoi 的便捷包装：

```bash
just apply              # chezmoi apply
just apply-verbose     # chezmoi apply -v
just diff              # chezmoi diff
just apply-interactive # chezmoi apply --interactive
just update            # chezmoi update
just status            # chezmoi status

just edit ~/.zshrc     # chezmoi edit ~/.zshrc
just add ~/.zshrc      # chezmoi add ~/.zshrc

just init              # 初始化 chezmoi（含确认）
just reset             # 清除所有状态（含确认）
just reinit            # 重置 + 重新初始化（含确认）
```

---

## 常见任务详解

### 场景 1：新机器从零开始

**问题**: 刚拿到一台新 Mac，什么都没有

**解决方案**:

```bash
# 1. 安装 Homebrew（前置）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 克隆 Homeup
git clone https://github.com/yourusername/homeup.git
cd homeup

# 3. 检查环境
just check
# 输出: Environment check passed

# 4. 完整初始化
just bootstrap
# 输出: Bootstrap complete! Please restart your shell: exec zsh -l

# 5. 重启 Shell
exec zsh -l

# 6. 验证
just doctor
# 输出: All checks passed
```

**耗时**: 约 15-30 分钟（取决于网络和磁盘速度）

---

### 场景 2：升级所有工具和包

**问题**: 需要升级到最新版本

**解决方案**:

```bash
# 方法 1: 使用 topgrade（推荐）
# 这会升级所有系统包和应用
just upgrade

# 内部逻辑:
#   如果安装了 topgrade: topgrade
#   否则回退: brew update && brew upgrade && brew cleanup

# 方法 2: 仅升级 Brew 包
brew update && brew upgrade

# 方法 3: 升级特定包
brew upgrade neovim
```

**包含升级**:
- Homebrew 包和 Cask
- Mise 管理的运行时（Python、Node 等）
- Cargo 工具（通过 topgrade）
- Npm 全局包（通过 topgrade）

---

### 场景 3：验证配置完整性

**问题**: 不确定是否有问题，想运行完整检查

**解决方案**:

```bash
# 快速验证
just validate-all

# 这会运行：
# 1. just validate        → 检查 Chezmoi 模板语法
# 2. just pkg-duplicates  → 检查包重复

# 完整 CI 检查
just ci

# 这会运行：
# 1. Linting             → Shell 脚本检查
# 2. Package validation  → 包可用性验证
# 3. Duplicate check     → 包重复检查
# 4. Health check        → just doctor
```

**输出示例**:

```
=== Checking Duplicates ===
Bootstrap <-> Core: OK
Core <-> macOS: OK
Core <-> Linux: OK
No duplicates found
```

---

### 场景 4：重新初始化（完全重置）

**问题**: Chezmoi 状态混乱，想从头开始

**警告**: ⚠️ 这会删除所有 Chezmoi 状态

**解决方案**:

```bash
# 完整重置 + 重新初始化
just reinit

# 提示：
# This will purge state and re-initialize. Continue? (y/n)

# 内部步骤：
# 1. chezmoi purge --force   → 清除所有缓存
# 2. chezmoi init --apply    → 重新初始化并应用
# 3. 保留所有配置文件

# 仅清除状态（保留配置）：
just reset
```

---

### 场景 5：更新配置文件

**问题**: 修改了 ~/.zshrc，想提交到版本控制

**解决方案**:

```bash
# 1. 修改文件
nvim ~/.zshrc

# 2. 查看变化（不应用）
just diff

# 3. 添加到 Chezmoi
just add ~/.zshrc

# 4. Chezmoi 自动提交
cd ~/.local/share/chezmoi
git add .
git commit -m "feat: update zsh config"
git push

# 或使用 Homeup 的 commit 快捷命令：
just commit "feat: update zsh config"
# 这会自动 git add -A && git commit -m
```

---

## 高级用法

### 自定义任务

#### 添加新的安装任务

```bash
# 编辑 justfile 或创建 .justfile.local

# 例: 添加自定义开发工具安装
my-dev-tools:
    @echo "Installing custom dev tools..."
    brew install ripgrep-all
    brew install ugrep

# 在其他任务中引用
setup: setup-shell setup-tools my-dev-tools
    @echo "All setup complete"
```

#### 创建带参数的任务

```bash
# 任务定义（已有示例）
edit file:
    chezmoi edit {{file}}

# 使用方式
just edit ~/.zshrc
just edit ~/.config/nvim/init.lua
```

#### 条件执行

```bash
# Just 内置条件逻辑

[confirm("Reset state?")]
my-reset:
    chezmoi purge --force

# 或使用 shell 条件

my-platform-task:
    #!/usr/bin/env bash
    if [[ "{{PROFILE}}" == "macos" ]]; then
        echo "Running on macOS"
        # macOS specific
    else
        echo "Running on Linux"
        # Linux specific
    fi
```

### 调试和日志

```bash
# 显示执行的实际命令
just --verbose doctor

# 仅显示任务内容，不执行
just --show install

# 列出所有任务及其依赖
just --graph

# 执行前查看模板变量替换
# 例：查看会执行什么
just --show install-profile
# 输出会显示 {{PROFILE}} 和 {{CHEZMOI_SOURCE}} 的实际值
```

### 性能优化

#### 跳过某些步骤

```bash
# 不重新安装，仅配置
just setup

# 不配置，仅安装
just install

# 仅安装 core，跳过 bootstrap 和 profile
just install-core
```

#### 并行执行（在脚本中）

```bash
# Just 默认按顺序执行
# 如果需要并行，在 shell 脚本中实现

# 例：同时执行多个任务
#!/usr/bin/env bash
set -euo pipefail

# 后台运行
just install-bootstrap &
just install-core &
wait  # 等待所有后台任务完成
```

---

## 与其他工具集成

### 与 Chezmoi 的集成

Just 是 Chezmoi 的高级包装：

```
┌─────────────────────────┐
│    Just Tasks Runner    │
│                         │
│  bootstrap              │
│  ├─ install             │
│  │  └─ brew bundle      │
│  └─ setup               │
│     ├─ setup-shell      │
│     ├─ setup-runtimes   │
│     └─ setup-security   │
│                         │
│  apply → chezmoi apply  │
│  diff  → chezmoi diff   │
│  edit  → chezmoi edit   │
└─────────────────────────┘
```

### 与 Mise 的集成

```bash
# Just setup-runtimes:
mise trust --all        # 信任配置文件
mise install            # 安装版本
mise use -g python@3.12 # 设置全局版本

# 在 .justfile 中可引用版本
VERSION := `mise exec -- python --version`
```

### 与 Homebrew 的集成

```bash
# Brewfile 是 Just 的数据层
packages/
├── Brewfile.bootstrap  → install-bootstrap 使用
├── Brewfile.core       → install-core 使用
├── Brewfile.macos      → install-profile (macOS)
└── Brewfile.linux      → install-profile (Linux)

# Just 任务提供了多种 Brewfile 组织方式
```

### 与 Git 的集成

```bash
# Just 提供便捷 Git 操作
just commit "feat: add new config"
# 相当于: git add -A && git commit -m "feat: add new config"

# Chezmoi 源管理
cd ~/.local/share/chezmoi
git push  # 推送配置更改
```

### 与 Lefthook 的集成

```bash
# Just 安装 Git hooks
just install-hooks

# 内部：
# - 检查 lefthook 可用性
# - 运行 lefthook install
# - 自动设置 pre-commit、pre-push 等钩子
```

---

## 常见问题

### ❓ 什么是 @前缀和 [private]？

两者都隐藏任务：

```bash
# [private] 任务
[private]
check-brew:
    command -v brew >/dev/null

# 效果：不在 just --list 中显示，但仍可调用
# 使用：作为其他任务的依赖

# @ 前缀任务
@apply:
    chezmoi apply

# 效果：隐藏，输出时不显示任务名
# 使用：简化用户输出

# 区别：
#   [private] - 隐藏，可作为依赖
#   @前缀 - 隐藏，执行静默
```

### ❓ 如何修改平台判断？

```bash
# 自动检测（默认）
PROFILE := env_var_or_default("HOMEUP_PROFILE", ...)

# 手动覆盖
export HOMEUP_PROFILE=linux
just install-profile

# 或在命令行
HOMEUP_PROFILE=macos just install-profile
```

### ❓ 为什么 setup-security 只在 macOS 运行？

```bash
# justfile 中的逻辑：
if [[ "{{PROFILE}}" != "macos" ]]; then
    echo "Skipping security setup (Linux profile)"
    exit 0
fi

# 原因：
#   - Linux 通常使用 SSH 密钥（无 GUI）
#   - macOS 支持 YubiKey 和 GPG GUI（pinentry）
#   - 容器中应跳过（检查 /.dockerenv）
```

### ❓ 包验证总是失败？

```bash
# 常见原因
# 1. 包名不存在（typo）
just pkg-validate

# 输出会显示：
# [FAIL] nonexistent-package (not found)

# 2. Homebrew 缓存过期
brew update
just pkg-validate

# 3. 特定于平台的包不可用
# 例：某个 cask 仅在 macOS 可用
# 解决：在 Brewfile.linux 中移除
```

### ❓ Bootstrap 中途失败怎么办？

```bash
# 场景：网络中断，或某个包无法安装

# 恢复方式 1：重新运行（会跳过已安装）
just bootstrap

# 恢复方式 2：仅重新运行 setup
just setup

# 恢复方式 3：部分重新运行
just install-core    # 重试核心包
just setup-runtimes  # 重试运行时配置

# 诊断
just doctor          # 查看当前状态
```

### ❓ 如何在 CI/CD 中使用？

```bash
# CI 环境中的最佳实践

# 1. 跳过交互式步骤
# justfile 自动检测 CI：
if [[ "${CI:-}" == "true" ]]; then
    exit 0  # 跳过某些步骤
fi

# 2. 使用无升级安装
just install-no-upgrade

# 3. 运行完整验证
just ci                # 所有检查

# 4. 环境变量
export CI=true
export HOMEUP_PROFILE=linux
```

### ❓ 如何查看模板变量值？

```bash
# 使用 just --show 查看实际值
just --show install-core

# 输出会显示：
# CHEZMOI_SOURCE="/Users/zopiya/workspace/homeup"
# PROFILE="macos"
# BREW_PREFIX="/opt/homebrew"

# 在脚本中查看
just --show check | grep PROFILE
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|----------|
| **新机器** | `just bootstrap` 一键初始化 |
| **日常使用** | `just apply` 应用更改，`just doctor` 验证 |
| **升级** | `just upgrade`（使用 topgrade）或 `brew upgrade` |
| **验证** | `just validate-all`（快速），`just ci`（完整） |
| **调试** | `just --verbose`，`just --show`，查看 justfile 源码 |
| **自定义** | 使用 `.justfile.local` 或修改 `justfile` |
| **CI/CD** | `just install-no-upgrade` + `just ci` |
| **平台特定** | 利用 PROFILE 变量和条件执行 |
| **文档** | `just help` 查看快速指南，`just --list` 完整列表 |

### 核心命令速查

```bash
# 初始化
just check               # 验证前置条件
just bootstrap           # 完整初始化（30 分钟左右）

# 日常
just apply              # 应用配置
just diff               # 查看差异
just doctor             # 健康检查
just upgrade            # 升级所有

# 添加和管理
just add ~/.zshrc       # 加入版本控制
just edit ~/.zshrc      # 编辑托管文件
just status             # 查看变化

# 验证
just validate-all       # 快速验证
just ci                 # 完整 CI 检查
just pkg-validate       # 检查包可用性
just pkg-duplicates     # 检查重复包

# 维护
just clean              # 清除缓存
just clean-all          # 清除缓存 + Brew 清理
just rescue             # 紧急修复

# 开发
just fmt                # 格式化 Shell 脚本
just lint               # Lint Shell 脚本
just install-hooks      # 安装 Git 钩子
```

---

## 参考资源

- [Just 官方文档](https://just.systems/)
- [Homeup justfile 源码](../justfile)
- [Homeup Brewfile 配置](../packages/)
- [Chezmoi 集成指南](CHEZMOI_COMPLETE_GUIDE.md)
- [Mise 运行时管理](MISE_GUIDE.md)
- [Homebrew 包管理](HOMEBREW_PACKAGE_MANAGEMENT_GUIDE.md)
