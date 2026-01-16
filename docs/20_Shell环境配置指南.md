# 高效 Shell 环境配置指南：Zsh + 现代工具栈

> 从 Bash 到 Zsh：提升 Shell 生产力的完整手册

**版本**: 1.0
**目标受众**: Shell 初学者、生产力极客、系统管理员
**前置知识**: 基础 Linux/Unix 命令

---

## 目录

- [核心概念](#核心概念)
- [Zsh 基础](#zsh-基础)
- [插件管理：Sheldon](#插件管理sheldon)
- [提示符：Starship](#提示符starship)
- [导航优化](#导航优化)
- [历史管理](#历史管理)
- [别名与函数](#别名与函数)
- [工作流优化](#工作流优化)
- [性能调优](#性能调优)

---

## 核心概念

### Zsh vs Bash

| 特性 | Bash | Zsh |
|------|------|-----|
| **自动补全** | 基础 | 强大（上下文感知） |
| **插件系统** | 无 | 丰富生态 |
| **主题支持** | 无 | 内置支持 |
| **数组** | 一维 | 多维 |
| **学习曲线** | 平 | 稍陡（值得） |

**为什么选择 Zsh？**
- ✅ 强大的补全引擎
- ✅ 现代化的语法
- ✅ 活跃的社区和插件生态
- ✅ 与现代工具深度集成

---

## Zsh 基础

### 安装与初始化

```bash
# macOS (已预装，但可升级)
brew install zsh

# Linux
apt install zsh  # Ubuntu/Debian
dnf install zsh  # Fedora
pacman -S zsh    # Arch

# 设为默认 Shell
chsh -s $(which zsh)

# 验证
zsh --version
```

### Zsh 配置文件加载顺序

```
~/.zprofile         ← 登录 Shell（SSH、终端应用首次启动）
~/.zshrc            ← 交互 Shell（每次新窗口）
~/.zshenv           ← 所有 Zsh 实例（最早加载）
```

**最佳实践**:
- `.zshenv`: 环境变量（PATH、导出等）
- `.zshrc`: 交互配置（别名、函数、提示符）
- `.zprofile`: 登录特定配置（极少使用）

### Homeup 的 Zsh 配置

```bash
~/.zshrc                # 主配置（由 Chezmoi 管理）
~/.config/zsh/
├── aliases.zsh         # 别名（已精简）
├── functions.zsh       # 工作流函数（600+ 行）
├── exports.zsh.tmpl    # 环境变量
├── brew.zsh.tmpl       # Homebrew 配置
├── tools.zsh.tmpl      # 工具初始化
└── ssh-agent.zsh.tmpl  # SSH 代理配置
```

---

## 插件管理：Sheldon

### 为什么用 Sheldon？

| 工具 | 性能 | 功能 | 学习曲线 |
|------|------|------|---------|
| **Oh My Zsh** | 慢（100+ms） | 全能 | 简单但太重 |
| **Zinit** | 快 | 强大 | 陡峭 |
| **Sheldon** | ⚡ 最快 | 够用 | 平缓 |

Sheldon 优势:
- Rust 实现，极快
- 声明式配置（TOML）
- 并行下载插件
- 轻量级（不含糖衣）

### 插件配置

```toml
# ~/.config/sheldon/plugins.toml

[plugins]
# 常用插件
zsh-users/zsh-autosuggestions = { clone = { depth = 1 } }
zsh-users/zsh-syntax-highlighting = { clone = { depth = 1 } }
zsh-users/zsh-completions = { clone = { depth = 1 } }

# Git 增强
wfxr/forgit = { clone = { depth = 1 } }  # Git 交互工具

# 目录导航
ajeetdsouza/zoxide = { apply = ["source"] }

# 其他增强
Aloxaf/fzf-tab = { clone = { depth = 1 } }  # FZF 补全
```

### Sheldon 命令

```bash
sheldon lock                # 生成锁文件（版本锁定）
sheldon source              # 输出初始化脚本
eval "$(sheldon source)"    # 在 .zshrc 中初始化
```

---

## 提示符：Starship

### 为什么用 Starship？

- 🚀 极快（Rust 实现）
- 📦 跨 Shell 支持（Zsh/Bash/Fish）
- 🎨 美观的默认主题
- 🔧 高度可定制

### 快速配置

```bash
# 初始化
eval "$(starship init zsh)"

# 配置位置
~/.config/starship.toml
```

### 核心配置

```toml
# starship.toml

format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$rust\
$line_break\
$character"""

# 字符提示符
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

# 目录显示
[directory]
truncation_length = 3
format = "[$path]($style) "

# Git 集成
[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "

[git_status]
format = "([\\[$all_status$ahead_behind\\]]($style) )"

# 语言版本显示
[nodejs]
symbol = " "
format = "[$symbol($version)]($style) "

[python]
symbol = " "
format = "[$symbol($version)]($style) "

[rust]
symbol = " "
format = "[$symbol($version)]($style) "

# 显示执行时间
[cmd_duration]
min_time = 1000  # 仅显示 >1s 的命令
format = "[$duration]($style) "
```

### 高级特性：条件显示

```toml
# 仅在 Rust 项目中显示 Rust 版本
[rust]
disabled = false
detect_files = ["Cargo.toml"]
detect_folders = []

# 仅在 Node 项目中显示
[nodejs]
disabled = false
detect_files = ["package.json"]
```

---

## 导航优化

### Zoxide：智能跳转

```bash
# 初始化
eval "$(zoxide init zsh)"

# 使用
z project              # 跳转到最常用的包含 "project" 的目录
zi                     # 交互式选择

# 原理：基于频率和最近性的加权算法
# z 会记住访问历史并学习
```

### Fzf：模糊查找

```bash
# 初始化（由 Homebrew 安装脚本完成）
eval "$(fzf --zsh)"

# 快捷键
Ctrl+R       # 搜索历史命令
Ctrl+T       # 搜索文件（预览）
Alt+C        # 搜索目录
```

### Fzf + Zoxide 结合

```bash
# .zshrc 中添加
function z() {
  if [[ "$#" == "0" ]]; then
    __zoxide_z -i
  else
    __zoxide_z "$@"
  fi
}
```

---

## 历史管理

### Atuin：同步 Shell 历史

Atuin 将 Shell 历史上传到云端，实现跨设备同步。

```bash
# 初始化
eval "$(atuin init zsh)"

# 使用
Ctrl+R       # 搜索历史（比 fzf 更强大）

# 配置 (~/.config/atuin/config.toml)
sync_address = "https://your-atuin-server"
sync_frequency = "5m"
```

### 本地历史优化

```bash
# ~/.zshrc

# 扩大历史限制
HISTSIZE=100000
SAVEHIST=100000

# 历史文件位置
HISTFILE=~/.zsh_history

# 高级选项
setopt INC_APPEND_HISTORY         # 实时添加历史
setopt HIST_IGNORE_DUPS          # 忽略连续重复
setopt HIST_FIND_NO_DUPS         # 搜索时跳过重复
setopt HIST_SAVE_NO_DUPS         # 保存时移除重复
```

---

## 别名与函数

### 别名（快捷命令）

```bash
# 目录
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"

# 现代替代
alias ls="eza --group-directories-first"
alias cat="bat"
alias grep="rg"

# Git
alias g="git"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"

# 工具
alias v="nvim"
alias tm="tmux"
alias lg="lazygit"
```

### 函数（可编程别名）

```bash
# 创建目录并进入
mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

# 快速备份文件
bak() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  cp "$1" "$1.bak.$timestamp"
  echo "✅ Backed up to $1.bak.$timestamp"
}

# 快速 HTTP 服务器
serve() {
  local port="${1:-8000}"
  python -m http.server "$port"
}

# Tmux 快速创建
tm() {
  if [[ -z "$1" ]]; then
    tmux list-sessions | fzf | awk '{print $1}' | xargs -I {} tmux attach-session -t {}
  else
    tmux new-session -s "$1" -c "$PWD"
  fi
}
```

---

## 工作流优化

### 工作流 1：快速项目切换

```bash
# 在 ~/.zshrc 中
proj() {
  local project_root="${PROJECTS_ROOT:-$HOME/projects}"
  local project=$(ls -d "$project_root"/*/ 2>/dev/null | xargs -n 1 basename | fzf)
  [[ -n "$project" ]] && cd "$project_root/$project"
}

# 使用
proj      # 交互式选择项目
```

### 工作流 2：Tmux + Mise + Direnv

```bash
# 自动化项目启动
work() {
  local project=$1
  cd "$project" || return

  # Direnv + Mise 自动加载
  direnv reload

  # 创建 Tmux 会话
  tmux new-session -s "$(basename $project)" -d
  tmux send-keys -t "$(basename $project)" "pnpm dev" Enter

  # 进入会话
  tmux attach-session -t "$(basename $project)"
}

# 使用
work ~/projects/myapp
```

### 工作流 3：Git 增强

```bash
# 使用 Forgit（通过 Sheldon 安装）
ga       # 交互式 git add
gco      # 交互式 git checkout
glog     # 漂亮的 git log

# 使用 Lazygit
lg       # 完整的 Git TUI
```

---

## 性能调优

### 测量启动时间

```bash
# 测量 Shell 启动时间
time zsh -i -c exit

# 分析加载时间
zsh -i -x -c exit 2>&1 | head -50
```

### 优化技巧

1. **延迟加载**

```bash
# 不要在启动时初始化所有工具
# 而是按需加载

# ❌ 不好
eval "$(rbenv init -)"
eval "$(pyenv init -)"
eval "$(nvm init -)"

# ✅ 好
# 使用 Mise 替代（启动更快）
eval "$(mise activate)"
```

2. **异步初始化**

```bash
# 在后台初始化慢的工具
(eval "$(fzf --zsh)") &
```

3. **条件加载**

```bash
# 仅在需要时加载
if command -v docker &>/dev/null; then
  eval "$(docker completion zsh)"
fi
```

### 启动时间目标

- ⚡ <100ms: 极速（使用 Mise + Sheldon）
- ✅ <300ms: 良好
- ⚠️  >500ms: 需要优化

---

## 完整配置示例

```bash
# ~/.zshrc

# ============================================================================
# 环境变量
# ============================================================================
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export TERM="xterm-256color"

# 历史配置
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history

# ============================================================================
# 插件管理 (Sheldon)
# ============================================================================
eval "$(sheldon source)"

# ============================================================================
# 提示符 (Starship)
# ============================================================================
eval "$(starship init zsh)"

# ============================================================================
# 版本管理 (Mise)
# ============================================================================
eval "$(mise activate zsh)"

# ============================================================================
# 导航优化
# ============================================================================
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# ============================================================================
# 历史选项
# ============================================================================
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

# ============================================================================
# 加载本地配置
# ============================================================================
[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh
[[ -f ~/.config/zsh/functions.zsh ]] && source ~/.config/zsh/functions.zsh

# ============================================================================
# 自定义快捷键
# ============================================================================
# Vim 模式
bindkey -v

# 快速进入 Vim 模式
bindkey jk vi-cmd-mode
```

---

## 速查表

```bash
# 导航
z project              # 跳转到 project 目录
zi                     # 交互式目录选择
Ctrl+T                 # FZF 文件搜索

# 历史
Ctrl+R                 # 搜索历史（Atuin）
history                # 显示所有历史

# Git 增强
ga                     # 交互式 add
glog                   # 漂亮的日志
lg                     # Lazygit TUI

# Tmux 集成
tm                     # 创建/选择会话
tmk session_name       # 杀死会话
tmp                    # 目录会话
```

---

## 总结与最佳实践

| 组件 | 工具 | 用途 | 性能 |
|------|------|------|------|
| **Shell** | Zsh | 现代交互 | ⚡⚡⚡ |
| **插件管理** | Sheldon | 快速加载 | ⚡⚡⚡ |
| **提示符** | Starship | 信息展示 | ⚡⚡⚡ |
| **导航** | Zoxide | 智能跳转 | ⚡⚡⚡ |
| **搜索** | Fzf | 交互查询 | ⚡⚡⚡ |
| **历史** | Atuin | 云同步 | ⚡⚡ |

**目标**: 启动时间 <100ms，工作流流畅无缝

---

## 参考资源

- [Zsh 官方文档](http://zsh.sourceforge.net/Doc/)
- [Sheldon 文档](https://sheldon.rs)
- [Starship 文档](https://starship.rs)
- [Zoxide 文档](https://github.com/ajeetdsouza/zoxide)
- [Atuin 文档](https://atuin.sh)
- [Homeup Shell 配置](../dot_config/zsh)

