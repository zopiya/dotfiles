# 项目贡献指南 (Contributing Guide)

感谢您对 Homeup 的兴趣！本指南将帮助您理解项目结构、编码规范和贡献流程。

**版本**: 2.1
**最后更新**: 2024-01-16

---

## 📋 目录

- [行为准则](#行为准则)
- [项目哲学](#项目哲学)
- [开发环境设置](#开发环境设置)
- [编码规范](#编码规范)
- [提交和推送](#提交和推送)
- [文档编写](#文档编写)
- [提交 PR](#提交-pr)
- [常见问题](#常见问题)

---

## 🤝 行为准则

### 我们的承诺

在参与本项目时，我们承诺：

- 尊重所有贡献者和用户
- 欢迎不同的观点和意见
- 接受建设性的批评
- 关注对社区最有利的事情

### 不可接受的行为

以下行为是不可接受的：

- 人身攻击或骚扰
- 不尊重的语言或评论
- 受保护的信息披露
- 任何形式的歧视

违反此行为准则的参与者将被暂停或永久禁止参与项目。

---

## 💡 项目哲学

### 设计原则

Homeup 遵循以下核心原则：

1. **简洁性优于复杂性**
   - 代码应该清晰易懂
   - 避免过度工程化
   - 使用最小的依赖

2. **代码即文档**
   - 代码应该自解释
   - 注释只用于解释"为什么"，而不是"是什么"
   - 函数名和变量名应该清晰

3. **一致性和标准化**
   - 遵循统一的编码风格
   - 遵循通用约定（如commit消息格式）
   - 维护一致的项目结构

4. **跨平台兼容性**
   - 支持 macOS 和 Linux
   - 测试多个系统和场景
   - 清晰地记录平台特定的行为

5. **可维护性**
   - 写易于维护的代码
   - 提供清晰的文档
   - 考虑未来的维护者

### 技术栈考虑

在提出新工具或技术时，请考虑：

- **必要性**: 这个工具真的必需吗？
- **维护成本**: 添加长期维护负担吗？
- **学习曲线**: 对新用户有多难？
- **替代方案**: 有更简单的替代方案吗？
- **平台支持**: 是否支持 macOS 和 Linux？

---

## 🛠️ 开发环境设置

### 前置要求

```bash
# 必需
macOS 11+ 或 Linux (Ubuntu 20.04+, Fedora 35+)
Git
Homebrew (或系统包管理器)
Chezmoi 2.68.1+
Just 1.14.0+

# 推荐
Neovim 0.9+
或 VS Code 1.70+
```

### 本地开发设置

```bash
# 1. Fork 项目（可选，如果您计划推送到远程）
# 访问 https://github.com/zopiya/homeup 并点击 Fork

# 2. Clone 仓库
git clone https://github.com/zopiya/homeup.git
cd homeup

# 3. 创建开发分支
git checkout -b feature/your-feature-name

# 4. 安装开发依赖
just install-dev  # 如果存在的话，否则运行 just bootstrap

# 5. 验证设置
just doctor
```

### 运行测试

```bash
# 运行所有验证
just validate-all

# 运行特定验证
just test-bootstrap        # 测试启动脚本
just validate-brewfile     # 验证Brewfile
just lint-yaml            # YAML检查
```

---

## 📝 编码规范

### Shell 脚本 (Bash/Zsh)

**命名规范**:
```bash
# 函数名：snake_case
function my_function() {
  :
}

# 常量：UPPER_SNAKE_CASE
readonly CONSTANT_NAME="value"

# 局部变量：snake_case
local local_var="value"
```

**风格指南**:
```bash
# ✅ 好
function install_packages() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Error: Package name required" >&2
    return 1
  fi
  brew install "$package"
}

# ❌ 差
function installPackages() {
  pkg=$1
  if [ $# -eq 0 ]; then
    echo "Error"
  fi
  brew install $pkg
}
```

**注释规范**:
```bash
# ✅ 好：解释"为什么"
# 延迟初始化LSP以提高启动速度
zsh-defer source ~/.config/nvim/lsp.zsh

# ❌ 差：解释"是什么"
# 加载LSP配置
zsh-defer source ~/.config/nvim/lsp.zsh
```

### TOML 配置文件

**命名规范**:
```toml
# 按功能分组
[plugins.group1]
name = "plugin1"
enabled = true

[plugins.group2]
name = "plugin2"
enabled = false
```

**注释规范**:
```toml
# ✅ 好：只在必要时添加
[tools]
# Python 保持在 3.11 以确保与某些库的兼容性
python = "3.11"

# ❌ 差：不必要的注释
# 这设置了Python版本
python = "3.11"
```

### Lua (Neovim)

**命名规范**:
```lua
-- 函数和变量：snake_case
local function setup_lsp()
  :
end

-- 常量：UPPER_SNAKE_CASE
local LSP_CONFIG = {}

-- 私有函数：_leading_underscore
local function _internal_helper()
  :
end
```

**风格指南**:
```lua
-- ✅ 好
local function configure_keymaps()
  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', '<leader>ff', builtin.find_files, opts)
end

-- ❌ 差
function setup() vim.keymap.set('n','<leader>ff',function() require('telescope.builtin').find_files() end) end
```

---

## 📦 文件结构规范

### 配置文件组织

```
dot_config/
├── nvim/                          # Neovim配置
│   ├── init.lua                   # 主配置文件
│   ├── lua/
│   │   ├── core/                  # 核心设置（选项、键盘映射）
│   │   ├── plugins/               # 插件加载和配置
│   │   └── lsp/                   # LSP配置
│   └── after/                     # 加载后配置
│
├── zsh/                           # Zsh配置
│   ├── aliases.zsh                # 别名定义
│   ├── functions.zsh              # 自定义函数
│   └── completion.zsh             # 补全配置
│
└── git/                           # Git配置
    └── config.tmpl                # Git配置模板
```

### 命名规范

```
配置文件：     snake_case.ext  (例：git_config.toml)
函数文件：     verbs_nouns.zsh (例：package_install.zsh)
插件目录：     lowercase        (例：plugins/)
常量名：       UPPER_SNAKE_CASE (例：PLUGIN_DIR)
```

---

## 💬 提交和推送

### Commit 消息规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**类型** (`type`):
```
feat:       新功能
fix:        修复bug
docs:       文档更改
style:      格式/风格（不影响功能）
refactor:   代码重构（不改变功能）
perf:       性能优化
test:       测试相关
chore:      构建/依赖相关
ci:         CI/CD流程
```

**范围** (`scope`) - 可选但推荐：
```
nvim       Neovim配置
zsh        Zsh相关
git        Git配置
homebrew   Brewfile相关
docs       文档
```

**主题** (`subject`):
- 使用祈使句（"add" 而不是 "added"）
- 不要大写开头
- 不要以句号结尾
- 限制在50个字符以内

**示例**:

```
✅ 好的 Commit 消息：

feat(nvim): add TreeSitter integration for better syntax highlighting

This commit adds Tree-sitter support to improve syntax highlighting
performance and accuracy across multiple programming languages.

Closes #123

fix(zsh): resolve Sheldon plugin loading timeout

- Increase plugin load timeout from 5s to 10s
- Add logging for plugin initialization
- Document performance optimization in README

docs(contributing): update commit message guidelines

refactor(git): simplify SSH configuration template

chore(homebrew): update package dependencies

❌ 差的 Commit 消息：

Fixed stuff
update
WIP: random changes
adds new features and fixes bugs
```

### Push 前清单

```bash
# 1. 更新到最新代码
git fetch origin
git merge origin/main

# 2. 运行所有验证
just validate-all

# 3. 检查提交消息格式
git log --oneline -5

# 4. 验证代码样式
# 手动检查代码的一致性

# 5. 测试相关更改
just test-bootstrap  # 如果修改了启动脚本

# 6. 推送到远程
git push origin feature/your-feature-name
```

---

## 📚 文档编写

### 文档结构

所有文档应遵循统一结构（参考 [50_文档风格指南.md](docs/50_文档风格指南.md)）：

```markdown
# 标题

> 一行简介

**版本**: X.X
**目标受众**: 谁应该读这个文档
**前置知识**: 需要理解什么

---

## 目录

## 核心概念
## 快速开始
## 配置详解
## 常见问题
## 总结与最佳实践
## 参考资源
```

### 文档规范

**标题**:
- 使用中文标题
- 使用 Markdown 标题层级（# ## ###）
- 每个文档一个 # 标题

**代码块**:
```markdown
语言标记要完整：
\`\`\`bash
command here
\`\`\`

不要使用：
\`\`\`
command here
\`\`\`
```

**链接**:
```markdown
✅ 好
[查看Neovim指南](10_Neovim完整指南.md)
[GitHub](https://github.com/zopiya/homeup)

❌ 差
[这里](file)
点击链接查看
```

**表格**:
```markdown
使用 GFM (GitHub Flavored Markdown) 表格
| 列1 | 列2 |
|-----|-----|
| 值1 | 值2 |
```

### 文档检查清单

```bash
- [ ] 标题清晰明确
- [ ] 目录链接有效
- [ ] 代码块有语言标记
- [ ] 内部链接使用相对路径
- [ ] 表格格式正确
- [ ] 无拼写错误
- [ ] 示例代码可运行
- [ ] 遵循文档风格指南
```

---

## 🔀 提交 PR

### PR 流程

1. **创建分支**
   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **进行更改**
   ```bash
   # 编辑文件...
   just validate-all  # 定期验证
   ```

3. **提交更改**
   ```bash
   git add .
   git commit -m "feat(scope): description"
   git push origin feature/descriptive-name
   ```

4. **创建 PR**
   - 访问 https://github.com/zopiya/homeup
   - 点击 "New Pull Request"
   - 选择您的分支
   - 填写 PR 描述（见下方模板）

5. **PR 描述模板**

```markdown
## 描述

简要描述您的更改。

## 关联问题

修复 #123
相关 #456

## 更改类型

- [ ] 新功能 (feat)
- [ ] Bug修复 (fix)
- [ ] 文档 (docs)
- [ ] 重构 (refactor)
- [ ] 性能 (perf)

## 测试清单

- [ ] 在macOS上测试
- [ ] 在Linux上测试
- [ ] 运行 `just validate-all`
- [ ] 更新了相关文档

## 截图 (如果适用)

[如果有UI更改，请添加截图]

## 额外信息

[任何其他需要审阅者了解的信息]
```

### PR 审阅期望

PR 创建后：

- 📝 **清晰的描述**: 让审阅者理解您的更改
- 🧪 **通过所有检查**: CI 必须通过
- 📚 **文档更新**: 如果添加了功能，请更新文档
- 💬 **对反馈开放**: 接受建设性批评

---

## ⚡ 常见任务

### 添加新工具文档

```bash
# 1. 查看编号系统
cat docs/00_快速导航指南.md

# 2. 创建新文件（使用适当的编号）
touch docs/NN_工具名完整指南.md

# 3. 遵循模板（参考现有文档）
# 复制 docs/10_Neovim完整指南.md 的结构

# 4. 更新导航指南
# 编辑 docs/00_快速导航指南.md 添加新工具

# 5. 验证所有链接有效
grep -r "NN_" docs/

# 6. 提交
git add docs/
git commit -m "docs(tools): add NN_工具名完整指南"
```

### 更新 Brewfile

```bash
# 1. 添加新包
just add-pkg brew:package-name

# 2. 验证
just validate-brewfile

# 3. 测试安装
just install

# 4. 提交
git add packages/Brewfile.core
git commit -m "chore(homebrew): add new package"
```

### 修复 Bug

```bash
# 1. 创建分支（使用 issue 号）
git checkout -b fix/issue-123

# 2. 修复
# 编辑文件...

# 3. 验证修复
just validate-all

# 4. 提交（引用 issue）
git commit -m "fix: resolve issue description

Fixes #123"
```

---

## 🔍 常见问题

### Q: 我如何知道我的贡献被接受？

A: 提交 PR 后，维护者会：
- 审阅您的代码
- 请求更改（如果需要）
- 批准并合并到 main

这通常需要 1-3 天。

### Q: 我可以贡献什么？

A: 欢迎所有类型的贡献：
- 💻 **代码**: 新功能、bug修复、改进
- 📚 **文档**: 新指南、改进现有文档、翻译
- 🐛 **Bug报告**: 详细的问题描述
- 💡 **功能请求**: 新工具或功能建议
- 🔄 **代码审阅**: 审阅他人的 PR

### Q: 我如何报告 Bug？

A: 创建 GitHub Issue：
1. 访问 Issues 标签
2. 点击 "New Issue"
3. 提供：
   - 清晰的标题
   - 步骤重现问题
   - 预期行为
   - 实际行为
   - 系统信息 (`just doctor`)

### Q: 代码审阅时间有多长？

A: 根据更改的复杂性：
- 小更改（文档、简单修复）: 1-2 天
- 中等更改（新功能）: 2-5 天
- 大更改（架构变更）: 5+ 天

### Q: 我可以建议新工具吗？

A: 当然！但请考虑：
- 为什么这个工具对 Homeup 有价值？
- 是否支持 macOS 和 Linux？
- 维护负担是什么？
- 是否有更简单的替代方案？

在 GitHub Discussions 中提出您的想法。

### Q: 我可以使用哪些许可证？

A: Homeup 使用 MIT 许可证。所有贡献应与 MIT 兼容。

### Q: 多久合并一次？

A: 我们使用持续集成方法：
- 稳定更改会尽快合并
- 破坏性更改会等待下一个主版本
- 文档更新会立即合并

---

## 🎯 成为维护者

如果您有兴趣成为项目维护者，请：

1. 做出多个有质量的贡献
2. 在 GitHub Discussions 中表达兴趣
3. 接受审查和任务分配

维护者负责：
- 审阅和合并 PR
- 回答问题和问题
- 参与路线图规划
- 发布新版本

---

## 📞 联系方式

- 📧 **邮件**: [您的邮件]
- 💬 **Discussions**: GitHub Discussions 标签
- 🐛 **Issues**: GitHub Issues
- 🔗 **远程**: https://git.7wate.org/zopiya/homeup.git

---

## 📖 相关文档

- [README.md](README.md) - 项目概述
- [CHANGELOG.md](CHANGELOG.md) - 版本历史
- [LICENSE](LICENSE) - MIT 许可证
- [docs/50_文档风格指南.md](docs/50_文档风格指南.md) - 文档标准
- [docs/52_架构设计文档.md](docs/52_架构设计文档.md) - 项目架构
- [docs/53_最佳实践指南.md](docs/53_最佳实践指南.md) - 最佳实践

---

## 🙏 致谢

感谢所有贡献者！无论多么小的贡献，都有帮助。

让我们一起构建更好的开发环境！

**版本**: 2.1 | **最后更新**: 2024-01-16
