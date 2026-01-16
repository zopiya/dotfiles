# Direnv Complete Guide: Automatic Project Environment Management

> Directory-specific environment variables and runtimes: Transparently activate per-project configurations

**版本**: 1.0
**目标受众**: 多项目开发者、DevOps 工程师、全栈开发者
**前置知识**: Shell 基础、环境变量概念、项目目录结构

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [基础配置](#基础配置)
- [环境变量管理](#环境变量管理)
- [与 Mise 集成](#与-mise-集成)
- [高级用法](#高级用法)
- [最佳实践](#最佳实践)
- [故障排除](#故障排除)
- [总结与参考](#总结与参考)

---

## 核心概念

### 什么是 Direnv？

**Direnv** 是一个环境管理工具，能够根据当前工作目录自动加载/卸载环境变量和工具：

```
MacBook Project 1 (.envrc 有 Node.js 20)
  cd myapp           →  node 自动切换到 20.x

MacBook Project 2 (.envrc 有 Node.js 18)
  cd legacy-app      →  node 自动切换到 18.x

MacBook Home Directory
  cd ~               →  环境恢复到系统默认

无需手动管理版本、无需 `nvm use` 或 `pyenv activate`
```

### 问题与解决方案

**传统方式的问题**:

```bash
# 问题 1: 手动切换工具版本
$ nvm use 20           # 手动激活 Node.js 20
$ pyenv activate 3.11  # 手动激活 Python 3.11
$ # 容易忘记，导致使用错误的版本

# 问题 2: 多项目环境混乱
$ cd project-a         # 应该用 Node 18
$ node --version       # 但我忘了切换，使用的是全局 Node 20
$ npm install          # 安装错误的依赖版本

# 问题 3: CI/CD 与本地环境不一致
# 本地：使用了错误的版本但没发现
# CI：使用了正确的版本，但测试在本地无法复现
```

**Direnv 的解决方案**:

```
✅ 进入目录时自动激活
✅ 离开目录时自动卸载
✅ 透明（无需手动命令）
✅ 与 Mise 完美集成
✅ 支持任意环境变量
```

### 关键概念

| 术语 | 含义 | 例子 |
|------|------|------|
| **.envrc** | Direnv 配置文件（每个项目一个） | `echo export NODE_VERSION=20` |
| **allow** | 信任 .envrc 文件（安全机制） | `direnv allow` |
| **deny** | 拒绝加载 .envrc | `direnv deny` |
| **use xxx** | 激活特定工具（如 Mise） | `use mise` |
| **export** | 设置环境变量 | `export API_URL=http://localhost:3000` |
| **PATH_add** | 向 PATH 添加目录 | `PATH_add ./bin` |
| **source_env** | 加载其他 .env 文件 | `source_env .env.local` |

> 💡 **关键优势**: Direnv 是"透明的" - 你进入目录，环境自动变化，无需手动命令

---

## 快速开始

### ⚡ 5 分钟基础设置

```bash
# 1. 安装 Direnv（通过 Homebrew）
brew install direnv

# 2. 在 Shell 配置中初始化
# 添加到 ~/.zshrc（已在 Homeup 中配置）
eval "$(direnv hook zsh)"

# 3. 重启 shell
exec zsh -l

# 4. 进入项目目录
mkdir my-project
cd my-project

# 5. 创建 .envrc
echo "use mise" > .envrc

# 6. 允许 direnv 加载它
direnv allow

# 7. 现在所有在 .mise.toml 中定义的工具都自动激活
# 进出目录会自动卸载/加载
```

### ✅ 验证安装

```bash
# 检查 direnv 是否工作
direnv version

# 查看当前目录的环境
direnv show

# 输出示例：
# direnv: loading /Users/zopiya/my-project/.envrc
# direnv: export +NODE_OPTIONS
# direnv: export +PATH
```

### 🔧 Homeup 中的使用

Homeup 已预装 direnv 并在 Shell 配置中初始化。使用它只需：

```bash
# 进入任何 Homeup 仓库
cd ~/workspace/homeup

# Direnv 自动搜索 .envrc（通常在根目录）
# 如果没有找到，会向上搜索父目录

# 查看加载的环境
direnv show
```

---

## 基础配置

### .envrc 文件格式

`.envrc` 是标准 Bash 脚本，可以使用任何 Bash 命令和 Direnv 函数：

```bash
# 最简单的 .envrc
echo "Hello from .envrc"
export MY_VAR="value"
PATH_add ./bin
```

### 常用 Direnv 指令

#### export - 设置环境变量

```bash
# 基础用法
export NODE_ENV="development"
export API_URL="http://localhost:3000"
export DATABASE_URL="postgresql://localhost/mydb"

# 多行变量
export JAVA_OPTS="-Xms512m -Xmx2048m"

# 引用其他变量
export APP_HOME="$(pwd)"
export LOG_DIR="$APP_HOME/logs"
```

#### PATH_add - 向 PATH 添加目录

```bash
# 添加本地 bin 目录到 PATH
PATH_add ./bin
PATH_add ./node_modules/.bin

# 效果：现在可以直接运行本地脚本
# $ ./bin/my-script.sh  →  $ my-script.sh
```

#### use - 加载工具（整合器）

```bash
# 最常见：加载 Mise 工具版本
use mise

# 加载特定版本（如果 Mise 不可用）
use node 18.0.0

# 加载多个工具
use mise
use node 18
use python 3.11
```

#### source_env - 加载 .env 文件

```bash
# 加载敏感变量（通常在 .gitignore 中）
source_env .env.local

# 安全：.env.local 不被版本控制，防止密钥泄露
```

#### dotenv - 加载 .env（Direnv 内置）

```bash
# 自动加载 .env 文件（如果存在）
dotenv
```

### 实际例子

#### 场景 1: React 全栈项目

```bash
# 项目根目录的 .envrc
use mise

# API 服务配置
export API_PORT=3000
export API_HOST="http://localhost:3000"

# 数据库配置
export DATABASE_URL="postgresql://localhost/myapp_dev"
export REDIS_URL="redis://localhost:6379"

# 开发工具配置
export NODE_ENV="development"
export DEBUG="app:*"

# 加载项目特定的敏感变量
source_env .env.local
```

**同时需要 .mise.toml**:

```toml
[tools]
node = "20.10"
python = "3.11"  # 如果后端也需要 Python
pnpm = "8"       # 包管理器

[env]
# Mise 也可以设置变量
NODE_OPTIONS = "--max-old-space-size=4096"
```

**使用流程**:

```bash
$ cd myapp

# 自动激活（无需手动）
direnv: loading ~/.envrc
direnv: using mise

$ node --version
v20.10.0

$ echo $API_URL
http://localhost:3000

$ npm install    # 使用 pnpm（via PATH_add）
```

#### 场景 2: 多环境配置

```bash
# .envrc - 根据环境加载不同配置
if [[ "$ENVIRONMENT" == "production" ]]; then
    source_env .env.prod
elif [[ "$ENVIRONMENT" == "staging" ]]; then
    source_env .env.staging
else
    source_env .env.local  # 默认开发环境
fi

use mise
```

**使用**:

```bash
# 开发环境（默认）
$ cd myapp

# 临时切换到生产环境
$ ENVIRONMENT=production direnv reload

# 检查配置
$ echo $DATABASE_URL
postgresql://prod.db.example.com/myapp
```

---

## 环境变量管理

### 本地环境变量（.env.local）

最常见的模式是使用 `.env.local` 存储本地/敏感变量：

```bash
# .gitignore
.env.local
.env*.local
```

```bash
# .envrc
source_env .env.local
```

```bash
# .env.local (不被版本控制)
API_KEY=sk-xxxxxxx
DATABASE_PASSWORD=secret123
STRIPE_KEY=sk_live_xxxxx
```

### 变量优先级

```
1. 全局 Shell 变量（登录时设置）
2. Direnv 变量（从 .envrc）
3. 项目变量（从 source_env .env.local）
4. 命令行变量（当前命令指定）

# 示例
$ DATABASE_URL=override npm test
# 此时 $DATABASE_URL 使用命令行的 override，而不是 .envrc 中的值
```

### 变量继承

```bash
# 父目录的 .envrc
# ~/myproject/.envrc
export COMPANY="Acme"
export PROJECT_ROOT="$(pwd)"

# 子目录的 .envrc
# ~/myproject/backend/.envrc
use mise
export SERVICE_NAME="backend"

# 结果：子目录既继承父的 COMPANY、PROJECT_ROOT，
# 又有自己的 SERVICE_NAME
```

### 列出当前环境

```bash
# 查看 Direnv 添加的所有变量
direnv show

# 输出示例：
# direnv: export +API_PORT
# direnv: export +API_HOST
# direnv: export +NODE_ENV
# direnv: export ~PATH  (修改了 PATH)

# 用 env | grep -E 查看具体值
env | grep -E "API_|NODE_ENV|DATABASE"
```

---

## 与 Mise 集成

### use mise - 推荐方式

Direnv 与 Mise 无缝集成：

```bash
# .envrc（仅一行）
use mise
```

这会：
1. 读取 `.mise.toml` 中的 `[tools]` 配置
2. 自动安装缺失的工具版本
3. 将这些工具添加到 PATH
4. 设置任何额外的 `[env]` 变量

### 完整例子：Node.js + Python + Go

```bash
# .mise.toml
[tools]
node = "20.10"
python = "3.11"
go = "1.21"
terraform = "1.5"

[env]
NODE_OPTIONS = "--max-old-space-size=4096"
PYTHONUNBUFFERED = "1"

[tasks]
dev = "npm run dev"
test = "npm test"
```

```bash
# .envrc
use mise

# 额外的项目变量
export API_PORT=3000
export DATABASE_URL="postgresql://localhost/dev"
```

**进入目录**:

```bash
$ cd myapp

# Direnv 加载 .envrc
direnv: loading .envrc

# use mise 触发 Mise 加载工具
# 自动版本切换（如果之前用了不同版本）
$ node --version
v20.10.0

$ python --version
Python 3.11.x

$ go version
go version go1.21 ...
```

### 手动版本管理

如果不用 Mise，可以手动指定：

```bash
# .envrc（不用 Mise）
export NODE_HOME="$HOME/.nvm/versions/node/v20.10.0"
export PYTHON_HOME="/opt/homebrew/opt/python@3.11"

PATH_add "$NODE_HOME/bin"
PATH_add "$PYTHON_HOME/bin"
```

但 **不推荐** - Mise 更现代、更快。

---

## 高级用法

### 条件加载

```bash
# .envrc - 根据条件加载不同配置
if [[ -f .env.local ]]; then
    source_env .env.local
fi

# 根据 Git 分支加载不同配置
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" == "main" ]]; then
    export ENVIRONMENT="production"
else
    export ENVIRONMENT="development"
fi

use mise
```

### 函数定义

```bash
# .envrc - 定义 Shell 函数
setup_db() {
    echo "Setting up database..."
    npm run migrate
    npm run seed
}

# 导出函数到 Shell
export -f setup_db

# 现在可以直接在 Shell 中调用
# $ setup_db
```

### 钩子和事件

```bash
# .envrc - 定义加载和卸载时的操作
# 注意：这些是 Bash 命令，不是 Direnv 特定的

# 加载时
echo "Entering project environment"

# 卸载时（通常在 Shell 脚本中定义清理函数）
trap 'echo "Leaving project environment"' EXIT
```

### 递归 .envrc

```bash
# 根目录 ~/.envrc（可选）
# 对所有子目录生效

# 子项目 ~/myproject/.envrc
# 继承根目录的设置，添加项目特定配置

use mise
export PROJECT_NAME="myproject"
```

### 加载外部文件

```bash
# .envrc - 加载 shell 脚本
source ./scripts/setup.sh

# 加载 dotenv 格式
dotenv

# 加载特定的 .env 文件（不是 dotenv 格式）
while IFS='=' read -r key value; do
    export "$key=$value"
done < .env.vars
```

---

## 最佳实践

### 安全管理敏感信息

```bash
# ❌ 错误：在 .envrc 中硬编码密钥
export API_KEY="sk-12345"

# ✅ 正确：使用 .env.local（加入 .gitignore）
# .envrc
source_env .env.local

# .env.local（不被版本控制）
export API_KEY="sk-12345"
export DATABASE_PASSWORD="secret"
```

### .gitignore 配置

```bash
# 永远不要提交敏感变量文件
.env.local
.env.*.local
.envrc.local

# 可以提交示例文件
# .env.example
API_KEY=your_key_here
DATABASE_URL=your_url_here
```

### 项目配置检查清单

```bash
# 创建新项目时的步骤：

# 1. 创建 .envrc
cat > .envrc <<'EOF'
use mise
source_env .env.local
export PROJECT_NAME="my-project"
EOF

# 2. 创建 .env.example（示例，可提交）
cat > .env.example <<'EOF'
API_KEY=your_key_here
DATABASE_URL=postgresql://localhost/mydb
EOF

# 3. 创建 .env.local（实际值，不提交）
# 手动复制 .env.example 并填入真实值
cp .env.example .env.local

# 4. 创建 .mise.toml
cat > .mise.toml <<'EOF'
[tools]
node = "20"
python = "3.11"

[env]
NODE_ENV = "development"
EOF

# 5. 允许 direnv
direnv allow

# 6. 验证
direnv show
```

### 防止 .envrc 执行错误

```bash
# .envrc - 添加错误处理
set -euo pipefail  # 遇到错误立即停止

if [[ ! -f .env.local ]]; then
    echo "Error: .env.local not found"
    echo "Copy from .env.example and update values"
    exit 1
fi

source_env .env.local

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "Error: DATABASE_URL not set"
    exit 1
fi

use mise
```

---

## 故障排除

### ❓ Direnv 没有加载 .envrc

**问题**:
```bash
$ cd myproject
# 没有看到 "direnv: loading" 信息
```

**原因和解决**:

```bash
# 1. 检查 direnv 是否安装
which direnv
# 如果无输出：brew install direnv

# 2. 检查 Shell hook 是否激活
# 查看 ~/.zshrc，应该有：
eval "$(direnv hook zsh)"

# 3. 重启 Shell
exec zsh -l

# 4. 检查 .envrc 是否被允许
direnv status

# 如果输出 "deny"，需要：
direnv allow
```

### ❓ "direnv: command not found"

**解决**:

```bash
# 1. 检查安装
brew install direnv

# 2. 在 ~/.zshrc 中添加 hook（如果没有）
eval "$(direnv hook zsh)"

# 3. 重启 Shell
exec zsh -l
```

### ❓ .envrc 变更后没有自动重新加载

**解决**:

```bash
# 手动重新加载
direnv reload

# 或离开目录再进入
cd ..
cd myproject
```

### ❓ Mise 工具没有激活

**问题**:
```bash
$ direnv allow
$ node --version
# bash: node: command not found
```

**解决**:

```bash
# 1. 检查 .envrc
cat .envrc
# 应该有 "use mise"

# 2. 检查 .mise.toml
cat .mise.toml
# 应该在 [tools] 中定义 node

# 3. 手动测试 Mise
mise install
mise list

# 4. 重新加载 direnv
direnv reload
```

### ❓ 离开目录后环境变量仍然存在

**原因**: Direnv hook 没有正确处理卸载

**解决**:

```bash
# 检查 Shell hook
grep direnv ~/.zshrc

# 应该显示：
# eval "$(direnv hook zsh)"

# 如果缺少，添加它并重启 Shell
exec zsh -l
```

### ❓ CI/CD 中的 direnv

```bash
# CI/CD 环境通常没有交互式 Shell
# 不需要 direnv，但可以手动加载 .env

# 方法 1: 直接加载 .env 文件
set -o allexport
source .env.local
set +o allexport

# 方法 2: 在 CI 中禁用 direnv hook
export DIRENV_LOG_FORMAT=""  # 禁用 direnv 输出
```

---

## 总结与参考

| 方面 | 最佳实践 |
|------|----------|
| **自动激活** | 在 Shell hook 中启用 direnv（.zshrc） |
| **项目变量** | 使用 source_env .env.local（敏感信息） |
| **运行时管理** | 使用 use mise（Mise 集成） |
| **安全** | 永不提交 .env.local，使用 .env.example |
| **信任** | direnv allow 白名单管理 |
| **调试** | direnv show 查看当前环境 |

### 核心命令速查

```bash
# 基础操作
direnv version           # 显示版本
direnv allow             # 信任当前 .envrc
direnv deny              # 拒绝加载 .envrc
direnv reload            # 重新加载当前 .envrc
direnv reset             # 重置所有 direnv 状态

# 调试
direnv show              # 显示当前环境（Direnv 添加的）
direnv status            # 显示 .envrc 信任状态
direnv edit              # 编辑当前 .envrc

# 清理
direnv prune             # 移除已删除项目的 .envrc 信息
```

### .envrc 关键函数

```bash
use mise                    # 加载 Mise 工具版本
export VAR=value          # 设置环境变量
PATH_add ./bin             # 向 PATH 添加目录
source_env .env.local      # 加载 .env 文件
dotenv                     # 加载 .env（Direnv 格式）
source ./script.sh         # 加载 Shell 脚本
```

---

## 参考资源

- [Direnv 官方文档](https://direnv.net/)
- [Mise Direnv 集成](https://mise.jdx.dev/direnv.html)
- [Homeup architecture.md](architecture.md)
- [Homeup MISE_GUIDE.md](MISE_GUIDE.md)
- [Homeup SHELL_SETUP.md](SHELL_SETUP.md)
- [Environment Variables Best Practices](best-practices.md)
