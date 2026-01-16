# Sheldon Plugins Deep Dive: Advanced Shell Plugin Management

> Lightweight, fast plugin manager for Zsh: Autosuggestions, syntax highlighting, completions, and custom plugins

**版本**: 1.0
**目标受众**: Zsh 用户、Shell 高手、想要优化启动时间的开发者
**前置知识**: Zsh 基础、Shell 脚本基础

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [插件生态](#插件生态)
- [配置详解](#配置详解)
- [性能优化](#性能优化)
- [自定义插件](#自定义插件)
- [与 Homeup 集成](#与-homeup-集成)
- [常见问题](#常见问题)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### 什么是 Sheldon？

**Sheldon** 是极简的 Zsh 插件管理器（用 Rust 编写）：

```
Sheldon = 快速 + 轻量级 + 并行加载

特点：
✅ 超快启动（毫秒级）
✅ 并行下载/加载插件
✅ 声明式 TOML 配置
✅ 灵活的模板系统
✅ 零依赖（单个二进制）
```

### 为什么选择 Sheldon？

```
传统方式（Oh My Zsh）:
❌ 加载缓慢（100+ ms）
❌ 大量功能堆砌
❌ 启动时加载所有插件
❌ 难以定制

Sheldon:
✅ 极快（<50 ms）
✅ 最小化设计
✅ 按需延迟加载
✅ 完全可定制
```

---

## 快速开始

### ⚡ 5 分钟基础设置

```bash
# 1. 安装 Sheldon
brew install sheldon

# 2. 初始化配置
mkdir -p ~/.config/sheldon
sheldon init --shell zsh

# 3. 编辑配置
nvim ~/.config/sheldon/plugins.toml

# 4. 添加一个插件
cat >> ~/.config/sheldon/plugins.toml <<'EOF'
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
EOF

# 5. 锁定插件版本
sheldon lock

# 6. 在 ~/.zshrc 中初始化
eval "$(sheldon source)"

# 7. 重启 Shell
exec zsh -l
```

### ✅ 验证安装

```bash
# 检查 Sheldon 版本
sheldon --version

# 列出已安装的插件
sheldon list

# 查看配置
sheldon show
```

---

## 插件生态

### Homeup 的推荐插件

Homeup 包含经过精选的 Zsh 插件组合：

#### 核心插件

```toml
# Defer loading for better startup time
[plugins.zsh-defer]
github = "romkatv/zsh-defer"

# Autosuggestion as you type
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
use = ["{{ name }}.zsh"]

# Syntax highlighting for commands
[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
apply = ["defer"]

# Additional completion functions
[plugins.zsh-completions]
github = "zsh-users/zsh-completions"
apply = ["defer"]

# History substring search (like Ctrl+R with grep)
[plugins.zsh-history-substring-search]
github = "zsh-users/zsh-history-substring-search"
apply = ["defer"]
```

### 热门插件库

| 插件 | 功能 | GitHub 仓库 |
|------|------|-----------|
| **zsh-autosuggestions** | 自动提示 | zsh-users/zsh-autosuggestions |
| **zsh-syntax-highlighting** | 语法高亮 | zsh-users/zsh-syntax-highlighting |
| **zsh-history-substring-search** | 历史搜索 | zsh-users/zsh-history-substring-search |
| **fast-syntax-highlighting** | 更快的高亮 | zdharma-continuum/fast-syntax-highlighting |
| **zsh-completions** | 额外补全 | zsh-users/zsh-completions |
| **forgit** | Git 交互工具 | wfxr/forgit |
| **fzf-tab** | FZF 补全 | Aloxaf/fzf-tab |
| **zoxide** | 智能目录导航 | ajeetdsouza/zoxide |
| **zsh-histdb** | 历史数据库 | larkery/zsh-histdb |

---

## 配置详解

### plugins.toml 结构

```toml
# ~/.config/sheldon/plugins.toml

# 设置 Shell
shell = "zsh"

# 定义模板（插件加载方式）
[templates]
# 标准加载
defer = "{{ hooks?.pre }}{% for file in files %}zsh-defer source \"{{ file }}\"\n{% endfor %}{{ hooks?.post }}"

# 插件定义
[plugins.plugin-name]
github = "user/repo"           # GitHub 源
use = ["*.plugin.zsh"]         # 使用哪些文件
apply = ["defer"]              # 应用模板
hooks = { pre = "...", post = "..." }  # 钩子
```

### 常见配置模式

#### 直接加载

```toml
# 立即加载（初始化时）
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
use = ["{{ name }}.zsh"]
# 无 apply，会立即加载
```

#### 延迟加载

```toml
# 使用 defer 模板延迟加载（加快启动）
[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
apply = ["defer"]
# 在 Zsh 完全加载后再加载此插件
```

#### 自定义钩子

```toml
# 在加载前后执行命令
[plugins.custom-plugin]
github = "user/repo"
hooks = {
  pre = "echo 'Loading custom plugin...'",
  post = "custom-plugin-init"
}
```

### Homeup 的优化配置

```toml
shell = "zsh"

# 定义 defer 模板（使用 zsh-defer 实现）
[templates]
defer = "{{ hooks?.pre | nl }}{% for file in files %}zsh-defer source \"{{ file }}\"\n{% endfor %}{{ hooks?.post | nl }}"

# 核心插件（即时加载，影响响应性）
[plugins.zsh-defer]
github = "romkatv/zsh-defer"
# 无延迟，立即加载

[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
use = ["{{ name }}.zsh"]
# 立即加载，为了自动提示功能

# 可延迟的插件（加快启动）
[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
apply = ["defer"]
# 使用 defer 模板，延迟加载

[plugins.zsh-completions]
github = "zsh-users/zsh-completions"
apply = ["defer"]

[plugins.zsh-history-substring-search]
github = "zsh-users/zsh-history-substring-search"
apply = ["defer"]
```

---

## 性能优化

### 启动时间测量

```bash
# 测试 Zsh 启动时间（不加 -i 则非交互）
time zsh -i -c exit

# 测试关键操作时间
zsh -c "time $(sheldon source)"
```

### 优化策略

#### 1. 使用 Defer 加载

```toml
# 只对非关键插件使用 defer
[templates]
defer = "{{ hooks?.pre }}{% for file in files %}zsh-defer source \"{{ file }}\"\n{% endfor %}{{ hooks?.post }}"

# 关键插件（立即）：自动提示、前缀补全
# 非关键插件（延迟）：语法高亮、历史搜索
```

#### 2. 缩小插件数量

```toml
# ❌ 安装太多插件
[plugins.plugin1]
[plugins.plugin2]
[plugins.plugin3]
# ... 20+ 插件

# ✅ 只安装必需的
[plugins.zsh-autosuggestions]    # 关键
[plugins.zsh-syntax-highlighting] # 关键
[plugins.zsh-completions]        # 有用但可延迟
```

#### 3. 限制插件文件

```toml
# 精确指定使用哪些文件
[plugins.large-plugin]
github = "user/repo"
use = ["main.zsh"]  # 仅加载必要文件，而不是 *

# 这减少了加载的代码量
```

### 性能基准

```bash
# 典型性能数据

不优化：
$ time zsh -i -c exit
zsh -i -c exit  0.35s user 0.12s system

使用 Sheldon + Defer：
$ time zsh -i -c exit
zsh -i -c exit  0.08s user 0.04s system

# 性能提升：4-5 倍
```

---

## 自定义插件

### 创建本地插件

```bash
# 1. 创建插件目录
mkdir -p ~/.local/share/zsh-plugins/my-custom

# 2. 创建插件脚本
cat > ~/.local/share/zsh-plugins/my-custom/init.zsh <<'EOF'
#!/usr/bin/env zsh

# 我的自定义插件
export MY_VAR="custom value"

alias myalias="echo 'Custom alias'"
EOF

# 3. 在 plugins.toml 中引用
[plugins.my-custom]
local = "~/.local/share/zsh-plugins/my-custom"
use = ["init.zsh"]
```

### 创建 GitHub 插件

```bash
# 1. 在 GitHub 上创建仓库
# my-zsh-plugin/

# 2. 创建插件文件
cat > my-zsh-plugin.plugin.zsh <<'EOF'
#!/usr/bin/env zsh

# Awesome plugin code
function awesome-function() {
  # ...
}
EOF

# 3. 在 Sheldon 中使用
[plugins.my-zsh-plugin]
github = "username/my-zsh-plugin"
use = ["*.plugin.zsh"]
```

---

## 与 Homeup 集成

### Homeup 的 Sheldon 配置

```bash
# 配置位置
~/.config/sheldon/plugins.toml

# 在 ~/.zshrc 中初始化
eval "$(sheldon source)"

# Homeup 推荐：
# 1. 在 ~/.zshrc 的早期初始化 Sheldon
# 2. 使用 defer 模板优化启动
# 3. 定期更新插件：sheldon lock
```

### 管理插件版本

```bash
# 生成 lock 文件（锁定版本）
sheldon lock

# 这会创建 sheldon.lock 文件
# 提交到 Git 以确保一致性
git add ~/.config/sheldon/sheldon.lock
git commit -m "feat: lock sheldon plugin versions"

# 在新机器上恢复
sheldon lock  # 使用现有 lock 文件
```

### 自定义 Zsh 初始化

在 `~/.zshrc` 中：

```bash
# 1. 初始化 Sheldon
eval "$(sheldon source)"

# 2. 加载自定义配置（如果有）
[[ -f ~/.config/zsh/custom.zsh ]] && source ~/.config/zsh/custom.zsh

# 3. 加载 Shell 函数
source ~/.config/zsh/functions.zsh

# 4. 初始化其他工具（Starship、FZF 等）
eval "$(starship init zsh)"
```

---

## 常见问题

### ❓ 如何卸载插件？

**答**:

```bash
# 1. 在 plugins.toml 中注释或删除该插件
# [plugins.unwanted-plugin]
# # github = "user/repo"  # 注释掉

# 2. 更新 lock 文件
sheldon lock

# 3. 重启 Shell
exec zsh -l

# 4. 清理缓存
rm -rf ~/.cache/sheldon/
```

### ❓ 如何更新所有插件？

**答**:

```bash
# 更新 lock 文件（会检查最新版本）
sheldon lock --update

# 清空缓存以重新下载
sheldon lock --update --force-download

# 重启 Shell
exec zsh -l
```

### ❓ 插件导致 Zsh 启动缓慢？

**答**:

```bash
# 1. 测试启动时间
time zsh -i -c exit

# 2. 找出哪个插件慢
# 逐个注释插件，重新测试

# 3. 对慢插件使用 defer
[plugins.slow-plugin]
apply = ["defer"]

# 4. 考虑移除不必要的插件
```

### ❓ 如何在远程主机上使用？

**答**:

```bash
# 1. 在远程主机安装 Sheldon
ssh user@remote
brew install sheldon

# 2. 复制本地配置
scp ~/.config/sheldon/plugins.toml user@remote:~/.config/sheldon/

# 3. 锁定版本
sheldon lock

# 4. 初始化
eval "$(sheldon source)"
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **插件数量** | 保持在 10 个以下 |
| **启动时间** | 目标 <100ms |
| **延迟加载** | 对非关键插件使用 defer |
| **版本管理** | 提交 sheldon.lock 文件 |
| **更新频率** | 每月更新一次 |
| **自定义** | 用本地插件而不是修改核心插件 |

### 核心命令速查

```bash
# 管理
sheldon init --shell zsh     # 初始化
sheldon lock                 # 锁定版本
sheldon lock --update        # 更新并锁定

# 查看
sheldon list                 # 列出插件
sheldon show                 # 显示配置

# 使用
eval "$(sheldon source)"     # 在 .zshrc 中初始化
sheldon edit                 # 编辑配置

# 维护
sheldon clean                # 清理缓存
sheldon update               # 更新插件
```

---

## 参考资源

- [Sheldon 官网](https://sheldon.cli.rs/)
- [Sheldon GitHub](https://github.com/rossmacarthur/sheldon)
- [Homeup Sheldon 配置](../dot_config/sheldon/)
- [Zsh 插件生态](https://github.com/zsh-users)
- [Homeup Shell Setup Guide](SHELL_SETUP.md)
