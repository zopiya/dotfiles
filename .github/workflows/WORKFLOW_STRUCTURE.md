# GitHub Actions Workflow Structure

This document provides a visual overview of the modular workflow architecture.

---

## 📊 Workflow File Overview

```
.github/workflows/
├── ci.yml                    (81 lines)  - Main entry point
├── test-platforms.yml        (475 lines) - Platform integration tests
├── test-quality.yml          (94 lines)  - Code quality & validation
├── test-justfile.yml         (204 lines) - Justfile functionality tests
└── test.yml.old              (backup)    - Old monolithic file
```

**Total**: 854 lines across 4 modular files

---

## 🔄 Execution Flow

### On Push / Pull Request

```
┌─────────────────────────────────────────────────────────────┐
│                         ci.yml                              │
│                    (Main Orchestrator)                      │
└──────────────────┬──────────────┬──────────────────────────┘
                   │              │              │
         ┌─────────┘              │              └─────────┐
         │                        │                        │
         ▼                        ▼                        ▼
┌────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│ test-platforms │    │  test-quality    │    │  test-justfile   │
│      .yml      │    │       .yml       │    │       .yml       │
└────────┬───────┘    └────────┬─────────┘    └────────┬─────────┘
         │                     │                       │
    ┌────┴────┬────┐      ┌────┴────┐            ┌────┴────┐
    │         │    │      │         │            │         │
    ▼         ▼    ▼      ▼         ▼            ▼         ▼
┌────────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐      ┌────┐  ┌────────┐
│ macOS  │ │Deb │ │Fed │ │Val │ │Lint│      │Just│  │ Just   │
│        │ │ian │ │ora │ │i-  │ │    │      │file│  │ Integ  │
│        │ │mini│ │mini│ │date│ │    │      │    │  │ration  │
│        │ │+   │ │+   │ │    │ │    │      │    │  │        │
│        │ │lnx │ │lnx │ │    │ │    │      │    │  │        │
└────────┘ └────┘ └────┘ └────┘ └────┘      └────┘  └────────┘

    ~45min  ~45min        ~15min             ~15min   ~20min

                              │
                              ▼
                     ┌─────────────────┐
                     │   Test Summary  │
                     │  ✅ All Passed  │
                     └─────────────────┘
```

**Total Duration**: ~45 minutes (wall time, parallel execution)

---

## 📋 Job Distribution

### test-platforms.yml (475 lines)

```yaml
jobs:
  test-macos:           # macOS Latest
    - Install Bash 5+
    - Cache Homebrew
    - Run bootstrap.sh
    - Apply chezmoi
    - Verify macOS features (GPG, YubiKey)

  test-debian:          # Matrix: [mini, linux]
    - Setup container
    - Run bootstrap.sh
    - Verify headless config
    - Check security exclusions

  test-fedora:          # Matrix: [mini, linux]
    - Setup container
    - Run bootstrap.sh
    - Verify RPM compatibility
    - Check security exclusions
```

**Platform Coverage**:
- ✅ macOS (with GUI support)
- ✅ Debian (headless mini + linux)
- ✅ Fedora (headless mini + linux)

---

### test-quality.yml (94 lines)

```yaml
jobs:
  validate-templates:   # ~10 min
    - Install chezmoi
    - Test macos profile
    - Test mini profile
    - Test linux profile
    - Verify template rendering

  lint:                 # ~5 min
    - Install shellcheck
    - Lint bootstrap.sh
    - Lint all *.sh files
    - Report issues
```

**Quality Checks**:
- ✅ Template syntax (3 profiles)
- ✅ Shell script linting
- ✅ Best practices enforcement

---

### test-justfile.yml (204 lines)

```yaml
jobs:
  test-justfile:        # ~15 min
    - Install just
    - Validate syntax
    - Test help commands
    - Test package verification
    - Test duplicate detection
    - Test info commands
    - Count commands (80+)

  test-integration:     # ~20 min
    - Install just + chezmoi
    - Test profile commands
    - Test chezmoi integration
    - Test validation
```

**Justfile Testing**:
- ✅ Syntax validation
- ✅ 80+ commands tested
- ✅ Package verification
- ✅ Integration with chezmoi

---

### ci.yml (81 lines)

```yaml
jobs:
  platform-tests:
    uses: ./.github/workflows/test-platforms.yml

  quality-tests:
    uses: ./.github/workflows/test-quality.yml

  justfile-tests:
    uses: ./.github/workflows/test-justfile.yml

  summary:
    needs: [platform-tests, quality-tests, justfile-tests]
    - Check all results
    - Report status
```

**Orchestration**:
- ✅ Calls 3 reusable workflows
- ✅ Runs tests in parallel
- ✅ Aggregates results
- ✅ Provides summary

---

## 🎯 Trigger Matrix

| Workflow | Push | PR | Manual | Called by CI |
|----------|------|----|---------| ------------|
| **ci.yml** | ✅ | ✅ | ✅ | - |
| **test-platforms.yml** | - | - | ✅ | ✅ |
| **test-quality.yml** | - | - | ✅ | ✅ |
| **test-justfile.yml** | - | - | ✅ | ✅ |

**Standard workflow**: Push/PR → triggers ci.yml → calls all 3 sub-workflows

**Manual workflow**: Can trigger any workflow individually

---

## 📊 Size Comparison

### Before (Monolithic)

```
test.yml
├─ test-macos (88 lines)
├─ test-debian (169 lines)
├─ test-fedora (168 lines)
├─ validate-templates (31 lines)
├─ lint (26 lines)
├─ test-justfile (106 lines)
└─ test-integration (65 lines)

Total: 725 lines in ONE file
```

**Issues**:
- ❌ Hard to navigate
- ❌ All tests coupled
- ❌ Large git diffs
- ❌ Difficult to maintain

### After (Modular)

```
ci.yml (81 lines)
├─ Orchestration
└─ Summary

test-platforms.yml (475 lines)
├─ test-macos
├─ test-debian
└─ test-fedora

test-quality.yml (94 lines)
├─ validate-templates
└─ lint

test-justfile.yml (204 lines)
├─ test-justfile
└─ test-integration

Total: 854 lines in FOUR files
```

**Benefits**:
- ✅ Clear separation
- ✅ Easy navigation
- ✅ Focused git diffs
- ✅ Easy to maintain

---

## 🚀 Usage Examples

### Run All Tests (Standard)

```bash
# Automatically triggered on push/PR
git push origin main
```

### Run Specific Test Group

```bash
# Only platform tests
gh workflow run test-platforms.yml

# Only quality checks (fast!)
gh workflow run test-quality.yml

# Only justfile tests
gh workflow run test-justfile.yml
```

### Run Specific Profile

```bash
# Test only macOS profile
gh workflow run test-platforms.yml -f profile=macos

# Test only mini profile
gh workflow run test-platforms.yml -f profile=mini
```

### Check Status

```bash
# View all workflow runs
gh run list

# View specific workflow
gh run list --workflow=ci.yml

# Watch latest run
gh run watch
```

---

## 🔍 Debugging

### When a Test Fails

1. **Check Summary**
   ```
   Actions → ci.yml → Latest run → Summary job
   ```
   This shows which test group failed

2. **View Specific Workflow**
   ```
   Click on failed workflow (e.g., test-platforms)
   ```

3. **View Specific Job**
   ```
   Click on failed job (e.g., test-debian / mini)
   ```

4. **Review Logs**
   ```
   Expand failed step for detailed error message
   ```

### Workflow File Structure

**Each workflow has**:
- Clear header with purpose
- Concurrency control
- Environment variables
- Well-named jobs
- Descriptive step names

**Example**:
```yaml
# Clear header
name: Platform Tests

# When to run
on:
  workflow_call:
  workflow_dispatch:

# Prevent duplicate runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

# Jobs
jobs:
  test-macos:
    name: macOS / macos  # Clear job name
    steps:
      - name: Checkout   # Descriptive step
      - name: Install Bash 5+
      # ...
```

---

## 📚 Related Documentation

- [CI_TESTING_GUIDE.md](./CI_TESTING_GUIDE.md) - Comprehensive testing guide
- [WORKFLOW_REFACTOR_SUMMARY.md](../../WORKFLOW_REFACTOR_SUMMARY.md) - Refactor details
- [README.md](../../README.md) - Project overview

---

**Last Updated**: 2026-01-13
**Version**: v2.0
