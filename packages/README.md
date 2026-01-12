# 📦 Homebrew 包管理配置

本目录包含 Homeup 项目的所有 Homebrew 包定义，采用模块化、分层设计，支持多种环境配置。

## 📂 文件结构

```
packages/
├── Brewfile.core       # 核心工具（所有环境必需）
├── Brewfile.macos      # macOS 工作站增量包
├── Brewfile.linux      # Linux 工作站增量包
├── Brewfile.server     # 服务器环境增量包
├── Brewfile.codespace  # 开发容器增量包
├── flatpak.txt         # Linux GUI 应用列表
└── README.md           # 本文档
```

## 🎯 设计原则

### 分层继承架构

```
Brewfile.core (基础层)
    ├── Brewfile.macos (workstation)
    ├── Brewfile.linux (workstation)
    ├── Brewfile.server (minimal)
    └── Brewfile.codespace (ephemeral)
```

所有环境都继承 `Brewfile.core`，其他文件仅包含**增量包**，避免重复定义。

### 核心价值观

- **少即是多**：只安装真正需要的工具
- **现代化优先**：拥抱 Rust/Go/Zig 等现代语言重写的工具
- **AI 驱动**：集成 AI 辅助开发工具
- **安全第一**：分层信任模型，最小权限原则

---

## 🛠️ 工具清单

### Brewfile.core - 核心工具

所有环境（workstation/codespace/server）都必需的基础工具。

#### Shell & 提示符

| 工具 | 说明 |
|------|------|
| **zsh** | 强大的现代 Shell，替代 Bash |
| **starship** | 快速、极简的跨 Shell 提示符，支持 Git 集成 |
| **sheldon** | 快速、可配置的 Zsh 插件管理器 |

#### 导航 & 搜索

| 工具 | 说明 |
|------|------|
| **zoxide** | 智能 cd 命令，自动跳转到常用目录（autojump 替代） |
| **fzf** | 模糊搜索工具，用于文件、历史记录、命令搜索 |
| **atuin** | Shell 历史记录同步和搜索，支持加密云同步 |

#### 现代化 Unix 工具替代

| 工具 | 替代对象 | 说明 |
|------|---------|------|
| **bat** | cat | 带语法高亮和 Git 集成的 cat |
| **eza** | ls | 彩色输出、Git 状态显示的 ls |
| **fd** | find | 更快、更简单的文件查找工具 |
| **ripgrep** | grep | 递归搜索目录，尊重 .gitignore |
| **sd** | sed | 更简单、更安全的文本替换工具 |
| **dust** | du | 可视化的磁盘使用分析工具 |
| **duf** | df | 更友好的磁盘使用显示 |
| **procs** | ps | 现代化的进程查看器 |
| **btop** | htop/top | 资源监控器，支持图表和鼠标交互 |

#### 文本处理 & 数据工具

| 工具 | 说明 |
|------|------|
| **jq** | JSON 处理器，API 调试必备 |
| **yq** | YAML 处理器，用于 K8s/CI 配置 |
| **miller** | CSV/JSON/TSV 处理器（结构化数据的 awk） |
| **gron** | 将 JSON 转换为可 grep 的格式 |
| **tldr** | 简化的 man 手册，带实用示例 |

#### 压缩 & 归档

| 工具 | 说明 |
|------|------|
| **zstd** | 现代压缩算法（Docker/Linux 内核标配） |
| **ouch** | 统一的压缩/解压接口（支持 zip/tar/gz/xz） |

#### 版本控制

| 工具 | 说明 |
|------|------|
| **git** | 分布式版本控制系统 |
| **gh** | GitHub CLI，管理 PR/Issues/Workflows |
| **lazygit** | Git 命令的终端 UI |
| **git-delta** | Git diff 的语法高亮分页器 |

#### 编辑器 & 终端复用

| 工具 | 说明 |
|------|------|
| **neovim** | 现代化的 Vim，可扩展的文本编辑器 |
| **tmux** | 终端复用器，支持会话持久化 |

#### 开发工作流

| 工具 | 说明 |
|------|------|
| **direnv** | 自动加载项目环境变量 |
| **just** | 命令运行器，现代化的 Make 替代 |
| **lefthook** | Git 钩子管理器 |
| **entr** | 文件监控，文件变化时运行命令 |

#### 网络基础

| 工具 | 说明 |
|------|------|
| **curl** | HTTP 客户端，API 测试 |
| **wget** | 文件下载器，支持递归下载 |

#### 系统维护

| 工具 | 说明 |
|------|------|
| **chezmoi** | Dotfiles 管理器（本项目的核心） |
| **topgrade** | 一键升级所有包管理器的工具 |

---

### Brewfile.macos / Brewfile.linux - 工作站工具

macOS 和 Linux 工作站共享的增强工具（macOS 额外包含 GUI 应用）。

#### 增强 Shell & CLI

| 工具 | 说明 |
|------|------|
| **fastfetch** | Neofetch 替代品，显示系统信息 |
| **zellij** | 现代化的 tmux 替代（Rust 实现，更好的用户体验） |
| **bottom** | 现代化的资源监控器，支持图表 |
| **choose** | 人性化的 cut/awk 替代 |

#### 文件管理 & 预览

| 工具 | 说明 |
|------|------|
| **yazi** | 终端文件管理器，支持图片预览 |
| **watchexec** | 文件监控器，比 entr 功能更强 |

#### AI 辅助开发

| 工具 | 说明 |
|------|------|
| **aider** | 终端中的 AI 结对编程工具 |
| **glow** | 终端 Markdown 渲染器 |
| **vhs** | 终端录制工具，生成演示 GIF |

#### 容器 & Kubernetes 生态

| 工具 | 说明 |
|------|------|
| **lazydocker** | Docker TUI，轻松管理容器 |
| **dive** | 分析 Docker 镜像层 |
| **k9s** | Kubernetes TUI，集群管理 |
| **helm** | Kubernetes 包管理器 |
| **kubectx** | 快速切换 K8s 上下文/命名空间 |
| **stern** | 聚合多个 Pod 日志 |
| **kustomize** | K8s 配置定制工具 |

#### 基础设施即代码 & DevOps

| 工具 | 说明 |
|------|------|
| **terraform** | 基础设施即代码标准工具 |
| **ansible** | 配置管理和自动化 |
| **trivy** | 容器/IaC 安全扫描器 |
| **grype** | 漏洞扫描器（Anchore） |
| **syft** | SBOM 生成器，供应链安全 |

#### 网络 & API 工具

| 工具 | 说明 |
|------|------|
| **httpie** | 用户友好的 HTTP 客户端 |
| **xh** | HTTPie 的 Rust 版本，更快 |
| **doggo** | 现代化的 dig 替代（DNS 查询） |
| **gping** | 带可视化图表的 ping |
| **trippy** | 网络诊断工具（traceroute 增强） |
| **grpcurl** | gRPC 的 curl |
| **evans** | gRPC 交互式客户端 |

#### 数据库工具

| 工具 | 说明 |
|------|------|
| **usql** | 通用 SQL CLI（支持 MySQL/Postgres/SQLite） |
| **pgcli** | PostgreSQL CLI，带自动补全 |

#### 运行时 & 包管理器

| 工具 | 说明 |
|------|------|
| **mise** | 多语言运行时管理器（asdf 继任者） |
| **uv** | 快速的 Python 包管理器（pip/poetry 替代） |
| **pnpm** | 快速、磁盘高效的 npm 替代 |

#### 性能 & 代码分析

| 工具 | 说明 |
|------|------|
| **hyperfine** | 命令行基准测试工具 |
| **tokei** | 快速的代码统计工具（行数统计） |
| **bandwhich** | 网络带宽监控（需要 root） |

#### Git 增强

| 工具 | 说明 |
|------|------|
| **git-cliff** | 从 Git 历史生成 CHANGELOG |
| **onefetch** | 终端中的 Git 仓库摘要 |

#### 安全 & 加密

| 工具 | 说明 |
|------|------|
| **gnupg** | GPG 加密和签名 |
| **age** | 现代化的加密工具（比 GPG 简单） |
| **ykman** | YubiKey 管理器 CLI |
| **1password-cli** | 1Password 命令行访问 |
| **pinentry-mac** | macOS 原生的 GPG 密码输入（仅 macOS） |
| **gitleaks** | 扫描 Git 仓库中的密钥泄露 |

#### 备份 & 系统维护

| 工具 | 说明 |
|------|------|
| **restic** | 快速、加密、去重的备份工具 |

---

### Brewfile.macos - macOS 专属

#### 字体

| 字体 | 说明 |
|------|------|
| **JetBrains Mono Nerd Font** | JetBrains Mono + 图标字体 |
| **Hack Nerd Font** | Hack + 图标字体 |
| **Noto Sans** | Google 的通用字体 |
| **Source Han Serif** | Adobe 的 CJK 衬线字体 |

#### GUI 应用

**浏览器**
- **Google Chrome** - 主力浏览器
- **Firefox** - 隐私优先的替代浏览器

**终端（GPU 加速）**
- **Ghostty** - Zig 实现，GPU 加速
- **Warp** - AI 原生终端，带 IDE 功能

**通讯 & 文件同步**
- **LocalSend** - 本地文件分享（AirDrop 替代）
- **Nextcloud** - 自托管云同步

**开发工具**
- **Visual Studio Code** - 主力代码编辑器
- **DBeaver Community** - 通用数据库 GUI
- **Bruno** - API 客户端（Postman 替代）

**生产力 & 知识管理**
- **1Password** - 密码管理器
- **Obsidian** - Markdown 知识库
- **Typora** - 所见即所得的 Markdown 编辑器

**系统工具**
- **Stats** - macOS 菜单栏系统监控
- **Keka** - 归档管理器（支持 7z/RAR/ZIP）
- **VLC** - 通用媒体播放器

---

### Brewfile.server - 服务器工具

最小化的服务器环境补充（继承 core 的所有工具）。

#### 增强监控

| 工具 | 说明 |
|------|------|
| **bottom** | 现代化的资源监控器 |
| **glances** | 全面的系统监控器（Python 实现） |
| **bmon** | 网络带宽监控 |

#### 日志管理 & 分析

| 工具 | 说明 |
|------|------|
| **lnav** | 日志文件导航器，自动格式检测 |

#### 备份 & 灾难恢复

| 工具 | 说明 |
|------|------|
| **restic** | 快速、加密、去重的备份工具 |

#### 安全加固（可选）

| 工具 | 说明 |
|------|------|
| **fail2ban** | 入侵防护（失败尝试后封禁 IP） |
| **lynis** | 安全审计和加固工具 |

---

### Brewfile.codespace - 开发容器工具

专为 GitHub Codespaces、Dev Containers、DevBox 设计的轻量级环境。

#### 特点

- 无 GUI 应用
- 无硬件安全密钥支持
- 专注于 AI 辅助和容器开发
- 借用信任模型（SSH 代理转发）

#### 与 Workstation 的差异

**包含的工具：**
- 基础 CLI 增强（fastfetch, zellij, bottom, choose）
- AI 辅助开发（aider, glow）
- 容器工具（lazydocker, dive, trivy）
- 网络 & API 工具（httpie, xh, doggo, gping, grpcurl, usql）
- 运行时管理（mise, uv, pnpm）
- 性能分析（hyperfine, tokei）
- Git 增强（git-cliff, onefetch）
- 基础安全（gnupg, age, gitleaks）

**不包含的工具：**
- 完整 K8s 工具链（k9s, helm, kubectx, stern, kustomize）
- 硬件密钥工具（ykman）
- macOS 特定工具（pinentry-mac）
- 重型工具（terraform, ansible）

---

### flatpak.txt - Linux GUI 应用

通过 Flatpak 管理的 Linux GUI 应用（沙盒隔离）。

#### 浏览器
- Chrome, Firefox

#### 通讯 & 同步
- Thunderbird（邮件客户端）
- LocalSend（本地文件分享）
- Nextcloud（云同步）
- Delta Chat（去中心化通讯）

#### 开发工具
- Visual Studio Code
- JetBrains Toolbox
- DBeaver Community（数据库 GUI）
- Electerm（SSH/SFTP 客户端）
- Podman Desktop（容器管理）
- Bruno（API 客户端）

#### 生产力 & 办公
- 1Password
- Obsidian
- Typora

#### 多媒体
- VLC

#### 系统 & 工具
- Flatseal（Flatpak 权限管理）
- Mission Center（系统监控，类似 macOS Stats）
- PeaZip（归档管理器）

---

## 📊 统计数据

| 文件 | 包数量 | 说明 |
|------|--------|------|
| **Brewfile.core** | 45 个 brew | 所有环境基础 |
| **Brewfile.macos** | 51 个 brew + 23 个 cask | macOS 工作站增量 |
| **Brewfile.linux** | 47 个 brew | Linux 工作站增量 |
| **Brewfile.server** | 5 个 brew (+2 可选) | 服务器最小化增量 |
| **Brewfile.codespace** | 30 个 brew | 开发容器增量 |
| **flatpak.txt** | 19 个应用 | Linux GUI 应用 |

**重复率：** ~5%（仅 workstation 共享工具在 macos/linux 重复）

---

## 🚀 使用方法

### 安装核心工具（所有环境）

```bash
brew bundle --file=packages/Brewfile.core
```

### 安装 macOS 工作站完整环境

```bash
brew bundle --file=packages/Brewfile.core
brew bundle --file=packages/Brewfile.macos
```

### 安装 Linux 工作站完整环境

```bash
brew bundle --file=packages/Brewfile.core
brew bundle --file=packages/Brewfile.linux

# 安装 GUI 应用
while read -r app; do
  [[ $app =~ ^# ]] && continue
  [[ -z $app ]] && continue
  flatpak install -y flathub "$app"
done < packages/flatpak.txt
```

### 安装服务器环境

```bash
brew bundle --file=packages/Brewfile.core
brew bundle --file=packages/Brewfile.server
```

### 安装 Codespace 环境

```bash
brew bundle --file=packages/Brewfile.core
brew bundle --file=packages/Brewfile.codespace
```

---

## 🔄 维护指南

### 添加新工具

1. 确定工具应该属于哪个层级：
   - 所有环境必需？→ `Brewfile.core`
   - 工作站开发工具？→ `Brewfile.macos` / `Brewfile.linux`
   - 服务器专用？→ `Brewfile.server`
   - 容器开发？→ `Brewfile.codespace`

2. 添加到对应文件的适当分类下

3. 更新本 README，在对应的工具清单中添加说明

### 删除工具

1. 从对应的 Brewfile 中删除
2. 更新本 README

### 重复检查

运行以下命令检查是否有重复定义：

```bash
cat packages/Brewfile.* | grep '^brew\|^cask' | sort | uniq -c | grep -v '^ *1 '
```

理想情况下，除了 workstation 共享工具，不应有其他重复。

---

## 📖 参考资源

- [Homebrew 官方文档](https://docs.brew.sh/)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- [Flatpak 官方文档](https://flatpak.org/)
- [现代化 Unix 工具清单](https://github.com/ibraheemdev/modern-unix)
