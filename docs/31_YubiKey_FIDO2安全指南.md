# YubiKey FIDO2 SSH Complete Guide: Hardware-Backed Security Keys

> Secure your identity with cryptographic hardware: SSH authentication and Git signing using YubiKey FIDO2

**版本**: 1.0
**目标受众**: 安全意识强的开发者、系统管理员、安全工程师
**前置知识**: SSH 基础、公钥密码学基本概念、YubiKey 或硬件钥匙相关经验

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [YubiKey 硬件](#yubikey-硬件)
- [密钥生成](#密钥生成)
- [SSH 认证](#ssh-认证)
- [SSH 签名](#ssh-签名)
- [Homeup 集成](#homeup-集成)
- [安全最佳实践](#安全最佳实践)
- [灾难恢复](#灾难恢复)
- [故障排除](#故障排除)
- [总结与参考](#总结与参考)

---

## 核心概念

### 为什么选择 YubiKey？

**传统 SSH 密钥的问题**:

```
❌ 私钥存储在磁盘上
├─ 如果磁盘被破解，所有身份都泄露
├─ 无法针对关键操作进行二次验证
├─ 密钥可能被无意中备份到云端

❌ 密钥管理复杂
├─ 多台机器需要同步密钥
├─ 密钥泄露时需要全面更新
└─ 无法撤销特定使用
```

**YubiKey FIDO2 的优势**:

```
✅ 硬件密钥存储
├─ 私钥永不离开硬件设备
├─ 即使磁盘被破解也安全
└─ 物理拥有是安全的先决条件

✅ FIDO2 标准支持
├─ 多数 Git 服务支持（GitHub、GitLab）
├─ SSH 8.2+ 原生支持
└─ 无需额外依赖

✅ 双因素强制
├─ 触摸（或生物识别）才能签名
├─ 防止中间人攻击
└─ 防止恶意软件自动签名
```

### 关键术语

| 术语 | 含义 | YubiKey 中 |
|------|------|---------|
| **FIDO2** | 无密码认证标准 | YubiKey 5+ 支持 |
| **SK Key** | Security Key（硬件支持的密钥） | `sk-ssh-ed25519@openssh.com` |
| **Resident Key** | 驻留在硬件上的密钥 | 可离线使用 |
| **User Presence** | 用户操作验证（触摸） | YubiKey 上的触摸按钮 |
| **User Verification** | 用户身份验证（PIN） | YubiKey PIN 码 |
| **Attestation** | 证明密钥真实性 | 证书链验证 |

---

## 快速开始

### ⚡ 5 分钟设置 YubiKey SSH 认证

```bash
# 1. 准备硬件
# - YubiKey 5.3 或更新版本
# - 连接到电脑

# 2. 安装工具
brew install yubikey-manager openssh

# 3. 验证 OpenSSH 版本（必须 8.2+）
ssh -V
# 输出: OpenSSH_8.6p1

# 4. 生成 SSH 密钥对
ssh-keygen -t ed25519-sk -O resident \
  -O application=ssh:main \
  -C "user@example.com" \
  -f ~/.ssh/main

# 提示触摸 YubiKey
# 输入 PIN（如果设置了）

# 5. 列出密钥
ssh-add -l
# 输出应显示 SK 密钥

# 6. 添加公钥到 GitHub
cat ~/.ssh/main.pub
# 复制到 GitHub Settings → SSH Keys

# 完成！现在可以用 YubiKey 进行 SSH 操作
```

### ✅ 验证 YubiKey 工作

```bash
# 1. 连接到任何支持 SSH 的服务器
ssh github.com

# 输出应该显示：
# Verify your identity using YubiKey
# Touch YubiKey...

# 2. 触摸 YubiKey
# （短暂闪烁/响应）

# 3. 连接成功
# Hi username! You've successfully authenticated.
```

---

## YubiKey 硬件

### YubiKey 系列对比

| 型号 | FIDO2 | NFC | 价格 | 推荐 |
|------|-------|-----|------|------|
| **5 Nano** | ✅ | ❌ | $45 | ✅ |
| **5 Series** | ✅ | ❌ | $50 | ✅ 主要选择 |
| **5C** | ✅ | ❌ | $50 | ✅ USB-C |
| **5C NFC** | ✅ | ✅ | $60 | ✅ 最全能 |
| **4 Series** | ❌ | ❌ | $30 | ⚠️ 不支持 FIDO2 |

**Homeup 推荐**: YubiKey 5 Series（USB-A）或 5C（USB-C）

### 硬件功能

```
YubiKey 5 Series 包含：
├─ FIDO2/U2F      → SSH、GitHub、各种服务 2FA
├─ PIV           → 智能卡支持、证书存储
├─ OATH           → Time-based OTP（Google Authenticator）
├─ Yubico OTP     → Yubico 专有 OTP
└─ OpenPGP       → GPG 支持（可选）
```

### YubiKey 初始设置

```bash
# 1. 连接 YubiKey
# （物理插入 USB）

# 2. 安装 YubiKey Manager
brew install yubikey-manager

# 3. 查看 YubiKey 信息
ykman info

# 输出示例：
# Device type: YubiKey 5
# Serial number: 12345678
# Firmware: 5.4.3
# FIDO2: Enabled
# PIV: Enabled

# 4. 设置 PIN（可选但推荐）
ykman fido2 set-pin

# 5. 重置 YubiKey（如需要）
ykman fido2 reset --force
```

---

## 密钥生成

### Ed25519-SK 密钥（推荐）

**优势**:

```
✅ 最快的签名速度
✅ 更小的密钥和签名大小
✅ 强加密强度
✅ 现代算法
```

**生成方式**:

```bash
# 1. 驻留密钥（推荐）- 存储在 YubiKey 上
ssh-keygen -t ed25519-sk -O resident \
  -O application=ssh:main \
  -f ~/.ssh/main \
  -C "user@example.com"

# 2. 触摸 YubiKey（可能需要多次）
# 3. 设置 PIN（如果 YubiKey 需要）

# 结果：
# ~/.ssh/main          (私钥引用，很小)
# ~/.ssh/main.pub      (公钥)
```

### ECDSA-SK 密钥（备选）

如果 Ed25519-SK 不可用（较旧的 OpenSSH）:

```bash
ssh-keygen -t ecdsa-sk -O resident \
  -O application=ssh:main \
  -f ~/.ssh/main \
  -C "user@example.com"
```

### 非驻留密钥（不推荐）

如果硬件不支持驻留密钥：

```bash
# 不推荐 - 密钥存储在磁盘上
ssh-keygen -t ed25519-sk \
  -O no-touch-required \
  -f ~/.ssh/main \
  -C "user@example.com"
```

**为什么不推荐**:
- ❌ 私钥在磁盘上，违反 YubiKey 的初衷
- ❌ 如果磁盘被破解，安全性降低
- ❌ 无法离线使用

### 密钥恢复

驻留密钥存储在硬件中，可以从任何支持 SSH 的电脑恢复：

```bash
# 在新电脑上：

# 1. 连接 YubiKey
# 2. 列出驻留密钥
ssh-add -l

# 3. 输出应显示：
# sk-ssh-ed25519@openssh.com AAAA... (FIDO2 resident key)

# 4. 导出公钥（用于 GitHub 等）
ssh-keygen -y -f ~/.ssh/main > ~/.ssh/main.pub
```

---

## SSH 认证

### 配置 SSH 使用 YubiKey

#### macOS 配置

```bash
# ~/.ssh/config

Host github.com
    User git
    IdentityFile ~/.ssh/main
    # YubiKey 会自动被 SSH Agent 使用
```

#### 加载 YubiKey 驻留密钥

```bash
# 方法 1：自动加载（推荐）
# 在 ~/.zshrc 中：
eval "$(ssh-agent)"
ssh-add -K  # 加载所有驻留密钥

# 方法 2：手动加载
ssh-add ~/.ssh/main

# 方法 3：Homeup 函数
yk  # 快捷函数，定义在 ~/.config/zsh/functions.zsh
```

#### 验证配置

```bash
# 1. 列出已加载的密钥
ssh-add -l

# 输出应包含：
# 256 SHA256:abc123... (FIDO2) main (FIDO2 resident key)

# 2. 测试 GitHub 连接
ssh -T git@github.com

# 输出：
# Verify your identity using YubiKey
# Touch YubiKey...
# Hi username! You've successfully authenticated.
```

### SSH 代理转发

在远程主机上也能使用本地 YubiKey：

```bash
# ~/.ssh/config

Host remote.example.com
    HostName example.com
    User zopiya
    ForwardAgent yes    # 启用代理转发
```

**使用**:

```bash
# 连接到远程主机
ssh remote.example.com

# 在远程上验证
ssh-add -l

# 应显示本地的 YubiKey 密钥

# 在远程上 clone 仓库
git clone git@github.com:username/repo.git

# 会提示触摸本地 YubiKey
# 成功克隆仓库
```

### 排除密码需求

```bash
# ~/.ssh/config

Host *
    PasswordAuthentication no
    PubkeyAuthentication yes
    AddKeysToAgent yes
    IdentitiesOnly yes
```

---

## SSH 签名

YubiKey 不仅可以用于 SSH 认证，也可以用于 Git 提交签名（在 GIT_SSH_SIGNING_COMPLETE_GUIDE.md 中详细介绍）。

### 双用密钥配置

```bash
# 同一个 YubiKey 密钥可以用于：
# 1. SSH 认证（连接服务器）
# 2. SSH 签名（Git 提交签名）

# 配置 Git 使用 YubiKey 签名
git config --global user.signingkey ~/.ssh/main
git config --global gpg.format ssh
git config --global gpg.ssh.program /usr/bin/ssh-keygen
git config --global commit.gpgsign true

# 现在所有提交都会被签名
git commit -m "feature"

# 提示触摸 YubiKey
```

---

## Homeup 集成

### Homeup 中的 YubiKey 配置

```toml
# .chezmoi.toml.tmpl

[data]
    # 主签名/认证密钥
    signingkey = "~/.ssh/main-ssh.zopiya.com"

    # 备用密钥（如果主 YubiKey 损坏）
    backupsigningkey = "~/.ssh/back-ssh.zopiya.com"

    # 公钥（用于 GitHub/allowed_signers）
    signingkey_pub = "sk-ssh-ed25519@... main-ssh.zopiya.com"
    backupsigningkey_pub = "sk-ssh-ed25519@... back-ssh.zopiya.com"
```

### 配置 SSH 使用 YubiKey

```bash
# ~/.ssh/config （由 Homeup 管理）

Host *
    # 使用 Homeup 配置的 YubiKey 密钥
    IdentityFile ~/.ssh/main-ssh.zopiya.com
    IdentityFile ~/.ssh/back-ssh.zopiya.com
    AddKeysToAgent yes
```

### 启用 YubiKey 密钥

```bash
# Homeup 提供的快捷函数
yk
# 或标准 SSH 命令
ssh-add -K
```

---

## 安全最佳实践

### 双密钥策略

```
主 YubiKey（日常使用）
├─ 主要的 SSH 认证密钥
├─ Git 签名密钥
└─ GitHub 访问

备用 YubiKey（灾难恢复）
├─ 备份的 SSH 认证密钥
├─ Git 签名密钥
└─ 存储在安全位置
```

**为什么两个密钥？**

```
场景：主 YubiKey 丢失或损坏
┌─ 立即切换到备用 YubiKey
├─ 继续工作，不中断
├─ 有时间撤销主 YubiKey 公钥
└─ 订购新的主 YubiKey
```

### 访问控制

```bash
# 1. 设置 YubiKey PIN（强制用户验证）
ykman fido2 set-pin

# 2. 设置触摸要求（防止自动化）
# （YubiKey 驻留密钥默认启用）

# 3. 限制应用范围
# 在密钥生成中指定 application
ssh-keygen -t ed25519-sk \
  -O application=ssh:myservice \
  ...

# 这样密钥仅在指定的应用中有效
```

### 公钥安全

```bash
# ✅ 安全做法：分享公钥
cat ~/.ssh/main.pub
# sk-ssh-ed25519@openssh.com AAAA...

# ❌ 危险：分享任何包含 "PRIVATE" 的文件
cat ~/.ssh/main
# -----BEGIN OPENSSH PRIVATE KEY-----
```

### 定期审计

```bash
# 定期检查 GitHub 授权的密钥
# GitHub → Settings → SSH and GPG keys

# 定期检查 Git 签名验证
git log --show-signature

# 定期测试 YubiKey 功能
ykman fido2 info

# 如果看不到密钥，YubiKey 可能有问题
ssh-add -l
```

---

## 灾难恢复

### 主 YubiKey 丢失

```bash
# 1. 立即在 GitHub 撤销丢失的公钥
# GitHub → Settings → SSH Keys → Delete

# 2. 插入备用 YubiKey
# （假设事先配置了备用）

# 3. 更新配置
git config --global user.signingkey ~/.ssh/back-ssh.zopiya.com

# 4. 继续工作
git clone ...
git push ...

# 5. 订购新的 YubiKey
# 6. 生成新的密钥对
# 7. 添加到 GitHub
# 8. 更新 Homeup 配置
```

### 两个 YubiKey 都丢失

```bash
# 最坏情况：无法访问任何需要 SSH 的服务

# 恢复步骤：
# 1. 购买新 YubiKey
# 2. 用备用认证方式访问 GitHub（PAT、OAuth）
# 3. 生成新 SSH 密钥
# 4. 添加到 GitHub
# 5. 恢复访问权限

# 预防：
# - 在安全位置备份公钥（不是私钥）
# - 在 GitHub 中保有备用的 PAT（Personal Access Token）
# - 在 1Password 等密码管理器中记录恢复步骤
```

### 备份策略

```bash
# ✅ 安全的备份方式

# 1. 备份公钥（可以安全分享）
cat ~/.ssh/main.pub > ~/backups/ssh-main-pub.txt

# 2. 保存恢复说明
cat > ~/backups/yubikey-recovery.md <<'EOF'
# YubiKey 恢复说明

## 主 YubiKey 丢失
1. 撤销 GitHub 上的公钥
2. 使用备用 YubiKey
3. git config --global user.signingkey ~/.ssh/back-ssh.zopiya.com

## 两个都丢失
1. 使用 GitHub 的 PAT 访问（保存在 1Password）
2. 订购新 YubiKey
3. 生成新密钥
4. 添加到 GitHub
EOF

# ❌ 绝不做这些
# 不要备份私钥文件
# 不要备份到云盘（Google Drive、iCloud）
# 不要通过邮件发送密钥
```

---

## 故障排除

### ❓ YubiKey 无响应

**问题**:

```
$ ssh github.com
Verify your identity using YubiKey
Touch YubiKey...
# 等待但没有响应
```

**解决**:

```bash
# 1. 检查 YubiKey 物理连接
# - 重新插拔
# - 尝试 USB 的其他端口

# 2. 重新加载密钥
ssh-add -D
ssh-add -K

# 3. 检查 YubiKey 状态
ykman info

# 4. 重试 SSH
ssh -v github.com
# -v 显示详细信息，有助于诊断
```

### ❓ "agent refused operation"

**原因**: SSH Agent 无法使用 YubiKey 密钥

**解决**:

```bash
# 1. 确保 SSH Agent 运行
ssh-add -l

# 2. 确保 YubiKey 已加载
ssh-add -K

# 3. 检查密钥兼容性
ssh -V
# 必须是 8.2+

# 4. 重启 SSH Agent
killall ssh-agent
eval "$(ssh-agent)"
ssh-add -K
```

### ❓ 无法生成 SK 密钥

**问题**: `ssh-keygen: invalid format` 或 `unsupported key type`

**原因**:

```
❌ OpenSSH 版本过旧（需要 8.2+）
❌ YubiKey 不支持 FIDO2
❌ 硬件固件过旧
```

**解决**:

```bash
# 1. 升级 OpenSSH
brew upgrade openssh
ssh -V

# 2. 升级 YubiKey 固件
ykman fido2 reset --force

# 3. 尝试备选方式
ssh-keygen -t ecdsa-sk ...
```

### ❓ Git 签名时 YubiKey 无响应

**问题**:

```
$ git commit -m "message"
# 没有看到触摸提示
error: gpg failed to sign the data
```

**解决**:

```bash
# 1. 检查 Git 配置
git config user.signingkey
# 应输出: ~/.ssh/main

# 2. 重新加载 YubiKey
ssh-add -K

# 3. 手动测试签名
ssh-keygen -Y sign -f ~/.ssh/main -I user@example.com <<< "test"

# 4. 重试 commit
git commit -m "message"
```

---

## 总结与参考

| 方面 | 最佳实践 |
|------|---------|
| **硬件** | YubiKey 5 Series（USB-A）或 5C（USB-C） |
| **密钥类型** | Ed25519-SK 驻留密钥 |
| **密钥数量** | 两个（主 + 备用） |
| **密钥存储** | 主用于日常，备用存储安全位置 |
| **访问控制** | 启用 PIN + 触摸验证 |
| **配置备份** | 备份公钥和恢复步骤（不备份私钥） |
| **定期审计** | 每月检查 GitHub 授权的密钥 |
| **灾难恢复** | 保存 GitHub PAT 作为应急方案 |

### 核心命令速查

```bash
# YubiKey 管理
ykman info                  # YubiKey 信息
ykman fido2 info            # FIDO2 信息
ykman fido2 set-pin         # 设置 PIN
ykman fido2 reset --force   # 重置 YubiKey

# 密钥生成
ssh-keygen -t ed25519-sk -O resident \
  -f ~/.ssh/main

# 密钥管理
ssh-add -K                  # 加载驻留密钥
ssh-add -l                  # 列出已加载密钥
ssh-add -D                  # 清除所有密钥

# 测试和验证
ssh -T git@github.com       # 测试 GitHub 连接
ssh-keygen -y -f ~/.ssh/main # 导出公钥
ssh-keygen -Y verify -f ~/.ssh/allowed_signers # 验证签名
```

---

## 参考资源

- [YubiKey 官网](https://www.yubico.com/)
- [YubiKey 开发文档](https://developers.yubico.com/SSH/)
- [YubiKey Manager](https://www.yubico.com/products/yubico-security-key/)
- [OpenSSH FIDO/U2F 支持](https://man.openbsd.org/ssh-keygen)
- [FIDO2 标准](https://fidoalliance.org/fido2/)
- [Homeup Git SSH Signing Guide](GIT_SSH_SIGNING_COMPLETE_GUIDE.md)
- [Homeup SSH 配置](../private_dot_ssh/config.tmpl)
