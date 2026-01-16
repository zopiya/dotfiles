# Git SSH Signing Complete Guide: Cryptographic Commit Authentication

> Modern Git signing using SSH keys and YubiKey FIDO2: Simpler than GPG, stronger than passwords

**版本**: 1.0
**目标受众**: DevOps 工程师、安全管理员、开发者
**前置知识**: Git 基础、SSH 基础、YubiKey 或 SSH 密钥相关知识

---

## 目录

- [核心概念](#核心概念)
- [快速开始](#快速开始)
- [架构详解](#架构详解)
- [密钥管理](#密钥管理)
- [YubiKey 集成](#yubikey-集成)
- [签名验证](#签名验证)
- [GitHub/GitLab 配置](#githubgitlab-配置)
- [故障排除](#故障排除)
- [总结与最佳实践](#总结与最佳实践)

---

## 核心概念

### 为什么用 SSH 签名替代 GPG？

**传统 GPG 方案的问题**:

```
❌ GPG 方案
├── 复杂的密钥环管理
├── 信任链维护困难
├── 子密钥、主密钥、吊销证书繁琐
├── SSH 代理转发时无法使用（需要特殊配置）
└── 在容器/远程环境中部署复杂

✅ SSH 签名方案
├── SSH 密钥简单（单一用途）
├── 已有 SSH 基础设施（GitHub/GitLab 支持）
├── FIDO2 YubiKey 原生支持
├── 无需生成、导入、刷新吊销证书
├── SSH 代理转发完全透明
└── CI/CD 环境中无缝工作
```

### SSH 签名架构

```
YubiKey (FIDO2 硬件密钥)
    ↓
ssh-keygen -Y sign (签名命令)
    ↓
签名内容 (二进制格式)
    ↓
~/.ssh/allowed_signers (公钥注册表)
    ↓
ssh-keygen -Y verify (验证命令)
    ↓
✅ / ❌ (验证结果)
```

### 关键术语

| 术语 | 含义 | 例子 |
|------|------|------|
| **SSH 签名密钥** | Git 提交签名使用的私钥 | `~/.ssh/main-ssh.zopiya.com` |
| **Public Key** | 签名密钥的公钥（需要发布） | `sk-ssh-ed25519@openssh.com AAAA...` |
| **allowed_signers** | 信任的公钥名单 | `~/.ssh/allowed_signers` |
| **YubiKey FIDO2** | 硬件安全密钥，生成 `sk-` 前缀的密钥 | 物理设备 |
| **Resident Key** | 存储在 YubiKey 上的密钥（可离线使用） | 推荐用于签名 |
| **sk-ssh-ed25519** | FIDO2 格式的 EdDSA 密钥 | Git 签名首选 |

> 💡 **核心优势**: SSH 签名使用的是你已经在用的 SSH 密钥，无需额外的密钥管理基础设施

---

## 快速开始

### ⚡ 5 分钟基础设置（无 YubiKey）

如果你还没有 YubiKey，可以用临时 SSH 密钥体验：

```bash
# 1. 生成 SSH 签名密钥（如还没有）
ssh-keygen -t ed25519 -f ~/.ssh/git-signing -C "signing-key" -N ""

# 2. 提取公钥
ssh-keygen -y -f ~/.ssh/git-signing > ~/.ssh/git-signing.pub

# 3. 配置 Git
git config --global user.signingkey ~/.ssh/git-signing
git config --global gpg.format ssh
git config --global gpg.ssh.program /usr/bin/ssh-keygen

# 4. 启用自动签名
git config --global commit.gpgsign true

# 5. 创建 allowed_signers
echo "$(git config user.email) $(cat ~/.ssh/git-signing.pub)" > ~/.ssh/allowed_signers

# 6. 验证配置
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

### ✅ 验证配置

```bash
# 测试提交签名
git commit --allow-empty -m "Test signed commit" -S

# 验证签名
git log --show-signature -1

# 输出应显示：
# gpg: Signature made ...
# gpg: using RSA key (or Ed25519 key)
# gpg: Good signature from "..."
```

### 🔧 Homeup 中的使用

Homeup 已预配置 YubiKey SSH 签名。只需：

```bash
# 1. 初始化 Homeup（包含 Git 配置）
just init

# 2. 加载 YubiKey 密钥
yk  # 自定义函数，等同于 ssh-add -K

# 3. 查看已加载的密钥
ssh-add -l

# 4. 开始提交（自动签名）
git commit -m "My commit"
```

---

## 架构详解

### Homeup 的三层 Git SSH 架构

#### 1. 配置层（.chezmoi.toml.tmpl）

```toml
[data]
    # 主签名密钥路径
    signingkey = "~/.ssh/main-ssh.zopiya.com"

    # 备用签名密钥路径
    backupsigningkey = "~/.ssh/back-ssh.zopiya.com"

    # 主密钥的公钥（含 YubiKey 标识）
    signingkey_pub = "key::sk-ssh-ed25519@openssh.com AAAA... main-ssh.zopiya.com"

    # 备用密钥的公钥
    backupsigningkey_pub = "key::sk-ssh-ed25519@openssh.com AAAA... back-ssh.zopiya.com"
```

**key:: 前缀含义**:
- `key::` = allowed_signers 格式的公钥字符串
- 包含完整的 FIDO2 标识符（`sk-ssh-ed25519@openssh.com`）
- 包含备注字段（`main-ssh.zopiya.com`）用于识别密钥来源

#### 2. Git 配置层（dot_config/git/config.tmpl）

```toml
[user]
    # 使用 .chezmoi.toml.tmpl 中定义的密钥路径
    signingkey = {{ .signingkey }}        # ~/.ssh/main-ssh.zopiya.com
    # signingkey = {{ .backupsigningkey }} # 备用（注释状态）

[commit]
    # 所有提交自动签名
    gpgsign = true
    verbose = true

[gpg]
    # 使用 SSH 而非 GPG
    format = ssh

[gpg "ssh"]
    # ssh-keygen 用于签名操作
    program = /usr/bin/ssh-keygen
    # allowed_signers 文件路径
    allowedSignersFile = ~/.ssh/allowed_signers
```

#### 3. 密钥注册层（private_dot_ssh/allowed_signers.tmpl）

```
# 主 YubiKey（主签名密钥）
{{ .email }} {{ .signingkey_pub }}

# 备用 YubiKey（备用签名密钥）
{{ .email }} {{ .backupsigningkey_pub }}
```

**Chezmoi 处理流程**:

```
.chezmoi.toml.tmpl (定义变量)
    ↓
config.tmpl (引用变量，如 {{ .signingkey }})
    ↓
allowed_signers.tmpl (注册公钥)
    ↓
最终文件：
  ~/.config/git/config       (已展开)
  ~/.ssh/allowed_signers     (已展开)
```

### Git 签名流程图

```
1. 创建提交
   $ git commit -m "message"

2. Git 调用签名
   git → ssh-keygen -Y sign \
              -f ~/.ssh/main-ssh.zopiya.com \
              -I <key-id> \
              <message-file>

3. YubiKey 处理（用户按键盘或触摸）
   YubiKey → 解锁 FIDO2 密钥 → 生成签名

4. 签名附加到 commit
   commit object = message + signature

5. 推送到 GitHub
   git push

6. GitHub 验证（可选）
   GitHub → ssh-keygen -Y verify \
               -f ~/.ssh/allowed_signers \
               -I <identity> \
               <signature>
   → ✅ 显示绿色 "Verified" 标记
```

---

## 密钥管理

### 两密钥策略

Homeup 推荐使用两个签名密钥：

```
主密钥 (main-ssh.zopiya.com)
├── 日常使用
├── 存储在主 YubiKey
└── GitHub 默认密钥

备用密钥 (back-ssh.zopiya.com)
├── 主 YubiKey 丢失/故障时使用
├── 存储在备用 YubiKey
└── GitHub 备用密钥
```

**为什么要两个密钥？**

```
场景 1: 主 YubiKey 丢失
  ❌ 如果只有一个密钥 → 无法签名
  ✅ 如果有备用密钥 → 快速切换

场景 2: YubiKey 损坏/无响应
  可能需要 1-2 周更换
  备用密钥保证业务连续性

场景 3: YubiKey 需要工厂重置
  重置前切换到备用
  重置后重新生成密钥
```

### 密钥切换

#### 场景：切换到备用密钥

```bash
# 1. 编辑 Git 配置
nvim ~/.config/git/config

# 2. 注释掉主密钥
# signingkey = ~/.ssh/main-ssh.zopiya.com

# 3. 取消注释备用密钥
signingkey = ~/.ssh/back-ssh.zopiya.com

# 4. 或直接使用 git config
git config --global user.signingkey ~/.ssh/back-ssh.zopiya.com

# 5. 验证
git config user.signingkey
# 输出: ~/.ssh/back-ssh.zopiya.com

# 6. 加载备用 YubiKey（触摸设备）
yk
```

#### 场景：使用 Chezmoi 管理密钥切换

```bash
# 1. 编辑 Chezmoi 配置
chezmoi edit-config

# 2. 修改 signingkey 值
[data]
    signingkey = "~/.ssh/back-ssh.zopiya.com"

# 3. 应用更改
chezmoi apply

# 4. Git 配置自动更新
git config user.signingkey
# 输出: ~/.ssh/back-ssh.zopiya.com
```

### 密钥生成和导入

#### 从 YubiKey 导出公钥

```bash
# 1. 确保 YubiKey 已连接并解锁
# 2. 导出主签名密钥的公钥
ssh-add -L | grep "main-ssh"
# 输出: sk-ssh-ed25519@openssh.com AAAA... main-ssh.zopiya.com

# 3. 导出备用密钥的公钥
ssh-add -L | grep "back-ssh"
# 输出: sk-ssh-ed25519@openssh.com AAAA... back-ssh.zopiya.com

# 4. 提取完整公钥（用于 allowed_signers）
# 格式: key::<公钥内容>
echo "key::$(ssh-add -L | grep 'main-ssh')" > ~/main-key.txt
```

#### 设置自己的 allowed_signers

```bash
# 1. 创建 allowed_signers 文件
touch ~/.ssh/allowed_signers

# 2. 添加主密钥
echo "your-email@example.com $(ssh-add -L | grep 'main-ssh')" >> ~/.ssh/allowed_signers

# 3. 添加备用密钥
echo "your-email@example.com $(ssh-add -L | grep 'back-ssh')" >> ~/.ssh/allowed_signers

# 4. 验证格式
cat ~/.ssh/allowed_signers

# 输出应为：
# your-email@example.com sk-ssh-ed25519@openssh.com AAAA... comment1
# your-email@example.com sk-ssh-ed25519@openssh.com AAAA... comment2

# 5. 配置 Git
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

---

## YubiKey 集成

### YubiKey 签名密钥生成

#### 前置条件

```bash
# 1. YubiKey Manager CLI
brew install yubikey-manager

# 2. OpenSSH 8.2+（支持 FIDO2）
ssh -V
# 输出应为: OpenSSH_X.X+, LibreSSL XXX（8.2 以上）

# 3. YubiKey 5 系列或更新版本
ykman --version
```

#### 生成 FIDO2 签名密钥（YubiKey 5.3+）

```bash
# 1. 在 YubiKey 上生成驻留密钥
ssh-keygen -t ecdsa-sk -O resident -O application=ssh:main-ssh-zopiya.com \
    -f ~/.ssh/main-ssh.zopiya.com \
    -C "main-ssh.zopiya.com" \
    -N ""

# 按 YubiKey 上的触摸按钮完成

# 输出：
# Generating public/private ecdsa-sk key pair.
# You may need to touch your YubiKey...
# Your identification has been saved in /Users/zopiya/.ssh/main-ssh.zopiya.com

# 2. 导出公钥
ssh-keygen -y -f ~/.ssh/main-ssh.zopiya.com > ~/.ssh/main-ssh.zopiya.com.pub

# 3. 查看公钥格式
cat ~/.ssh/main-ssh.zopiya.com.pub
# 输出: sk-ecdsa-sha2-nistp256@openssh.com AAAA... main-ssh.zopiya.com
```

#### 生成 Ed25519-SK（推荐，更快）

```bash
# Ed25519-SK 比 ECDSA-SK 签名更快
ssh-keygen -t ed25519-sk -O resident \
    -O application=ssh:main-ssh-zopiya.com \
    -f ~/.ssh/main-ssh.zopiya.com \
    -C "main-ssh.zopiya.com" \
    -N ""

# 生成的公钥格式：
# sk-ssh-ed25519@openssh.com AAAA... main-ssh.zopiya.com
```

### 加载和管理 YubiKey 密钥

#### 加载 YubiKey 驻留密钥

```bash
# 方法 1: ssh-add 加载所有驻留密钥
ssh-add -K
# 输出：
# FIDO2 device for key /Users/zopiya/.ssh/main-ssh.zopiya.com present
# Identity added: /Users/zopiya/.ssh/main-ssh.zopiya.com (main-ssh.zopiya.com)

# 方法 2: Homeup 快捷函数
yk
# （定义在 ~/.config/zsh/functions.zsh 中）

# 方法 3: 手动加载特定密钥
ssh-add ~/.ssh/main-ssh.zopiya.com
# 系统会提示触摸 YubiKey
```

#### 列出已加载的密钥

```bash
# 查看 SSH 代理中的所有密钥
ssh-add -l

# 输出示例：
# 256 SHA256:abc123... (FIDO2) main-ssh.zopiya.com (FIDO2 resident key)
# 256 SHA256:def456... (FIDO2) back-ssh.zopiya.com (FIDO2 resident key)
```

#### 清除 SSH 代理

```bash
# 清除所有加载的密钥
ssh-add -D

# 清除特定密钥
ssh-add -d ~/.ssh/main-ssh.zopiya.com
```

### YubiKey 签名流程

```bash
# 1. 创建提交（自动签名）
git commit -m "My changes"

# 2. Git 调用签名程序
/usr/bin/ssh-keygen -Y sign \
    -f ~/.ssh/main-ssh.zopiya.com \
    -I i@zopiya.com \
    <message>

# 3. 系统提示
# Touch FIDO2 device to sign

# 4. 用户触摸 YubiKey

# 5. 签名完成，提交成功

# 6. 查看签名
git log --show-signature -1
# 输出显示签名和 YubiKey 信息
```

### YubiKey 故障排除

```bash
# 问题 1: YubiKey 无响应
# 解决：重新插拔 YubiKey，重新加载

# 问题 2: 签名时超时
ssh-add -K  # 重新加载
git commit -m "retry"

# 问题 3: 忘记 YubiKey PIN
# 使用备用 YubiKey 或联系管理员重置

# 查看 YubiKey 状态
ykman info
```

---

## 签名验证

### 本地验证签名

```bash
# 1. 查看最近的提交（包含签名）
git log --show-signature -1

# 输出：
# commit abc123def456...
# gpg: Signature made Mon Jan 16 12:00:00 2026 UTC
# gpg: using RSA key (or ECDSA key)
# gpg: Good signature from "i@zopiya.com"
# Author: Zopiya <i@zopiya.com>
# Date:   Mon Jan 16 12:00:00 2026 +0000
#
#     My commit message

# 2. 验证特定提交
git verify-commit abc123def456

# 输出同上

# 3. 使用 ssh-keygen 直接验证（高级）
# Git 内部使用此命令
ssh-keygen -Y verify \
    -f ~/.ssh/allowed_signers \
    -I i@zopiya.com \
    -n "commit" \
    -s commit-signature-file
```

### allowed_signers 文件验证

```bash
# 查看文件格式
cat ~/.ssh/allowed_signers

# 应该显示：
# i@zopiya.com sk-ssh-ed25519@openssh.com AAAA... main-ssh.zopiya.com
# i@zopiya.com sk-ssh-ed25519@openssh.com AAAA... back-ssh.zopiya.com

# 问题诊断：
# 1. 公钥格式错误 → 签名验证失败
# 2. 缺少公钥 → 新 YubiKey 签名无法验证
# 3. 邮箱不匹配 → 身份验证失败
```

---

## GitHub/GitLab 配置

### 在 GitHub 上验证签名

#### 步骤 1：添加 SSH 公钥到 GitHub

```bash
# 1. 获取公钥
cat ~/.ssh/main-ssh.zopiya.com.pub

# 2. 访问 GitHub 账户设置
# https://github.com/settings/ssh/new

# 3. 新建密钥
# 标题: main-ssh.zopiya.com (signing key)
# 密钥类型: Signing key
# 公钥内容: 粘贴上面的公钥

# 4. 对备用密钥重复步骤 2-3
```

#### 步骤 2：设置签名政策（可选）

```bash
# 在仓库设置中启用签名要求：
# GitHub → Repository → Settings → Merge Button
# 勾选: Require signed commits (可选)
```

#### 步骤 3：验证 GitHub 上的签名

```bash
# GitHub 会自动验证：
# 1. 检查提交是否签名
# 2. 从 allowed_signers 验证公钥
# 3. 显示绿色 "Verified" 标记

# 如果看不到绿色标记，可能原因：
# - SSH 公钥未添加到 GitHub
# - 邮箱不匹配
# - 使用了错误的签名密钥
```

### 在 GitLab 上验证签名

```bash
# 1. 获取公钥
cat ~/.ssh/main-ssh.zopiya.com.pub

# 2. 访问 GitLab GPG 密钥设置
# https://gitlab.com/-/user_settings/gpg_keys

# 3. 添加 SSH 密钥（作为 GPG 密钥）
# GitLab 将识别为 SSH 签名密钥

# 4. 提交时使用 -S 标志
git commit -S -m "My commit"

# 5. GitLab 会显示 "Signed" 标记
```

---

## 故障排除

### ❓ 签名失败："Permission denied"

**问题**:
```
gpg: signing failed: Inappropriate ioctl for device
error: gpg failed to sign the data
```

**原因**: YubiKey 未加载或 SSH 代理不可用

**解决**:

```bash
# 1. 加载 YubiKey
ssh-add -K
# 或
yk

# 2. 验证密钥已加载
ssh-add -l

# 3. 重试提交
git commit -m "retry"

# 4. 如果仍失败，检查签名密钥路径
git config user.signingkey
# 应输出: ~/.ssh/main-ssh.zopiya.com

# 5. 检查密钥文件存在
ls -la ~/.ssh/main-ssh.zopiya.com
# 应该存在
```

### ❓ 签名时提示 "Touch FIDO2 device" 无响应

**问题**: 触摸 YubiKey 无反应

**解决**:

```bash
# 1. 检查 YubiKey 连接
# 物理检查 YubiKey 是否插入

# 2. 尝试重新插拔
unplug YubiKey
sleep 2
plug YubiKey back in

# 3. 重新加载
ssh-add -K

# 4. 再次提交
git commit -m "retry"
```

### ❓ GitHub 上签名显示 "Unverified"

**问题**: 提交显示灰色 "Unverified" 标记

**原因可能**:

```
1. SSH 公钥未添加到 GitHub
   → GitHub Settings → SSH Keys → 添加新密钥

2. 邮箱不匹配
   git config user.email  # 检查 Git 邮箱
   # 应与 GitHub 账户邮箱相同

3. 使用了不同的签名密钥
   git log --show-signature -1  # 检查哪个密钥签名
   # 确保该密钥已添加到 GitHub

4. allowed_signers 格式错误
   cat ~/.ssh/allowed_signers  # 检查格式
   # 应为: email sk-ssh-ed25519@... AAAA...
```

**修复步骤**:

```bash
# 1. 查看最近提交的签名信息
git log --show-signature -1

# 2. 从输出中找到使用的密钥
# "using ECDSA key" 或 "using Ed25519 key"

# 3. 查看对应的公钥
ssh-add -l | grep -E "main|back"

# 4. 添加该公钥到 GitHub
# GitHub → Settings → SSH and GPG keys → New SSH key

# 5. 等待 GitHub 刷新（通常立即）

# 6. 重新推送（或强制刷新 GitHub）
git push --force-with-lease
```

### ❓ 多个邮箱时的签名混乱

**问题**: 使用多个 Git 邮箱时，签名混乱

**解决**: 为每个邮箱添加 allowed_signers 条目

```bash
# allowed_signers 应包含：
personal-email@example.com sk-ssh-ed25519@... AAAA... main-ssh
work-email@company.com sk-ssh-ed25519@... AAAA... main-ssh

# Git 提交时指定邮箱
git -c user.email=work-email@company.com commit -m "work commit"

# 或全局配置
git config user.email work-email@company.com
```

### ❓ 在 SSH 转发的远程主机上签名

**问题**: 在远程服务器上 Git 提交，希望使用本地 YubiKey 签名

**解决**: SSH 代理转发

```bash
# 1. 本地配置 ~/.ssh/config
Host myserver
    HostName example.com
    User zopiya
    ForwardAgent yes  # 启用代理转发

# 2. 连接到远程
ssh myserver

# 3. 在远程验证代理
ssh-add -l
# 应显示本地的 YubiKey 密钥

# 4. 在远程提交（自动使用本地 YubiKey）
cd /path/to/repo
git commit -m "remote commit"

# 5. YubiKey 会提示触摸（即使在远程）
```

---

## 总结与最佳实践

| 方面 | 最佳实践 |
|------|---------|
| **密钥管理** | 使用两个签名密钥（主 + 备用），储存在两个 YubiKey 上 |
| **密钥类型** | Ed25519-SK 优于 ECDSA-SK（更快） |
| **驻留密钥** | 使用驻留密钥（Resident Key），离线可用 |
| **enabled** | 启用 commit.gpgsign，自动签名所有提交 |
| **allowed_signers** | 包含所有信任的公钥（主 + 备用 + 其他身份） |
| **GitHub/GitLab** | 将 SSH 签名密钥添加为 "Signing key"（不是 auth key） |
| **SSH 代理转发** | 在远程主机上启用 `ForwardAgent yes`（用于远程签名） |
| **备份** | 定期备份公钥到安全位置（不需要私钥） |

### 核心命令速查

```bash
# YubiKey 密钥加载
yk                      # 加载所有驻留密钥
ssh-add -K             # 等同于上面
ssh-add -l             # 列出已加载的密钥
ssh-add -D             # 清除所有密钥

# Git 签名配置
git config user.signingkey ~/.ssh/main-ssh...
git config commit.gpgsign true
git config gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
git config gpg.ssh.program /usr/bin/ssh-keygen

# 签名和验证
git commit -m "message"     # 自动签名（如果启用 gpgsign）
git commit -S -m "message"  # 强制签名
git log --show-signature    # 显示签名信息
git verify-commit <commit>  # 验证提交

# 密钥切换
git config user.signingkey ~/.ssh/back-ssh...  # 切换到备用
chezmoi edit-config                            # 或通过 Chezmoi
chezmoi apply                                   # 应用更改
```

---

## 参考资源

- [OpenSSH 文档](https://man.openbsd.org/ssh-keygen)
- [Git 签名文档](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [YubiKey 开发者指南](https://developers.yubico.com/SSH/)
- [Homeup Git 配置](../dot_config/git/config.tmpl)
- [Homeup SSH 配置](../private_dot_ssh/config.tmpl)
- [Homeup Chezmoi 配置](../.chezmoi.toml.tmpl)
- [YubiKey 5 系列](https://www.yubico.com/products/yubikey-5-series/)
