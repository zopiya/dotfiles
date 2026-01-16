# Mise 版本管理完整指南：构建多语言开发环境

> 从单语言到多运行时：统一的版本管理方案

**版本**: 1.0
**目标受众**: 全栈开发者、多语言用户、DevOps 工程师
**前置知识**: 基础 Shell 命令

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [项目级配置](#项目级配置)
- [全局版本管理](#全局版本管理)
- [高级用法](#高级用法)
- [最佳实践](#最佳实践)
- [与其他工具集成](#与其他工具集成)
- [故障排查](#故障排查)

---

## 核心概念

### Mise vs Nvm vs Pyenv vs Asdf

| 特性 | Mise | Nvm | Pyenv | Asdf |
|------|------|-----|-------|------|
| **多语言** | ✅ 开箱即用 | ❌ 仅 Node | ❌ 仅 Python | ✅ 需插件 |
| **性能** | ⚡ 极快（Rust） | 中等 | 中等 | 中等 |
| **配置文件** | `.mise.toml` | `.nvmrc` | `.python-version` | `.tool-versions` |
| **学习曲线** | 平缓 | 平缓 | 平缓 | 陡峭 |
| **社区** | 新兴（快速增长） | 成熟 | 成熟 | 成熟 |

**Mise 优势**:
- 单一命令管理所有语言版本
- 性能更好（Rust 实现）
- 现代化的配置语法（TOML）
- 与 Direnv 深度集成

### 关键术语

**Tool**: Node.js、Python、Ruby 等运行时或工具
**Runtime**: 版本化的工具实例（如 node@20.0.0）
**Scope**: 版本应用范围（全局、目录、会话）

---

## 快速开始

### 安装

```bash
# macOS
brew install mise

# Linux
curl https://mise.jdx.dev/install.sh | sh

# 验证
mise --version
```

### 初始化

```bash
# 在 ~/.zshrc 或 ~/.bashrc 中添加
eval "$(mise activate)"

# 重启 shell
exec zsh -l
```

### 最常用的 5 个命令

```bash
mise use node@20              # 使用 Node.js 20
mise use python@3.11          # 使用 Python 3.11
mise list                      # 列出已安装工具
mise trust ~/.mise.toml        # 信任项目配置
mise install                   # 安装 .mise.toml 中的所有工具
```

---

## 项目级配置

### 场景：React 全栈项目

创建 `.mise.toml`:

```toml
[tools]
node = "20.10"
python = "3.11"
ruby = "3.2"

[env]
NODE_OPTIONS = "--max-old-space-size=4096"
PYTHONUNBUFFERED = "1"

[settings]
activate_aggressive = true   # 自动激活工具
```

### 与 Direnv 集成

Mise 与 Direnv 天生兼容：

```bash
# 项目目录中创建 .envrc
use mise

# 激活
direnv allow

# 进入目录时自动加载 Mise 配置
```

### 项目特定配置

```toml
# .mise.toml
[tools]
node = "20"
pnpm = "8"

[env]
API_BASE_URL = "http://localhost:3000"
DATABASE_URL = "postgresql://localhost/mydb"

[tasks.dev]
description = "Start development server"
run = """
pnpm install
pnpm dev
"""

[tasks.test]
description = "Run tests"
run = "pnpm test"

[tasks.build]
description = "Build for production"
run = "pnpm build"
```

### 使用任务运行

```bash
mise run dev              # 启动开发服务器
mise run test             # 运行测试
mise run build            # 构建应用

# 列出所有任务
mise tasks
```

---

## 全局版本管理

### 设置全局默认版本

```bash
# 永久设置全局版本
mise use -g node@20
mise use -g python@3.11
mise use -g ruby@3.2

# 验证
mise ls
```

**位置**: 配置保存在 `~/.config/mise/config.toml`

### 全局 .tool-versions 文件

如果需要 Asdf 兼容性：

```bash
# 在 home 目录创建 .tool-versions
cat ~/.tool-versions
# node 20.10
# python 3.11
# ruby 3.2

# Mise 会自动识别此文件
```

---

## 高级用法

### 版本锁定与约束

```toml
# .mise.toml

[tools]
# 精确版本
node = "20.10.0"

# 小版本约束
python = "3.11.*"

# 主版本约束
ruby = "3.*"

# 范围约束
java = ">=17 <22"

# 最新版本
rust = "latest"
```

### 条件激活

```toml
[tools]
# 仅在 macOS 上
node = { version = "20", if = "platform == 'macos'" }

# 仅在 Linux 上
python = { version = "3.11", if = "platform == 'linux'" }
```

### 工具别名与虚拟工具

```bash
# 创建别名
mise alias set node 20 20.10.0
mise alias list

# 使用别名
mise use node@20   # 等同于 node@20.10.0
```

### 批量安装多个工具

```bash
# 从 .mise.toml 安装所有工具
mise install

# 安装特定工具
mise install node

# 安装特定版本
mise install node@20
```

### 环境变量管理

```toml
[tools]
node = "20"
python = "3.11"

[env]
# 开发环境
NODE_ENV = "development"
PYTHONDONTWRITEBYTECODE = "1"

# API 配置
API_BASE_URL = "http://localhost:3000"
API_KEY = { default = "dev-key", source = "env" }  # 从环境读取

# 条件设置
RAILS_ENV = { value = "development", if = "platform == 'macos'" }
```

### 插件与自定义工具

```bash
# 查看可用工具
mise plugins ls

# 安装自定义工具
mise plugins install my-custom-tool https://github.com/user/my-tool

# 使用自定义工具
mise use my-custom-tool@1.0
```

---

## 最佳实践

### 模式 1：多项目版本隔离

项目 A：

```toml
# ~/projects/project-a/.mise.toml
[tools]
node = "18"
python = "3.10"
```

项目 B：

```toml
# ~/projects/project-b/.mise.toml
[tools]
node = "20"
python = "3.12"
```

进入项目时自动切换版本：

```bash
cd ~/projects/project-a
node --version  # v18.x.x

cd ~/projects/project-b
node --version  # v20.x.x
```

### 模式 2：开发与生产环境分离

```toml
# .mise.toml

[env]
DEV = "true"
LOG_LEVEL = "debug"

[tools]
node = "20"

[tasks.dev]
run = "npm run dev"

[tasks.prod]
env = { DEV = "false", LOG_LEVEL = "info" }
run = "npm run build && npm start"

[tasks.test]
run = "npm test"
```

### 模式 3：团队协作

1. **版本锁定**: 在 `.mise.toml` 中指定精确版本
2. **配置共享**: 提交 `.mise.toml` 到 Git
3. **自动激活**: 开发者 `direnv allow` 一次

```bash
# 团队成员克隆项目后
cd myproject
direnv allow        # 一次性激活

# 之后每次进入自动加载正确版本
cd ..
cd myproject        # 自动激活配置
node --version      # 与其他项目一致
```

---

## 与其他工具集成

### Tmux 集成

在 Tmux 中自动加载项目环境：

```bash
# 创建项目会话时
tmux new-session -s myproject -c ~/myproject

# Direnv 自动加载 Mise 配置
# 窗格已有正确的 node 版本和环境变量
```

### Neovim/Vim 集成

在编辑器中检测项目工具版本：

```lua
-- nvim lsp.lua
local function get_node_path()
  -- Mise 会在 PATH 中暴露工具位置
  return vim.fn.system("which node"):gsub("\n", "")
end

-- LSP 配置使用检测到的路径
```

### GitHub Actions 集成

```yaml
name: CI

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: jdx/mise-action@v2
        with:
          install: true

      - run: node --version   # 使用 .mise.toml 中的版本
      - run: python --version
      - run: mise run test
```

### Docker 集成

```dockerfile
FROM node:20

# 安装 Mise
RUN curl https://mise.jdx.dev/install.sh | sh

WORKDIR /app
COPY .mise.toml .

# 安装工具
RUN mise install

CMD ["node", "app.js"]
```

---

## 故障排查

### 问题 1: 版本未自动激活

```bash
# 检查 Mise 是否初始化
echo $MISE_SHELL
# 应输出 zsh/bash

# 重新初始化
eval "$(mise activate)"
exec zsh -l
```

### 问题 2: 项目内版本不生效

```bash
# 检查 .mise.toml 是否正确
mise ls

# 手动信任配置
mise trust .mise.toml

# 验证激活
mise which node  # 应指向项目版本
```

### 问题 3: Direnv 冲突

```bash
# 检查 .envrc 配置
cat .envrc

# 应包含
use mise

# 重新激活
direnv reload
```

### 问题 4: PATH 混乱

```bash
# 检查 PATH 中的优先级
echo $PATH

# Mise 应该排在前面
# 如果不是，检查 shell 配置中的初始化顺序

# 正确的顺序：
eval "$(mise activate)"  # 必须在其他版本管理器之前
```

### 问题 5: 跨平台兼容性

```toml
# 确保配置支持多平台
[tools]
node = "20"

# 特定平台覆盖
[env]
# macOS 特定
PATH = { value = "/opt/homebrew/bin:$PATH", if = "platform == 'macos'" }
```

---

## 速查表

```bash
# 安装与初始化
mise install node@20                    # 安装特定版本
mise install                             # 安装所有工具
mise uninstall node@20                  # 卸载版本

# 版本管理
mise use node@20                        # 当前目录使用
mise use -g node@20                     # 全局设置
mise ls                                 # 列出已安装
mise ls -a                              # 列出所有可用

# 环境检查
mise which node                         # 显示使用的路径
mise env                                # 显示环境变量
mise current                            # 显示当前版本

# 项目配置
mise trust .mise.toml                   # 信任配置
mise run dev                            # 运行任务
mise tasks                              # 列出所有任务

# 调试
mise doctor                             # 诊断问题
mise cache clean                        # 清理缓存
```

---

## 总结

| 场景 | 推荐方案 |
|------|---------|
| **单项目多语言** | `.mise.toml` + `direnv allow` |
| **跨项目切换** | 全局配置 + 项目覆盖 |
| **团队协作** | 提交 `.mise.toml` 到 Git |
| **CI/CD** | `jdx/mise-action` |
| **容器化** | 在 Dockerfile 中安装 Mise |

Mise 的哲学：**一个命令管理所有版本，自动化而非手动。**

---

## 参考资源

- [Mise 官方文档](https://mise.jdx.dev)
- [Mise GitHub](https://github.com/jdx/mise)
- [Direnv 官方文档](https://direnv.net)
- [Homeup Mise 配置](../dot_config/mise)

