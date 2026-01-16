# Zellij Complete Guide: Modern Terminal Multiplexer

> Next-generation terminal multiplexing: Layouts, floating panes, and intuitive keybindings without the complexity

**版本**: 1.0
**目标受众**: Terminal 用户、开发者、Tmux 用户想要尝试现代替代品
**前置知识**: Terminal 基础、Terminal multiplexer 概念

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [Zellij vs Tmux](#zellij-vs-tmux)
- [配置详解](#配置详解)
- [会话和布局](#会话和布局)
- [高级功能](#高级功能)
- [与 Homeup 集成](#与-homeup-集成)
- [常见问题](#常见问题)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### 什么是 Zellij？

**Zellij** 是现代的 Terminal 多路复用器，类似 Tmux 但更简洁：

```
Zellij = Rust 实现 + 直观 UI + 预配置布局 + 浮动窗格

特点：
✅ 开箱即用（无需复杂配置）
✅ 浮动 Pane（悬浮窗口）
✅ 预定义布局（Dev、Ops、Full）
✅ 现代快捷键
✅ 会话管理自动化
```

### Zellij vs Tmux

| 特性 | Tmux | Zellij |
|------|------|--------|
| **学习曲线** | 陡峭 | 平缓 |
| **配置复杂度** | 复杂 | 简单 |
| **默认体验** | 需要配置 | 开箱可用 |
| **浮动窗格** | ❌ 无 | ✅ 有 |
| **布局** | ❌ 手动 | ✅ 预定义 |
| **会话管理** | ❌ 需要脚本 | ✅ 自动 |
| **跨平台** | ✅ 所有平台 | ✅ 所有平台 |
| **性能** | 快 | 快（Rust） |

**何时选择 Zellij**:

```
✅ 想要开箱即用的体验
✅ 喜欢现代、直观的 UI
✅ 不需要向后兼容 Tmux 脚本
✅ 想使用浮动窗格

❌ 何时坚持 Tmux:
  - 需要远程会话持久化
  - 已有大量 Tmux 配置
  - 需要最大的社区生态
```

---

## 快速开始

### ⚡ 5 分钟入门

```bash
# 1. Homeup 已包含 Zellij
# 2. 启动默认会话
zj

# 或使用快捷函数（如果定义）
zellij

# 3. 查看布局
# Zellij 以默认布局启动

# 4. 快速操作
Ctrl+A          # 进入 Tmux 模式（熟悉的快捷键）
Alt+1           # 切换到标签页 1
Alt+N           # 新建 Pane
Alt+H/J/K/L     # 导航 Pane

# 5. 退出
Ctrl+A d        # 分离会话（保持运行）
Ctrl+A q        # 退出会话
```

### ✅ 验证安装

```bash
# 检查 Zellij 版本
zellij --version

# 应输出：
# zellij 0.39.0 或更新

# 列出所有会话
zellij ls

# 列出可用布局
zellij list-sessions
```

---

## Zellij vs Tmux

### 快捷键对比

| 操作 | Tmux | Zellij |
|------|------|--------|
| **进入前缀** | Ctrl+B | Ctrl+A |
| **分割水平** | " | Ctrl+A " |
| **分割垂直** | % | Ctrl+A % |
| **导航** | 方向键 | h/j/k/l 或方向键 |
| **新标签页** | c | Ctrl+A c |
| **重命名** | , | Ctrl+A , |
| **关闭** | x | Ctrl+A x |
| **分离** | d | Ctrl+A d |

### 迁移指南

**从 Tmux 迁移到 Zellij**:

```bash
# 1. Homeup 的 Zellij 配置已为 Tmux 用户优化
# config.kdl.tmpl 中：
#   keybinds clear-defaults=true
#   bind "Ctrl a" { SwitchToMode "tmux"; }
#   这样 Ctrl+A 进入 Tmux 兼容模式

# 2. 学习 Zellij 原生快捷键
# Alt+N      - 新 Pane（比 Ctrl+A " 更快）
# Alt+H/J/K/L - 导航（类似 Vim）
# Alt+1-9    - 快速切换标签页

# 3. 保留 Tmux 知识
# 大多数概念相同：
# - 会话（Session）
# - 窗口（Window/Tab）
# - 窗格（Pane）
```

---

## 配置详解

### config.kdl 配置文件

```kdl
// ~/.config/zellij/config.kdl

// 选择主题
theme "github-dark"

// 默认布局
default_layout "base"

// 快捷键绑定
keybinds clear-defaults=true {
    normal {
        bind "Ctrl a" { SwitchToMode "tmux"; }
    }

    tmux {
        // Tmux 兼容模式
        bind "c" { NewTab; SwitchToMode "normal"; }
        bind "\"" { NewPane "down"; SwitchToMode "normal"; }
        bind "%" { NewPane "right"; SwitchToMode "normal"; }
    }
}
```

### Homeup 的三个布局

#### 1. Base Layout（基础）

```kdl
// dev.kdl - 开发布局
layout {
    pane size=1 borderless=true {
        plugin location="zellij:strftime" {
            format "%A, %d %b — %H:%M"
        }
    }
    pane split_direction="vertical" {
        pane {
            // 编辑器窗格
        }
        pane split_direction="horizontal" {
            // 上：终端
            // 下：日志
        }
    }
}
```

#### 2. Dev Layout（开发）

用于编码工作：

```
Editor (占左边 70%)
├─ Code editing
│
Terminals (占右边 30%)
├─ 上：命令行
└─ 下：日志
```

#### 3. Ops Layout（运维）

用于系统操作：

```
Monitor (占上面 30%)
├─ 系统监控
│
Terminals (占下面 70%)
├─ 左：SSH 连接 1
├─ 中：SSH 连接 2
└─ 右：本地命令
```

### 应用不同布局

```bash
# 启动指定布局
zellij --layout dev

# 或在会话中切换
Alt+]           # 下一个布局
Alt+[           # 上一个布局

# 或通过浮动窗格选择
Ctrl+A Space    # 切换布局
```

---

## 会话和布局

### 会话管理

```bash
# 创建新会话
zellij -s myproject

# 附加到现有会话
zellij attach myproject

# 分离当前会话
Ctrl+A d

# 列出所有会话
zellij ls

# 删除会话
zellij kill-session myproject
```

### 智能会话函数

在 Homeup 中添加快捷函数：

```bash
# ~/.config/zsh/functions.zsh

# 智能会话：如果存在则附加，否则创建
zjs() {
    local session_name="${1:-main}"
    if zellij list-sessions | grep -q "^$session_name"; then
        zellij attach "$session_name"
    else
        zellij -s "$session_name"
    fi
}

# 快速启动开发布局
zjd() {
    zellij --layout dev
}

# 快速启动完整布局
zjf() {
    zellij --layout full
}
```

---

## 高级功能

### 浮动窗格

Zellij 的独特功能之一是浮动窗格：

```bash
# 切换浮动窗格
Ctrl+A w

# 浮动窗格用途：
# ✅ 临时编辑文件（无需分割）
# ✅ 快速命令执行
# ✅ 临时信息显示
```

### 窗格专注模式

```bash
# 全屏显示当前窗格
Ctrl+A z

# 再按一次返回多窗格视图
```

### 会话同步

```bash
# 所有 Pane 中运行相同命令
Ctrl+A Ctrl+E   # 进入同步模式
# 输入命令后按 Enter
# 所有 Pane 都会执行
```

---

## 与 Homeup 集成

### Homeup 的 Zellij 配置

```bash
# 位置
~/.config/zellij/
├── config.kdl.tmpl       # 主配置（由 Chezmoi 管理）
├── layouts/
│   ├── base.kdl          # 基础布局
│   ├── dev.kdl           # 开发布局
│   └── ops.kdl           # 运维布局
└── themes/
    └── extended.kdl      # 主题定义
```

### 自定义 Zellij

#### 添加新布局

```kdl
// ~/.config/zellij/layouts/custom.kdl

layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar" {}
    }
    pane split_direction="vertical" {
        pane {
            focus=true
        }
        pane split_direction="horizontal" size=40 {
            pane {}
            pane {}
        }
    }
}
```

#### 自定义主题

```kdl
// ~/.config/zellij/themes/my-theme.kdl

themes {
    my-dark {
        fg 200 200 200
        bg 30 30 30
        black 40 40 40
        red 200 100 100
        green 100 200 100
        // ... 更多颜色
    }
}
```

### 在脚本中使用

```bash
# 项目启动脚本
#!/bin/bash

PROJECT_NAME="myapp"
LAYOUT="dev"

# 创建会话并启动
zellij -s "$PROJECT_NAME" --layout "$LAYOUT"

# 在会话中运行命令
zellij run -s "$PROJECT_NAME" -c npm run dev
```

---

## 常见问题

### ❓ 如何在 SSH 远程主机上运行 Zellij？

**答**:

```bash
# 在远程主机上
ssh user@remote

# 如果 Zellij 已安装
zellij

# 或
ssh user@remote zellij

# 注意：Zellij 会话不会持久化（像 Tmux）
# 如果 SSH 断开，会话就结束了

# 解决方案：在 SSH 连接中嵌套 Tmux
ssh user@remote
tmux new-session -s persistent
zellij  # 在 Tmux 中运行 Zellij
# 这样 SSH 断开时，Tmux 保持运行
```

### ❓ Zellij 和 Tmux 能否共存？

**答**:

```bash
# 是的，它们可以共存
# 在 ~/.zshrc 中：

# 如果同时启用了两者
alias tm="tmux"
alias zj="zellij"

# 或者根据工作流选择：
# - 需要持久化会话：使用 Tmux
# - 本地开发：使用 Zellij
```

### ❓ 如何恢复会话布局？

**答**:

```bash
# Zellij 不会自动保存会话
# 但可以通过脚本恢复：

# 1. 创建启动脚本
cat > ~/.local/bin/zellij-restore <<'EOF'
#!/bin/bash
SESSIONS=("dev" "work" "monitor")
for session in "${SESSIONS[@]}"; do
    zellij -s "$session" --layout dev &
done
wait
EOF

# 2. 在 ~/.zshrc 中调用
# alias zellij-restore="bash ~/.local/bin/zellij-restore"

# 3. 需要时恢复所有会话
zellij-restore
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **何时使用** | 本地开发和快速多窗格管理 |
| **何时用 Tmux** | 需要远程会话持久化 |
| **配置** | 开箱即用，仅自定义必要部分 |
| **快捷键** | 学习原生快捷键，同时保留 Tmux 兼容模式 |
| **会话** | 使用项目名称创建会话，便于追踪 |
| **布局** | 为不同工作流创建不同布局 |

### 核心快捷键速查

```bash
# 基本操作（Tmux 模式）
Ctrl+A c        # 新标签页
Ctrl+A \"       # 水平分割
Ctrl+A %        # 垂直分割
Ctrl+A h/j/k/l  # 导航
Ctrl+A x        # 关闭窗格
Ctrl+A d        # 分离会话

# 原生快捷键（更快）
Alt+1-9         # 切换标签页 1-9
Alt+N           # 新窗格
Alt+H/J/K/L     # 导航
Alt+=/+         # 增大窗格
Alt+-           # 缩小窗格
Alt+[/]         # 上/下一个布局

# 高级功能
Ctrl+A z        # 全屏模式
Ctrl+A w        # 浮动窗格
Ctrl+A Space    # 切换布局
```

---

## 参考资源

- [Zellij 官网](https://zellij.dev/)
- [Zellij GitHub](https://github.com/zellij-org/zellij)
- [Zellij 文档](https://docs.zellij.dev/)
- [Homeup Zellij 配置](../dot_config/zellij/)
- [Homeup Tmux Guide](TMUX_GUIDE.md)
- [Terminal 多路复用比较](MODERN_WORKFLOW.md)
