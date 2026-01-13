# ==============================================================================
# Homeup Justfile - Task Orchestration for Dotfiles Management
# ==============================================================================
# Version: 2.1
# Usage: just <task>
# Quick help: just --list or just help
# ==============================================================================

# Set shell for all recipes
set shell := ["bash", "-uc"]

# Enable .env file loading
set dotenv-load := true

# Variables
CHEZMOI_SOURCE := justfile_directory()
PROFILE := env_var_or_default("HOMEUP_PROFILE", "macos")

# ------------------------------------------------------------------------------
# 📚 帮助与导航 (Help & Navigation)
# ------------------------------------------------------------------------------

# 显示交互式菜单 (默认任务)
@default:
    just --choose

# 显示分类帮助信息
help:
    @echo "━━━ Homeup 任务运行器 ━━━"
    @echo ""
    @echo "🔥 常用高频 (Daily):"
    @echo "  just apply              # 应用配置更改 (最常用)"
    @echo "  just diff               # 查看待变更内容"
    @echo "  just update             # 拉取远程代码并应用"
    @echo "  just install-packages   # 安装/更新软件包"
    @echo ""
    @echo "🛠️ 维护诊断 (Maintenance):"
    @echo "  just doctor             # 系统健康检查"
    @echo "  just check              # 快速验证配置"
    @echo "  just clean              # 清理缓存"
    @echo "  just rescue             # 🚑 紧急修复助手"
    @echo ""
    @echo "🎭 Profile 管理:"
    @echo "  just profile            # 显示当前 Profile"
    @echo "  just profile-[type]     # 切换 Profile (macos/linux/mini)"
    @echo ""
    @echo "🧪 开发与测试:"
    @echo "  just ci                 # 运行完整 CI 测试"
    @echo "  just validate           # 验证模板语法"
    @echo ""
    @echo "💡 提示: 使用 'just --list' 查看所有任务"

# 快速导航菜单 (交互式)
quick:
    @echo "━━━ 快速导航 ━━━"
    @echo "请选择要执行的操作:"
    @echo "1) 应用配置 (apply)"
    @echo "2) 查看差异 (diff)"
    @echo "3) 更新系统 (update + upgrade)"
    @echo "4) 健康检查 (doctor)"
    @echo "5) 退出"
    @read -p "请输入选项 [1-5]: " choice; \
    case "$choice" in \
        1) just apply ;; \
        2) just diff ;; \
        3) just update && just upgrade ;; \
        4) just doctor ;; \
        *) echo "已取消" ;; \
    esac

# 🚑 紧急修复助手
rescue:
    @echo "━━━ 🚑 救援模式 ━━━"
    @echo "正在尝试自动修复常见问题..."
    @echo ""
    @echo "1. 清理 Chezmoi 缓存..."
    @chezmoi purge --force || true
    @echo "2. 重新初始化 Git钩子..."
    @just install-hooks || true
    @echo "3. 运行健康检查..."
    @just doctor
    @echo ""
    @echo "如果问题仍然存在，请尝试: just reinstall"

# ------------------------------------------------------------------------------
# 🔥 核心日常操作 (Core Operations)
# ------------------------------------------------------------------------------

# 应用配置 (Apply dotfiles configuration)
apply:
    @echo "正在应用配置..."
    chezmoi apply

# 应用配置 (显示详细日志)
apply-verbose:
    @echo "正在应用配置 (详细模式)..."
    chezmoi apply -v

# 查看差异 (Show diff before applying)
diff:
    @echo "查看差异..."
    chezmoi diff

# 交互式应用 (Interactive apply)
apply-interactive:
    @echo "交互式应用..."
    chezmoi apply --interactive

# 从远程仓库更新并应用 (Update from remote)
update:
    @echo "从远程更新..."
    chezmoi update

# 查看状态 (Show chezmoi status)
status:
    chezmoi status

# 编辑受管文件 (Edit a managed file)
edit file:
    chezmoi edit {{file}}

# 添加文件到管理 (Add a file to chezmoi)
add file:
    @echo "添加 {{file}} 到 chezmoi..."
    chezmoi add {{file}}

# ------------------------------------------------------------------------------
# 📦 软件包管理 (Package Management)
# ------------------------------------------------------------------------------

# 安装当前 Profile 的软件包
install-packages:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "━━━ 安装软件包 (Profile: {{PROFILE}}) ━━━"
    echo ""

    if [ "{{PROFILE}}" = "mini" ]; then
        echo "📦 安装 Brewfile.mini (精简版)"
        brew bundle --file=packages/Brewfile.mini
    elif [ "$(uname)" = "Darwin" ]; then
        echo "📦 安装 Brewfile.core"
        brew bundle --file=packages/Brewfile.core
        echo ""
        echo "📦 安装 Brewfile.macos"
        brew bundle --file=packages/Brewfile.macos
    else
        echo "📦 安装 Brewfile.core"
        brew bundle --file=packages/Brewfile.core
        echo ""
        echo "📦 安装 Brewfile.linux"
        brew bundle --file=packages/Brewfile.linux
    fi

    echo ""
    echo "✅ 软件包安装完成!"

# 安装软件包但不更新现有包
install-packages-no-upgrade:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "安装软件包 (跳过更新)..."

    if [ "{{PROFILE}}" = "mini" ]; then
        brew bundle --file=packages/Brewfile.mini --no-upgrade
    elif [ "$(uname)" = "Darwin" ]; then
        brew bundle --file=packages/Brewfile.core --no-upgrade
        brew bundle --file=packages/Brewfile.macos --no-upgrade
    else
        brew bundle --file=packages/Brewfile.core --no-upgrade
        brew bundle --file=packages/Brewfile.linux --no-upgrade
    fi

# 验证 Homebrew 软件包可用性
packages-verify:
    #!/usr/bin/env bash
    echo "━━━ Homebrew 软件包验证 ━━━"
    echo ""
    cd packages
    failed=0

    for brewfile in Brewfile.core Brewfile.macos Brewfile.linux Brewfile.mini; do
        if [ ! -f "$brewfile" ]; then continue; fi

        echo "检查 $brewfile..."
        # Check brew formulae
        while read -r pkg; do
            if [ -z "$pkg" ]; then continue; fi
            if brew info "$pkg" &>/dev/null; then
                echo "  ✓ $pkg"
            else
                echo "  ✗ $pkg - 未找到"
                failed=1
            fi
        done < <(grep '^brew "' "$brewfile" 2>/dev/null | sed 's/^brew "\([^"]*\)".*/\1/' || true)

        # Check casks
        while read -r pkg; do
            if [ -z "$pkg" ]; then continue; fi
            if brew info --cask "$pkg" &>/dev/null; then
                echo "  ✓ [cask] $pkg"
            else
                echo "  ✗ [cask] $pkg - 未找到"
                failed=1
            fi
        done < <(grep '^cask "' "$brewfile" 2>/dev/null | sed 's/^cask "\([^"]*\)".*/\1/' || true)
        echo ""
    done

    if [ $failed -eq 0 ]; then
        echo "✅ 所有软件包验证通过!"
    else
        echo "❌ 部分软件包不可用"
        exit 1
    fi

# 检查软件包重复定义
packages-check-duplicates:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "━━━ 检查重复软件包 ━━━"
    echo ""

    # Check core vs macos
    echo "### Core vs macOS 重复:"
    comm -12 \
        <(grep -E '^brew "' packages/Brewfile.core | sed 's/^brew "\([^"]*\)".*/\1/' | sort) \
        <(grep -E '^brew "' packages/Brewfile.macos | sed 's/^brew "\([^"]*\)".*/\1/' | sort) | \
        sed 's/^/  ⚠️  /' || echo "  ✓ 无重复"

    echo ""
    echo "### Core vs Linux 重复:"
    comm -12 \
        <(grep -E '^brew "' packages/Brewfile.core | sed 's/^brew "\([^"]*\)".*/\1/' | sort) \
        <(grep -E '^brew "' packages/Brewfile.linux | sed 's/^brew "\([^"]*\)".*/\1/' | sort) | \
        sed 's/^/  ⚠️  /' || echo "  ✓ 无重复"

    echo ""
    echo "### macOS vs Linux 重复 (Ops工具例外):"
    macos_linux_dupes=$(comm -12 \
        <(grep -E '^brew "' packages/Brewfile.macos | sed 's/^brew "\([^"]*\)".*/\1/' | sort) \
        <(grep -E '^brew "' packages/Brewfile.linux | sed 's/^brew "\([^"]*\)".*/\1/' | sort))

    if [ -z "$macos_linux_dupes" ]; then
        echo "  ✓ 无重复"
    else
        echo "$macos_linux_dupes" | while read pkg; do
            if grep -q "^brew \"$pkg\"" packages/Brewfile.core; then
                echo "  ✓ $pkg (在 core 中 - OK)"
            else
                echo "  ⚠️  $pkg (Ops 工具 - 预期内)"
            fi
        done
    fi

# 查看软件包统计
packages-info:
    #!/usr/bin/env bash
    echo "━━━ 软件包统计 ━━━"
    core_count=$(grep -c '^brew "' packages/Brewfile.core)
    macos_brew=$(grep -c '^brew "' packages/Brewfile.macos)
    macos_cask=$(grep -c '^cask "' packages/Brewfile.macos)
    linux_count=$(grep -c '^brew "' packages/Brewfile.linux)
    mini_count=$(grep -c '^brew "' packages/Brewfile.mini)

    echo "📊 分布:"
    echo "  Core:  $core_count"
    echo "  macOS: $((macos_brew + macos_cask)) ($macos_brew formula + $macos_cask cask)"
    echo "  Linux: $linux_count"
    echo "  Mini:  $mini_count"

# 列出已安装的包
packages-list:
    @echo "━━━ 已安装软件包 ━━━"
    @brew list --formula
    @if [ "$(uname)" = "Darwin" ]; then echo ""; echo "Casks:"; brew list --cask; fi

# 检查可更新的包
packages-outdated:
    @echo "━━━ 待更新软件包 ━━━"
    @brew outdated

# 清理未使用的包
packages-cleanup:
    @echo "清理 Homebrew..."
    brew cleanup --prune=all
    brew autoremove
    @echo "✅ 清理完成"

# ------------------------------------------------------------------------------
# 🎭 Profile 管理 (Profile Management)
# ------------------------------------------------------------------------------

# 显示当前 Profile
profile:
    @echo "当前 Profile: {{PROFILE}}"
    @echo ""
    @echo "可用 Profiles:"
    @echo "  • macos - 全功能 macOS 工作站 (GPG, YubiKey, GUI)"
    @echo "  • linux - 无头 Linux 服务器 (SSH-only, 无 GUI)"
    @echo "  • mini  - 极简临时环境 (容器, Codespaces)"
    @echo ""
    @echo "切换方式: export HOMEUP_PROFILE=<profile>"

# 切换到 macos Profile
profile-macos:
    @echo "export HOMEUP_PROFILE=macos"
    @echo "请运行: source ~/.zshrc 或重启 Shell"

# 切换到 linux Profile
profile-linux:
    @echo "export HOMEUP_PROFILE=linux"
    @echo "请运行: source ~/.zshrc 或重启 Shell"

# 切换到 mini Profile
profile-mini:
    @echo "export HOMEUP_PROFILE=mini"
    @echo "请运行: source ~/.zshrc 或重启 Shell"

# 比较两个 Profile 的差异
profile-diff from to:
    @echo "比较 Profile: {{from}} vs {{to}}"
    @echo ""
    @echo "=== 在 {{from}} 中但不在 {{to}} 中的包 ==="
    @comm -23 \
        <(grep -E '^brew "' packages/Brewfile.{{from}} 2>/dev/null | sed 's/^brew "\([^"]*\)".*/\1/' | sort || true) \
        <(grep -E '^brew "' packages/Brewfile.{{to}} 2>/dev/null | sed 's/^brew "\([^"]*\)".*/\1/' | sort || true) || true

# ------------------------------------------------------------------------------
# 🔍 诊断与维护 (Diagnostics & Maintenance)
# ------------------------------------------------------------------------------

# 运行全面健康检查
doctor:
    #!/usr/bin/env bash
    echo "━━━ Homeup 健康检查 ━━━"
    echo ""
    errors=0

    # 1. 检查工具
    echo "🔧 检查必要工具..."
    for cmd in brew chezmoi git; do
        if command -v $cmd &>/dev/null; then echo "  ✓ $cmd"; else echo "  ✗ $cmd (缺失)"; errors=$((errors + 1)); fi
    done

    echo "   检查开发工具 (可选)..."
    for cmd in shfmt shellcheck lefthook topgrade; do
        if command -v $cmd &>/dev/null; then echo "  ✓ $cmd"; else echo "  ○ $cmd (缺失 - 建议安装)"; fi
    done

    # 2. 检查文件结构
    echo ""
    echo "📂 检查文件结构..."
    for file in bootstrap.sh packages/Brewfile.core; do
        if [ -f "$file" ]; then echo "  ✓ $file"; else echo "  ✗ $file (缺失)"; errors=$((errors + 1)); fi
    done

    # 3. 检查 Profile
    echo ""
    echo "🎭 检查 Profile 配置..."
    echo "  当前: {{PROFILE}}"
    if [[ "{{PROFILE}}" =~ ^(macos|linux|mini)$ ]]; then echo "  ✓ Profile 有效"; else echo "  ✗ Profile 无效 (必须是: macos, linux, mini)"; errors=$((errors + 1)); fi

    # 4. 检查敏感文件
    echo ""
    echo "🔐 检查敏感文件..."
    if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then echo "  ✓ SSH Key 存在"; else echo "  ⚠️  未发现常见 SSH Key"; fi

    echo ""
    if [ $errors -eq 0 ]; then echo "✅ 所有检查通过!"; else echo "❌ 发现 $errors 个问题"; exit 1; fi

# 全系统升级 (Topgrade)
upgrade:
    @if command -v topgrade &>/dev/null; then \
        echo "运行全系统升级 (Topgrade)..."; \
        topgrade; \
    else \
        echo "⚠️  Topgrade 未安装，回退到 Homebrew 更新..."; \
        just update-brew; \
    fi

# 更新 Homebrew
update-brew:
    @echo "更新 Homebrew..."
    @brew update && brew upgrade && brew cleanup
    @echo "✅ Homebrew 更新完成"

# 清理缓存
clean:
    @echo "清理缓存..."
    @chezmoi purge --force || true
    @rm -rf /tmp/chezmoi-test-* 2>/dev/null || true
    @echo "✅ 缓存已清理"

# 深度清理 (包含 Homebrew)
clean-all:
    @echo "深度清理..."
    @just clean
    @just packages-cleanup
    @echo "✅ 深度清理完成"

# ------------------------------------------------------------------------------
# 🧪 测试与验证 (Testing & CI)
# ------------------------------------------------------------------------------

# 运行所有 CI 检查 (本地)
ci:
    @echo "━━━ 运行 CI 检查 ━━━"
    @echo "1/5: Linting..." && just lint
    @echo "2/5: 软件包验证..." && just packages-verify
    @echo "3/5: 重复检查..." && just packages-check-duplicates
    @echo "4/5: 模板验证..." && just validate
    @echo "5/5: 健康检查..." && just doctor
    @echo ""
    @echo "✅ 所有 CI 检查通过!"

# 快速检查 (CI 的子集)
check:
    @echo "运行快速检查..."
    @just validate
    @just packages-check-duplicates
    @echo "✅ 快速检查通过"

# 验证所有 Profile 的模板
validate:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "━━━ 验证模板 ━━━"
    failed=0
    for profile in macos linux mini; do
        echo "测试 Profile: $profile"
        export HOMEUP_PROFILE=$profile
        if chezmoi init --source . --destination /tmp/chezmoi-test-$profile --dry-run 2>/dev/null; then
            echo "  ✅ $profile: OK"
        else
            echo "  ❌ $profile: FAILED"
            failed=1
        fi
    done
    if [ $failed -eq 0 ]; then echo "✅ 所有 Profile 验证成功"; else exit 1; fi

# ------------------------------------------------------------------------------
# 🛠️ 开发工具 (Development)
# ------------------------------------------------------------------------------

# 安装 Git Hooks
install-hooks:
    @echo "安装 Git hooks..."
    @if command -v lefthook &>/dev/null; then \
        lefthook install; \
    else \
        echo "⚠️  未安装 lefthook (brew install lefthook)"; \
    fi

# 运行代码格式化
fmt:
    @echo "格式化 Shell 脚本..."
    @if command -v shfmt &>/dev/null; then \
        find . -name "*.sh" -type f ! -path "./.git/*" -exec shfmt -w -i 4 {} \;; \
        echo "✅ 完成"; \
    else \
        echo "⚠️  未安装 shfmt"; \
    fi

# 运行 Linters
lint:
    @echo "运行 ShellCheck..."
    @if command -v shellcheck &>/dev/null; then \
        find . -name "*.sh" -type f ! -path "./.git/*" -exec shellcheck {} \;; \
    else \
        echo "⚠️  未安装 shellcheck (brew install shellcheck)"; \
    fi

# 快速提交
commit msg:
    @git add -A
    @git commit -m "{{msg}}"
    @echo "✅ 已提交: {{msg}}"

# 初始化新机器
[confirm("这将初始化新机器配置。继续?")]
init:
    #!/usr/bin/env bash
    echo "初始化 Homeup..."
    ./bootstrap.sh -p {{PROFILE}}
    echo "✅ 初始化完成"

# 重置 Chezmoi (危险操作)
[confirm("⚠️  这将清除所有 chezmoi 状态。继续?")]
reset:
    @chezmoi purge --force
    @echo "✅ Chezmoi 状态已清除"
