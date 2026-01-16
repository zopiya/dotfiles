# Ghostty 终端配置和集成指南

> 本指南详细说明如何在 homeup 项目中使用和配置 Ghostty 终端，以及如何与你的现有开发工具（Tmux、Neovim、Zsh）无缝集成。

## 📋 目录

1. [快速开始](#快速开始)
2. [文件位置](#文件位置)
3. [核心配置说明](#核心配置说明)
4. [工具集成](#工具集成)
5. [远程开发](#远程开发)
6. [性能优化](#性能优化)
7. [快捷键参考](#快捷键参考)
8. [故障排查](#故障排查)
9. [社区资源](#社区资源)

---

## 快速开始

### 1. 安装 Ghostty

**macOS:**
```bash
# 使用 Homebrew 安装
brew install ghostty

# 或从官网下载：https://ghostty.org/download
```

**Linux:**
```bash
# 参考官方文档：https://ghostty.org/docs/install
# 通常需要从源码构建，或使用包管理器（如果有）
```

### 2. 应用配置

如果你已经使用 chezmoi，配置会自动同步：

```bash
# 首次设置
chezmoi init --source . --apply

# 更新现有配置
chezmoi apply
```

配置文件会自动部署到：
- **macOS:** `~/Library/Application Support/com.mitchellh.ghostty/config`
- **Linux:** `~/.config/ghostty/config`

### 3. 验证安装

```bash
# 检查版本
ghostty --version

# 显示当前配置
ghostty +show-config

# 列出可用主题
ghostty +list-themes
```

---

## 文件位置

### 项目内

```
homeup/
├── dot_config/
│   ├── ghostty/
│   │   └── config.toml          ← 主配置文件（本项目管理）
│   ├── zsh/
│   │   └── exports.zsh.tmpl     ← 已更新：添加了 TERM 设置
│   ├── tmux/
│   │   └── tmux.conf.tmpl
│   └── nvim/
│       └── init.lua
└── docs/
    └── GHOSTTY_SETUP.md         ← 本文档
```

### 系统路径

**macOS:**
```
~/Library/Application Support/com.mitchellh.ghostty/
├── config                       # Main config file
├── cache/
└── logs/
```

**Linux:**
```
~/.config/ghostty/
├── config
├── cache/
└── logs/
```

### 获取配置路径

```bash
# 列出当前配置位置
ghostty +show-paths

# 打开配置目录
# macOS: open ~/Library/Application\ Support/com.mitchellh.ghostty/
# Linux: nautilus ~/.config/ghostty/
```

---

## 核心配置说明

### 1. 性能设置

#### 字体

你的配置使用 **Monaspace Neon**，这是一个优秀的开发字体。

**为什么选择 Monaspace？**
- ✅ 清晰的代码标志
- ✅ 支持连字（ligatures）
- ✅ 现代字体渲染
- ✅ 优秀的 Unicode 支持

**安装：**
```bash
brew install --cask font-monaspace
```

**备选方案（如果 Monaspace 性能问题）：**

| 字体 | 特点 | 安装 |
|------|------|------|
| **Fira Mono** | 清晰、现代 | `brew install --cask font-fira-mono` |
| **JetBrains Mono** | 专为编码设计 | `brew install --cask font-jetbrains-mono` |
| **Hack** | 极简、快速 | `brew install --cask font-hack` |
| **Monaco** | macOS 原生，超快 | 无需安装（系统自带） |

#### 内存和渲染

```toml
scrollback-lines = 10000        # 10,000 行历史记录
vsync = true                    # 垂直同步
refresh-rate = 0                # 使用显示器刷新率
```

**调优建议：**
- 如果遇到滚动卡顿 → 减少 `scrollback-lines` 到 5000
- 如果 CPU 占用高 → 禁用 `vsync = false`
- 对于远程 SSH → 降低 `font-size` 到 12

### 2. 主题配置

你的配置使用 **GitHub Dark**，这是一个平衡良好的主题。

```toml
theme = "GitHub Dark"
```

**其他推荐主题：**

```bash
# 列出所有主题
ghostty +list-themes

# 流行选择：
# - GitHub Dark       → 清晰、专业、最小化
# - Catppuccin Mocha  → 温暖、流行、现代
# - Dracula           → 高对比、鲜艳
# - Nord              → 冷色调、舒适
# - Solarized Dark    → 科学设计的配色
```

**切换主题：**
编辑 `~/.config/ghostty/config` 或使用 chezmoi：

```bash
# 编辑项目配置
vi dot_config/ghostty/config.toml

# 更改 theme = "GitHub Dark" 为你喜欢的主题

# 应用更改
chezmoi apply
```

### 3. 窗口和分页

```toml
macos-titlebar-style = "tabs"   # 显示原生标签栏
initial-window = {
    width = 220,                # 字符数
    height = 50,
}
```

**标签页快捷键：**
- `Cmd+T` → 新标签页
- `Cmd+W` → 关闭标签页
- `Cmd+Shift+Right/Left` → 切换标签页
- `Cmd+1~9` → 跳转到指定标签页

---

## 工具集成

### 1. Tmux 集成 🔗

#### 核心概念

你的系统采用了**最优的快捷键划分**：

| 层级 | 前缀 | 作用 | 示例 |
|------|------|------|------|
| **Ghostty** | `Cmd+*` | 窗口/标签页管理 | `Cmd+T` 新标签 |
| **Tmux** | `Ctrl+A` | 窗口/面板管理 | `Ctrl+A, C` 新窗口 |
| **Shell** | 标准 | 文本编辑 | `Ctrl+R` 历史搜索 |
| **应用** | 应用特定 | 编辑器/REPL | `Vim` 模式命令 |

#### 工作流示例

```bash
# 1. 打开 Ghostty
# 使用 Cmd+T 创建新标签（Ghostty 层级）

# 2. SSH 到远程服务器
ssh remote-server

# 3. 在远程启动 Tmux
tmux new-session -s work

# 4. 在 Tmux 中创建新窗口
# 使用 Ctrl+A, C （Tmux 层级）

# 5. 在 Vim 中编辑
vim file.py

# 6. 在 Vim 中搜索
# 使用 /pattern （Vim 层级）
```

#### 颜色一致性

你的 Tmux 配置使用 **Orange (#d65407)** 作为强调色。Ghostty 的 GitHub Dark 主题支持同样的暖色调。

#### 粘贴和复制

```toml
# Ghostty 配置
copy-on-select = true           # 自动复制选中文本
paste-protection = true         # 防止意外执行

# Tmux 配置已支持
# - Ctrl+A, [ → 进入复制模式
# - v → 开始选择
# - y → 复制
```

### 2. Neovim/Vim 集成 ✏️

#### 配置

在你的 `nvim/init.lua` 中，确保启用真实色彩：

```lua
-- Neovim configuration snippet
if vim.env.TERM == "ghostty" or vim.env.COLORTERM == "truecolor" then
    vim.opt.termguicolors = true
end

-- Optional: Better cursor styles
vim.opt.guicursor = {
    "n-v-c:block",              -- Normal/visual/command: block
    "i-ci-ve:ver25",            -- Insert: vertical bar
    "r-cr:hor20",               -- Replace: horizontal bar
    "o:hor50",                  -- Operator-pending: horizontal
}
```

#### 颜色渲染

- ✅ **24-bit True Color** - 完全支持
- ✅ **Undercurl** - 错误下划波浪线
- ✅ **Color Blend** - 透明度和混合
- ✅ **Semantic Highlighting** - LSP 颜色

#### 鼠标支持

```lua
-- Neovim already detects Ghostty's mouse support
vim.opt.mouse = "a"  -- Enable mouse in all modes
```

### 3. Zsh 集成 🐚

#### Shell 集成（自动）

Ghostty 检测 Zsh 并启用 Shell Integration：

```toml
# 在 ghostty/config 中
shell-integration = "detect"    # 自动检测 zsh
```

#### 环境变量

已在 `dot_config/zsh/exports.zsh.tmpl` 中配置：

```bash
export COLORTERM=truecolor     # 24-bit 真实色彩
export TERM=xterm-256color     # 或 ghostty（如果已安装 terminfo）
```

#### 命令补全

Ghostty 与 Zsh 补全完全兼容，无需额外配置。

#### 性能优化

```bash
# 在 ~/.zshrc 中（由 chezmoi 管理）
# 已包含的优化：
# - Lazy loading of tools
# - Selective sourcing of modules
# - Fast prompt rendering (Starship)
```

---

## 远程开发

### 1. SSH 配置

你已在项目中配置了 SSH。确保 `~/.ssh/config` 中有：

```bash
Host remote-server
    HostName server.example.com
    User your-username

    # Session persistence
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist yes

    # Keep connection alive
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### 2. 远程 Ghostty 设置

#### 选项 A：本地 Ghostty + 远程 Shell（推荐 ⭐）

```bash
# 本地工作流
┌─────────────┐
│ Ghostty     │ ← GPU 加速（本地渲染）
├─────────────┤
│ Zsh         │ ← 本地 shell
│ SSH connect │ ← 到远程
└─────────────┘
```

**优点：**
- 最流畅的用户体验
- 本地渲染性能优秀
- 网络延迟影响小（只有命令和输出）

**使用方法：**
```bash
# 打开 Ghostty
# 连接到远程
ssh remote-server

# 在远程执行命令
python script.py

# 返回本地
exit
```

#### 选项 B：本地 Ghostty + 远程 Tmux

```bash
# 增强的远程工作流
┌─────────────────────┐
│ Ghostty (local)     │
├─────────────────────┤
│ SSH                 │
│ └─ Tmux (remote)    │
│    ├─ Window 1      │
│    ├─ Window 2      │
│    └─ Window 3      │
└─────────────────────┘
```

**优点：**
- 会话持久化
- 断网重连无损
- 适合长期任务

**使用方法：**
```bash
# SSH 到远程
ssh remote-server

# 创建或重连 Tmux 会话
tmux new-session -s work
# 或
tmux attach-session -t work

# 在 Tmux 中工作
# Ctrl+A, C → 新窗口
# Ctrl+A, N → 下一个窗口
```

### 3. 远程终端配置

在远程服务器上安装或配置 Ghostty 支持（可选）：

```bash
# 检查远程 TERM 支持
ssh remote-server "infocmp ghostty" 2>/dev/null || echo "Not installed"

# 如果需要，安装 terminfo
ssh remote-server '
  mkdir -p ~/.terminfo
  infocmp ghostty > /tmp/ghostty.terminfo 2>/dev/null || \
  curl -s https://raw.githubusercontent.com/ghostty-org/ghostty/main/terminfo/ghostty.terminfo > /tmp/ghostty.terminfo
  tic -x -o ~/.terminfo /tmp/ghostty.terminfo
'
```

### 4. 远程 Zsh 配置

在远程服务器的 `~/.zshrc` 中：

```bash
# 基础设置
export TERM=xterm-256color
export COLORTERM=truecolor

# Shell Integration（如果已安装）
# [eval Ghostty shell integration]
```

### 5. 网络延迟优化

**症状：** 远程 SSH 响应慢

**解决方案：**

```bash
# 1. 启用 SSH 连接复用
# ~/.ssh/config 已配置 ControlMaster

# 2. 减少往返次间隔
ssh -o ServerAliveInterval=30 remote-server

# 3. 使用压缩
ssh -C remote-server

# 4. Tmux 优化（如果使用）
# 在 tmux.conf 中
set -sg escape-time 10          # 减少 ESC 延迟
set -g focus-events on          # 启用焦点事件
```

---

## 性能优化

### 1. 诊断性能问题

```bash
# 查看 Ghostty 进程
ps aux | grep ghostty

# 监控性能
# macOS
top -p $(pgrep ghostty)

# Linux
htop -p $(pgrep ghostty)

# 渲染性能测试
time (for i in {1..100}; do echo "Test $i"; done)
```

### 2. 优化建议

| 问题 | 症状 | 解决方案 |
|------|------|---------|
| **内存占用高** | 应用占用 > 500MB | 减少 `scrollback-lines` 到 5000 |
| **滚动卡顿** | 快速滚动时延迟 | 禁用 `vsync = false`，或减少 `scrollback-lines` |
| **启动缓慢** | Ghostty 启动 > 2s | 简化 shell 配置，使用 `time` 诊断 |
| **CPU 占用高** | 持续占用 > 50% | 检查后台进程，减少主题特效 |
| **字体模糊** | 文字显示不清晰 | 更改 `text-anti-alias = "monochrome"` |
| **远程连接慢** | SSH 响应迟钝 | 启用 `ControlMaster`，检查网络 |

### 3. 快速优化配置

```toml
# 性能优先（牺牲一些美观）
scrollback-lines = 3000
vsync = false
font-size = 12
text-anti-alias = "monochrome"
theme = "GitHub Dark"           # 简洁主题

# 平衡配置（推荐）
scrollback-lines = 10000
vsync = true
font-size = 14
text-anti-alias = "subpixel"
theme = "GitHub Dark"

# 视觉优先（消耗更多资源）
scrollback-lines = 50000
vsync = true
font-size = 16
text-anti-alias = "subpixel"
theme = "Catppuccin Mocha"      # 复杂的主题
```

---

## 快捷键参考

### Ghostty 快捷键

#### 窗口/标签管理
| 快捷键 | 动作 |
|--------|------|
| `Cmd+N` | 新窗口 |
| `Cmd+W` | 关闭窗口 |
| `Cmd+T` | 新标签页 |
| `Cmd+Shift+W` | 关闭标签页 |
| `Cmd+Shift+Right` | 下一个标签页 |
| `Cmd+Shift+Left` | 上一个标签页 |
| `Cmd+1~9` | 跳转到标签页 1-9 |

#### 文本操作
| 快捷键 | 动作 |
|--------|------|
| `Cmd+C` | 复制 |
| `Cmd+V` | 粘贴 |
| `Cmd+A` | 全选 |
| `Cmd+F` | 搜索 |

#### 字体
| 快捷键 | 动作 |
|--------|------|
| `Cmd++` | 增大字体 |
| `Cmd+-` | 减小字体 |
| `Cmd+0` | 重置字体 |

#### 其他
| 快捷键 | 动作 |
|--------|------|
| `Cmd+,` | 打开配置文件 |
| `Cmd+Ctrl+F` | 全屏 |
| `Cmd+Q` | 退出 Ghostty |

### Tmux 快捷键（Ghostty 内部）

| 快捷键 | 动作 | 说明 |
|--------|------|------|
| `Ctrl+A, C` | 新窗口 | 在 Tmux 中 |
| `Ctrl+A, N` | 下一个窗口 | |
| `Ctrl+A, P` | 上一个窗口 | |
| `Ctrl+A, H/J/K/L` | 切换面板 | Vim 方向键 |
| `Ctrl+A, \|` | 分割窗口（水平） | |
| `Ctrl+A, -` | 分割窗口（垂直） | |
| `Ctrl+A, [` | 进入复制模式 | 然后 `v` 选择，`y` 复制 |
| `Ctrl+A, ]` | 粘贴 | 从复制缓冲区 |

### Zsh 快捷键（Shell 内部）

| 快捷键 | 动作 |
|--------|------|
| `Ctrl+R` | 反向搜索历史 |
| `Ctrl+A` | 移到行首 |
| `Ctrl+E` | 移到行尾 |
| `Ctrl+U` | 删除到行首 |
| `Ctrl+K` | 删除到行尾 |
| `Ctrl+W` | 删除前一个单词 |
| `Alt+D` | 删除后一个单词 |
| `Ctrl+L` | 清屏 |

---

## 故障排查

### 常见问题

#### Q1: Ghostty 启动很慢

**诊断：**
```bash
# 测量启动时间
time ghostty -e exit

# 检查 shell 配置
time zsh -i -c exit
```

**解决方案：**
1. 检查 Zsh 配置文件（太多 plugin）
2. 减少在 .zshrc 中初始化的工具
3. 使用延迟加载（lazy loading）

#### Q2: 颜色在 SSH 上看起来不对

**诊断：**
```bash
ssh remote-server "echo \$TERM"
ssh remote-server "echo \$COLORTERM"
```

**解决方案：**
```bash
# 强制使用特定 TERM
ssh -o SendEnv=TERM remote-server

# 或在 ~/.ssh/config 中
SendEnv TERM LANG LC_*
```

#### Q3: Tmux 和 Ghostty 快捷键冲突

**原因：** `Ctrl+A` 被重复使用

**解决方案：**
✅ **已解决** - 你的配置使用 `Cmd+*` 给 Ghostty，`Ctrl+A` 给 Tmux，无冲突。

#### Q4: 在远程服务器上字体显示不正常

**解决方案：**
```bash
# 方案 1：在本地使用所有特性，远程显示基础文本
# 这是推荐做法

# 方案 2：在远程服务器安装相同字体
ssh remote-server "
  # Ubuntu/Debian
  sudo apt install fonts-monaspace

  # RHEL/CentOS
  sudo yum install fonts-monaspace

  # macOS
  brew install --cask font-monaspace
"
```

#### Q5: 粘贴时执行了意外命令

**原因：** `paste-protection` 未启用

**解决方案：**
```toml
# 在 ghostty/config 中
paste-protection = true
```

#### Q6: 在 Vim/Neovim 中颜色显示错误

**诊断：**
```bash
# 检查 TERM 和色彩支持
echo $TERM
echo $COLORTERM

# 在 Vim 中
:set t_Co?     " 应该返回 256（或更高）
```

**解决方案：**
```lua
-- nvim/init.lua
vim.opt.termguicolors = true
```

#### Q7: Ghostty 占用内存过高

**诊断：**
```bash
ps aux | grep ghostty
# 查看 RSS（实际占用内存）列
```

**解决方案：**
```toml
# 减少历史记录
scrollback-lines = 5000

# 或完全禁用（不推荐）
# scrollback-lines = 0
```

#### Q8: 在 Linux 上 Ghostty 不可用

**解决方案：**
1. Ghostty 对 Linux 的支持仍在开发中
2. 临时使用 Alacritty 或 Kitty
3. 从源代码编译最新版本

```bash
# 检查官方 Linux 支持状态
# https://ghostty.org/docs/install
```

### 获取帮助

```bash
# 查看帮助
ghostty --help
ghostty +help

# 显示配置路径
ghostty +show-paths

# 显示当前配置
ghostty +show-config

# 查看日志（如果有问题）
cat ~/Library/Application\ Support/com.mitchellh.ghostty/logs/
# 或 Linux
cat ~/.config/ghostty/logs/
```

---

## 社区资源

### 官方资源

- **官网**: https://ghostty.org
- **文档**: https://ghostty.org/docs
- **GitHub**: https://github.com/ghostty-org/ghostty
- **问题反馈**: https://github.com/ghostty-org/ghostty/issues

### 配置和主题

- **配置示例**: https://github.com/ghostty-org/ghostty/tree/main/examples
- **主题库**: https://github.com/ghostty-org/ghostty-themes
- **社区配置**: https://github.com/search?q=ghostty+config

### 相关项目

- **Alacritty** - GPU 加速终端（对比）
- **Kitty** - 功能丰富的终端
- **WezTerm** - 跨平台 GPU 加速终端
- **Iterm2** - macOS 专用（已有替代品）

### 学习资源

- **Tmux 官方**: https://github.com/tmux/tmux/wiki
- **Zsh 文档**: http://zsh.sourceforge.net/Doc/
- **Neovim 文档**: https://neovim.io/doc/
- **Shell 脚本指南**: https://mywiki.wooledge.org/BashGuide

---

## 维护和更新

### 更新配置

1. **编辑配置文件**
   ```bash
   vi dot_config/ghostty/config.toml
   ```

2. **测试更改**
   ```bash
   # Ghostty 会实时重载配置
   # 或手动：Cmd+, 打开配置，编辑后保存
   ```

3. **提交到 Git**
   ```bash
   git add dot_config/ghostty/config.toml
   git commit -m "update: improve ghostty configuration"
   ```

4. **应用到其他机器**
   ```bash
   chezmoi apply
   ```

### 检查更新

```bash
# 检查 Ghostty 版本
ghostty --version

# 检查最新版本
# 访问: https://ghostty.org/download

# 更新（使用 Homebrew）
brew upgrade ghostty
```

---

## 快速参考卡片

```
┌─────────────────────────────────────────────────────────┐
│ GHOSTTY 快速参考                                       │
├─────────────────────────────────────────────────────────┤
│ 新标签        Cmd+T      新窗口      Cmd+N            │
│ 关闭标签      Cmd+W      关闭窗口    Cmd+Q            │
│ 下一标签      Cmd+⇧→    上一标签    Cmd+⇧←           │
│ 复制          Cmd+C      粘贴        Cmd+V             │
│ 搜索          Cmd+F      配置        Cmd+,             │
│ 增大字体      Cmd++      减小字体    Cmd+-             │
│ 全屏          Cmd+⌃F    退出        Cmd+Q             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ TMUX 快速参考（Ctrl+A 前缀）                          │
├─────────────────────────────────────────────────────────┤
│ 新窗口        Ctrl+A, C   下窗口      Ctrl+A, N       │
│ 上窗口        Ctrl+A, P   选窗口      Ctrl+A, W       │
│ 竖分割        Ctrl+A, |   横分割      Ctrl+A, -       │
│ 复制模式      Ctrl+A, [   粘贴        Ctrl+A, ]       │
│ 列表          Ctrl+A, S   命令        Ctrl+A, :       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ SHELL 快速参考（Zsh）                                 │
├─────────────────────────────────────────────────────────┤
│ 搜索历史      Ctrl+R      清屏        Ctrl+L           │
│ 行首          Ctrl+A      行尾        Ctrl+E           │
│ 删除到行首    Ctrl+U      删除到行尾  Ctrl+K           │
│ 删除前词      Ctrl+W      完成        Tab/↹            │
└─────────────────────────────────────────────────────────┘
```

---

## 致谢

本配置指南基于：
- Ghostty 官方文档
- 社区最佳实践
- 你的 Homeup 项目结构

**最后更新**: 2026-01-16
**维护者**: zopiya
**项目**: [homeup](https://github.com/zopiya/homeup)
