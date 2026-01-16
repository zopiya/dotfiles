# Homebrew Package Management Complete Guide: MacOS/Linux Package Manager

> Unified package management: Install, update, manage dependencies with Brewfiles for reproducible environments

**版本**: 1.0
**目标受众**: macOS/Linux 用户、DevOps 工程师、系统管理员
**前置知识**: Shell 基础、包管理概念

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [Brewfile 管理](#brewfile-管理)
- [包管理操作](#包管理操作)
- [Homeup 的三层策略](#homeup-的三层策略)
- [常见任务](#常见任务)
- [高级配置](#高级配置)
- [故障排除](#故障排除)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### Homebrew 简介

**Homebrew** 是 macOS 和 Linux 上的包管理器：

```
Homebrew = 包管理 + 依赖解析 + 版本控制

特点：
✅ 跨平台（macOS / Linux）
✅ 用户安装（不需要 sudo）
✅ 简洁的命令行接口
✅ Brewfile 支持（声明式配置）
✅ 自动依赖管理
```

### 术语

| 术语 | 含义 | 例子 |
|------|------|------|
| **Formula** | 软件包定义（Brew 术语） | `zsh`, `neovim`, `git` |
| **Cask** | macOS 图形应用包 | `visual-studio-code`, `chrome` |
| **Tap** | 第三方软件源 | `homebrew/cask` |
| **Brewfile** | 声明式包定义文件 | `Brewfile.core`, `Brewfile.macos` |
| **Bundle** | Brewfile 的安装/管理工具 | `brew bundle` |
| **Cellar** | Homebrew 安装目录 | `/opt/homebrew/Cellar` |
| **Keg** | 单个软件的安装目录 | `/opt/homebrew/Cellar/neovim/0.9.0` |

---

## 快速开始

### ⚡ 5 分钟基础操作

```bash
# 1. 安装 Homebrew（如果还没安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 搜索包
brew search neovim

# 3. 安装包
brew install neovim

# 4. 查看已安装包
brew list

# 5. 升级包
brew upgrade neovim

# 6. 卸载包
brew uninstall neovim

# 7. 清理缓存
brew cleanup
```

### ✅ 验证安装

```bash
# 检查 Homebrew 版本和状态
brew --version

# 诊断问题
brew doctor

# 输出应该显示：
# Your system is ready to brew.
```

### 🔧 在 Homeup 中使用

Homeup 使用 Brewfile 进行声明式包管理：

```bash
# 一键安装所有包（通过 Just）
just install

# 或手动运行
brew bundle --file=Brewfile.core

# 检查是否有过时的包
brew outdated

# 升级所有包
brew upgrade
```

---

## Brewfile 管理

### Brewfile 格式

```ruby
# Brewfile - 声明式包定义

# 添加水龙头（第三方源）
tap "homebrew/cask"

# 命令行工具（Formula）
brew "zsh"
brew "neovim"
brew "git"

# macOS 应用（Cask）
cask "visual-studio-code"
cask "docker"

# 应用商店（macOS only）
mas "Slack", id: 803453959

# 依赖说明
brew "neovim", args: ["with-luajit"]
```

### Homeup 的三层 Brewfile 结构

```
packages/
├── Brewfile.bootstrap  (22 packages)
│   └── 基础工具：zsh, git, starship, sheldon, zoxide, fzf, chezmoi, just
│
├── Brewfile.core       (92 packages)
│   ├── 共享工具：编辑器、终端、开发工具
│   ├── 现代替代：bat, eza, fd, ripgrep, sd, dust
│   ├── 数据工具：jq, yq, miller, gron
│   ├── Git 增强：lazygit, git-delta
│   ├── 开发：neovim, tmux, direnv, lefthook
│   └── 运行时：mise, uv, pnpm
│
├── Brewfile.macos      (33 additional packages)
│   ├── 安全工具：gnupg, ykman, pinentry-mac
│   ├── GUI 应用：visual-studio-code, ghostty, obsidian
│   └── Ops 工具：k9s, helm, terraform
│
└── Brewfile.linux      (15 additional packages)
    ├── 监控工具：glances, bmon, lnav
    └── Ops 工具：k9s, helm, terraform
```

**设计原则**:

```
Brewfile.bootstrap (必需)
        ↓
Brewfile.core (跨平台)
        ↓
Brewfile.{macos|linux} (平台特定)

结果：
✅ macOS: 22 + 92 + 33 = 147 packages
✅ Linux: 22 + 92 + 15 = 129 packages
```

### 创建自己的 Brewfile

```bash
# 1. 在项目目录创建 Brewfile
cd ~/my-project
touch Brewfile

# 2. 列出已安装的包
brew list --formula > formula.txt
brew list --cask > cask.txt

# 3. 写入 Brewfile
cat > Brewfile << 'EOF'
tap "homebrew/cask"

# 核心开发工具
brew "git"
brew "neovim"
brew "tmux"

# Node.js 开发
brew "node@20"
brew "pnpm"

# Python 开发
brew "python@3.11"

# 应用
cask "visual-studio-code"
cask "docker"
EOF

# 4. 在另一台机器上复用
brew bundle --file=~/my-project/Brewfile
```

### 导出当前环境

```bash
# 导出当前环境到 Brewfile
brew bundle dump --file=Brewfile --describe --force

# 输出文件会包含：
# tap "homebrew/cask"
# brew "zsh"
# ...
# cask "visual-studio-code"
```

---

## 包管理操作

### 搜索包

```bash
# 模糊搜索
brew search zsh

# 精确搜索
brew search "^zsh$"

# 查看包详情
brew info zsh
# 显示：版本、依赖、来源、文档链接
```

### 安装包

```bash
# 安装单个包
brew install neovim

# 安装多个包
brew install neovim git tmux

# 安装 Cask（macOS GUI 应用）
brew install --cask visual-studio-code

# 从特定版本安装
brew install neovim@0.9

# 安装多个版本
brew install python@3.11 python@3.12
```

### 升级包

```bash
# 检查过时的包
brew outdated

# 升级单个包
brew upgrade neovim

# 升级所有包
brew upgrade

# 升级 Cask（macOS）
brew upgrade --cask
```

### 卸载包

```bash
# 卸载包
brew uninstall neovim

# 卸载包及其依赖
brew uninstall neovim --formula

# 卸载所有版本
brew uninstall neovim@0.8 neovim@0.9
```

### 清理

```bash
# 清理过时的包文件
brew cleanup

# 清理特定包
brew cleanup neovim

# 深度清理（删除所有缓存）
brew cleanup --prune=all

# 检查磁盘使用
brew cleanup -s
```

---

## Homeup 的三层策略

### Layer 1: Bootstrap (22 packages)

**目的**: 最小化依赖，快速启动新机器

```
必需的基础工具：
- zsh          # 默认 Shell
- git          # 版本控制
- starship     # 提示符
- sheldon      # Shell 插件管理
- zoxide       # 智能目录导航
- fzf          # 模糊查找
- chezmoi      # 配置管理
- just         # 任务运行
```

**使用场景**:

```bash
# 新服务器初始化
just install-bootstrap

# 容器基础镜像
FROM homebrew/brew:latest
RUN brew bundle --file=/path/to/Brewfile.bootstrap
```

### Layer 2: Core (92 packages)

**目的**: 完整的开发和运维工具集

```
包括：
✅ 编辑器：neovim, vim
✅ 终端多路：tmux, zellij
✅ 现代替代：bat, eza, fd, ripgrep, sd
✅ 开发工具：git, gh, lazygit
✅ 运行时：mise, uv, pnpm
✅ 数据工具：jq, yq, miller, gron
✅ 网络工具：httpie, xh, doggo
✅ Ops 工具：k9s, helm, docker
```

**使用场景**:

```bash
# 所有机器都需要
just install-core

# 开发 + 运维 + 数据分析工作流
# 一套工具满足大多数需求
```

### Layer 3: Profile (Platform-Specific)

#### macOS Profile (33 additional)

```
安全工具：
✅ gnupg        # GPG 加密
✅ ykman        # YubiKey 管理
✅ pinentry-mac # macOS 密码输入

GUI 应用：
✅ visual-studio-code
✅ ghostty, warp  # 终端模拟器
✅ obsidian       # 笔记应用
✅ raycast        # 应用启动器

Ops/Dev：
✅ k9s, helm, terraform, ansible
✅ docker, dive
```

#### Linux Profile (15 additional)

```
监控工具：
✅ glances    # 系统监控
✅ bmon       # 网络监控
✅ lnav       # 日志导航

Ops/Dev：
✅ k9s, helm, terraform, ansible
```

---

## 常见任务

### 场景 1：新机器从零开始

```bash
# 1. 安装 Homebrew（前置）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 克隆 Homeup
git clone https://github.com/yourusername/homeup.git
cd homeup

# 3. 检查环境
just check

# 4. 安装所有包
just install

# 涵盖：
# - Bootstrap (基础)
# - Core (共享)
# - Profile (平台特定)
```

### 场景 2：添加新包

**方法 1：编辑 Brewfile**

```bash
# 1. 确定包的类型
# - Formula: brew install xxx
# - Cask: brew install --cask xxx

# 2. 编辑对应的 Brewfile
# 如果是跨平台：编辑 Brewfile.core
# 如果是 macOS 专用：编辑 Brewfile.macos

# 3. 添加包
echo 'brew "lazygit"' >> packages/Brewfile.core

# 4. 应用
brew bundle --file=packages/Brewfile.core

# 5. 提交
git add packages/Brewfile.core
git commit -m "feat: add lazygit"
```

**方法 2：使用 brew bundle dump**

```bash
# 1. 手动安装新包
brew install lazygit

# 2. 更新 Brewfile
brew bundle dump --file=Brewfile.core --force --describe

# 3. 检查差异
git diff Brewfile.core

# 4. 提交
git commit -am "feat: add lazygit"
```

### 场景 3：更新所有包

```bash
# 使用 Just（推荐）
just upgrade

# 内部调用：
# - topgrade (如果安装了，升级所有工具)
# - 或 brew update && brew upgrade

# 手动步骤
brew update
brew upgrade
brew cleanup

# 验证
brew outdated
# 输出应该为空
```

### 场景 4：在 CI/CD 中使用 Brewfile

```bash
# GitHub Actions
name: Install Dependencies
on: [push]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Homebrew packages
        run: |
          brew update
          brew bundle --file=packages/Brewfile.core

      - name: Run tests
        run: npm test
```

### 场景 5：创建最小容器镜像

```dockerfile
# Dockerfile
FROM homebrew/brew:latest

# 安装基础工具
RUN brew bundle --file=/path/to/Brewfile.bootstrap
RUN brew bundle --file=/path/to/Brewfile.core

# 应用程序
COPY . /app
WORKDIR /app
RUN npm install
CMD ["npm", "start"]

# 结果：
# ✅ 最小镜像，只包含必需包
# ✅ 可复用的 Brewfile
# ✅ 与本地环境一致
```

---

## 高级配置

### 条件安装

```ruby
# Brewfile - 根据条件安装

if OS.mac?
  brew "gnupg"
  brew "ykman"
  cask "visual-studio-code"
elsif OS.linux?
  brew "glances"
  brew "bmon"
end
```

### 多个 Brewfile

```bash
# 不同环境使用不同 Brewfile

# 开发环境
brew bundle --file=Brewfile.dev

# 生产环境
brew bundle --file=Brewfile.prod --no-upgrade

# CI/CD
brew bundle --file=Brewfile.ci
```

### Tap（第三方源）

```bash
# 添加第三方 tap
brew tap homebrew/cask-fonts

# 安装来自 tap 的包
brew install --cask font-jetbrains-mono

# 列出已添加的 tap
brew tap

# 移除 tap
brew untap homebrew/cask-fonts
```

---

## 故障排除

### ❓ "formula not found"

**问题**: `brew install nonexistent-package`

**解决**:

```bash
# 1. 检查包名
brew search partial-name

# 2. 查看包详情
brew info package-name

# 3. 如果真的不存在，可能是：
# - 包名拼写错误
# - 包已被移除或重命名
# - 需要添加 tap
brew tap <tap-name>
brew install <package>
```

### ❓ "Permission denied" 错误

**问题**: `Error: Permission denied @ rb_file_s_mkdir_p`

**解决**:

```bash
# 1. 修复 Homebrew 权限
sudo chown -R $(whoami) /opt/homebrew

# 2. 或重装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### ❓ Brewfile 冲突

**问题**: `brew bundle` 失败，提示冲突

**解决**:

```bash
# 1. 检查现有包
brew list

# 2. 卸载冲突的包
brew uninstall conflicting-package

# 3. 重试 bundle
brew bundle --file=Brewfile.core
```

### ❓ 磁盘空间不足

**解决**:

```bash
# 1. 清理缓存
brew cleanup --prune=all

# 2. 检查大小
du -sh /opt/homebrew/Cellar

# 3. 卸载不需要的包
brew list
brew uninstall unused-package
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **组织** | 按 bootstrap → core → profile 分层 Brewfile |
| **版本控制** | 提交 Brewfile 到 Git，实现可复用环境 |
| **升级策略** | 定期 `brew upgrade`，在生产前测试 |
| **清理** | 定期 `brew cleanup`，保持系统干净 |
| **CI/CD** | 使用 `brew bundle --no-upgrade` 保证一致性 |
| **文档** | 在 Brewfile 中添加注释解释包的用途 |

### 核心命令速查

```bash
# 搜索和信息
brew search <pattern>       # 搜索包
brew info <package>         # 包详情
brew list                   # 已安装包

# 安装和卸载
brew install <package>      # 安装
brew install --cask <app>   # 安装 Cask（GUI）
brew uninstall <package>    # 卸载
brew uninstall <package>@<version> # 卸载特定版本

# 升级和清理
brew update                 # 更新包列表
brew upgrade                # 升级所有包
brew upgrade <package>      # 升级特定包
brew outdated               # 显示过时的包
brew cleanup                # 清理缓存

# Brewfile 管理
brew bundle --file=Brewfile # 安装 Brewfile 中的包
brew bundle dump            # 导出当前环境
brew bundle --no-upgrade    # 仅安装缺失的包

# 诊断
brew doctor                 # 健康检查
brew config                 # 显示配置
brew --version              # 显示版本
```

---

## 参考资源

- [Homebrew 官网](https://brew.sh/)
- [Homebrew 文档](https://docs.brew.sh/)
- [Brewfile 文档](https://github.com/Homebrew/homebrew-bundle)
- [Homeup Brewfiles](../packages/)
- [Homeup Just Guide](JUST_TASK_RUNNER_GUIDE.md)
- [Homeup Architecture](architecture.md)
