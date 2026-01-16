# Neovim LSP Multi-Language Guide: IDE-Grade Code Intelligence

> Language Server Protocol integration: IntelliSense, diagnostics, refactoring for Python, Node.js, Go, Rust and more

**版本**: 1.0
**目标受众**: 多语言开发者、全栈工程师、Neovim 用户
**前置知识**: Neovim 基础、LSP 概念、多语言项目经验

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [LSP 架构](#lsp-架构)
- [按语言配置](#按语言配置)
- [IntelliSense 和自动完成](#intellisense-和自动完成)
- [诊断和错误处理](#诊断和错误处理)
- [重构和导航](#重构和导航)
- [高级配置](#高级配置)
- [性能优化](#性能优化)
- [常见问题](#常见问题)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### LSP 是什么？

**Language Server Protocol** (LSP) 是微软开发的标准协议，将语言智能分离出来：

```
编辑器                           语言服务器
Neovim ←→ (通过 LSP) ←→ Pyright
         ←→              Typescript Server
         ←→              gopls
         ←→              rust-analyzer
         ←→              lua-language-server
```

### 传统方式 vs LSP 方式

**传统方式（IDE 集成）**:

```
❌ VSCode 内置 Python 支持
❌ VSCode 内置 TypeScript 支持
❌ 每个编辑器重复实现同样的功能
❌ 编辑器臃肿，维护困难
```

**LSP 方式（标准化）**:

```
✅ Neovim、VSCode、Sublime 都可用同一个 Server
✅ 各编辑器独立维护客户端（轻量）
✅ 服务器专注于语言智能
✅ 编辑器专注于用户体验
```

### LSP 提供的功能

| 功能 | 描述 | 快捷键（Homeup） |
|------|------|---------|
| **Hover** | 悬停查看类型和文档 | `K` |
| **Go to Definition** | 跳转到定义 | `gd` |
| **Go to Declaration** | 跳转到声明 | `gD` |
| **Go to Implementation** | 跳转到实现 | `gi` |
| **References** | 查找所有引用 | `gr` |
| **Rename** | 重命名符号 | `<leader>rn` |
| **Code Actions** | 快速修复/重构 | `<leader>ca` |
| **Diagnostics** | 错误/警告/提示 | `[d`, `]d` |
| **Format** | 格式化代码 | `<leader>f` |
| **Completion** | 自动完成 | `Ctrl+Space` |
| **Signature Help** | 函数签名帮助 | `Ctrl+k` |

---

## 快速开始

### ⚡ 5 分钟设置 Python LSP

```bash
# 1. Homeup 已预装所有依赖
# - neovim
# - nvim-lspconfig (LSP 客户端)
# - mason (LSP 服务器管理)
# - cmp + cmp-nvim-lsp (自动完成)

# 2. 进入 Neovim
nvim

# 3. 安装 Python 语言服务器
:MasonInstall pyright

# 4. 验证安装
:Mason
# 应该看到 pyright 在列表中并标记为 ✓ installed

# 5. 打开 Python 文件
:e test.py

# 6. 测试 LSP 功能
import os
def hello():
    pass

# 在函数名上按 K，应该看到悬停帮助
# 在 os 上按 gd，应该跳转到定义
```

### ✅ 验证 LSP 工作

```bash
# 进入 Neovim
nvim

# 命令查看 LSP 状态
:LspInfo

# 输出应该显示：
# Language client log (server: pyright)
#  Pid: 12345
#  Running in: /current/directory
#  Capabilities: textDocument/definition, textDocument/hover, ...
```

### 🔧 Homeup 中的 LSP

Homeup 已预配置以下语言服务器：

```lua
-- ~/.config/nvim/lua/config/lsp.lua

ensure_installed = {
  "lua_ls",      # Lua
  "pyright",     # Python
  "ts_ls",       # TypeScript / JavaScript
  "bashls",      # Bash
  "jsonls",      # JSON
}
```

要添加更多语言，编辑此文件并重启 Neovim。

---

## LSP 架构

### 三层架构

```
┌────────────────────────────────────────┐
│        Neovim (编辑器)                  │
│                                        │
│  • UI 渲染                              │
│  • 按键映射                             │
│  • Buffer 管理                          │
└──────────────┬─────────────────────────┘
               │ (LSP 协议)
┌──────────────▼─────────────────────────┐
│    nvim-lspconfig (LSP 客户端)         │
│                                        │
│  • 启动/关闭服务器                     │
│  • 处理 RPC 消息                       │
│  • 集成 completion、diagnostic          │
└──────────────┬─────────────────────────┘
               │ (标准输入/输出)
┌──────────────▼─────────────────────────┐
│    Language Server (pyright 等)        │
│                                        │
│  • 解析代码                             │
│  • 类型检查                             │
│  • 符号查找                             │
│  • 生成诊断                             │
└────────────────────────────────────────┘
```

### 关键组件

| 组件 | 作用 | 例子 |
|------|------|------|
| **nvim-lspconfig** | LSP 客户端配置 | 定义如何启动 pyright |
| **mason** | 服务器包管理 | 安装/卸载语言服务器 |
| **mason-lspconfig** | 自动化配置 | 自动注册 mason 安装的服务器 |
| **nvim-cmp** | 自动完成引擎 | 补全菜单 |
| **cmp-nvim-lsp** | LSP 完成源 | 使用 LSP 的智能补全 |
| **null-ls** (optional) | 额外的 linter/formatter | ESLint、Prettier、Black |

---

## 按语言配置

### Python (Pyright)

#### 基础配置

```lua
-- ~/.config/nvim/lua/config/lsp.lua

lspconfig.pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    python = {
      pythonPath = vim.fn.exepath("python"),
      analysis = {
        extraPaths = {},
        typeCheckingMode = "basic",  -- "off", "basic", "strict"
      },
    },
  },
})
```

#### 虚拟环境支持

```lua
-- 自动检测虚拟环境
lspconfig.pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    python = {
      pythonPath = (function()
        local activate_this = os.getenv("VIRTUAL_ENV") .. "/bin/python"
        if vim.fn.executable(activate_this) == 1 then
          return activate_this
        end
        return exepath("python")
      end)(),
    },
  },
})
```

#### Mise 集成

```lua
-- 使用 Mise 管理的 Python
lspconfig.pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    python = {
      pythonPath = "/Users/zopiya/.mise/installs/python/3.11.x/bin/python",
    },
  },
})
```

#### 常用快捷键

```bash
K              # 查看类型和文档
gd             # 跳转到定义
gi             # 跳转到实现
<leader>rn     # 重命名
<leader>ca     # 代码操作（提取函数、快速修复）

# 诊断导航
[d             # 上一个诊断
]d             # 下一个诊断
<leader>e      # 显示行诊断
```

#### 例子：重构函数

```python
# 原始代码
def process_data(data):
    result = []
    for item in data:
        if item > 0:
            result.append(item * 2)
    return result

# 在函数名上：
# 1. 按 <leader>ca (Code action)
# 2. 选择 "Extract variable" 或 "Extract method"
# 3. 函数自动重构
```

### TypeScript / JavaScript (TypeScript LSP)

#### 基础配置

```lua
lspconfig.ts_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
  },
})
```

#### React 项目优化

```lua
-- 使用 typescript 而非 javascript
lspconfig.ts_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
})
```

#### 常用快捷键

```bash
K              # 查看类型提示
gd             # 跳转到定义
gi             # 跳转到实现（接口）
gr             # 查找引用
<leader>rn     # 重命名
<leader>ca     # 代码操作（提取变量、函数、接口）
<leader>f      # 格式化（Prettier）
```

### Go (gopls)

#### 配置

```lua
lspconfig.gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
    },
  },
})
```

#### 常用操作

```bash
K              # 查看类型和文档
gd             # 跳转到定义
gi             # 跳转到接口实现
<leader>rn     # 重命名
<leader>ca     # 代码操作（提取变量、函数）
<leader>f      # 格式化（gofmt）

# Go 特定
gr             # 查看方法接收者
```

### Rust (rust-analyzer)

#### 配置

```lua
lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
      inlayHints = {
        bindingModeHints = {
          enable = false,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 25,
        },
        closureReturnTypeHints = {
          enable = "never",
        },
        lifetimeElisionHints = {
          enable = "never",
        },
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "never",
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
    },
  },
})
```

---

## IntelliSense 和自动完成

### 自动完成引擎

Homeup 使用 **nvim-cmp** 作为完成引擎：

```lua
-- ~/.config/nvim/lua/plugins/completion.lua

local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },      # LSP
    { name = "luasnip" },       # 代码片段
    { name = "buffer" },        # 当前 buffer
  }),
})
```

### 完成触发器

```bash
Ctrl+Space          # 手动触发完成
<Tab>               # 选择下一个
<S-Tab>             # 选择上一个
<CR>                # 确认选择
<C-b>/<C-f>         # 向上/向下滚动文档
```

### 源的优先级

```lua
sources = cmp.config.sources({
  { name = "nvim_lsp" },      # 优先级 1（LSP）
  { name = "luasnip" },       # 优先级 2（代码片段）
  { name = "buffer" },        # 优先级 3（当前文件）
  { name = "path" },          # 优先级 4（文件路径）
})
```

---

## 诊断和错误处理

### 显示诊断

```bash
# 在当前行显示诊断
<leader>e

# 在浮动窗口中显示
:LspDiagnosticsShowLineCodeActions

# 列出所有诊断
:Telescope diagnostics
```

### 诊断导航

```bash
[d             # 上一个诊断
]d             # 下一个诊断
<leader>q      # 打开 quickfix 列表
```

### 诊断严重级别

```lua
-- 配置诊断显示
vim.diagnostic.config({
  virtual_text = {
    prefix = "● ",
    format = function(diagnostic)
      return string.format("%s (%s)", diagnostic.message, diagnostic.source)
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})
```

### 类型检查级别

Python 的 Pyright 支持三个级别：

```lua
settings = {
  python = {
    analysis = {
      typeCheckingMode = "off",    # 关闭
      -- typeCheckingMode = "basic",  # 基础检查
      -- typeCheckingMode = "strict", # 严格检查
    },
  },
}
```

---

## 重构和导航

### 查找和跳转

```bash
gd             # 定义
gD             # 声明
gi             # 实现
gr             # 引用
Ctrl+]         # 标签跳转
```

### 代码操作

```bash
<leader>ca     # 显示可用的代码操作

常见操作：
- Extract variable
- Extract function
- Rename
- Implement interface
- Add missing imports
- Remove unused imports
- Quick fix (fix errors)
```

### 重命名示例

```python
# 原始
def get_user_name():
    return "John"

name = get_user_name()  # 使用此处

# 在函数定义上：
# 1. 按 <leader>rn
# 2. 输入新名称 get_full_name
# 3. 回车

# 结果：函数和所有引用都被重命名
def get_full_name():
    return "John"

name = get_full_name()
```

---

## 高级配置

### 多个 LSP 服务器

```lua
-- 为不同文件类型配置不同服务器

-- Python
lspconfig.pyright.setup({ ... })

-- TypeScript
lspconfig.ts_ls.setup({ ... })

-- Go
lspconfig.gopls.setup({ ... })

-- Rust
lspconfig.rust_analyzer.setup({ ... })

-- Lua
lspconfig.lua_ls.setup({ ... })

-- JSON
lspconfig.jsonls.setup({ ... })

-- Bash
lspconfig.bashls.setup({ ... })
```

### 格式化集成

```lua
-- 使用 Prettier 格式化 JS/TS
lspconfig.ts_ls.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    -- 保存时自动格式化
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})
```

### 自定义诊断符号

```lua
local signs = { Error = "🔴", Warn = "🟠", Hint = "💡", Info = "ℹ️" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end
```

---

## 性能优化

### 延迟加载 LSP

```lua
-- 仅在打开支持的文件时加载 LSP
if vim.fn.executable("pyright") == 1 then
  require("config.lsp")
end
```

### 减少诊断开销

```lua
vim.diagnostic.config({
  update_in_insert = false,  # 不在插入模式更新
  virtual_text = false,      # 关闭虚拟文本
})
```

### 异步格式化

```lua
vim.lsp.buf.format({ async = true })
```

---

## 常见问题

### ❓ LSP 没有启动

**检查**:

```bash
# 1. 查看 LSP 状态
:LspInfo

# 2. 检查服务器是否安装
:Mason

# 3. 查看错误日志
:LspLog
```

### ❓ 自动完成不工作

**解决**:

```lua
-- 1. 检查 cmp 和 LSP 是否都启用
-- 2. 检查 sources 配置
-- 3. 尝试手动触发
Ctrl+Space

-- 4. 检查文件类型是否支持
:set filetype?
```

### ❓ 重命名时出错

**问题**: "Rename failed: unable to rename"

**解决**:

```bash
# 1. 确保在可重命名的符号上（类型、函数、变量）
# 2. 尝试手动重命名再提交
# 3. 检查 LSP 日志看详细错误
:LspLog
```

### ❓ 跳转到定义不工作

**解决**:

```bash
# 1. 检查 LSP 是否已启动
:LspInfo

# 2. 尝试手动跳转
:LspDefinition

# 3. 使用 Ctrl+] 标签跳转（备选）
Ctrl+]

# 4. 检查代码中是否有对该符号的定义
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **多语言** | 为每种语言配置相应的 LSP 服务器 |
| **虚拟环境** | 配置 pythonPath 指向正确的 Python 可执行文件 |
| **完成** | 使用 nvim-cmp + LSP 源获得智能补全 |
| **导航** | 学习 gd/gi/gr 快捷键，快速代码浏览 |
| **诊断** | 使用 [d/]d 导航错误，<leader>e 查看详情 |
| **格式化** | 配置 on_attach 钩子在保存时自动格式化 |
| **性能** | 关闭不需要的功能（虚拟文本、insert 模式更新） |

### 核心快捷键速查

```bash
# 导航
gd       - 定义
gD       - 声明
gi       - 实现
gr       - 引用
<leader>rn - 重命名

# 代码操作
<leader>ca - 代码操作
<leader>f  - 格式化
<leader>e  - 显示诊断

# 诊断
[d       - 上一个诊断
]d       - 下一个诊断

# 完成
Ctrl+Space - 手动触发
<C-b/f>   - 滚动文档
<CR>      - 确认
```

---

## 参考资源

- [nvim-lspconfig GitHub](https://github.com/neovim/nvim-lspconfig)
- [Language Server Protocol](https://microsoft.github.io/language-server-protocol/)
- [Pyright Documentation](https://github.com/microsoft/pyright)
- [Typescript Server](https://github.com/typescript-language-server/typescript-language-server)
- [Go Language Server](https://github.com/golang/tools/wiki/gopls)
- [Rust Analyzer](https://rust-analyzer.github.io/)
- [Homeup Neovim Guide](NEOVIM_COMPLETE_GUIDE.md)
- [Homeup Mise Guide](MISE_GUIDE.md)
