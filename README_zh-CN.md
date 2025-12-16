# 🚀 Homeup - 现代化个人开发环境

<div align="center">

![License](https://img.shields.io/github/license/zopiya/dotfiles?style=flat-square)
![Chezmoi](https://img.shields.io/badge/managed%20by-chezmoi-0055FF?style=flat-square&logo=chezmoi)
![Neovim](https://img.shields.io/badge/editor-neovim-57A143?style=flat-square&logo=neovim)
![Zsh](https://img.shields.io/badge/shell-zsh-F15A24?style=flat-square&logo=zsh)

[English](README.md) | [简体中文](README_zh-CN.md) | [架构文档 (中文)](ARCHITECTURE_zh-CN.md)

</div>

**Homeup** 是一个高度模块化、跨平台且自动化的开发环境配置系统，以实用主义为核心设计理念。它利用现代化的工具链，为 macOS 和 Linux 提供可复用且极速的安装体验。

> **设计理念**: "志存高远，实事求是" - 架构设计保留扩展空间，但当下只做必要的事。

## ✨ 特性

- **⚡️ 极速启动**: 从裸机到全功能开发环境仅需约 15 分钟。
- **🍎🐧 跨平台**: 完美支持 macOS (Apple Silicon/Intel) 和 Linux (Debian/Fedora/Ubuntu)。
- **🧩 模块化设计**: 基于配置文件的设置（工作站/服务器/最小化），支持细粒度模块控制。
- **🔒 安全优先**: 可选的 YubiKey + GPG + 1Password 集成，用于凭证管理。
- **🛠 现代技术栈**: 社区验证的工具 - Homebrew, Mise, Starship, Neovim, Sheldon。
- **🔄 配置即代码**: 单一 Git 仓库管理所有配置文件，基于模板的定制化。

## 🎯 使用场景

| 场景                   | 配置文件    | 启用模块                               | 安装耗时 |
| ---------------------- | ----------- | -------------------------------------- | -------- |
| **主力 MacBook**       | Workstation | Core + GUI + 字体 + Mise + 安全 + 维护 | ~15 分钟 |
| **远程 Linux 服务器**  | Server      | Core + Mise + 维护                     | ~8 分钟  |
| **Docker 容器**        | Minimal     | 仅 Core                                | ~3 分钟  |
| **工作机（受限环境）** | Manual      | Core + GUI（无安全模块）               | ~10 分钟 |
| **树莓派**             | Server      | Core + Mise                            | ~10 分钟 |

## 🏗 架构

本项目采用 **4 层模块化架构**：

```
┌─────────────────────────────────────────────┐
│  第 3 层: 维护工具（可选）                   │
│  Topgrade, Restic                           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  第 2 层: 项目运行时（可选）                 │
│  Mise → Python, Node.js, Rust, Go           │
│  uv, pnpm, cargo                            │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  第 1 层: 用户环境（模块化）                 │
│  ┌──────────────────────────────────────┐   │
│  │ Core 模块（必选）                    │   │
│  │ Git, Zsh, Neovim, Starship, Sheldon  │   │
│  └──────────────────────────────────────┘   │
│  ┌──────────────────────────────────────┐   │
│  │ GUI 模块（可选）                     │   │
│  │ VSCode, 浏览器, 终端模拟器           │   │
│  └──────────────────────────────────────┘   │
│  ┌──────────────────────────────────────┐   │
│  │ Security 模块（可选）                │   │
│  │ YubiKey, GPG, 1Password              │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  第 0 层: 系统引导（必需）                   │
│  安装 Homebrew + Chezmoi                    │
└─────────────────────────────────────────────┘
```

### 核心技术栈

- **配置管理**: [Chezmoi](https://www.chezmoi.io/) - 基于模板的配置文件管理器
- **包管理**: [Homebrew](https://brew.sh/) - macOS/Linux 通用包管理器
- **运行时管理**: [Mise](https://mise.jdx.dev/) - 快速、多语言版本管理器
- **Shell**: Zsh + [Sheldon](https://sheldon.cli.rs/)（插件管理器）+ [Starship](https://starship.rs/)（提示符）
- **编辑器**: [Neovim](https://neovim.io/) - 现代化 vim，Lua 配置（Lazy.nvim）
- **安全**: YubiKey + GPG + 1Password CLI（可选）

## 📂 目录结构

```
├── bootstrap.sh          # 安装入口脚本
├── data/                 # 软件包列表 (Brewfile, Flatpak)
├── dot_config/           # XDG Config Home 配置目录
│   ├── git/              # Git 配置
│   ├── mise/             # 运行时版本配置
│   ├── nvim/             # Neovim 配置
│   ├── sheldon/          # Zsh 插件配置
│   ├── starship.toml     # 终端提示符配置
│   └── zsh/              # Zsh 配置 (ZDOTDIR)
├── dot_local/            # 本地二进制文件和脚本
└── private_dot_ssh/      # SSH 配置模版
```

## 🚀 快速开始

### 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zopiya/dotfiles/main/bootstrap.sh)
```

**执行流程**:

1. 检测操作系统（macOS/Linux）和 CPU 架构（x86/ARM）
2. 安装系统依赖（仅 Linux）
3. 安装 Homebrew
4. 通过 Homebrew 安装 Chezmoi
5. 运行 `chezmoi init --apply` 并进行交互式配置

### 交互式配置

初始化过程中，系统会询问：

```
👋 欢迎使用 homeup 安装程序

1. 身份配置
   Git 名称: 你的名字
   Git 邮箱: your@email.com

2. 机器配置文件
   [1] workstation  (macOS/Linux GUI) - 完整工具栈
   [2] server       (无头环境)         - CLI + 运行时
   [3] minimal      (容器/CI)          - 仅核心
   [9] manual       (自定义)           - 细粒度控制
   选择配置: 1

3. 安全模块
   安装安全工具？(YubiKey/GPG/1Password) [y/N]: n

📝 配置摘要：
   Git 用户:    你的名字 <your@email.com>
   配置文件:     workstation
   模块:
     [x] Core CLI (基础)
     [x] GUI 应用程序
     [x] 字体
     [x] Mise 运行时
     [x] 维护工具
     [ ] 安全套件
```

### 安装后操作

```bash
# 重启 shell 应用更改
exec zsh

# 验证安装
chezmoi doctor
starship --version
nvim --version
```

## 🔧 日常使用

### 编辑配置

```bash
# ✅ 正确方式（编辑源文件，自动同步）
chezmoi edit ~/.zshrc

# ❌ 错误方式（创建配置漂移）
vim ~/.zshrc
```

### 应用变更

```bash
# 预览变更
chezmoi diff

# 应用到系统
chezmoi apply -v

# 验证一致性
chezmoi verify
```

### 跨机器同步

```bash
# 从 Git 拉取最新配置
chezmoi update

# 推送本地变更
chezmoi cd
git add .
git commit -m "feat: 添加新别名"
git push
```

### 管理运行时（如果启用 Mise）

```bash
# 安装全局工具
mise use --global python@3.12 node@20

# 项目特定版本
cd ~/projects/my-app
mise use python@3.11 node@18

# 查看当前版本
mise current
```

## ⚙️ 定制

### Fork 并个性化

1. **Fork** 本仓库
2. 克隆并初始化：
   ```bash
   chezmoi init --apply your-username
   ```
3. 修改配置：
   - `data/Brewfile.tmpl` - 添加/移除软件包
   - `dot_config/zsh/aliases.zsh` - 自定义别名
   - `dot_config/nvim/lua/plugins/init.lua` - Neovim 插件

### 高级：模块选择

编辑 `.chezmoi.toml.tmpl` 更改默认模块行为：

```toml
{{- $install_gui := promptBool "安装 GUI 应用？" true -}}
{{- $install_mise := promptBool "安装 Mise？" true -}}
```

## 🔒 安全最佳实践

### 密钥管理

- ✅ **应该**: 使用 1Password CLI 或 Bitwarden 管理密钥
- ✅ **应该**: 将 GPG 密钥存储在 YubiKey 中
- ❌ **不要**: 提交 `.chezmoi.toml`（包含机器特定数据）
- ❌ **不要**: 在配置文件中硬编码令牌

### 示例：1Password 集成

```toml
# dot_config/gh/config.yml.tmpl
github.com:
  user: {{ .github_username }}
  oauth_token: {{ onePasswordRead "op://Private/GitHub/token" }}
```

## 🐛 故障排查

| 问题                      | 解决方案                                         |
| ------------------------- | ------------------------------------------------ |
| `command not found: brew` | 重启 shell：`exec zsh`                           |
| `chezmoi: template error` | 检查语法：`chezmoi execute-template < file.tmpl` |
| Zsh 启动慢（>0.5 秒）     | 性能分析：`zsh -xv` 并优化插件加载               |
| GPG 签名失败              | 导入密钥：`gpg --import ~/.gnupg/pubring.gpg`    |
| Mise 未切换版本           | 检查项目目录中的 `.mise.toml`                    |

运行健康检查：

```bash
chezmoi doctor
```

## 🤝 贡献

欢迎贡献！请：

1. 遵循现有代码风格
2. 如可能，在 macOS 和 Linux 上测试
3. 为新功能更新文档

## 📚 延伸阅读

- [ARCHITECTURE_zh-CN.md](ARCHITECTURE_zh-CN.md) - 综合架构指南（中文）
- [Chezmoi 文档](https://www.chezmoi.io/)
- [Mise 文档](https://mise.jdx.dev/)

## 📜 许可证

MIT - 欢迎将此项目作为你的 dotfiles 模板！
