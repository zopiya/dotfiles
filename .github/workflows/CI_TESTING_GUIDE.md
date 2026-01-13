# GitHub Actions CI Testing Guide

This document describes the comprehensive CI/CD testing strategy for Homeup v2.0.

## 📁 Workflow Structure

The CI pipeline is split into **4 modular workflow files** for better maintainability:

| Workflow File | Purpose | Jobs | Trigger |
|---------------|---------|------|---------|
| **ci.yml** | Main entry point | Orchestrates all tests | Push, PR, Manual |
| **test-platforms.yml** | Platform integration tests | test-macos, test-debian, test-fedora | Called by ci.yml |
| **test-quality.yml** | Code quality checks | validate-templates, lint | Called by ci.yml |
| **test-justfile.yml** | Justfile testing | test-justfile, test-integration | Called by ci.yml |

**Benefits of this structure**:
- ✅ **Modular**: Each workflow has a single responsibility
- ✅ **Reusable**: Can be triggered individually via `workflow_call`
- ✅ **Maintainable**: Easier to understand and modify
- ✅ **Parallel**: All workflows run in parallel for faster feedback

---

## 📊 Test Overview

The CI pipeline includes **8 test jobs** covering all aspects of the project:

| Job | Purpose | Duration | Platform |
|-----|---------|----------|----------|
| **test-macos** | Test macOS profile | ~45 min | macOS Latest |
| **test-debian** | Test mini/linux profiles | ~45 min | Debian Container |
| **test-fedora** | Test mini/linux profiles | ~45 min | Fedora Container |
| **validate-templates** | Validate chezmoi templates | ~10 min | Ubuntu |
| **lint** | Shellcheck all scripts | ~5 min | Ubuntu |
| **test-justfile** | Test justfile commands | ~15 min | Ubuntu |
| **test-just-integration** | Test just + chezmoi integration | ~20 min | Ubuntu |

**Total**: 7 jobs, ~185 minutes of testing per commit

---

## 🎯 Test Matrix

### Profile Coverage

```
Profile    macOS   Debian   Fedora
───────────────────────────────────
macos       ✓        -        -
linux       -        ✓        ✓
mini        -        ✓        ✓
```

### Feature Coverage

- ✅ Bootstrap installation
- ✅ Homebrew setup
- ✅ Chezmoi application
- ✅ Profile-specific configurations
- ✅ Security settings (GPG, SSH, YubiKey)
- ✅ Template syntax validation
- ✅ Shell script linting
- ✅ **Justfile syntax validation** (NEW)
- ✅ **Just command functionality** (NEW)
- ✅ **Package verification** (NEW)

---

## 🧪 Test Jobs Breakdown

### 1. test-macos

**Platform**: macOS Latest
**Profile**: macos
**Duration**: ~45 minutes

**What it tests**:
- Bootstrap.sh installation on macOS
- Homebrew installation & caching
- Chezmoi dotfiles application
- Config file generation:
  - starship.toml
  - .zshrc
  - .ssh/config
  - .gnupg/gpg.conf
- Core tool installation:
  - zsh, starship, nvim, fzf
- macOS-specific features:
  - GPG signing enabled
  - YubiKey configuration
  - 1Password integration

**Key validations**:
```bash
grep -q "gpgsign = true" "$HOME/.config/git/config"
test -f "$HOME/.gnupg/gpg.conf"
command -v starship
```

---

### 2. test-debian (Matrix)

**Platform**: Debian Container
**Profiles**: mini, linux
**Duration**: ~45 minutes

**What it tests**:
- Bootstrap.sh on Debian
- Linuxbrew installation
- Profile-specific configurations
- Security exclusions (no GPG/YubiKey on Linux)

**Matrix jobs**:
1. **Debian / mini**
   - Minimal package set
   - GPG signing disabled
   - SSH ForwardAgent disabled

2. **Debian / linux**
   - Full headless setup
   - GPG signing disabled (uses forwarding)
   - SSH ForwardAgent disabled
   - 1Password/YubiKey configs excluded

**Key validations**:
```bash
grep -q "gpgsign = false" "$HOME/.config/git/config"
grep -q "ForwardAgent no" "$HOME/.ssh/config"
test ! -f "$HOME/.config/security/1password.inc"
```

---

### 3. test-fedora (Matrix)

**Platform**: Fedora Container
**Profiles**: mini, linux
**Duration**: ~45 minutes

**What it tests**:
- Same as Debian but on Fedora
- Ensures RPM-based distro compatibility

**Why Fedora?**
- Tests dnf package manager
- Tests different system libraries
- Validates cross-distro compatibility

---

### 4. validate-templates

**Platform**: Ubuntu
**Duration**: ~10 minutes

**What it tests**:
- Chezmoi template syntax
- Template rendering for all profiles
- No undefined variables
- No template errors

**How it works**:
```bash
for profile in macos mini linux; do
  export HOMEUP_PROFILE=$profile
  chezmoi init --source . --dry-run || exit 1
done
```

---

### 5. lint

**Platform**: Ubuntu
**Duration**: ~5 minutes

**What it tests**:
- Shell script syntax
- Shellcheck compliance
- Best practices

**Files checked**:
- bootstrap.sh
- All *.sh files in the repository

**Shellcheck rules enforced**:
- No unused variables
- Proper quoting
- Array handling
- Error checking

---

### 6. test-justfile (NEW)

**Platform**: Ubuntu
**Duration**: ~15 minutes

**What it tests**:
- ✅ Justfile syntax validation
- ✅ Help commands (help, examples, shortcuts)
- ✅ Package verification (packages-verify)
- ✅ Duplicate detection (packages-check-duplicates)
- ✅ Info commands (info, packages-info, stats)
- ✅ Command count (80+ commands)

**Test steps**:

1. **Syntax Validation**
   ```bash
   just --list > /dev/null
   ```

2. **Help Commands**
   ```bash
   just help
   just examples
   just shortcuts
   ```

3. **Package Verification**
   ```bash
   brew update
   just packages-verify
   just packages-check-duplicates
   ```

4. **Info Commands**
   ```bash
   just info
   just packages-info
   just stats
   ```

5. **Command Count**
   ```bash
   command_count=$(just --list --unsorted | grep -c "^  ")
   [ "$command_count" -ge 80 ]
   ```

**Why this matters**:
- Ensures justfile has no syntax errors
- Validates all 80+ commands are accessible
- Tests package verification before actual use
- Catches duplicate packages early

---

### 7. test-just-integration (NEW)

**Platform**: Ubuntu
**Duration**: ~20 minutes

**What it tests**:
- ✅ Just + Chezmoi integration
- ✅ Profile commands
- ✅ Profile comparison (profile-diff)
- ✅ Chezmoi commands via just
- ✅ Validation commands

**Test steps**:

1. **Profile Commands**
   ```bash
   export HOMEUP_PROFILE=mini
   just profile
   just profile-diff macos linux
   ```

2. **Chezmoi Commands**
   ```bash
   just status
   just data
   ```

3. **Validation Commands**
   ```bash
   just validate
   ```

**Why this matters**:
- Tests real-world workflow
- Validates just wrapper around chezmoi
- Ensures profile switching works
- Tests template validation integration

---

## 🚀 Running Tests Locally

### Run All Tests (Just Commands)

```bash
# Full CI suite
just ci

# Quick check (faster subset)
just check

# Individual tests
just lint
just validate
just packages-verify
just packages-check-duplicates
```

### Manual GitHub Actions Testing

```bash
# Trigger workflow manually
just ci-trigger

# Check workflow status
just ci-status

# View logs
just ci-logs
```

### Test Specific Profile

```bash
# Via GitHub UI
# Actions → Test → Run workflow → Select profile

# Or via gh CLI
gh workflow run test.yml -f profile=mini
```

---

## 📈 Test Coverage

### Code Coverage

| Component | Coverage |
|-----------|----------|
| bootstrap.sh | ✅ Full (all profiles tested) |
| Brewfile.* | ✅ Full (package verification) |
| Templates | ✅ Full (all profiles validated) |
| Shell scripts | ✅ Full (shellcheck) |
| Justfile | ✅ Full (syntax + 80+ commands) |

### Platform Coverage

| Platform | mini | linux | macos |
|----------|------|-------|-------|
| macOS | - | - | ✅ |
| Debian | ✅ | ✅ | - |
| Fedora | ✅ | ✅ | - |

### Integration Coverage

- ✅ Bootstrap → Homebrew
- ✅ Homebrew → Chezmoi
- ✅ Chezmoi → Dotfiles
- ✅ Just → Chezmoi
- ✅ Just → Package Management
- ✅ Profile switching

---

## 🔍 What Gets Caught

### Real Issues Found by CI

1. **Shellcheck Error** (lint)
   - Issue: Unused `has_gui` variable
   - Fixed: Removed GUI detection from Linux

2. **Template Error** (validate-templates)
   - Issue: Undefined variable in template
   - Fixed: Added default value

3. **Missing Package** (test-justfile)
   - Issue: `usql` removed from Homebrew
   - Fixed: Removed from Brewfiles

4. **Duplicate Packages** (test-justfile)
   - Issue: 43 packages duplicated
   - Fixed: Moved to Core

5. **Design Violation** (test-debian)
   - Issue: GPG/YubiKey on Linux
   - Fixed: Removed from Linux profile

---

## ⚙️ CI Configuration

### Concurrency Control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

**Effect**: Only one test run per branch at a time.

### Caching Strategy

**Homebrew Cache**:
- macOS: `~/Library/Caches/Homebrew`
- Linux: `/home/linuxbrew/.linuxbrew`
- Key: `${{ runner.os }}-homebrew-${{ hashFiles('bootstrap.sh') }}`

**Benefits**:
- Faster test runs (~30% speedup)
- Reduced GitHub Actions minutes
- Reduced Homebrew API load

### Timeout Strategy

| Job | Timeout | Reason |
|-----|---------|--------|
| Profile tests | 45 min | Full package installation |
| Template validation | 10 min | Quick syntax check |
| Lint | 5 min | Fast syntax check |
| Justfile tests | 15 min | Package verification |
| Integration tests | 20 min | Multiple tool interaction |

---

## 🎯 Best Practices

### Before Committing

Run local checks:
```bash
# Quick pre-commit check
just check

# Full CI simulation
just ci
```

### When Adding Packages

```bash
# Verify package exists
just packages-verify

# Check for duplicates
just packages-check-duplicates

# Validate templates
just validate
```

### When Modifying Templates

```bash
# Test all profiles
just validate

# Or test specific profile
just test mini
just test linux
just test macos
```

### When Modifying Justfile

```bash
# Check syntax
just --list

# Test new command
just <new-command>

# Run full test suite
just ci
```

---

## 📊 Performance Metrics

### Average Run Times (with cache)

- macOS test: ~30 min
- Debian test (2 profiles): ~35 min
- Fedora test (2 profiles): ~35 min
- Template validation: ~2 min
- Lint: ~1 min
- Justfile test: ~10 min
- Integration test: ~12 min

**Total wall time**: ~45 min (parallel execution)

### Resource Usage

- **Compute**: ~185 min of GitHub Actions compute per commit
- **Cache**: ~2 GB Homebrew cache (shared across runs)
- **Bandwidth**: ~500 MB package downloads (without cache)

---

## 🔄 Future Improvements

### Potential Additions

1. **Performance Tests**
   - Bootstrap speed benchmarks
   - Package installation time tracking

2. **Security Scanning**
   - Dependency vulnerability scanning
   - Secret detection

3. **Documentation Tests**
   - Markdown linting
   - Link validation
   - Screenshot freshness

4. **End-to-End Tests**
   - Full bootstrap → usage workflow
   - Multi-machine sync testing

5. **Benchmark Tests**
   - Compare package counts over time
   - Track template complexity
   - Monitor CI duration

---

## 🆘 Troubleshooting

### CI Failing Locally Works

```bash
# Clear caches
rm -rf ~/Library/Caches/Homebrew  # macOS
rm -rf ~/.cache/Homebrew           # Linux

# Run with same env vars as CI
export NONINTERACTIVE=1
export CI=true
export HOMEBREW_NO_AUTO_UPDATE=1

just ci
```

### Timeout Issues

- Check if packages are downloading slowly
- Review cache effectiveness
- Consider splitting long jobs

### Flaky Tests

- Usually caused by network issues
- Retry the workflow
- Check Homebrew API status

---

## 📚 Related Documentation

- [JUSTFILE_GUIDE.md](../../JUSTFILE_GUIDE.md) - Just command reference
- [README.md](../../README.md) - Project overview
- [packages/README.md](../../packages/README.md) - Package management

---

**Last Updated**: 2026-01-13
**Version**: v2.0
