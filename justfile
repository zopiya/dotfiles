# ==============================================================================
# Homeup Justfile
# ==============================================================================
# Task orchestration for dotfiles management.
# Usage: just <task>
# ==============================================================================

# Default task: show help
default:
    @just --list

# ------------------------------------------------------------------------------
# Chezmoi Operations
# ------------------------------------------------------------------------------

# Apply chezmoi configuration
apply:
    chezmoi apply

# Apply with verbose output
apply-verbose:
    chezmoi apply -v

# Show diff before applying
diff:
    chezmoi diff

# Edit a managed file
edit file:
    chezmoi edit {{file}}

# Update from remote and apply
update:
    chezmoi update

# Re-add a file to chezmoi
add file:
    chezmoi add {{file}}

# Show chezmoi status
status:
    chezmoi status

# Verify chezmoi configuration
verify:
    chezmoi verify

# ------------------------------------------------------------------------------
# Development
# ------------------------------------------------------------------------------

# Install git hooks (lefthook)
install-hooks:
    @echo "Installing git hooks..."
    lefthook install
    @echo "Done."

# Uninstall git hooks
uninstall-hooks:
    lefthook uninstall

# Run pre-commit hooks manually
pre-commit:
    lefthook run pre-commit

# Run all linters
lint:
    @echo "=== ShellCheck ==="
    find . -name "*.sh" -type f ! -path "./.git/*" -exec shellcheck {} \; || true
    @echo ""
    @echo "=== Template Validation ==="
    @just validate

# Format shell scripts (requires shfmt)
fmt:
    @echo "Formatting shell scripts..."
    find . -name "*.sh" -type f ! -path "./.git/*" -exec shfmt -w -i 4 {} \; 2>/dev/null || echo "shfmt not installed, skipping"

# ------------------------------------------------------------------------------
# Testing
# ------------------------------------------------------------------------------

# Validate templates for all profiles
validate:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Validating templates for all profiles..."
    for profile in workstation codespace server; do
        echo "--- Profile: $profile ---"
        export HOMEUP_PROFILE=$profile
        chezmoi init --source . --destination /tmp/chezmoi-test-$profile --dry-run 2>/dev/null && echo "OK" || echo "FAIL"
    done

# Test specific profile
test profile="workstation":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Testing profile: {{profile}}"
    export HOMEUP_PROFILE={{profile}}
    chezmoi init --source . --destination /tmp/chezmoi-test-{{profile}} --dry-run
    echo "Profile {{profile}} is valid"

# Run bootstrap in dry-run mode
bootstrap-dry profile="workstation":
    @echo "Dry-run bootstrap for profile: {{profile}}"
    HOMEUP_PROFILE={{profile}} ./bootstrap.sh -p {{profile}} -y --help || true

# ------------------------------------------------------------------------------
# Profiles
# ------------------------------------------------------------------------------

# Show current profile
profile:
    @echo "Current profile: ${HOMEUP_PROFILE:-workstation}"

# Set profile to workstation
profile-workstation:
    @echo "export HOMEUP_PROFILE=workstation"

# Set profile to codespace
profile-codespace:
    @echo "export HOMEUP_PROFILE=codespace"

# Set profile to server
profile-server:
    @echo "export HOMEUP_PROFILE=server"

# ------------------------------------------------------------------------------
# Packages
# ------------------------------------------------------------------------------

# Install packages for current profile
install-packages:
    @echo "Installing packages..."
    brew bundle --file=packages/Brewfile.core
    @if [ "$(uname)" = "Darwin" ]; then \
        brew bundle --file=packages/Brewfile.macos; \
    else \
        brew bundle --file=packages/Brewfile.linux; \
    fi
    @if [ "$HOMEUP_PROFILE" = "codespace" ]; then \
        brew bundle --file=packages/Brewfile.codespace; \
    elif [ "$HOMEUP_PROFILE" = "server" ]; then \
        brew bundle --file=packages/Brewfile.server; \
    fi

# List all brew packages
packages-list:
    brew list

# Cleanup unused packages
packages-cleanup:
    brew cleanup --prune=all
    brew autoremove

# ------------------------------------------------------------------------------
# Maintenance
# ------------------------------------------------------------------------------

# Full system update (topgrade)
upgrade:
    topgrade

# Clean chezmoi cache
clean:
    chezmoi purge --force || true
    rm -rf /tmp/chezmoi-test-* 2>/dev/null || true
    @echo "Cache cleaned."

# Reset to clean state (dangerous!)
[confirm("This will remove all chezmoi state. Continue?")]
reset:
    chezmoi purge --force
    @echo "Chezmoi state purged."

# ------------------------------------------------------------------------------
# Git Operations
# ------------------------------------------------------------------------------

# Quick commit with message
commit msg:
    git add -A
    git commit -m "{{msg}}"

# Amend last commit
amend:
    git commit --amend --no-edit

# Push to remote
push:
    git push

# Pull from remote
pull:
    git pull --rebase

# Show git log (pretty)
log:
    git log --oneline -20

# ------------------------------------------------------------------------------
# CI/CD
# ------------------------------------------------------------------------------

# Run CI checks locally
ci:
    @echo "=== Lint ==="
    @just lint
    @echo ""
    @echo "=== Validate ==="
    @just validate
    @echo ""
    @echo "=== CI Checks Complete ==="

# Trigger GitHub Actions (requires gh)
ci-trigger:
    gh workflow run test.yml

# Watch GitHub Actions status
ci-status:
    gh run list --limit 5
