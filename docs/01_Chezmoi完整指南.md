# Chezmoi 完整指南：点文件管理和配置同步

> Homeup 的核心基础设施：安全、可版本控制的配置管理

**版本**: 1.0
**目标受众**: DevOps 工程师、系统管理员、多机器用户
**前置知识**: Git 基础、命令行操作

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [配置初始化](#配置初始化)
- [模板系统](#模板系统)
- [多机器同步](#多机器同步)
- [日常操作](#日常操作)
- [Homeup 特定工作流](#homeup-特定工作流)
- [常见问题](#常见问题)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### 什么是点文件管理？

**点文件** = 隐藏配置文件（以 `.` 开头）

```
~/.zshrc          # Zsh 配置
~/.config/nvim/   # Neovim 配置
~/.gitconfig      # Git 配置
~/.ssh/config     # SSH 配置
```

**问题**: 跨多台机器维护这些文件很困难

- 📱 MacBook 上的配置与 Linux 服务器不同步
- 🔄 新机器需要手动设置
- ⚠️ 配置不在版本控制中，丢失风险大

### Chezmoi 解决方案

```
GitHub 上的点文件仓库 (chezmoi source)
        ↓
Chezmoi（本地管理工具）
        ↓
真实的点文件（~/.zshrc 等）
```

**核心概念**:

| 术语 | 含义 | 例子 |
|------|------|------|
| **Source** | 点文件的版本控制存储库 | GitHub 私有仓库 |
| **Target** | 实际的点文件位置 | `~/.zshrc` |
| **Chezmoi State** | 已应用配置的跟踪 | `~/.local/share/chezmoi/` |

> 💡 **简单理解**: Chezmoi = Git for Dotfiles + 智能同步

---

## 快速开始

### ⚡ 5 分钟初始化

```bash
# 1. 克隆 Homeup（包含 Chezmoi 配置）
git clone https://github.com/yourusername/homeup.git
cd homeup

# 2. 初始化 Chezmoi
just init

# 3. 查看将要应用的更改
just diff

# 4. 应用配置
just apply

# 5. 验证
chezmoi status
```

### ✅ 验证安装

```bash
# 检查 Chezmoi
chezmoi --version

# 查看当前状态
chezmoi status

# 应显示：
# ...
# modified: .zshrc
# ...
```

---

## 配置初始化

### Homeup 的 Chezmoi 结构

Homeup 项目本身就是一个 Chezmoi 源：

```
homeup/                       # Chezmoi source 目录
├── .chezmoi.toml.tmpl       # Chezmoi 全局配置
├── .chezmoiignore.tmpl      # 忽略规则
├── dot_zshenv.tmpl          # Zsh 环境变量模板
│
├── dot_config/              # ~/.config 目录
│   ├── nvim/                # Neovim 配置
│   ├── zsh/                 # Zsh 配置
│   ├── git/                 # Git 配置
│   ├── tmux/                # Tmux 配置
│   └── ...
│
└── private_dot_ssh/         # ~/.ssh 目录（加密）
    ├── config.tmpl
    ├── allowed_signers.tmpl
    └── authorized_keys.tmpl
```

### 特殊文件说明

#### `.chezmoi.toml.tmpl`

全局配置和模板变量：

```toml
[data]
  profile = "macos"    # 或 "linux"
  username = "zopiya"
  hostname = "macbook"

[encrypted]
  suffix = ".age"      # 加密文件后缀
```

这些变量在模板中可用：`{{ .profile }}` 等

#### `.chezmoiignore.tmpl`

哪些文件不应该被管理：

```
# 忽略规则
.DS_Store
*.swp
*.tmp

# 平台特定（条件忽略）
{{- if ne .profile "macos" }}
dot_config/git/identity.gitconfig  # 仅 macOS 有 GPG
{{- end }}
```

#### `dot_` 前缀

Chezmoi 的约定：

```
dot_zshrc          → ~/.zshrc
dot_config/        → ~/.config/
private_dot_ssh/   → ~/.ssh/ (权限 700)
```

---

## 模板系统

### 为什么需要模板？

不同机器的配置不同：

```
MacBook:
  - 使用 /opt/homebrew/bin/
  - GPG 支持
  - YubiKey 配置

Linux Server:
  - 使用 /usr/local/bin/
  - 无 GUI 应用
  - SSH 密钥导向
```

### 模板语法

#### 条件渲染

```toml
# ~/.config/git/config.tmpl

[core]
  editor = nvim
  pager = delta

{{- if eq .profile "macos" }}
# macOS 特定配置
[gpg]
  program = gpg
{{- else }}
# Linux 特定配置
[credential]
  helper = store
{{- end }}
```

#### 变量替换

```bash
# ~/.zshenv.tmpl

export USER="{{ .username }}"
export HOSTNAME="{{ .hostname }}"

{{- if eq .profile "macos" }}
export BREW_PREFIX="/opt/homebrew"
{{- else }}
export BREW_PREFIX="/home/linuxbrew/.linuxbrew"
{{- end }}
```

#### 循环示例

```toml
{{- range .ssh_keys }}
# SSH 密钥 {{ . }}
{{- end }}
```

### 模板测试

```bash
# 查看模板渲染结果（不应用）
chezmoi cat ~/.zshrc

# 看到的是处理后的内容（变量已替换）
```

---

## 多机器同步

### 场景：MacBook + Linux VPS 配置同步

#### 步骤 1：创建私有 GitHub 仓库

```bash
# 在 GitHub 创建私有仓库 "dotfiles" 或 "homeup"
# 添加 SSH 密钥（用于无密码 clone）
```

#### 步骤 2：第一台机器初始化

```bash
# MacBook
chezmoi init https://github.com/yourusername/homeup.git
chezmoi apply
```

#### 步骤 3：第二台机器初始化

```bash
# Linux VPS
chezmoi init https://github.com/yourusername/homeup.git
chezmoi apply
```

Chezmoi 会自动检测平台，应用对应的配置！

#### 步骤 4：在一台机器上修改配置

```bash
# 在 MacBook 上
nvim ~/.zshrc

# Chezmoi 自动检测更改
chezmoi status

# 提交更改到版本控制
chezmoi add ~/.zshrc
```

#### 步骤 5：其他机器同步

```bash
# 在 Linux VPS 上
chezmoi update    # Pull + Apply
```

---

## 日常操作

### 添加新配置文件

当创建或修改配置文件后：

```bash
# 1. 修改配置
nvim ~/.tmux.conf

# 2. 告诉 Chezmoi 管理它
chezmoi add ~/.tmux.conf

# 3. 检查
chezmoi status

# 4. 提交
git -C ~/.local/share/chezmoi add ~/.tmux.conf
git -C ~/.local/share/chezmoi commit -m "feat: add tmux config"
```

### 编辑管理的文件

直接编辑真实文件或通过 Chezmoi：

```bash
# 方式 1：直接编辑（推荐）
nvim ~/.zshrc

# 方式 2：通过 Chezmoi
chezmoi edit ~/.zshrc
```

### 查看差异

```bash
# 查看本地改动 vs 最后应用的版本
chezmoi diff

# 只查看特定文件
chezmoi diff ~/.zshrc
```

### 应用配置

```bash
# 查看即将应用的更改
chezmoi diff

# 实际应用
chezmoi apply

# 或交互式确认
chezmoi apply --interactive
```

### 推送更改到 GitHub

```bash
# 在 Chezmoi 源目录提交
cd ~/.local/share/chezmoi/

# 查看状态
git status

# 提交更改
git add .
git commit -m "feat: update shell config"

# 推送到 GitHub
git push
```

---

## Homeup 特定工作流

### 使用 Just 进行 Chezmoi 操作

Homeup 提供了便捷的 Just 任务：

```bash
# 应用配置（推荐方式）
just apply

# 查看差异
just diff

# 交互式应用
just apply-interactive

# 编辑文件
just edit ~/.zshrc

# 添加文件
just add ~/.config/myapp/config.yaml

# 查看状态
just status
```

### Homeup 的验证系统

```bash
# 运行所有验证
just validate-all

# 这会检查：
# - Chezmoi 模板语法
# - 包的重复
# - 配置一致性
```

### Homeup 的初始化流程

```bash
# 一键初始化新机器
just bootstrap

# 这个任务依次运行：
# 1. just check          # 检查前置条件
# 2. just install        # 安装所有工具
# 3. just setup          # 配置环境
# 4. chezmoi apply       # 应用点文件
```

---

## 常见问题

### ❓ 如何加密敏感文件？

Chezmoi 支持 age 加密：

```bash
# 1. 设置加密
chezmoi encrypt-age-identity

# 2. 加密文件
chezmoi encrypt ~/.ssh/private_key

# 3. 该文件会被加密存储在仓库中
# 其他机器需要访问密钥才能解密
```

> ⚠️ **注意**: Homeup 在 `private_dot_ssh/` 中已有加密配置

### ❓ 如何忽略某个文件？

```bash
# 编辑忽略规则
chezmoi edit-config

# 或直接编辑 .chezmoiignore.tmpl
# 添加要忽略的文件，比如：
# .vimrc.local
# .gitconfig.local
```

### ❓ 不小心应用了不想要的配置？

```bash
# 查看即将应用的更改（不会真的应用）
chezmoi diff

# 如果觉得有问题，恢复到上一个状态
chezmoi revert
```

### ❓ 如何合并来自两台机器的配置？

```bash
# 机器 A 上
chezmoi apply
git -C ~/.local/share/chezmoi push

# 机器 B 上
chezmoi update  # 这会 pull + apply
```

如果有冲突，Git 会报告。手动解决后继续。

### ❓ 能否只管理某些目录？

可以通过 `.chezmoiignore` 实现：

```
# 只管理 ~/.config 和 ~/.ssh，忽略其他
{{- if not (has "config" .directories) }}
dot_config/**/*
{{- end }}
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **版本控制** | 所有配置都在 Git 中 |
| **机器特定** | 使用模板变量进行条件配置 |
| **敏感信息** | 加密或使用环境变量 |
| **同步频率** | 每日更新配置 |
| **备份** | GitHub 自动备份 |
| **新机器** | `just bootstrap` 一键初始化 |

### 核心命令速查

```bash
# 初始化
chezmoi init <repo-url>

# 日常使用
chezmoi status          # 查看状态
chezmoi diff            # 查看差异
chezmoi apply           # 应用配置
chezmoi update          # 同步并应用

# 管理文件
chezmoi add ~/.zshrc    # 添加文件
chezmoi edit ~/.zshrc   # 编辑文件
chezmoi remove ~/.zshrc # 停止管理文件

# Git 操作
chezmoi cd              # 进入 Chezmoi 源目录
git push                # 推送到 GitHub

# Homeup 特定
just bootstrap          # 完整初始化
just apply              # 应用配置
just diff               # 查看差异
just validate-all       # 运行验证
```

---

## 参考资源

- [Chezmoi 官方文档](https://www.chezmoi.io/reference/)
- [Chezmoi 模板指南](https://www.chezmoi.io/user-guide/use-templates-to-manage-different-machines/)
- [Homeup Chezmoi 配置](../.chezmoi.toml.tmpl)
- [Homeup 架构设计](architecture.md)
- [多机器同步指南](MULTI_MACHINE_SYNC_AND_BACKUP_GUIDE.md)

