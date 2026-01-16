# Lefthook Git Hooks Complete Guide: Automated Code Quality Checks

> Lightweight Git hooks manager: Enforce quality standards, prevent bad commits, automate pre-push validation

**版本**: 1.0
**目标受众**: 开发者、团队负责人、Git 工作流优化者
**前置知识**: Git 基础、Shell 脚本基础

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [Git 钩子类型](#git-钩子类型)
- [Lefthook 配置](#lefthook-配置)
- [常见检查](#常见检查)
- [高级用法](#高级用法)
- [团队协作](#团队协作)
- [故障排除](#故障排除)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### 什么是 Git 钩子？

**Git 钩子** 是在 Git 事件前后自动执行的脚本：

```
Git 事件                    钩子触发
$ git commit -m "msg"    →  pre-commit (检查代码)
                         →  commit-msg (检查提交信息)

$ git push               →  pre-push (检查历史)
```

### 传统钩子 vs Lefthook

**传统方式（手动管理）**:

```bash
❌ 钩子脚本分散在 .git/hooks/ 中
❌ 无法版本控制（.git 不提交）
❌ 团队成员需手动配置
❌ 调试和维护困难
❌ 无法跨项目共享
```

**Lefthook 方式**:

```
✅ 配置集中在 lefthook.yml（可版本控制）
✅ Git clone 后自动 lefthook install
✅ 所有开发者使用相同规则
✅ 清晰的命令行输出
✅ 快速并行执行
✅ 易于跳过（--no-verify）
```

### 关键概念

| 术语 | 含义 | 例子 |
|------|------|------|
| **pre-commit** | 提交前触发 | 检查代码风格、Lint |
| **commit-msg** | 提交信息验证 | 检查信息格式 |
| **pre-push** | 推送前触发 | 最后的完整性检查 |
| **post-checkout** | 切换分支后 | 更新依赖 |
| **skip_output** | 减少输出 | 隐藏不重要的信息 |
| **parallel** | 并行执行 | 加速检查 |
| **staged_files** | 暂存的文件 | 在 pre-commit 中使用 |

---

## 快速开始

### ⚡ 5 分钟设置

```bash
# 1. Homeup 已包含 lefthook 和配置
# 2. 安装钩子
just install-hooks

# 或手动
lefthook install

# 3. 验证安装
ls -la .git/hooks | grep lefthook
# 应显示 .git/hooks/pre-commit 等

# 4. 测试钩子
echo "secret_password=12345" > test-secret.txt
git add test-secret.txt
git commit -m "test"

# 输出应该被 pre-commit 钩子阻止：
# ✗ Potential secret found: test-secret.txt
```

### ✅ 验证设置

```bash
# 显示所有已安装的钩子
lefthook list

# 输出应该显示：
# pre-commit
# commit-msg
# pre-push

# 显示每个钩子的详细信息
lefthook info pre-commit
```

---

## Git 钩子类型

### pre-commit（提交前）

在 `git commit` 执行前触发，最常用的钩子。

**典型用途**:

```
✅ Lint 代码风格
✅ 格式化代码
✅ 检查秘钥泄露
✅ 验证 YAML/JSON
✅ 检查文件大小
```

**执行时机**:

```
$ git commit -m "message"
    ↓
pre-commit 钩子运行
    ├─ 检查 shell 脚本
    ├─ 验证模板
    └─ 防止秘钥泄露
    ↓
✅ 通过 → 提交成功
❌ 失败 → 提交被中止
```

### commit-msg（提交信息验证）

在编写提交信息后、实际提交前触发。

**典型用途**:

```
✅ 检查提交信息长度
✅ 验证格式（Conventional Commits）
✅ 检查是否存在空信息
✅ 强制引用 Issue（#123）
```

### pre-push（推送前）

在 `git push` 前触发，最后的防线。

**典型用途**:

```
✅ 运行完整测试
✅ 验证所有模板语法
✅ 检查历史完整性
✅ 防止推送到主分支
```

**执行时机**:

```
$ git push
    ↓
pre-push 钩子运行
    ├─ 验证所有模板
    ├─ Lint 所有 shell 脚本
    └─ 检查秘钥
    ↓
✅ 通过 → 推送执行
❌ 失败 → 推送被中止
```

### 其他钩子

| 钩子 | 触发时机 | 典型用途 |
|------|---------|--------|
| **post-commit** | 提交后 | 更新日志、发送通知 |
| **post-checkout** | 切换分支后 | 更新依赖、同步环境 |
| **post-merge** | 合并后 | 重新安装依赖 |
| **post-rewrite** | Rebase/Amend 后 | 更新环境 |

---

## Lefthook 配置

### 配置文件结构

```yaml
# lefthook.yml

# 全局设置
skip_output:       # 减少输出
  - meta
  - summary

# 钩子定义
pre-commit:
  parallel: true   # 并行执行命令
  commands:
    lint:          # 命令名称
      glob: "*.sh" # 文件匹配
      run: shellcheck {staged_files}  # 执行脚本

commit-msg:
  commands:
    check-format:
      run: |
        msg=$(cat {1})
        # 检查逻辑
```

### 文件匹配（glob）

```yaml
# 匹配特定文件
glob: "*.sh"           # 所有 .sh 文件
glob: "**/*.py"        # 所有 Python 文件
glob: "{src,lib}/**"   # 特定目录

# 多个模式
glob: "*.{js,ts,jsx,tsx}"
```

### 使用 staged_files 和特殊变量

```yaml
commands:
  lint:
    # {staged_files} - 暂存的文件列表
    run: eslint {staged_files}

  # {1}, {2}, ... - 命令行参数
  commit-msg:
    run: |
      msg=$(cat {1})  # {1} = 提交信息文件
```

### Homeup 的 Lefthook 配置

```yaml
# lefthook.yml

# 前置检查（快速）
pre-commit:
  parallel: true
  commands:
    shellcheck:         # Shell 脚本检查
      glob: "*.sh"
      run: shellcheck {staged_files}

    template-check:     # 模板语法检查
      glob: "*.tmpl"
      run: |
        for file in {staged_files}; do
          chezmoi execute-template < "$file" > /dev/null
        done

    no-secrets:         # 防止秘钥泄露
      run: |
        grep -r "password\|secret\|token" {staged_files}

# 提交信息验证
commit-msg:
  commands:
    format-check:       # 检查提交信息格式
      run: |
        msg=$(cat {1})
        # 检查长度 ≤ 72 字符
        # 检查非空

# 推送前检查（全面）
pre-push:
  parallel: true
  commands:
    validate-templates: # 验证所有模板（两个 Profile）
      run: |
        for profile in macos linux; do
          chezmoi init --source . \
            --destination /tmp/validate-$profile \
            --dry-run

    lint-all:           # Lint 所有 shell 脚本
      run: find . -name "*.sh" -exec shellcheck {} \;
```

---

## 常见检查

### 防止秘钥泄露

```yaml
pre-commit:
  commands:
    no-secrets:
      run: |
        for file in {staged_files}; do
          # 跳过模板和示例文件
          [[ "$file" =~ \.(tmpl|example)$ ]] && continue

          # 检查常见秘钥模式
          if grep -iE "(password|secret|token|api[_-]?key)\s*=" "$file"; then
            echo "✗ Potential secret found: $file"
            exit 1
          fi
        done
```

**最佳实践**:

```bash
# ❌ 错误：硬编码秘钥
DATABASE_PASSWORD=secret123

# ✅ 正确：使用环境变量
DATABASE_PASSWORD=$DATABASE_PASSWORD

# ✅ 正确：使用 .env.example
# .env.example 可以提交
DATABASE_PASSWORD=your_password_here

# ✅ 正确：使用模板
{{.database_password}}  # 在 .chezmoi.toml 中定义
```

### Shell 脚本 Lint

```yaml
pre-commit:
  commands:
    shellcheck:
      glob: "*.sh"
      run: shellcheck {staged_files}
```

**常见 shellcheck 错误**:

```bash
# ❌ SC2086: Double quote to prevent globbing
find . -name "*.txt"  # 应该是 "*.txt"

# ❌ SC2046: Quote this
cmd $(echo $var)      # 应该是 "$(echo "$var")"

# ✅ 修复方式
find . -name "*.txt"  # 引用
cmd "$(echo "$var")"  # 引用变量
```

### 提交信息格式

```yaml
commit-msg:
  commands:
    format-check:
      run: |
        msg=$(cat {1})
        subject=$(echo "$msg" | head -n1)

        # 检查长度（传统：50 字符，Homeup：72 字符）
        if [ ${#subject} -gt 72 ]; then
          echo "✗ Subject line too long (max 72 chars)"
          exit 1
        fi

        # 检查空信息
        if [ -z "$(echo "$msg" | grep -v '^#')" ]; then
          echo "✗ Empty commit message"
          exit 1
        fi
```

**推荐的提交信息格式**:

```
feat: add user authentication

- Implement JWT token generation
- Add login endpoint
- Add password hashing

Fixes #123
```

**格式规则**:

```
<type>: <subject>      # 一行，≤72 字符

<body>                 # 可选，详细描述

<footer>               # 可选，参考 Issue

类型（type）:
- feat:   新功能
- fix:    修复
- docs:   文档
- style:  代码风格（无逻辑改变）
- refactor: 重构
- perf:   性能优化
- test:   测试
```

### 模板验证

```yaml
pre-push:
  commands:
    validate-templates:
      run: |
        echo "Validating templates for all profiles..."
        for profile in macos linux; do
          export HOMEUP_PROFILE=$profile
          if ! chezmoi init --source . \
               --destination /tmp/validate-$profile \
               --dry-run; then
            echo "✗ Template failed for $profile"
            exit 1
          fi
        done
        echo "✓ All profiles valid"
```

---

## 高级用法

### 跳过钩子

```bash
# 跳过 pre-commit（仅在特殊情况）
git commit --no-verify -m "message"

# 跳过 pre-push
git push --no-verify

# 禁用特定命令
lefthook skip <hook-name>

# 恢复
lefthook uninstall
lefthook install
```

### 条件执行

```yaml
pre-commit:
  commands:
    lint-js:
      glob: "*.{js,ts,jsx,tsx}"
      run: eslint {staged_files}

    lint-py:
      glob: "*.py"
      run: pylint {staged_files}
```

### 自定义脚本

```yaml
pre-commit:
  commands:
    custom-check:
      run: |
        # 自定义逻辑
        for file in {staged_files}; do
          if ! ./scripts/validate.sh "$file"; then
            echo "Validation failed for $file"
            exit 1
          fi
        done
```

### 依赖管理的钩子

```yaml
post-checkout:
  commands:
    # 切换分支后更新依赖
    install-deps:
      run: |
        if git diff --name-only HEAD@{1}..HEAD | grep -q "Gemfile";
        then
          bundle install
        fi
```

---

## 团队协作

### 分享 lefthook 配置

```bash
# 1. 版本控制配置
git add lefthook.yml
git commit -m "ci: add lefthook configuration"
git push

# 2. 团队成员克隆后
git clone <repo>
cd <repo>

# 3. 安装钩子
lefthook install

# 4. 验证
lefthook list
```

### 禁用特定开发者的钩子

```bash
# 临时禁用（不推荐）
git config core.hooksPath /dev/null

# 恢复
git config --unset core.hooksPath
```

### CI/CD 集成

```yaml
# GitHub Actions
- name: Lefthook validation
  run: |
    lefthook run pre-commit
    lefthook run commit-msg
```

---

## 故障排除

### ❓ 钩子无法运行

**检查**:

```bash
# 1. 验证安装
lefthook list

# 2. 检查文件权限
ls -la .git/hooks/pre-commit

# 3. 重新安装
lefthook install

# 4. 查看详细错误
lefthook run pre-commit --verbose
```

### ❓ "Command not found"

**解决**:

```bash
# 问题：shellcheck 未安装
# 解决：
brew install shellcheck

# 或配置可选依赖
pre-commit:
  commands:
    shellcheck:
      run: |
        if ! command -v shellcheck &>/dev/null; then
          echo "⚠ shellcheck not installed, skipping"
          exit 0
        fi
        shellcheck {staged_files}
```

### ❓ 误触发钩子规则

**解决**:

```bash
# 使用 --no-verify 绕过（仅用于调试）
git commit --no-verify -m "message"

# 或编辑 lefthook.yml，调整 glob 规则
glob: "src/**/*.sh"  # 仅检查 src 目录下的脚本
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **pre-commit** | 快速检查，<5 秒 |
| **commit-msg** | 强制格式，团队一致 |
| **pre-push** | 全面检查，防止故障 |
| **版本控制** | 提交 lefthook.yml |
| **跳过** | 仅用于特殊情况（--no-verify） |
| **文档** | 在 lefthook.yml 中添加注释 |
| **性能** | 使用 parallel: true 加速 |

### 核心命令速查

```bash
# 安装和卸载
lefthook install            # 安装钩子
lefthook uninstall          # 卸载钩子

# 查看状态
lefthook list               # 列出所有钩子
lefthook info <hook>        # 查看钩子详情

# 手动运行钩子
lefthook run pre-commit     # 手动运行 pre-commit
lefthook run pre-push       # 手动运行 pre-push
lefthook run pre-commit -v  # 详细输出

# Git 操作中跳过钩子
git commit --no-verify -m "msg"
git push --no-verify

# 禁用/启用钩子
lefthook skip <hook>
lefthook uninstall && lefthook install
```

---

## 参考资源

- [Lefthook GitHub](https://github.com/evilmartians/lefthook)
- [Lefthook 文档](https://github.com/evilmartians/lefthook/blob/master/docs)
- [Homeup Lefthook 配置](../lefthook.yml)
- [Homeup Conventional Commits 指南](best-practices.md)
- [Git 官方钩子文档](https://git-scm.com/docs/githooks)
