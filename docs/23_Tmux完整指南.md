# Tmux 完整指南：终端复用与会话管理

> 从零到精通：构建高效的终端工作环境

**版本**: 1.0
**目标受众**: 开发者、运维工程师、系统管理员
**前置知识**: 基础 Shell 命令

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [配置优化](#配置优化)
- [高级技巧](#高级技巧)
- [工作流模式](#工作流模式)
- [与其他工具集成](#与其他工具集成)
- [常见问题](#常见问题)

---

## 核心概念

### Session（会话）

会话是 Tmux 的顶级容器，代表一个独立的工作环境。

```bash
tmux new-session -s mywork      # 创建会话
tmux list-sessions              # 列出所有会话
tmux attach-session -t mywork   # 连接会话
tmux kill-session -t mywork     # 删除会话
```

**实际场景**: 为每个项目创建独立的会话

```bash
# 项目 A
tmux new-session -s projectA -c ~/projects/projectA

# 项目 B
tmux new-session -s projectB -c ~/projects/projectB

# 快速切换
tmux select-session -t projectA
```

### Window（窗口）

每个会话包含多个窗口，窗口在会话内独立切换。

```bash
C-a c          # 创建新窗口
C-a n          # 下一个窗口
C-a p          # 上一个窗口
C-a 0-9        # 切换到指定窗口
C-a ,          # 重命名当前窗口
```

**最佳实践**: 为窗口命名以快速识别

```bash
C-a ,  # 然后输入窗口名，例如 "editor" 或 "server"
```

### Pane（窗格）

窗口可以分割成多个窗格，同时显示多个内容。

```bash
C-a |          # 垂直分割
C-a -          # 水平分割
C-a h/j/k/l    # 在窗格间导航（hjkl）
C-a x          # 关闭当前窗格
C-a z          # 最大化/还原窗格
```

---

## 快速开始

### 安装与初始化

```bash
brew install tmux         # macOS
apt install tmux          # Linux

# 验证安装
tmux -V
```

### Homeup 推荐配置

Homeup 项目已预配置了优化的 Tmux 配置：

```bash
~/.config/tmux/tmux.conf.tmpl
```

主要特性：
- ✅ 前缀键：`C-a`（比 `C-b` 更易按）
- ✅ 256 色和 True Color 支持
- ✅ 鼠标支持（选择、滚动、调整大小）
- ✅ 智能分割（保持当前目录）
- ✅ Vim 风格导航（hjkl）

### 使用内置函数快速操作

Homeup 提供的 Shell 函数简化了日常操作：

```bash
tm              # 交互式选择或创建会话
tm mywork       # 快速进入或创建 mywork 会话

tmk mywork      # 杀死指定会话
tmp             # 基于当前目录创建会话

tmw             # 窗口模糊查找和切换
tmka            # 杀死所有会话（确认式）
```

---

## 配置优化

### 核心配置解析

```tmux
# 前缀键配置
set -g prefix C-a                    # 设置 C-a 为前缀键
unbind C-b                           # 移除默认的 C-b
bind C-a send-prefix                 # 发送 C-a 到程序
bind C-a last-window                 # C-a C-a 切换到上一个窗口

# 窗口索引
set -g base-index 1                  # 窗口从 1 开始（不是 0）
setw -g pane-base-index 1            # 窗格也从 1 开始
set -g renumber-windows on           # 窗口号自动连续

# 终端和颜色
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"  # True Color 支持

# 鼠标支持
set -g mouse on                      # 启用鼠标

# 聚焦事件
set -g focus-events on               # 支持焦点事件
set -g set-clipboard on              # 系统剪贴板支持
```

### 性能优化

```tmux
# 响应时间
set -s escape-time 0                 # 立即响应 Esc
set -g display-time 2000             # 状态栏消息显示时间

# 历史缓冲
set -g history-limit 50000           # 增大历史缓冲

# 更新频率
set -g status-interval 1             # 状态栏更新频率（秒）
```

### 键位绑定优化

```tmux
# 分割窗格（智能保持当前目录）
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vim 风格导航
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# 快速调整窗格大小
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Alt + 方向键快速切换窗格
bind -n M-Left select-pane -L
bind -n M-Down select-pane -D
bind -n M-Up select-pane -U
bind -n M-Right select-pane -R
```

---

## 高级技巧

### 会话持久化

保持 Tmux 会话在服务器重启后存活：

```bash
# 分离所有会话
tmux detach-client -a

# 连接回来（会话仍然存在）
tmux list-sessions
tmux attach-session -t <session-name>
```

**关键点**: 即使 SSH 连接中断，会话仍然在后台运行。

### 窗格同步输入

在多个窗格中同时执行相同命令：

```tmux
# 绑定同步快捷键
bind S setw synchronize-panes

# 在状态栏会显示 "panes synchronized" 提示
```

### 命令模式

Tmux 命令模式中输入命令而非按键：

```bash
C-a :                         # 进入命令模式
:send-keys -t mywindow "ls"   # 在指定窗口运行命令
:kill-window -t mywindow      # 关闭窗口
:list-sessions                # 列出所有会话
```

### 窗格缩放

某个窗格需要更多空间时：

```bash
C-a z          # 最大化窗格（成为整个窗口）
C-a z          # 再按一次还原
```

### 窗格目录追踪

**问题**: 在新窗格中当前目录是 home，而非原窗格目录

**解决方案**: 分割时指定路径

```tmux
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
```

---

## 工作流模式

### 模式 1：按项目组织会话

```bash
# 创建项目会话框架
tmux new-session -s myproject -d -c ~/projects/myproject
tmux new-window -t myproject -n editor -c ~/projects/myproject
tmux new-window -t myproject -n server -c ~/projects/myproject
tmux new-window -t myproject -n logs -c ~/projects/myproject

# 进入会话
tmux attach-session -t myproject

# 窗口分布：
# ├─ Window 0: main     (监视日志或杂务)
# ├─ Window 1: editor   (代码编辑)
# ├─ Window 2: server   (运行应用)
# └─ Window 3: logs     (查看日志)
```

### 模式 2：按任务类型组织

```bash
# 全局会话用于快速任务
tmux new-session -s work -d
tmux new-window -t work -n dev
tmux new-window -t work -n devops
tmux new-window -t work -n docs

# 快速切换任务窗口
tmux select-window -t work:dev
tmux select-window -t work:devops
```

### 模式 3：远程开发环境

在服务器上创建持久会话：

```bash
# SSH 连接时恢复或创建会话
ssh user@server -t "tmux attach-session -t work || tmux new-session -s work"

# 这样每次连接都进入相同的会话环境
```

---

## 与其他工具集成

### Vim/Neovim 集成

在 Tmux 中使用 Vim 的窗格导航：

```vim
" ~/.config/nvim/init.lua
-- Vim 中 Ctrl+hjkl 等同于 Tmux 中的 Alt+hjkl
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
```

### Zoxide 集成

在 Tmux 中快速导航目录：

```bash
# .zshrc
eval "$(zoxide init zsh)"

# 在 Tmux 窗格中使用
z myproject      # 跳转到常用目录
zi               # 交互式选择
```

### Lazygit 集成

```bash
# 在 Tmux 窗格中打开 lazygit
tmux new-window -n git -c "#{pane_current_path}"
# 然后在该窗格中运行 lg（lazygit 别名）
```

### Mise 集成

```bash
# 在 Tmux 窗格创建时自动加载项目环境
tmux new-window -c ~/myproject   # 自动触发 direnv/mise

# Mise 会自动读取 .mise.toml 并设置环境
```

---

## 常见问题

### Q1: 如何在 Tmux 中复制文本？

```bash
# 进入复制模式
C-a [

# 移动到起点，按 Space 开始选择
# 移动到终点，按 Enter 复制

# 粘贴
C-a ]
```

**提示**: 启用鼠标后可以直接拖拽选择。

### Q2: 如何保持 Tmux 会话活跃？

```bash
# 方法 1：设置活动告警
setw -g monitor-activity on
set -g visual-activity on

# 方法 2：定期执行命令保持连接
# 在窗格中运行：
watch -n 300 "date"   # 每 5 分钟输出日期
```

### Q3: Tmux 和 SSH 一起使用时遇到颜色问题？

```bash
# 在 SSH 连接中设置
export TERM=xterm-256color

# 或在 ~/.zshrc 中
alias ssh='TERM=xterm-256color ssh'
```

### Q4: 如何在 Tmux 中使用系统剪贴板？

```tmux
# macOS
set -g copy-command "pbcopy"

# Linux (需要 xclip)
set -g copy-command "xclip -i -selection clipboard"
```

### Q5: 如何共享 Tmux 会话？

```bash
# 用户 A 创建会话
tmux new-session -s shared

# 用户 B 加入同一会话
tmux attach-session -t shared

# 两用户现在看到相同的会话（可见相对方的光标）
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **会话数** | 按项目/任务组织，3-5 个并发会话最优 |
| **窗口数** | 每个会话 3-5 个窗口（editor, server, logs 等） |
| **窗格分割** | 避免过度分割（>4 个），难以管理 |
| **命名规范** | 使用有意义的名称（不要用 "1", "2"） |
| **绑定键** | 学习 Vim 风格的导航（hjkl），提高效率 |
| **脚本化** | 创建 Shell 函数自动化常见工作流 |

---

## 参考资源

- [Tmux 官方文档](https://man.openbsd.org/tmux)
- [Homeup Tmux 配置](../dot_config/tmux/tmux.conf.tmpl)
- [Shell 函数集](../dot_config/zsh/functions.zsh) - `tm`, `tmk`, `tmp`, `tmw`, `tmka`

