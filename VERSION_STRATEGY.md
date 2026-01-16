# 版本管理策略

> Homeup 版本号管理和发布流程

**版本**: 2.1.0
**更新日期**: 2024-01-16

---

## 📋 目录

- [语义版本化](#语义版本化)
- [版本号生命周期](#版本号生命周期)
- [发布流程](#发布流程)
- [版本号同步](#版本号同步)
- [向后兼容性](#向后兼容性)
- [发布清单](#发布清单)

---

## 📌 语义版本化

Homeup 遵循 [Semantic Versioning 2.0.0](https://semver.org/)

### 版本号格式

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

例如：
2.1.0              (稳定版本)
2.1.0-alpha.1      (预发布)
2.1.0+build.20240116  (构建元数据)
```

### 版本号规则

**MAJOR 版本** - 破坏性变更
- 更改架构
- 移除功能
- API 不兼容变更
- 升级示例: 1.0.0 → 2.0.0

**MINOR 版本** - 新功能（向后兼容）
- 新工具支持
- 新文档
- 改进功能
- 升级示例: 2.0.0 → 2.1.0

**PATCH 版本** - Bug 修复
- 修复问题
- 安全补丁
- 小改进
- 升级示例: 2.1.0 → 2.1.1

### 预发布版本

```
Alpha:   2.1.0-alpha.1      (功能不完整)
Beta:    2.1.0-beta.1       (功能完整，需要测试)
RC:      2.1.0-rc.1         (准备发布)
```

---

## 🔄 版本号生命周期

### 开发阶段

```
1. 确定下一个版本号
2. 在 VERSION 文件中更新（带 -dev 后缀）
   2.2.0-dev

3. 进行开发和提交
   git commit -m "feat: new feature"
   git commit -m "fix: bug fix"

4. 更新 CHANGELOG.md 的 Unreleased 部分
```

### 预发布阶段

```
1. 更新 VERSION 为预发布版本
   2.2.0-alpha.1

2. 运行完整测试
   just validate-all
   jest --coverage
   npm audit

3. 标记并推送
   git tag -a v2.2.0-alpha.1 -m "Alpha release"
   git push origin v2.2.0-alpha.1

4. 等待反馈和修复
```

### 稳定发布

```
1. 确认所有检查通过
   just doctor
   just validate-all

2. 更新版本号（移除 -dev）
   2.2.0

3. 更新 CHANGELOG.md
   ## [2.2.0] - 2024-01-20

4. 提交和标记
   git add -A
   git commit -m "chore: release v2.2.0"
   git tag -a v2.2.0 -m "Release version 2.2.0"
   git push origin main --tags

5. 创建 GitHub Release
```

---

## 📦 发布流程

### 完整发布清单

#### 发布前 (1-2 周)

- [ ] 确定发布日期
- [ ] 汇总 CHANGELOG
- [ ] 运行 lint 和测试
- [ ] 更新文档
- [ ] 检查破坏性变更

#### 发布当天

- [ ] 冻结 main 分支
- [ ] 最后一次测试
- [ ] 更新 VERSION 文件
- [ ] 更新 CHANGELOG.md
- [ ] 创建 Git tag
- [ ] 创建 GitHub Release
- [ ] 发送公告

#### 发布后

- [ ] 监控问题报告
- [ ] 准备热修复（如需要）
- [ ] 收集反馈
- [ ] 规划下一个版本

### 版本号更新脚本

```bash
#!/bin/bash
# scripts/update-version.sh

set -eo pipefail

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: update-version.sh <version>"
  echo "Example: update-version.sh 2.2.0"
  exit 1
fi

echo "Updating version to $VERSION..."

# 1. 更新 VERSION 文件
echo "$VERSION" > VERSION

# 2. 验证版本格式
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "⚠️ Warning: Non-standard version format"
fi

# 3. 更新文件中的版本号
find docs -name "*.md" -exec sed -i "s/版本.*:.*/版本: ${VERSION}/g" {} \;

# 4. 提交
git add VERSION docs/
git commit -m "chore: bump version to $VERSION"

echo "✅ Version updated to $VERSION"
echo ""
echo "Next steps:"
echo "  1. Update CHANGELOG.md"
echo "  2. git tag -a v$VERSION -m 'Release version $VERSION'"
echo "  3. git push origin main --tags"
```

使用:

```bash
chmod +x scripts/update-version.sh
./scripts/update-version.sh 2.2.0
```

---

## 🔗 版本号同步

### 文件中的版本号位置

版本号应该在以下位置保持同步：

| 文件 | 位置 | 格式 |
|------|------|------|
| **VERSION** | 根目录 | `2.1.0` |
| **README.md** | 项目信息 | 在文本中提及 |
| **CHANGELOG.md** | 顶部 | `## [2.1.0] - 2024-01-16` |
| **各文档** | 页头 | `版本: 2.1.0` |
| **.chezmoi.toml.tmpl** | 元数据 | `[data.homeup_version]` |

### 自动同步检查

```bash
#!/bin/bash
# scripts/check-version-sync.sh

VERSION=$(cat VERSION)
echo "Checking version sync for $VERSION..."

# 检查 CHANGELOG.md
if ! grep -q "## \[$VERSION\]" CHANGELOG.md; then
  echo "❌ CHANGELOG.md not updated"
  exit 1
fi

# 检查 README
if ! grep -q "$VERSION" README.md; then
  echo "⚠️ Warning: VERSION not mentioned in README"
fi

# 检查文档
doc_count=$(grep -r "版本: $VERSION" docs/ | wc -l)
if [ "$doc_count" -lt 20 ]; then
  echo "⚠️ Warning: Not all docs have correct version"
fi

echo "✅ Version sync check passed"
```

---

## 🔄 向后兼容性

### 兼容性承诺

**Minor 和 Patch 版本**:
- 必须向后兼容
- 不能移除功能
- 不能改变 API

**Major 版本**:
- 可以有破坏性变更
- 必须在 CHANGELOG 中明确说明
- 必须提供迁移指南

### 弃用政策

```
版本 N.x.x: 功能正常工作
版本 N+1.x.x: 功能标记为弃用，显示警告
版本 N+2.x.x: 功能可以移除

例如：
2.0.0: 支持 Tmux
2.1.0: Zellij 作为新选项，Tmux 标记为可选
3.0.0: Zellij 作为默认，Tmux 支持可选
```

### 迁移指南

对于破坏性变更，必须提供：

```markdown
## 迁移指南：从 1.x 到 2.0

### 变更 1: Brewfile 结构

**旧方式**:
```
Brewfile
```

**新方式**:
```
Brewfile.core
Brewfile.macos
Brewfile.linux
```

**迁移**:
1. 导出现有包: `brew bundle dump`
2. 手动分类到新 Brewfile
3. 删除旧 Brewfile
```

---

## 📋 发布清单

### 代码质量检查

```bash
# 运行所有验证
just validate-all

# 检查测试覆盖率
jest --coverage

# 验证 lint
eslint src/
prettier --check .

# 安全审计
npm audit
```

### 文档检查

```bash
# 拼写检查
npx cspell docs/**/*.md

# 链接检查
npx broken-link-checker https://github.com/zopiya/homeup

# 内容一致性
grep -r "vX.X.X" docs/ | grep -v VERSION
```

### 发布公告模板

```markdown
# 🎉 Homeup v2.1.0 发布

## 新功能

- ✨ [特性1描述](链接)
- ✨ [特性2描述](链接)

## 改进

- 🚀 [性能改进](链接)
- 📚 [文档改进](链接)

## Bug修复

- 🐛 [修复1](链接)
- 🐛 [修复2](链接)

## 致谢

感谢以下贡献者...

## 下载

- [GitHub Releases](https://github.com/zopiya/homeup/releases/tag/v2.1.0)
- [Changelog](CHANGELOG.md)

---

**版本**: 2.1.0
**发布日期**: 2024-01-16
**支持**: 社区 Issues
```

---

## 🔧 版本号命令速查

```bash
# 查看当前版本
cat VERSION

# 更新版本
echo "2.2.0" > VERSION

# 查看版本历史
git tag -l

# 创建版本标记
git tag -a v2.1.0 -m "Release version 2.1.0"

# 查看特定版本
git show v2.1.0

# 显示某个版本的变更
git log v2.0.0..v2.1.0 --oneline
```

---

## 📊 发布历史

| 版本 | 日期 | 主要特性 |
|------|------|--------|
| 2.1.0 | 2024-01-16 | 完整文档、导航指南、速查卡片 |
| 2.0.0 | 2024-01-10 | 架构重构、安全增强 |
| 1.0.0 | 2024-01-01 | 初始发布 |

---

## 💡 最佳实践

1. **经常发布小版本**
   - 小改变更容易审阅
   - 用户更容易迁移
   - 反馈更清晰

2. **清晰的版本消息**
   - CHANGELOG 要详细
   - 提供迁移指南
   - 解释为什么要改变

3. **提前通知**
   - 弃用提前 1-2 个版本
   - 提供升级路径
   - 发送公告

4. **保留历史**
   - 保存所有 CHANGELOG
   - 保存所有 Git tags
   - 文档支持旧版本

5. **自动化检查**
   - 验证版本一致性
   - 自动化测试
   - 自动化发布流程

---

## 🔗 相关文档

- [CHANGELOG.md](CHANGELOG.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [README.md](README.md)

---

**版本**: 2.1.0 | **最后更新**: 2024-01-16
