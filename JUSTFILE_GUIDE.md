# Justfile 完全指南 - Homeup v2.0

这是 Homeup 项目经过全面优化的 Task Runner 指南。

---

## 🚀 快速开始

```bash
# 查看帮助
just help

# 查看所有可用命令
just --list

# 交互式选择命令
just --choose
```

---

## 📚 新增功能概览

### 🆕 新增命令（56个）

#### 1. 帮助与信息（7个）
- `just help` - 详细帮助信息
- `just info` - 系统信息
- `just examples` - 常用示例
- `just shortcuts` - 快捷方式
- `just docs` - 打开文档
- `just stats` - 统计信息
- `just report` - 生成报告

#### 2. Chezmoi 操作（11个）
- `just apply-interactive` - 交互式应用
- `just data` - 显示 chezmoi 数据
- `just execute-dry` - 干运行脚本
- `just find-template <file>` - 查找模板源
- `just diff-full` - 完整 diff
- （保留原有的 apply, diff, status 等）

#### 3. Profile 管理（2个）
- `just profile-diff <from> <to>` - 对比 profiles
- （改进了 profile 显示信息）

#### 4. 包管理（9个）
- `just packages-info` - 📊 包统计信息
- `just packages-outdated` - 检查过期包
- `just packages-dump` - 导出当前安装
- `just packages-deps <pkg>` - 显示依赖
- `just packages-search <query>` - 搜索包
- `just install-packages-no-upgrade` - 安装但不升级
- `just update-brew` - 更新 Homebrew
- `just brew-size` - 显示磁盘占用
- （改进了现有的包验证命令）

#### 5. 诊断与调试（3个）
- `just doctor` - 🏥 健康检查
- `just debug` - 调试信息
- `just security-check` - 安全检查

#### 6. Git 操作（3个）
- `just st` - git status 简写
- `just log [count]` - 图形化 log
- `just branch <name>` - 创建分支

#### 7. CI/CD（2个）
- `just check` - 快速检查
- `just ci-logs` - 查看 CI 日志

#### 8. 维护清理（5个）
- `just clean-all` - 深度清理
- `just update-brew` - 更新 Homebrew
- `just backup` - 备份配置
- （改进了 clean 和 upgrade）

#### 9. 高级操作（3个）
- `just init` - 初始化新机器
- `just reinstall` - 重新运行安装
- `just export` - 导出配置

---

## 🎯 常用场景

### 场景 1: 初次设置新机器

```bash
# 1. 克隆仓库
git clone https://github.com/zopiya/homeup.git
cd homeup

# 2. 运行 bootstrap（或使用 just init）
./bootstrap.sh -p macos

# 3. 查看会改变什么
just diff

# 4. 应用配置
just apply

# 5. 安装包
just install-packages

# 6. 设置 git hooks
just install-hooks

# 7. 健康检查
just doctor
```

### 场景 2: 日常使用

```bash
# 查看状态
just status

# 查看改动
just diff

# 应用更改
just apply

# 添加新文件
just add ~/.config/some-new-file

# 提交更改
just commit "Add new configuration"
just push
```

### 场景 3: 包管理

```bash
# 查看包统计
just packages-info

# 检查过期包
just packages-outdated

# 搜索包
just packages-search neovim

# 查看依赖
just packages-deps neovim

# 更新所有包
just upgrade

# 清理
just packages-cleanup
```

### 场景 4: 调试问题

```bash
# 健康检查
just doctor

# 查看调试信息
just debug

# 查看系统信息
just info

# 查找模板源
just find-template ~/.zshrc

# 完整 diff
just diff-full
```

### 场景 5: 开发与测试

```bash
# 验证所有配置文件
just validate

# 测试特定 profile
just test linux

# 运行 lint
just lint

# 运行所有 CI 检查
just ci

# 快速检查
just check
```

### 场景 6: Profile 对比

```bash
# 查看当前 profile
just profile

# 对比 profiles
just profile-diff macos linux

# 对比 mini 和 macos
just profile-diff mini macos
```

---

## 📊 命令分类完整列表

### 🏠 Chezmoi 操作（11个）
```
apply                   应用配置
apply-verbose           详细输出应用
apply-interactive       交互式应用
diff                    显示差异
diff-full               完整差异（无分页）
edit <file>             编辑文件
add <file>              添加文件
update                  从远程更新
status                  查看状态
verify                  验证配置
data                    显示数据
execute-dry             干运行脚本
find-template <file>    查找模板源
```

### 🎭 Profile 管理（6个）
```
profile                 显示当前 profile
profile-macos           设置为 macOS
profile-linux           设置为 Linux
profile-mini            设置为 Mini
profile-diff <from> <to> 对比 profiles
```

### 📦 包管理（15个）
```
install-packages        安装包
install-packages-no-upgrade  安装但不升级
packages-verify         验证包可用性
packages-check-duplicates    检查重复
packages-info           显示统计信息
packages-list           列出已安装包
packages-outdated       检查过期包
packages-dump           导出当前安装
packages-cleanup        清理无用包
packages-deps <pkg>     显示依赖
packages-search <query> 搜索包
update-brew             更新 Homebrew
brew-size               显示磁盘占用
```

### 🧪 测试与验证（3个）
```
validate                验证所有 profiles
test [profile]          测试特定 profile
bootstrap-dry [profile] Bootstrap 干运行
```

### 🔍 诊断与调试（3个）
```
doctor                  健康检查
debug                   调试信息
info                    系统信息
```

### 🛠️  开发与 Git（11个）
```
install-hooks           安装 git hooks
uninstall-hooks         卸载 git hooks
pre-commit              运行 pre-commit
lint                    运行 linters
fmt                     格式化脚本
commit <msg>            快速提交
amend                   修改最后提交
push                    推送
pull                    拉取
log [count]             显示日志
st                      git status
branch <name>           创建分支
```

### 🚀 CI/CD（4个）
```
ci                      运行所有 CI 检查
check                   快速检查
ci-trigger              触发 GitHub Actions
ci-status               查看 CI 状态
ci-logs                 查看 CI 日志
```

### 🔄 维护与清理（6个）
```
upgrade                 全系统更新（topgrade）
update-brew             更新 Homebrew
clean                   清理缓存
clean-all               深度清理
reset                   重置（危险）
backup                  备份配置
```

### 📊 统计与报告（2个）
```
stats                   显示统计信息
report                  生成报告
```

### 🎓 学习与文档（3个）
```
help                    显示帮助
examples                显示示例
shortcuts               显示快捷方式
docs                    打开文档
```

### 🔧 高级操作（4个）
```
init                    初始化新机器
reinstall               重新运行安装
export                  导出配置
security-check          安全检查
```

---

## 💡 实用技巧

### 1. 使用交互式选择

```bash
# 从菜单选择命令
just --choose
```

这会显示所有可用命令的交互式菜单。

### 2. 快速查看帮助

```bash
# 查看简洁帮助
just help

# 查看所有命令
just --list

# 查看示例
just examples
```

### 3. Profile 工作流

```bash
# 检查当前 profile
just profile

# 切换 profile
export HOMEUP_PROFILE=linux

# 验证新 profile
just test linux

# 应用更改
just apply
```

### 4. 包管理工作流

```bash
# 先查看统计
just packages-info

# 检查过期
just packages-outdated

# 更新
just upgrade

# 清理
just packages-cleanup
```

### 5. 调试工作流

```bash
# 健康检查
just doctor

# 查看详细信息
just info
just debug

# 查看差异
just diff
just diff-full
```

### 6. Git 工作流

```bash
# 快速查看状态
just st

# 查看日志
just log

# 提交
just commit "Fix something"

# 推送
just push
```

### 7. CI/CD 工作流

```bash
# 提交前快速检查
just check

# 完整 CI 检查
just ci

# 查看 GitHub Actions
just ci-status
just ci-logs
```

---

## 🎨 命令输出示例

### `just packages-info`
```
━━━ Package Statistics ━━━

📊 Package Distribution:
  Core:  64 formulae
  macOS: 16 formulae + 19 casks = 35 total
  Linux: 15 formulae
  Mini:  23 formulae

  Total unique packages: 102

📦 Current profile (macos):
  Would install: 99 packages

💾 Installed packages:
  186 formulae
  47 casks
```

### `just doctor`
```
━━━ Homeup Health Check ━━━

🔧 Checking required tools...
  ✓ brew
  ✓ chezmoi
  ✓ git

📂 Checking file structure...
  ✓ bootstrap.sh
  ✓ packages/Brewfile.core
  ✓ packages/Brewfile.macos
  ✓ packages/Brewfile.linux
  ✓ packages/Brewfile.mini

🎭 Checking profile configuration...
  Current: macos
  ✓ Valid profile

🔐 Checking sensitive files...
  ✓ SSH key exists
  ✓ GPG installed

✅ All checks passed!
```

### `just profile-diff macos mini`
```
Comparing profiles: macos vs mini

=== Packages in macos but not in mini ===
atuin
btop
duf
dust
...
```

---

## 🔧 高级用法

### 变量支持

Justfile 使用以下变量：

```makefile
PROFILE := env_var_or_default("HOMEUP_PROFILE", "macos")
CHEZMOI_SOURCE := justfile_directory()
```

你可以在命令中使用这些变量。

### 确认提示

某些危险操作需要确认：

```bash
just reset   # 需要确认
just init    # 需要确认
```

### 并行执行

Just 支持并行任务：

```bash
# CI 检查按顺序运行
just ci

# 但你可以手动并行运行独立任务
just validate & just packages-verify & wait
```

---

## 📝 与原版对比

### 新增功能
- ✅ 56 个新命令
- ✅ 更好的帮助系统
- ✅ 健康检查（doctor）
- ✅ 包统计信息
- ✅ Profile 对比
- ✅ 备份功能
- ✅ 安全检查
- ✅ 报告生成
- ✅ 更多 Git shortcuts

### 改进功能
- ✨ 所有输出使用 emoji 和颜色
- ✨ 更清晰的错误消息
- ✨ 统一的命令风格
- ✨ 更好的组织和分类
- ✨ 改进的验证脚本

### 保持兼容
- ✅ 所有原有命令保持不变
- ✅ 向后兼容
- ✅ 无破坏性更改

---

## 🎯 最佳实践

### 1. 每日工作流

```bash
# 早上
just status      # 查看状态
just diff        # 查看改动
just apply       # 应用更改

# 工作中
just add ~/.new-config
just edit ~/.config/existing

# 晚上
just commit "Daily updates"
just push
```

### 2. 定期维护

```bash
# 每周
just packages-outdated
just upgrade
just packages-cleanup

# 每月
just doctor
just security-check
just backup
```

### 3. 开发新功能

```bash
# 开始
just branch feature/new-thing
just validate

# 开发中
just diff
just test macos

# 提交前
just ci
just commit "Add new feature"
just push
```

---

## 🆘 故障排除

### 问题: 命令找不到

```bash
# 检查 just 是否安装
which just

# 安装 just（如果需要）
brew install just
```

### 问题: 包验证失败

```bash
# 先更新 Homebrew
just update-brew

# 再次验证
just packages-verify
```

### 问题: Profile 不正确

```bash
# 检查当前 profile
just profile

# 设置正确的 profile
export HOMEUP_PROFILE=macos

# 验证
just test macos
```

### 问题: Chezmoi 状态混乱

```bash
# 查看调试信息
just debug

# 查看差异
just diff-full

# 如果需要，重置（危险！）
just reset
```

---

## 📚 相关资源

- [Just 官方文档](https://github.com/casey/just)
- [Chezmoi 文档](https://www.chezmoi.io/)
- [Homebrew 文档](https://docs.brew.sh/)
- [Homeup README](./README.md)
- [包审计报告](./PACKAGE_AUDIT_REPORT.md)

---

## 🎉 总结

Homeup v2.0 的 Justfile 提供了：

- **80+ 个命令** - 覆盖所有常见和高级用例
- **直观的组织** - 按功能分类，易于查找
- **丰富的帮助** - 内置文档和示例
- **强大的诊断** - doctor, debug, info 等工具
- **完善的 CI/CD** - 本地和远程测试
- **友好的输出** - Emoji 和彩色输出

享受使用！🚀
