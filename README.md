# ANTHROPIC API 配置管理器

一个用于 macOS 的交互式 ANTHROPIC API 配置管理工具，支持多配置管理、自动备份和环境变量切换。

## 功能特性

- 🔧 **多配置管理** - 支持添加、删除、切换多个 API 配置
- ✏️ **配置编辑** - 支持编辑现有配置的名称、Token、URL 和模型字段
- 🔄 **一键切换** - 快速在不同的 API 配置之间切换
- 📦 **自动备份** - 自动备份 .zshrc 文件，支持备份管理
- 🌐 **环境变量管理** - 自动更新 ANTHROPIC_AUTH_TOKEN、ANTHROPIC_BASE_URL 和可选的模型环境变量
- 🤖 **模型配置** - 可选配置 ANTHROPIC_MODEL 和 ANTHROPIC_SMALL_FAST_MODEL
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
bash <(curl -fsSL https://raw.githubusercontent.com/JulianHunag/anthropic_config_manager/refs/heads/main/anthropic_config.sh)
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
- API Token（必填）
- Base URL（必填）
- Model（可选，直接回车跳过）
- Small Fast Model（可选，直接回车跳过）

#### 2. 编辑配置
选择菜单选项 `5. ✏️ 编辑配置`，可以对现有配置进行修改：
- **编辑 Token** - 更新 API Token
- **编辑 URL** - 更新 Base URL
- **编辑 Model** - 更新模型配置（可选）
- **编辑 Small Fast Model** - 更新小型快速模型配置（可选）
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
model=your_model_here (可选)
small_fast_model=your_small_fast_model_here (可选)
active=true/false
```

## 环境变量

脚本会在 `~/.zshrc` 中设置以下环境变量：

```bash
export ANTHROPIC_AUTH_TOKEN=你的API令牌
export ANTHROPIC_BASE_URL=你的基础URL
export ANTHROPIC_MODEL=你的模型 (如果配置了)
export ANTHROPIC_SMALL_FAST_MODEL=你的小型快速模型 (如果配置了)
```

**注意**：模型相关的环境变量只有在配置中设置了对应值时才会导出。

## 模型配置功能

### 新增模型字段
从 v2.0 版本开始，支持可选的模型配置字段：

- **ANTHROPIC_MODEL** - 主要使用的模型（如：claude-3-5-sonnet-20241022）
- **ANTHROPIC_SMALL_FAST_MODEL** - 小型快速模型（如：claude-3-haiku-20240307）

### 模型字段特点
- **完全可选** - 可以直接按回车跳过，不影响基本功能
- **智能导出** - 只有设置了值的字段才会导出到环境变量
- **独立编辑** - 可以单独编辑模型字段，无需修改其他配置
- **兼容现有配置** - 旧版本的配置会自动兼容新版本

### 使用建议
- 对于需要区分不同模型的应用场景，可以设置模型字段
- 如果只使用默认模型，可以跳过模型配置
- 模型字段支持任意字符串，根据实际需要填写

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

### 场景4：模型配置管理
针对不同的应用场景配置不同的模型，如：
- 开发环境使用快速模型节省成本
- 生产环境使用高性能模型保证质量
- 测试不同模型的效果和性能

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

**Q: 模型环境变量没有导出？**
A: 检查配置中对应的模型字段是否为空，只有非空值才会导出环境变量

**Q: 如何清除已设置的模型配置？**
A: 在编辑配置时，将模型字段设置为空值即可清除对应的环境变量
