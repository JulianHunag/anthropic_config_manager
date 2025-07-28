# ANTHROPIC API 配置管理器

一个用于 macOS 的交互式 ANTHROPIC API 配置管理工具，支持多配置管理、自动备份和环境变量切换。

## 功能特性

- 🔧 **多配置管理** - 支持添加、删除、切换多个 API 配置
- ✏️ **配置编辑** - 支持编辑现有配置的名称、Token 和 URL
- 🔄 **一键切换** - 快速在不同的 API 配置之间切换
- 📦 **自动备份** - 自动备份 .zshrc 文件，支持备份管理
- 🌐 **环境变量管理** - 自动更新 ANTHROPIC_AUTH_TOKEN 和 ANTHROPIC_BASE_URL
- 📋 **配置查看** - 查看所有配置和当前激活的配置
- 🗑️ **清理工具** - 智能清理旧备份文件

## 系统要求

- macOS 系统
- Bash shell
- Zsh (使用 ~/.zshrc 配置文件)

## 安装与使用

### 快速开始

#### 方法一：一键使用（推荐）
直接下载并运行脚本：
```bash
curl -fsSL https://raw.githubusercontent.com/JulianHunag/anthropic_config_manager/refs/heads/main/anthropic_config.sh | bash
```

#### 方法二：本地安装
1. 下载脚本到本地：
```bash
git clone git@github.com:JulianHunag/anthropic_config_manager.git
cd anthropic_config_manager
```

2. 运行配置管理器：
```bash
bash anthropic_config.sh
```

### 主要功能

#### 1. 添加新配置
选择菜单选项 `4. ➕ 添加新配置`，输入：
- 配置名称（如：openai_proxy）
- API Token
- Base URL

#### 2. 编辑配置
选择菜单选项 `5. ✏️ 编辑配置`，可以对现有配置进行修改：
- **编辑 Token** - 更新 API Token
- **编辑 URL** - 更新 Base URL
- **编辑配置名称** - 重命名配置
- **编辑全部信息** - 一次性更新所有配置信息

如果编辑的是当前激活的配置，系统会自动更新 .zshrc 文件并重新加载环境变量。

#### 3. 切换配置
选择菜单选项 `3. 🔄 切换配置`，从列表中选择要激活的配置。

#### 4. 查看配置
- `1. 📋 查看所有配置` - 显示所有配置及其状态
- `2. 🔍 查看当前激活配置` - 显示当前生效的配置

#### 5. 删除配置
选择菜单选项 `6. 🗑️ 删除配置`，从列表中选择要删除的配置。

#### 6. 管理备份
选择菜单选项 `7. 🗂️ 管理备份文件`，支持：
- 按时间清理旧备份
- 保留指定数量的最新备份
- 手动选择删除特定备份

## 配置文件格式

配置信息存储在 `~/.anthropic_configs` 文件中，格式如下：

```ini
[配置名称]
token=your_api_token_here
url=your_base_url_here
active=true/false
```

## 环境变量

脚本会在 `~/.zshrc` 中设置以下环境变量：

```bash
export ANTHROPIC_AUTH_TOKEN=你的API令牌
export ANTHROPIC_BASE_URL=你的基础URL
```

## 备份策略

- 每次切换配置前自动创建 .zshrc 备份
- 备份文件命名格式：`.zshrc.backup_YYYYMMDD_HHMMSS`
- 自动保留最新 5 个备份文件
- 支持按时间或数量清理旧备份

## 使用场景

### 场景1：开发环境切换
在不同的开发环境（测试、生产）之间快速切换 API 配置。

### 场景2：多账户管理
管理多个 ANTHROPIC 账户的 API 配置，避免频繁手动修改。

### 场景3：代理服务器切换
在直连和代理服务器之间切换，适应不同的网络环境。

## 注意事项

- 脚本会修改 `~/.zshrc` 文件，建议使用前备份
- 配置切换后需要重新启动终端或执行 `source ~/.zshrc`
- API Token 等敏感信息存储在本地文件中，请注意文件权限安全
- 仅支持 Zsh shell，其他 shell 需要手动适配

## 故障排除

### 常见问题

**Q: 切换配置后环境变量没有生效？**
A: 请重新启动终端或执行 `source ~/.zshrc`

**Q: 无法找到 .zshrc 文件？**
A: 确保使用的是 Zsh shell，并且 `~/.zshrc` 文件存在

**Q: 配置文件损坏？**
A: 可以删除 `~/.anthropic_configs` 文件，脚本会自动重新创建
