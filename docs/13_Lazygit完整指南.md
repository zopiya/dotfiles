# Lazygit Complete Guide: Interactive Git TUI for Efficient Workflows

> Visual Git client with keyboard-driven UI: Stage, commit, rebase, and resolve conflicts without touching the command line

**版本**: 1.0
**目标受众**: 开发者、Git 用户、想要更快工作流的工程师
**前置知识**: Git 基础、Shell 操作

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [核心操作](#核心操作)
- [分支与变基](#分支与变基)
- [冲突解决](#冲突解决)
- [高级工作流](#高级工作流)
- [配置和定制](#配置和定制)
- [常见问题](#常见问题)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### Lazygit vs 命令行 Git

**命令行 Git 的问题**:

```bash
# 查看状态
git status

# 暂存部分更改
git add src/file1.js
git add src/file2.js

# 查看差异
git diff

# 提交
git commit -m "feat: add feature"

# 查看历史
git log --oneline --graph

# 变基
git rebase -i HEAD~5

# 解决冲突（需要手动编辑）
# ...

# 问题：
# ❌ 多个命令不直观
# ❌ 分阶段操作容易出错
# ❌ 看不到全局上下文
# ❌ 变基和冲突解决繁琐
```

**Lazygit 的优势**:

```
✅ 统一的 TUI 界面
✅ 实时预览所有操作
✅ 键盘导航，快速无缝
✅ 分阶段操作可视化
✅ 自动冲突解决建议
✅ 撤销/重做完全支持
✅ Fuzzy 搜索集成
✅ 直观的分支管理
```

### 关键术语

| 术语 | 含义 | Lazygit 位置 |
|------|------|-----------|
| **Stage** | 暂存区（待提交的更改） | Left panel (Files) |
| **Unstaged** | 未暂存的更改 | Red 标记 |
| **Staged** | 已暂存的更改 | Green 标记 |
| **Commit** | 本地版本记录 | Left panel (Commits) |
| **Branch** | 分支 | Top section (Branches) |
| **Rebase** | 重新基于另一分支的提交历史 | Commits menu |
| **Stash** | 临时保存未完成的工作 | Bottom menu |
| **Conflict** | 合并冲突 | Red X 标记 + 冲突编辑器 |

---

## 快速开始

### ⚡ 5 分钟入门

```bash
# 1. 安装（已在 Homeup 中包含）
brew install lazygit

# 2. 进入 Git 仓库
cd ~/workspace/homeup

# 3. 启动 Lazygit
lazygit
# 或快捷函数（在 Homeup 中可用）
lg
```

### 首次进入的界面

```
┌─────────────────────────────────────────────┐
│ Lazygit (Homeup Repository)                 │
├─────────────┬─────────────┬─────────────────┤
│ Branches    │ Log         │ Files (Diff)    │
│             │             │                 │
│ main   ← ▸  │ abc123 feat │ M  src/file.js  │
│ feat-x      │ def456 docs │ D  old_file.sh  │
│ bug-fix     │ ghi789 fix  │ A  new_file.rs  │
│             │             │                 │
├─────────────┼─────────────┼─────────────────┤
│ Stash      │ Status                          │
│            │ On branch main                  │
│ [1] work-1 │ Your branch is ahead...        │
│            │ 3 files changed, 15 additions  │
│            │                                 │
└────────────┴──────────────┴─────────────────┘
```

### 关键快捷键

```
Navigation & Selection:
  ↑/↓ j/k      - 向上/向下移动
  ←/→ h/l      - 切换 panel
  Enter        - 选择/打开项目
  Esc          - 返回/关闭菜单

Common Operations:
  s            - Stage/Unstage 文件
  c            - 提交
  P            - 推送
  p            - 拉取
  r            - Rebase
  m            - 合并
  d            - 删除分支
  ?            - 显示帮助
```

### ✅ 第一次提交

```bash
# 1. 启动 lazygit
lazygit

# 2. 查看更改（Files panel）
# 看到修改的文件列表

# 3. 暂存文件
# 在文件上按 Space 或 s

# 4. 写提交信息
# 按 c，在编辑器中写提交信息
# :wq 保存

# 5. 推送
# 按 P 推送到远程

# 完成！
```

---

## 核心操作

### 文件暂存（Stage）

**按文件暂存**:

```
在 Files panel 中：
1. 选择文件（↑/↓ 导航）
2. 按 Space 或 s
3. 文件会移到 "Staged changes" 部分

效果：
❌ src/old-code.js
✅ src/new-feature.js
```

**整个文件夹暂存**:

```
在 Files panel 中：
1. 选择文件夹
2. 按 Space 暂存整个文件夹
```

**部分文件暂存（Hunks）**:

```
1. 在 Files panel 中选择文件
2. 按 Ctrl+S 查看 hunks（代码块）
3. 选择性暂存需要的 hunk
4. 按 Space 暂存该 hunk
```

### 提交（Commit）

**基础提交**:

```
1. 暂存文件（见上）
2. 按 c（Commit）
3. 在编辑器中写提交信息：
   feat: add new feature

   - Add login form
   - Add validation
   - Add error handling
4. :wq 保存

Lazygit 会：
✅ 创建提交
✅ 显示提交 hash
✅ 更新历史视图
```

**提交选项**:

```
c  - Commit           (标准提交)
C  - Commit (amend)   (修改最后一次提交)
s  - Squash           (合并到上一个提交)
f  - Fixup            (自动合并，不保留提交信息)
r  - Reword           (修改提交信息)
```

### 推送和拉取（Push/Pull）

**推送**:

```
P (大写)  - 推送当前分支
          Lazygit 会显示：
          ├─ 要推送的提交数
          ├─ 确认推送
          └─ 成功提示
```

**拉取**:

```
p (小写)  - 拉取当前分支
          Lazygit 会：
          ├─ 获取远程更新
          ├─ 自动变基或合并
          └─ 显示结果
```

**拉取所有分支**:

```
Ctrl+P   - 从所有远程拉取
         效果：
         ├─ 获取所有分支更新
         ├─ 本地分支自动同步
         └─ 可以看到新的远程分支
```

---

## 分支与变基

### 分支操作

**查看分支**:

```
Branches panel (左上角):
  main   ← 当前分支（* 标记）
  feat-login
  bug-fix-123
  develop

操作：
  按 Space    - 切换分支
  按 n        - 新建分支
  按 d        - 删除分支
  按 r        - Rename 分支
```

**创建新分支**:

```
1. 在 Branches panel 中
2. 按 n（New branch）
3. 输入分支名：feat/user-auth
4. 选择基于哪个提交（通常是 main）
5. 创建完成，自动切换到新分支
```

**删除分支**:

```
1. 选择要删除的分支
2. 按 d（Delete）
3. 确认删除

注意：
❌ 无法删除当前分支
❌ 如果有未合并的提交，需确认强制删除
```

### 变基（Rebase）

**交互式变基**:

```
1. 在 Commits panel（右上方）
2. 选择要变基的提交
3. 按 r（Rebase）
4. 选择 "Interactive rebase"
5. Lazygit 显示变基菜单：

   Current commit: abc123

   Options:
   p - pick       (保留这个提交)
   r - reword     (修改提交信息)
   s - squash     (合并到上一个)
   f - fixup      (合并，不保留信息)
   d - drop       (删除这个提交)

6. 使用 ↑/↓ 导航，按对应快捷键操作
7. 完成后 Lazygit 会自动执行
```

**变基到另一个分支**:

```
1. 选择当前分支（Branches panel）
2. 按 r（Rebase）
3. 选择目标分支（如 main）
4. Lazygit 会：
   ├─ 检查冲突
   ├─ 显示进度
   └─ 提示需要解决的冲突（如果有）
```

**中止变基**:

```
如果变基出错或想取消：

1. 在 Commits panel
2. 按 ? 查看帮助
3. 找到 "Abort rebase" 选项
4. 按对应快捷键中止

# 或从命令行
git rebase --abort
```

---

## 冲突解决

### 识别冲突

```
在 Lazygit 中，冲突文件会显示：
❌ src/file.js (conflict)

红色 ❌ 标记表示有冲突
```

### 解决冲突

**方法 1: 使用 Lazygit 的冲突编辑器**:

```
1. 选择冲突文件（Files panel）
2. 按 o（Open）或 Enter
3. Lazygit 打开冲突编辑器：

   <<<<<<< HEAD (current)
   function newFeature() {     ← 当前分支的改动
     console.log('feature');
   }
   =======
   function oldFunction() {     ← 传入分支的改动
     console.log('old');
   }
   >>>>>>> feature-branch

4. 选择要保留的部分：
   o - open in editor         (用编辑器打开)
   d - delete conflict markers (删除冲突标记)
   m - mark resolved          (标记已解决)
```

**方法 2: 使用外部编辑器**:

```
1. 选择冲突文件
2. 按 o 用外部编辑器打开
3. 手动编辑文件，保留需要的内容
4. 保存文件
5. 回到 Lazygit
6. 按 c 提交解决冲突的结果
```

**方法 3: 使用 Git 合并工具**:

```
1. 如果配置了 mergetool（如 vimdiff）
2. 在冲突文件上按 m
3. 用配置的工具打开
4. 解决冲突
5. 保存
```

### 合并解决后

```
冲突解决后：

1. Lazygit 显示文件为 modified (M)
2. 暂存文件（Space）
3. 提交（c）：
   Commit message 会自动生成：
   "Merge branch 'feature' into main"
4. 推送（P）
```

---

## 高级工作流

### 场景 1：修改最后一次提交

**问题**: 刚提交，发现信息写错了或忘记添加文件

**解决**:

```
1. 在 Commits panel 中选择最后一次提交
2. 按 C（大写，Commit amend）
3. Lazygit 打开编辑器修改提交信息
4. 修改后 :wq 保存

或者修改提交内容：
1. 修改文件
2. 暂存（Space）
3. 按 C（Commit amend）
4. 按 Space 跳过信息修改
5. 提交成功，文件添加到最后一次提交

结果：
✅ 提交信息已修改
✅ 文件已添加
✅ 提交 hash 不变（未推送时）
```

### 场景 2：复原某个提交

**问题**: 某个特定提交引入了 bug，想要撤销它

**解决**:

```
方法 1: 使用 Revert（推荐）
1. 在 Commits panel 中选择要复原的提交
2. 按 t（Revert）
3. Lazygit 创建一个新提交，撤销指定提交的更改
4. 推送（P）

优点：
✅ 保留历史
✅ 可追踪撤销
✅ 安全（已推送的提交）

方法 2: 使用 Reset（仅本地）
1. 在 Commits panel 中选择提交
2. 按 g（Reset）
3. 选择 reset 类型：
   soft  - 保留更改，取消提交
   mixed - 取消暂存和提交
   hard  - 完全删除更改
```

### 场景 3：挑选提交（Cherry-pick）

**问题**: 需要将某个分支上的特定提交应用到当前分支

**解决**:

```
1. 切换到包含目标提交的分支
2. 在 Commits panel 中选择提交
3. 按 c（Cherry-pick）
4. 切换回目标分支（如 main）
5. Lazygit 自动应用这个提交
6. 如果有冲突，解决冲突并提交

结果：
✅ 提交被复制到当前分支
✅ 新的提交 hash（独立的提交）
```

### 场景 4：暂存工作（Stash）

**问题**: 需要切换分支，但当前有未完成的工作

**解决**:

```
1. 在 Lazygit 菜单中选择 Stash
2. 按 n（New stash）
3. 输入 stash 名称（可选）
4. Lazygit 保存当前工作

查看 stash：
1. 按 s（Stash）
2. 查看所有保存的 stash
3. 选择一个，按 Space 应用（apply）或 d 删除

恢复工作：
1. 选择 stash
2. 按 u（Unstash）
3. Lazygit 恢复工作并删除 stash
```

---

## 配置和定制

### 配置文件位置

```bash
# 配置文件
~/.config/lazygit/config.yml

# 创建基础配置
mkdir -p ~/.config/lazygit
touch ~/.config/lazygit/config.yml
```

### 常用配置

#### 编辑器配置

```yaml
# ~/.config/lazygit/config.yml
os:
  editCommand: nvim
  editCommandTemplate: nvim -- {{filename}}
  openCommand: open

git:
  paging:
    colorArg: always
    pager: delta
```

#### 快捷键定制

```yaml
keybinding:
  universal:
    quit: q
    quit-alt1: <c-c>
    return: <enter>
    undo: u
    redo: <c-r>

  files:
    stageAll: a
    stageFile: <space>
    unstageFile: d

  commits:
    rebaseEdit: e
    amend: C
    pick: p
    reword: r
    drop: d
```

#### 主题配置

```yaml
gui:
  theme:
    activeBorderColor:
      - green
      - bold
    inactiveBorderColor:
      - white
    selectedLineBgColor:
      - blue
    selectedRangeBgColor:
      - blue
```

### 集成 FZF（Fuzzy Finder）

```yaml
# ~/.config/lazygit/config.yml
git:
  branchLogCmd: git log --graph --color=always --abbrev-commit --decorate --date=short --pretty=medium {{branchName}}

# 这样分支和提交历史会使用 FZF 搜索
```

---

## 常见问题

### ❓ 如何在 Lazygit 中撤销某个操作？

**答**:

```
1. 按 u（Undo）
2. Lazygit 会回退最后一个操作

支持撤销的操作：
✅ 提交
✅ 删除分支
✅ 暂存/取消暂存
✅ Rebase
✅ Merge
✅ Reset

不支持撤销：
❌ 强制推送（too dangerous）
❌ 本地 hard reset（可以用 reflog）
```

### ❓ 如何处理 "detached HEAD" 状态？

**答**:

```
Detached HEAD = 在某个提交上，而不是分支上

发生原因：
- 按 Space 选中了某个提交
- 进行了 reset --hard
- 变基失败

解决：
1. 按 c（Create branch）
2. 输入分支名
3. 提交会被保存到新分支

或者：
1. 切换到其他分支（Space）
2. Lazygit 会警告未提交的更改
```

### ❓ 推送时出现 "rejected"（被拒绝）

**问题**:

```
Error: failed to push some refs to 'origin'

原因：
❌ 远程有你没有的提交
❌ 历史不一致（可能有人强制推送）
❌ 权限问题
```

**解决**:

```
1. 先拉取（p）
2. 如果有冲突，解决冲突
3. 再推送（P）

或者：

1. 用 Lazygit 的 "Force push" 选项（仅在确定的情况下）
2. 按 P（推送）
3. 如果失败，按 P（再次尝试）
4. Lazygit 会提示 "Force with lease" 选项
```

### ❓ 如何在 Lazygit 中搜索提交？

**答**:

```
1. 在 Commits panel
2. 按 /（搜索）
3. 输入搜索词（可以是 hash、信息、作者）
4. Lazygit 会过滤匹配的提交
5. 按 Esc 清除搜索
```

### ❓ 性能问题：Lazygit 在大仓库中很慢

**解决**:

```
优化方案：

1. 限制显示的提交数
   git config --global lazy.commits 200

2. 禁用某些功能
   # config.yml
   gui:
     skipRefreshStatusAfterCommandExecution: true

3. 使用更快的 Git
   git config --global core.preloadindex true
   git config --global core.untrackedCache true

4. 考虑使用 shallow clone
   git clone --depth 1 <repo>
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **日常使用** | 用 Lazygit 处理暂存、提交、推送，命令行处理复杂操作 |
| **冲突解决** | 使用 Lazygit 的可视化编辑器，比手动编辑更直观 |
| **历史修改** | 交互式变基、amend、reword 都用 Lazygit 完成 |
| **分支管理** | Lazygit 的分支面板比命令行更高效 |
| **协作** | 使用 cherry-pick 和 rebase 保持历史整洁 |
| **安全** | 仅本地使用 hard reset，已推送的用 revert |

### 关键快捷键速查

```bash
# 导航和选择
↑/↓ j/k        - 上下移动
←/→ h/l        - 切换 panel
Enter          - 确认/打开
Esc            - 返回/关闭

# 文件操作
Space / s      - Stage/Unstage 文件
c              - Commit
Ctrl+S         - 查看 hunks（代码块）

# 分支和 Commit
n              - 新建分支
d              - 删除分支
Space          - 切换分支
r              - Rebase
C              - Amend commit
P              - 推送
p              - 拉取

# 高级
t              - Revert 提交
e              - Edit commit（交互式变基）
m              - Merge
u              - Undo
/              - 搜索

# 帮助和其他
?              - 显示帮助
q              - 退出
```

---

## 参考资源

- [Lazygit GitHub](https://github.com/jesseduffield/lazygit)
- [Lazygit 官方文档](https://github.com/jesseduffield/lazygit/tree/master/docs)
- [Homeup Git SSH Signing Guide](GIT_SSH_SIGNING_COMPLETE_GUIDE.md)
- [Homeup Modern Workflow](MODERN_WORKFLOW.md)
- [Git 官方文档](https://git-scm.com/doc)
