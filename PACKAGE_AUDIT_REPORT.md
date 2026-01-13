# Package Audit Report - Homeup v2.0

**Date**: 2026-01-13
**Auditor**: Claude Code
**Scope**: All Brewfile configurations (core, macos, linux, mini)

---

## Executive Summary

The audit identified **43 duplicate packages** between `Brewfile.macos` and `Brewfile.linux`, leading to maintenance overhead and inconsistency risks. All packages are valid and available in Homebrew, but the organization needs optimization.

### Status Overview
- ✅ **All packages are available** in Homebrew
- ⚠️ **43 duplicates** found between macOS and Linux profiles
- ✅ **Mini profile is correctly standalone** (intentional overlap with Core)
- ✅ **No platform-specific mismatches** detected
- ✅ **Taps are correctly declared**

---

## Detailed Findings

### 1. Package Count Summary

| File | Taps | Formulae | Casks | Total |
|------|------|----------|-------|-------|
| **Brewfile.core** | 0 | 36 | 0 | 36 |
| **Brewfile.macos** | 2 | 44 | 19 | 65 |
| **Brewfile.linux** | 1 | 46 | 0 | 47 |
| **Brewfile.mini** | 0 | 23 | 0 | 23 |

### 2. Critical Issue: Duplicate Packages (43 total)

The following packages exist in BOTH `Brewfile.macos` AND `Brewfile.linux`:

#### 2.1 Runtime & Package Managers (Should move to Core)
```
mise          # Universal version manager
uv            # Python package manager
pnpm          # Node.js package manager
```

**Recommendation**: Move to `Brewfile.core` as these are essential for both profiles.

#### 2.2 Enhanced CLI Tools (Should move to Core)
```
fastfetch     # System info
zellij        # Terminal multiplexer
bottom        # System monitor
choose        # Better cut
```

**Recommendation**: Move to `Brewfile.core` for consistency across macOS/Linux.

#### 2.3 File Management
```
yazi          # File manager
watchexec     # File watcher
```

**Recommendation**: Keep in both (or move to Core if widely used).

#### 2.4 AI & Development Tools
```
aider         # AI coding assistant
glow          # Markdown renderer
vhs           # Terminal recorder
```

**Recommendation**: Move to Core or keep duplicated (both profiles need them).

#### 2.5 Container & Kubernetes Ecosystem (All duplicated)
```
lazydocker, dive, k9s, helm, kubectx, stern, kustomize
```

**Recommendation**: These are ops tools - consider if Core needs them or keep in both profiles.

#### 2.6 Infrastructure as Code & DevOps
```
terraform     # IaC
ansible       # Configuration management
trivy         # Security scanner
grype         # Vulnerability scanner
syft          # SBOM generator
```

**Recommendation**: These are ops-heavy. Keep in macos/linux, or move to Core if essential everywhere.

#### 2.7 Network & API Tools
```
httpie, xh, doggo, gping, trippy, grpcurl, evans
```

**Recommendation**: Network tools used everywhere - consider moving to Core.

#### 2.8 Database Tools
```
pgcli         # PostgreSQL CLI
```

**Recommendation**: Move to Core if database work is common.

#### 2.9 Performance & Analysis
```
hyperfine     # Benchmarking
tokei         # Code statistics
bandwhich     # Bandwidth monitor
```

**Recommendation**: Keep in both or move to Core.

#### 2.10 Git Enhancements
```
git-cliff     # Changelog generator
onefetch      # Repo info
gitleaks      # Secret scanner
```

**Recommendation**: Move to Core (git workflows are universal).

#### 2.11 Security & Encryption
```
gnupg         # GPG (but should be macOS-only per design!)
age           # Modern encryption
ykman         # YubiKey manager
1password-cli # 1Password CLI
```

**⚠️ CRITICAL**: According to v2.0 design, GPG should be **macOS-only**. This is a design violation!

#### 2.12 Backup
```
restic        # Backup tool
```

**Recommendation**: Move to Core if backups are universal.

### 3. Profile-Specific Packages (Correct)

#### 3.1 macOS Only
```
pinentry-mac  # ✅ Correct (macOS-specific GPG pinentry)
```

**+ 19 GUI Casks** (fonts, browsers, terminals, productivity apps)

#### 3.2 Linux Only
```
bmon          # ✅ Bandwidth monitor (server monitoring)
glances       # ✅ Advanced system monitor (server monitoring)
lnav          # ✅ Log file navigator (server operations)
```

These are correctly Linux-specific for server operations.

### 4. Mini Profile Analysis

Mini is **intentionally standalone** and does NOT inherit from Core. The 20 overlapping packages with Core are by design for a self-contained minimal environment.

**Overlapping packages (intentional)**:
```
zsh, starship, sheldon, fzf, zoxide, neovim, tmux, mise, uv, pnpm,
git, lazygit, git-delta, bat, eza, ripgrep, fd, jq, sd, direnv,
just, chezmoi, curl
```

✅ **This is correct** - Mini is designed to be independent.

### 5. Tap Dependencies

| Tap | Used For | Status |
|-----|----------|--------|
| `homebrew/cask-fonts` | 4 font casks in macOS | ✅ Valid |
| `1password/tap` | 1password-cli (macos/linux) | ✅ Valid |

**Note**: Taps are declared where first used. This is correct.

---

## Design Violations

### 🚨 Critical: GPG in Linux Profile

According to `REFACTOR_PLAN.md` and README:
- **macOS profile**: Full GPG support, signing, YubiKey
- **Linux profile**: **NO GPG** (agent forwarded from macOS)
- **Mini profile**: No GPG

**Current State**: `gnupg` is in BOTH `Brewfile.macos` AND `Brewfile.linux`

**Required Action**: Remove `gnupg` from `Brewfile.linux` to match v2.0 design.

---

## Recommendations

### Priority 1: Fix Design Violations (CRITICAL)

1. **Remove `gnupg` from `Brewfile.linux`**
   - Linux should use agent forwarding, not local GPG
   - This aligns with the headless, zero-trust design

### Priority 2: Optimize Package Organization (HIGH)

Create two categories of shared packages:

#### Option A: Aggressive Consolidation (Recommended)
Move the following to `Brewfile.core`:

```bash
# Runtimes (essential for all development)
mise, uv, pnpm

# Enhanced CLI (universal utilities)
fastfetch, zellij, bottom, choose

# File management
yazi, watchexec

# AI & docs
aider, glow, vhs

# Network tools (commonly used)
httpie, xh, doggo, gping, trippy, grpcurl, evans

# Database
pgcli

# Performance
hyperfine, tokei, bandwhich

# Git enhancements
git-cliff, onefetch, gitleaks

# Security (except GPG)
age, ykman, 1password-cli

# Backup
restic
```

Keep in profile-specific files:
- **macOS**: Container/K8s tools, IaC tools, GUI apps, pinentry-mac, gnupg
- **Linux**: bmon, glances, lnav, Container/K8s tools, IaC tools

#### Option B: Conservative (Keep Ops Tools Separate)
Only move universally-needed tools to Core:

```bash
# Move to Core:
mise, uv, pnpm           # Runtimes
fastfetch, zellij        # Enhanced CLI
aider, glow              # AI & docs
git-cliff, onefetch      # Git enhancements
age                      # Encryption (not GPG)
restic                   # Backup

# Keep duplicated in macos/linux:
- All Kubernetes/Container tools (k9s, lazydocker, helm, etc.)
- All IaC tools (terraform, ansible, trivy, etc.)
- All network tools (httpie, xh, etc.)
```

### Priority 3: Documentation Updates (MEDIUM)

1. Update `packages/README.md` to reflect current package counts
2. Add comments in Brewfiles explaining why packages are in specific locations
3. Document the philosophy: Core = Universal, Profile = Specialized

---

## Package Availability Verification

All packages were verified against Homebrew:

### ✅ All Formulae: Available
- 36 packages in Core
- 44 packages in macOS
- 46 packages in Linux
- 23 packages in Mini

### ✅ All Casks: Available
- 19 casks in macOS (fonts, browsers, apps)

### ✅ All Taps: Valid
- `homebrew/cask-fonts` - Standard Homebrew tap
- `1password/tap` - Official 1Password tap

**No broken or missing packages found.**

---

## Action Plan

### Immediate (Must Fix)

1. **Remove `gnupg` from `Brewfile.linux`**
   ```bash
   # File: packages/Brewfile.linux
   # Remove line: brew "gnupg"
   ```

### Short Term (Optimize)

2. **Choose consolidation strategy** (Option A or B above)
3. **Move shared packages to Core** (based on chosen option)
4. **Update profile-specific Brewfiles** (remove moved packages)
5. **Test all three profiles** (`just validate`)

### Long Term (Maintain)

6. **Add validation to CI/CD** to prevent future duplicates
7. **Document package placement policy** in `packages/README.md`
8. **Create a package decision tree** (when to use Core vs Profile)

---

## Conclusion

The Homeup package configuration is **fundamentally sound** with all packages available and valid. However:

1. **1 critical design violation**: GPG in Linux (against v2.0 spec)
2. **43 duplicates**: Opportunity for significant optimization
3. **No broken packages**: All dependencies are resolvable

**Estimated effort to fix**:
- Critical fix (GPG removal): 5 minutes
- Optimization (consolidation): 30-60 minutes
- Testing: 15 minutes
- Total: ~1-1.5 hours

---

## Appendix: Complete Duplicate List

<details>
<summary>All 43 Duplicates Between macOS and Linux</summary>

```
1password-cli, age, aider, ansible, bandwhich, bottom, choose, dive,
doggo, evans, fastfetch, git-cliff, gitleaks, glow, gnupg, gping,
grpcurl, grype, helm, httpie, hyperfine, k9s, kubectx, kustomize,
lazydocker, mise, onefetch, pgcli, pnpm, restic, stern, syft,
terraform, tokei, trippy, trivy, uv, vhs, watchexec, xh, yazi,
ykman, zellij
```

</details>

---

**Report Generated**: 2026-01-13
**Next Review**: After implementing recommendations
