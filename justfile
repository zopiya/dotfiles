# ==============================================================================
# Homeup Justfile - Task Orchestration for Dotfiles Management
# ==============================================================================
# Version: 2.0
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
# 📚 Help & Information
# ------------------------------------------------------------------------------

# Show this help message (default task)
@default:
    just --choose

# Show detailed help with examples
help:
    @echo "━━━ Homeup Task Runner ━━━"
    @echo ""
    @echo "🎯 Quick Start:"
    @echo "  just apply              # Apply dotfiles"
    @echo "  just diff               # Show changes before applying"
    @echo "  just install-packages   # Install Homebrew packages"
    @echo "  just validate           # Validate all profiles"
    @echo ""
    @echo "📦 Package Management:"
    @echo "  just packages-verify    # Verify package availability"
    @echo "  just packages-info      # Show package statistics"
    @echo "  just packages-outdated  # Check for outdated packages"
    @echo ""
    @echo "🔍 Diagnostics:"
    @echo "  just doctor             # Run health checks"
    @echo "  just info               # Show system information"
    @echo "  just debug              # Debug chezmoi configuration"
    @echo ""
    @echo "🧪 Testing:"
    @echo "  just ci                 # Run all CI checks"
    @echo "  just test [profile]     # Test specific profile"
    @echo ""
    @echo "💡 Use 'just --list' to see all available tasks"
    @echo "💡 Use 'just --choose' for interactive selection"

# Show system information
info:
    @echo "━━━ System Information ━━━"
    @echo ""
    @echo "OS: $(uname -s) $(uname -r)"
    @echo "Architecture: $(uname -m)"
    @echo "Profile: {{PROFILE}}"
    @echo "Chezmoi version: $(chezmoi --version | head -1)"
    @echo "Homebrew version: $(brew --version | head -1)"
    @echo "Shell: $SHELL"
    @echo "Git version: $(git --version)"
    @echo ""
    @echo "📂 Paths:"
    @echo "  Source: {{CHEZMOI_SOURCE}}"
    @echo "  Config: $HOME/.config/chezmoi"
    @echo "  Data: $HOME/.local/share/chezmoi"

# ------------------------------------------------------------------------------
# 🏠 Chezmoi Operations
# ------------------------------------------------------------------------------

# Apply dotfiles configuration
apply:
    @echo "Applying dotfiles..."
    chezmoi apply

# Apply with verbose output
apply-verbose:
    @echo "Applying dotfiles (verbose)..."
    chezmoi apply -v

# Show diff before applying
diff:
    @echo "Showing differences..."
    chezmoi diff

# Interactive apply (review each change)
apply-interactive:
    @echo "Interactive apply..."
    chezmoi apply --interactive

# Edit a managed file
edit file:
    chezmoi edit {{file}}

# Update from remote repository and apply
update:
    @echo "Updating from remote..."
    chezmoi update

# Re-add a file to chezmoi
add file:
    @echo "Adding {{file}} to chezmoi..."
    chezmoi add {{file}}

# Show chezmoi status
status:
    chezmoi status

# Verify chezmoi configuration
verify:
    chezmoi verify

# Show chezmoi data
data:
    chezmoi data

# Execute chezmoi scripts in dry-run mode
execute-dry:
    @echo "Dry-run executing scripts..."
    chezmoi execute-template --init --promptBool=false < /dev/null || true

# ------------------------------------------------------------------------------
# 🎭 Profile Management
# ------------------------------------------------------------------------------

# Show current profile
profile:
    @echo "Current profile: {{PROFILE}}"
    @echo ""
    @echo "Available profiles:"
    @echo "  • macos - Full macOS workstation (GPG, YubiKey, GUI apps)"
    @echo "  • linux - Headless Linux server (SSH-only, no GUI)"
    @echo "  • mini  - Minimal ephemeral (containers, Codespaces)"
    @echo ""
    @echo "To change: export HOMEUP_PROFILE=<profile>"

# Set profile to macos
profile-macos:
    @echo "export HOMEUP_PROFILE=macos"
    @echo "Run: source ~/.zshrc or restart shell"

# Set profile to linux
profile-linux:
    @echo "export HOMEUP_PROFILE=linux"
    @echo "Run: source ~/.zshrc or restart shell"

# Set profile to mini
profile-mini:
    @echo "export HOMEUP_PROFILE=mini"
    @echo "Run: source ~/.zshrc or restart shell"

# Show profile differences
profile-diff from to:
    @echo "Comparing profiles: {{from}} vs {{to}}"
    @echo ""
    @echo "=== Packages in {{from}} but not in {{to}} ==="
    @comm -23 \
        <(grep -E '^brew "' packages/Brewfile.{{from}} 2>/dev/null | sed 's/^brew "\([^"]*\)".*/\1/' | sort || true) \
        <(grep -E '^brew "' packages/Brewfile.{{to}} 2>/dev/null | sed 's/^brew "\([^"]*\)".*/\1/' | sort || true) || true

# ------------------------------------------------------------------------------
# 📦 Package Management
# ------------------------------------------------------------------------------

# Install packages for current profile
install-packages:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "━━━ Installing packages for profile: {{PROFILE}} ━━━"
    echo ""

    if [ "{{PROFILE}}" = "mini" ]; then
        echo "📦 Installing Brewfile.mini (standalone)"
        brew bundle --file=packages/Brewfile.mini
    elif [ "$(uname)" = "Darwin" ]; then
        echo "📦 Installing Brewfile.core"
        brew bundle --file=packages/Brewfile.core
        echo ""
        echo "📦 Installing Brewfile.macos"
        brew bundle --file=packages/Brewfile.macos
    else
        echo "📦 Installing Brewfile.core"
        brew bundle --file=packages/Brewfile.core
        echo ""
        echo "📦 Installing Brewfile.linux"
        brew bundle --file=packages/Brewfile.linux
    fi

    echo ""
    echo "✅ Package installation complete!"

# Install packages without upgrading existing ones
install-packages-no-upgrade:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing packages (no upgrade)..."

    if [ "{{PROFILE}}" = "mini" ]; then
        brew bundle --file=packages/Brewfile.mini --no-upgrade
    elif [ "$(uname)" = "Darwin" ]; then
        brew bundle --file=packages/Brewfile.core --no-upgrade
        brew bundle --file=packages/Brewfile.macos --no-upgrade
    else
        brew bundle --file=packages/Brewfile.core --no-upgrade
        brew bundle --file=packages/Brewfile.linux --no-upgrade
    fi

# Verify all packages are available in Homebrew
packages-verify:
    #!/usr/bin/env bash
    echo "━━━ Homebrew Package Verification ━━━"
    echo ""
    cd packages
    failed=0

    for brewfile in Brewfile.core Brewfile.macos Brewfile.linux Brewfile.mini; do
        if [ ! -f "$brewfile" ]; then
            continue
        fi

        echo "Checking $brewfile..."

        # Check brew formulae
        while read -r pkg; do
            if [ -z "$pkg" ]; then continue; fi
            if brew info "$pkg" &>/dev/null; then
                echo "  ✓ $pkg"
            else
                echo "  ✗ $pkg - NOT FOUND"
                failed=1
            fi
        done < <(grep '^brew "' "$brewfile" 2>/dev/null | sed 's/^brew "\([^"]*\)".*/\1/' || true)

        # Check casks
        while read -r pkg; do
            if [ -z "$pkg" ]; then continue; fi
            if brew info --cask "$pkg" &>/dev/null; then
                echo "  ✓ [cask] $pkg"
            else
                echo "  ✗ [cask] $pkg - NOT FOUND"
                failed=1
            fi
        done < <(grep '^cask "' "$brewfile" 2>/dev/null | sed 's/^cask "\([^"]*\)".*/\1/' || true)

        echo ""
    done

    if [ $failed -eq 0 ]; then
        echo "✅ All packages verified successfully!"
    else
        echo "❌ Some packages are not available"
        exit 1
    fi

# Check for duplicate packages across Brewfiles
packages-check-duplicates:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "━━━ Checking for Duplicate Packages ━━━"
    echo ""

    # Check core vs macos
    echo "### Core vs macOS duplicates:"
    comm -12 \
        <(grep -E '^brew "' packages/Brewfile.core | sed 's/^brew "\([^"]*\)".*/\1/' | sort) \
        <(grep -E '^brew "' packages/Brewfile.macos | sed 's/^brew "\([^"]*\)".*/\1/' | sort) | \
        sed 's/^/  ⚠️  /' || echo "  ✓ No duplicates"

    echo ""

    # Check core vs linux
    echo "### Core vs Linux duplicates:"
    comm -12 \
        <(grep -E '^brew "' packages/Brewfile.core | sed 's/^brew "\([^"]*\)".*/\1/' | sort) \
        <(grep -E '^brew "' packages/Brewfile.linux | sed 's/^brew "\([^"]*\)".*/\1/' | sort) | \
        sed 's/^/  ⚠️  /' || echo "  ✓ No duplicates"

    echo ""

    # Check macos vs linux (excluding core)
    echo "### macOS vs Linux duplicates (intentional Ops tools):"
    macos_linux_dupes=$(comm -12 \
        <(grep -E '^brew "' packages/Brewfile.macos | sed 's/^brew "\([^"]*\)".*/\1/' | sort) \
        <(grep -E '^brew "' packages/Brewfile.linux | sed 's/^brew "\([^"]*\)".*/\1/' | sort))

    if [ -z "$macos_linux_dupes" ]; then
        echo "  ✓ No duplicates"
    else
        echo "$macos_linux_dupes" | while read pkg; do
            if grep -q "^brew \"$pkg\"" packages/Brewfile.core; then
                echo "  ✓ $pkg (in core - OK)"
            else
                echo "  ⚠️  $pkg (Ops tool - intentional)"
            fi
        done
    fi

    echo ""
    echo "### Package counts:"
    echo "  Core:  $(grep -c '^brew "' packages/Brewfile.core) packages"
    echo "  macOS: $(grep -c '^brew "' packages/Brewfile.macos) formulae + $(grep -c '^cask "' packages/Brewfile.macos) casks"
    echo "  Linux: $(grep -c '^brew "' packages/Brewfile.linux) packages"
    echo "  Mini:  $(grep -c '^brew "' packages/Brewfile.mini) packages"

# Show package statistics and information
packages-info:
    #!/usr/bin/env bash
    echo "━━━ Package Statistics ━━━"
    echo ""

    core_count=$(grep -c '^brew "' packages/Brewfile.core)
    macos_brew=$(grep -c '^brew "' packages/Brewfile.macos)
    macos_cask=$(grep -c '^cask "' packages/Brewfile.macos)
    linux_count=$(grep -c '^brew "' packages/Brewfile.linux)
    mini_count=$(grep -c '^brew "' packages/Brewfile.mini)

    total_unique=$(cat packages/Brewfile.* | grep -E '^(brew|cask) "' | sed 's/^[^ ]* "\([^"]*\)".*/\1/' | sort -u | wc -l | tr -d ' ')

    echo "📊 Package Distribution:"
    echo "  Core:  $core_count formulae"
    echo "  macOS: $macos_brew formulae + $macos_cask casks = $((macos_brew + macos_cask)) total"
    echo "  Linux: $linux_count formulae"
    echo "  Mini:  $mini_count formulae"
    echo ""
    echo "  Total unique packages: $total_unique"
    echo ""
    echo "📦 Current profile ({{PROFILE}}):"
    if [ "{{PROFILE}}" = "mini" ]; then
        echo "  Would install: $mini_count packages"
    elif [ "$(uname)" = "Darwin" ]; then
        echo "  Would install: $((core_count + macos_brew + macos_cask)) packages"
    else
        echo "  Would install: $((core_count + linux_count)) packages"
    fi

    echo ""
    echo "💾 Installed packages:"
    echo "  $(brew list --formula | wc -l | tr -d ' ') formulae"
    if [ "$(uname)" = "Darwin" ]; then
        echo "  $(brew list --cask | wc -l | tr -d ' ') casks"
    fi

# List installed packages
packages-list:
    @echo "━━━ Installed Packages ━━━"
    @echo ""
    @echo "Formulae:"
    @brew list --formula
    @if [ "$(uname)" = "Darwin" ]; then \
        echo ""; \
        echo "Casks:"; \
        brew list --cask; \
    fi

# Check for outdated packages
packages-outdated:
    @echo "━━━ Outdated Packages ━━━"
    @echo ""
    @brew outdated

# Update Brewfile with currently installed packages
packages-dump:
    @echo "Generating Brewfile from current installation..."
    @brew bundle dump --file=Brewfile.dump --force
    @echo "✅ Saved to Brewfile.dump"
    @echo "Review and merge changes into appropriate Brewfiles"

# Cleanup unused packages
packages-cleanup:
    @echo "Cleaning up Homebrew..."
    brew cleanup --prune=all
    brew autoremove
    @echo "✅ Cleanup complete"

# Show package dependencies
packages-deps package:
    @echo "Dependencies for {{package}}:"
    @brew deps {{package}} --tree

# Search for a package
packages-search query:
    @echo "Searching for: {{query}}"
    @brew search {{query}}

# ------------------------------------------------------------------------------
# 🧪 Testing & Validation
# ------------------------------------------------------------------------------

# Validate templates for all profiles
validate:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "━━━ Validating Templates ━━━"
    echo ""

    failed=0
    for profile in macos linux mini; do
        echo "Testing profile: $profile"
        export HOMEUP_PROFILE=$profile

        if chezmoi init --source . --destination /tmp/chezmoi-test-$profile --dry-run 2>/dev/null; then
            echo "  ✅ $profile: OK"
        else
            echo "  ❌ $profile: FAILED"
            failed=1
        fi
    done

    echo ""
    if [ $failed -eq 0 ]; then
        echo "✅ All profiles validated successfully!"
    else
        echo "❌ Some profiles failed validation"
        exit 1
    fi

# Test specific profile
test profile="macos":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "━━━ Testing Profile: {{profile}} ━━━"
    echo ""

    export HOMEUP_PROFILE={{profile}}

    echo "1. Template validation..."
    chezmoi init --source . --destination /tmp/chezmoi-test-{{profile}} --dry-run

    echo ""
    echo "2. Checking Brewfiles..."
    if [ "{{profile}}" = "mini" ]; then
        [ -f packages/Brewfile.mini ] && echo "  ✓ Brewfile.mini exists"
    elif [ "{{profile}}" = "macos" ]; then
        [ -f packages/Brewfile.core ] && echo "  ✓ Brewfile.core exists"
        [ -f packages/Brewfile.macos ] && echo "  ✓ Brewfile.macos exists"
    else
        [ -f packages/Brewfile.core ] && echo "  ✓ Brewfile.core exists"
        [ -f packages/Brewfile.linux ] && echo "  ✓ Brewfile.linux exists"
    fi

    echo ""
    echo "✅ Profile {{profile}} is valid"

# Run bootstrap in dry-run mode
bootstrap-dry profile="macos":
    @echo "━━━ Bootstrap Dry-Run: {{profile}} ━━━"
    @HOMEUP_PROFILE={{profile}} ./bootstrap.sh --help || true

# ------------------------------------------------------------------------------
# 🔍 Diagnostics & Debugging
# ------------------------------------------------------------------------------

# Run comprehensive health checks
doctor:
    #!/usr/bin/env bash
    echo "━━━ Homeup Health Check ━━━"
    echo ""

    errors=0

    # Check required commands
    echo "🔧 Checking required tools..."
    for cmd in brew chezmoi git; do
        if command -v $cmd &>/dev/null; then
            echo "  ✓ $cmd"
        else
            echo "  ✗ $cmd (NOT FOUND)"
            errors=$((errors + 1))
        fi
    done

    echo ""
    echo "📂 Checking file structure..."
    for file in bootstrap.sh packages/Brewfile.core packages/Brewfile.macos packages/Brewfile.linux packages/Brewfile.mini; do
        if [ -f "$file" ]; then
            echo "  ✓ $file"
        else
            echo "  ✗ $file (MISSING)"
            errors=$((errors + 1))
        fi
    done

    echo ""
    echo "🎭 Checking profile configuration..."
    echo "  Current: {{PROFILE}}"
    if [[ "{{PROFILE}}" =~ ^(macos|linux|mini)$ ]]; then
        echo "  ✓ Valid profile"
    else
        echo "  ✗ Invalid profile (must be: macos, linux, or mini)"
        errors=$((errors + 1))
    fi

    echo ""
    echo "🔐 Checking sensitive files..."
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        echo "  ✓ SSH key exists"
    else
        echo "  ⚠️  No SSH key found (run: ssh-keygen -t ed25519)"
    fi

    if [ "{{PROFILE}}" = "macos" ]; then
        if command -v gpg &>/dev/null; then
            echo "  ✓ GPG installed"
        else
            echo "  ⚠️  GPG not installed (expected for macOS profile)"
        fi
    fi

    echo ""
    if [ $errors -eq 0 ]; then
        echo "✅ All checks passed!"
    else
        echo "❌ Found $errors error(s)"
        exit 1
    fi

# Debug chezmoi configuration
debug:
    @echo "━━━ Chezmoi Debug Information ━━━"
    @echo ""
    @echo "Data:"
    @chezmoi data | head -50
    @echo ""
    @echo "Managed files:"
    @chezmoi managed | head -20
    @echo ""
    @echo "Source path: $(chezmoi source-path)"

# Show chezmoi diff with context
diff-full:
    @echo "━━━ Full Diff with Context ━━━"
    @chezmoi diff --no-pager

# Find which template generates a file
find-template file:
    @echo "Source template for {{file}}:"
    @chezmoi source-path {{file}}

# ------------------------------------------------------------------------------
# 🛠️ Development & Git
# ------------------------------------------------------------------------------

# Install git hooks (lefthook)
install-hooks:
    @echo "Installing git hooks..."
    @lefthook install
    @echo "✅ Git hooks installed"

# Uninstall git hooks
uninstall-hooks:
    @echo "Uninstalling git hooks..."
    @lefthook uninstall
    @echo "✅ Git hooks uninstalled"

# Run pre-commit hooks manually
pre-commit:
    @echo "Running pre-commit hooks..."
    @lefthook run pre-commit

# Run all linters
lint:
    @echo "━━━ Running Linters ━━━"
    @echo ""
    @echo "ShellCheck:"
    @find . -name "*.sh" -type f ! -path "./.git/*" -exec shellcheck {} \; || true
    @echo ""
    @echo "Template Validation:"
    @just validate

# Format shell scripts (requires shfmt)
fmt:
    @echo "Formatting shell scripts..."
    @if command -v shfmt &>/dev/null; then \
        find . -name "*.sh" -type f ! -path "./.git/*" -exec shfmt -w -i 4 {} \;; \
        echo "✅ Formatted"; \
    else \
        echo "⚠️  shfmt not installed, skipping"; \
    fi

# Quick commit with message
commit msg:
    @git add -A
    @git commit -m "{{msg}}"
    @echo "✅ Committed: {{msg}}"

# Amend last commit
amend:
    @git commit --amend --no-edit
    @echo "✅ Amended last commit"

# Push to remote
push:
    @git push
    @echo "✅ Pushed to remote"

# Pull from remote
pull:
    @git pull --rebase
    @echo "✅ Pulled from remote"

# Show git log (pretty)
log count="20":
    @git log --oneline -{{count}} --graph --decorate

# Show git status
st:
    @git status -sb

# Create a new branch
branch name:
    @git checkout -b {{name}}
    @echo "✅ Created and switched to branch: {{name}}"

# ------------------------------------------------------------------------------
# 🚀 CI/CD
# ------------------------------------------------------------------------------

# Run all CI checks locally
ci:
    @echo "━━━ Running CI Checks ━━━"
    @echo ""
    @echo "1/5: Linting..."
    @just lint
    @echo ""
    @echo "2/5: Package verification..."
    @just packages-verify
    @echo ""
    @echo "3/5: Duplicate check..."
    @just packages-check-duplicates
    @echo ""
    @echo "4/5: Template validation..."
    @just validate
    @echo ""
    @echo "5/5: Health check..."
    @just doctor
    @echo ""
    @echo "✅ All CI checks passed!"

# Run quick checks (fast subset of CI)
check:
    @echo "Running quick checks..."
    @just validate
    @just packages-check-duplicates
    @echo "✅ Quick checks passed"

# Trigger GitHub Actions workflow
ci-trigger:
    @gh workflow run test.yml
    @echo "✅ GitHub Actions triggered"

# Watch GitHub Actions status
ci-status:
    @echo "Recent workflow runs:"
    @gh run list --limit 5

# View latest GitHub Actions run
ci-logs:
    @gh run view --log

# ------------------------------------------------------------------------------
# 🔄 Maintenance & Cleanup
# ------------------------------------------------------------------------------

# Full system update (topgrade)
upgrade:
    @echo "Running topgrade..."
    @topgrade

# Update Homebrew and packages
update-brew:
    @echo "Updating Homebrew..."
    @brew update
    @brew upgrade
    @brew cleanup
    @echo "✅ Homebrew updated"

# Clean chezmoi cache and temp files
clean:
    @echo "Cleaning caches..."
    @chezmoi purge --force || true
    @rm -rf /tmp/chezmoi-test-* 2>/dev/null || true
    @echo "✅ Caches cleaned"

# Clean everything (brew + chezmoi + temp)
clean-all:
    @echo "Deep cleaning..."
    @just clean
    @just packages-cleanup
    @echo "✅ Deep clean complete"

# Reset chezmoi to clean state (dangerous!)
[confirm("⚠️  This will remove ALL chezmoi state. Continue?")]
reset:
    @chezmoi purge --force
    @echo "✅ Chezmoi state purged"

# Backup current dotfiles
backup:
    #!/usr/bin/env bash
    backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    echo "Creating backup in $backup_dir..."
    mkdir -p "$backup_dir"

    # Backup key files
    for file in .zshrc .gitconfig .ssh/config .config/nvim .config/starship.toml; do
        if [ -e "$HOME/$file" ]; then
            cp -r "$HOME/$file" "$backup_dir/" 2>/dev/null || true
        fi
    done

    echo "✅ Backup created: $backup_dir"

# Show disk usage of Homebrew
brew-size:
    @echo "Homebrew disk usage:"
    @du -sh $(brew --prefix) 2>/dev/null || echo "Unable to calculate"
    @echo ""
    @echo "Cache size:"
    @du -sh $(brew --cache) 2>/dev/null || echo "Unable to calculate"

# ------------------------------------------------------------------------------
# 📊 Statistics & Reporting
# ------------------------------------------------------------------------------

# Show comprehensive statistics
stats:
    #!/usr/bin/env bash
    echo "━━━ Homeup Statistics ━━━"
    echo ""

    echo "📦 Packages:"
    just packages-info

    echo ""
    echo "📁 Managed Files:"
    echo "  Total: $(chezmoi managed | wc -l) files"

    echo ""
    echo "🔀 Git Information:"
    echo "  Commits: $(git rev-list --count HEAD)"
    echo "  Branch: $(git branch --show-current)"
    echo "  Last commit: $(git log -1 --format='%ar')"

    if command -v tokei &>/dev/null; then
        echo ""
        echo "📊 Code Statistics:"
        tokei --exclude .git
    fi

# Generate report for current setup
report:
    #!/usr/bin/env bash
    report_file="homeup-report-$(date +%Y%m%d-%H%M%S).md"

    cat > "$report_file" << EOF
    # Homeup Setup Report

    Generated: $(date)

    ## System Information
    - OS: $(uname -s) $(uname -r)
    - Profile: {{PROFILE}}
    - Chezmoi: $(chezmoi --version | head -1)
    - Homebrew: $(brew --version | head -1)

    ## Package Statistics
    EOF

    just packages-info >> "$report_file"

    cat >> "$report_file" << EOF

    ## Managed Files
    $(chezmoi managed | wc -l) files under management

    ## Git Status
    - Branch: $(git branch --show-current)
    - Commits: $(git rev-list --count HEAD)
    - Last commit: $(git log -1 --format='%h %s')
    EOF

    echo "✅ Report generated: $report_file"

# ------------------------------------------------------------------------------
# 🎓 Learning & Documentation
# ------------------------------------------------------------------------------

# Show common usage examples
examples:
    @echo "━━━ Common Usage Examples ━━━"
    @echo ""
    @echo "🏁 Initial Setup:"
    @echo "  just install-packages    # Install all packages"
    @echo "  just apply               # Apply dotfiles"
    @echo "  just install-hooks       # Setup git hooks"
    @echo ""
    @echo "📝 Daily Usage:"
    @echo "  just diff                # Check what would change"
    @echo "  just apply               # Apply changes"
    @echo "  just status              # See modified files"
    @echo ""
    @echo "🔄 Updates:"
    @echo "  just update              # Update from remote"
    @echo "  just upgrade             # Update all packages"
    @echo "  just packages-outdated   # Check for updates"
    @echo ""
    @echo "🧹 Maintenance:"
    @echo "  just clean               # Clean caches"
    @echo "  just packages-cleanup    # Clean Homebrew"
    @echo "  just doctor              # Health check"
    @echo ""
    @echo "🧪 Before Committing:"
    @echo "  just ci                  # Run all checks"
    @echo "  just check               # Quick checks"

# Show keyboard shortcuts and aliases
shortcuts:
    @echo "━━━ Useful Shortcuts ━━━"
    @echo ""
    @echo "Git:"
    @echo "  just st                  # git status"
    @echo "  just log                 # git log"
    @echo "  just commit \"msg\"        # Quick commit"
    @echo ""
    @echo "Chezmoi:"
    @echo "  just add ~/.file         # Track new file"
    @echo "  just edit ~/.file        # Edit tracked file"
    @echo ""
    @echo "Packages:"
    @echo "  just packages-search X   # Search for package"
    @echo "  just packages-deps X     # Show dependencies"

# Open documentation
docs:
    @echo "Opening documentation..."
    @if [ -f "README.md" ]; then \
        if command -v glow &>/dev/null; then \
            glow README.md; \
        elif command -v bat &>/dev/null; then \
            bat README.md; \
        else \
            cat README.md; \
        fi; \
    else \
        echo "README.md not found"; \
    fi

# ------------------------------------------------------------------------------
# 🔧 Advanced Operations
# ------------------------------------------------------------------------------

# Initialize a new machine with this dotfiles
[confirm("This will initialize chezmoi. Continue?")]
init:
    #!/usr/bin/env bash
    echo "Initializing Homeup on new machine..."

    # Run bootstrap
    ./bootstrap.sh -p {{PROFILE}}

    echo ""
    echo "✅ Initialization complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Review changes: just diff"
    echo "  2. Apply dotfiles: just apply"
    echo "  3. Install packages: just install-packages"

# Re-run all installation scripts
reinstall:
    @echo "⚠️  Re-running installation scripts..."
    @chezmoi init --apply --force

# Export current configuration for backup
export:
    #!/usr/bin/env bash
    export_dir="homeup-export-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$export_dir"

    echo "Exporting configuration to $export_dir..."

    cp -r packages "$export_dir/"
    cp -r .chezmoiscripts "$export_dir/" 2>/dev/null || true
    cp bootstrap.sh justfile README.md "$export_dir/"

    tar -czf "$export_dir.tar.gz" "$export_dir"
    rm -rf "$export_dir"

    echo "✅ Exported to: $export_dir.tar.gz"

# Check for security issues
security-check:
    @echo "━━━ Security Check ━━━"
    @echo ""
    @echo "Checking for secrets in git history..."
    @if command -v gitleaks &>/dev/null; then \
        gitleaks detect --no-git; \
    else \
        echo "⚠️  gitleaks not installed (run: brew install gitleaks)"; \
    fi
    @echo ""
    @echo "Checking file permissions..."
    @find . -name "*.sh" ! -path "./.git/*" -exec ls -l {} \; | grep -v "^-rwxr"

# ==============================================================================
# End of Justfile
# ==============================================================================
