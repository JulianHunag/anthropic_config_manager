#!/bin/bash

# ANTHROPIC API Interactive Configuration Manager for macOS
# Author: macOS Bash Expert
# Version: 2.0
# Description: Interactive management of ANTHROPIC API configurations

set -euo pipefail

# Configuration files
CONFIG_FILE="$HOME/.anthropic_configs"
ZSHRC_FILE="$HOME/.zshrc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    clear
    print_color "$CYAN" "=================================="
    print_color "$CYAN" " ANTHROPIC API配置管理器"
    print_color "$CYAN" "=================================="
    echo
}

# Create config file if it doesn't exist
ensure_config_file() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << 'EOF'
# ANTHROPIC API Configurations
# Format: [config_name]
# token=your_token_here
# url=your_base_url_here
# active=true/false
EOF
        print_color "$YELLOW" "配置文件已创建: $CONFIG_FILE"
    fi
}

# Read all configurations from config file
read_configs() {
    local configs=()
    local current_config=""
    local token=""
    local url=""
    local active="false"
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            # Save previous config if exists
            if [[ -n "$current_config" ]]; then
                configs+=("$current_config|$token|$url|$active")
            fi
            # Start new config
            current_config="${BASH_REMATCH[1]}"
            token=""
            url=""
            active="false"
        elif [[ "$line" =~ ^token=(.+)$ ]]; then
            token="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^url=(.+)$ ]]; then
            url="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^active=(.+)$ ]]; then
            active="${BASH_REMATCH[1]}"
        fi
    done < "$CONFIG_FILE"
    
    # Save last config
    if [[ -n "$current_config" ]]; then
        configs+=("$current_config|$token|$url|$active")
    fi
    
    printf '%s\n' "${configs[@]}"
}

# List all configurations
list_configs() {
    print_header
    print_color "$BLUE" "📋 当前所有配置："
    echo "----------------------------------------"
    
    local configs=($(read_configs))
    local count=0
    
    for config in "${configs[@]}"; do
        if [[ -n "$config" ]]; then
            IFS='|' read -r name token url active <<< "$config"
            count=$((count + 1))
            
            local status_color="$YELLOW"
            local status_text="未激活"
            if [[ "$active" == "true" ]]; then
                status_color="$GREEN"
                status_text="✅ 当前激活"
            fi
            
            echo -e "${BOLD}$count. $name${NC}"
            echo -e "   Token: ${token:0:20}..."
            echo -e "   URL: $url"
            echo -e "   状态: ${status_color}$status_text${NC}"
            echo
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        print_color "$YELLOW" "❌ 没有找到任何配置"
    else
        print_color "$BLUE" "总计: $count 个配置"
    fi
    
    echo
    read -p "按回车键继续..." 
}

# Show current active configuration
show_current() {
    print_header
    print_color "$BLUE" "🔍 当前激活的配置："
    echo "----------------------------------------"
    
    local configs=($(read_configs))
    local found=false
    
    for config in "${configs[@]}"; do
        if [[ -n "$config" ]]; then
            IFS='|' read -r name token url active <<< "$config"
            if [[ "$active" == "true" ]]; then
                echo -e "${GREEN}✅ 配置名称: $name${NC}"
                echo -e "${GREEN}🔑 Token: $token${NC}"
                echo -e "${GREEN}🌐 URL: $url${NC}"
                found=true
                break
            fi
        fi
    done
    
    if [[ "$found" == false ]]; then
        print_color "$YELLOW" "❌ 没有激活的配置"
    fi
    
    echo
    read -p "按回车键继续..."
}

# Switch configuration
switch_config() {
    print_header
    print_color "$BLUE" "🔄 切换配置："
    echo "----------------------------------------"
    
    local configs=($(read_configs))
    local count=0
    local config_names=()
    
    # Display numbered list
    for config in "${configs[@]}"; do
        if [[ -n "$config" ]]; then
            IFS='|' read -r name token url active <<< "$config"
            count=$((count + 1))
            config_names+=("$name")
            
            local status=""
            if [[ "$active" == "true" ]]; then
                status=" ${GREEN}(当前激活)${NC}"
            fi
            
            echo -e "$count. $name${status}"
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        print_color "$RED" "❌ 没有可用的配置"
        read -p "按回车键继续..."
        return
    fi
    
    echo
    echo "0. 返回主菜单"
    echo
    
    while true; do
        read -p "请选择要激活的配置 (0-$count): " choice
        
        if [[ "$choice" == "0" ]]; then
            return
        elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [[ $choice -le $count ]]; then
            local selected_name="${config_names[$((choice-1))]}"
            
            # Backup .zshrc
            backup_zshrc
            
            # Update config file - set all to inactive, then activate selected
            update_config_active "$selected_name" "true"
            
            # Update .zshrc
            update_zshrc_config "$selected_name"
            
            print_color "$GREEN" "✅ 已切换到配置: $selected_name"
            source_zshrc
            break
        else
            print_color "$RED" "❌ 无效选择，请输入 0-$count 之间的数字"
        fi
    done
    
    echo
    read -p "按回车键继续..."
}

# Add new configuration
add_config() {
    print_header
    print_color "$BLUE" "➕ 添加新配置："
    echo "----------------------------------------"
    
    echo
    read -p "请输入配置名称 (如: openai_proxy): " name
    
    if [[ -z "$name" ]]; then
        print_color "$RED" "❌ 配置名称不能为空"
        read -p "按回车键继续..."
        return
    fi
    
    # Check if name already exists
    local configs=($(read_configs))
    for config in "${configs[@]}"; do
        if [[ -n "$config" ]]; then
            IFS='|' read -r existing_name token url active <<< "$config"
            if [[ "$existing_name" == "$name" ]]; then
                print_color "$RED" "❌ 配置名称 '$name' 已存在"
                read -p "按回车键继续..."
                return
            fi
        fi
    done
    
    read -p "请输入API Token: " token
    if [[ -z "$token" ]]; then
        print_color "$RED" "❌ Token不能为空"
        read -p "按回车键继续..."
        return
    fi
    
    read -p "请输入Base URL: " url
    if [[ -z "$url" ]]; then
        print_color "$RED" "❌ URL不能为空"
        read -p "按回车键继续..."
        return
    fi
    
    # Add to config file
    cat >> "$CONFIG_FILE" << EOF

[$name]
token=$token
url=$url
active=false
EOF
    
    print_color "$GREEN" "✅ 配置 '$name' 已成功添加"
    echo
    read -p "按回车键继续..."
}

# Delete configuration
delete_config() {
    print_header
    print_color "$BLUE" "🗑️  删除配置："
    echo "----------------------------------------"
    
    local configs=($(read_configs))
    local count=0
    local config_names=()
    
    # Display numbered list
    for config in "${configs[@]}"; do
        if [[ -n "$config" ]]; then
            IFS='|' read -r name token url active <<< "$config"
            count=$((count + 1))
            config_names+=("$name")
            
            local status=""
            if [[ "$active" == "true" ]]; then
                status=" ${GREEN}(当前激活)${NC}"
            fi
            
            echo -e "$count. $name${status}"
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        print_color "$RED" "❌ 没有可删除的配置"
        read -p "按回车键继续..."
        return
    fi
    
    echo
    echo "0. 返回主菜单"
    echo
    
    while true; do
        read -p "请选择要删除的配置 (0-$count): " choice
        
        if [[ "$choice" == "0" ]]; then
            return
        elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [[ $choice -le $count ]]; then
            local selected_name="${config_names[$((choice-1))]}"
            
            echo
            print_color "$YELLOW" "⚠️  确定要删除配置 '$selected_name' 吗?"
            read -p "输入 'yes' 确认删除: " confirm
            
            if [[ "$confirm" == "yes" ]]; then
                remove_config_from_file "$selected_name"
                print_color "$GREEN" "✅ 配置 '$selected_name' 已删除"
            else
                print_color "$BLUE" "❌ 删除操作已取消"
            fi
            break
        else
            print_color "$RED" "❌ 无效选择，请输入 0-$count 之间的数字"
        fi
    done
    
    echo
    read -p "按回车键继续..."
}

# Update configuration active status
update_config_active() {
    local target_name="$1"
    local new_active="$2"
    
    local temp_file=$(mktemp)
    local current_config=""
    local in_target=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            current_config="${BASH_REMATCH[1]}"
            in_target=false
            if [[ "$current_config" == "$target_name" ]]; then
                in_target=true
            fi
            echo "$line" >> "$temp_file"
        elif [[ "$line" =~ ^active= ]]; then
            if [[ "$in_target" == true ]]; then
                echo "active=$new_active" >> "$temp_file"
            else
                echo "active=false" >> "$temp_file"
            fi
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$CONFIG_FILE"
    
    mv "$temp_file" "$CONFIG_FILE"
}

# Remove configuration from file
remove_config_from_file() {
    local target_name="$1"
    local temp_file=$(mktemp)
    local current_config=""
    local skip_section=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            current_config="${BASH_REMATCH[1]}"
            if [[ "$current_config" == "$target_name" ]]; then
                skip_section=true
                continue
            else
                skip_section=false
            fi
        fi
        
        if [[ "$skip_section" == false ]]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$CONFIG_FILE"
    
    mv "$temp_file" "$CONFIG_FILE"
}

# Update .zshrc with selected configuration
update_zshrc_config() {
    local config_name="$1"
    local configs=($(read_configs))
    local target_token=""
    local target_url=""
    
    # Find the configuration
    for config in "${configs[@]}"; do
        if [[ -n "$config" ]]; then
            IFS='|' read -r name token url active <<< "$config"
            if [[ "$name" == "$config_name" ]]; then
                target_token="$token"
                target_url="$url"
                break
            fi
        fi
    done
    
    if [[ -z "$target_token" ]]; then
        print_color "$RED" "❌ 配置 '$config_name' 未找到"
        return 1
    fi
    
    # Remove all ANTHROPIC related content from .zshrc (exports and comments)
    local temp_file=$(mktemp)
    awk '
    /^# ANTHROPIC API Configuration/ { skip = 1; next }
    /^export ANTHROPIC_/ { skip = 1; next }
    skip && /^$/ { skip = 0; next }
    !skip { print }
    ' "$ZSHRC_FILE" > "$temp_file"
    
    # Add new configuration block at the end
    cat >> "$temp_file" << EOF

# ANTHROPIC API Configuration - $config_name
export ANTHROPIC_AUTH_TOKEN=$target_token
export ANTHROPIC_BASE_URL=$target_url
EOF
    
    mv "$temp_file" "$ZSHRC_FILE"
}

# List backup files
list_backup_files() {
    local backups=($(ls -t "${ZSHRC_FILE}.backup_"* 2>/dev/null || true))
    printf '%s\n' "${backups[@]}"
}

# Clean old backups (keep only the most recent N files)
clean_old_backups() {
    local keep_count="${1:-5}"  # Default keep 5 most recent backups
    local backups=($(list_backup_files))
    local total=${#backups[@]}
    
    if [[ $total -le $keep_count ]]; then
        return 0
    fi
    
    # Remove old backups (keep most recent ones)
    for ((i=$keep_count; i<$total; i++)); do
        rm -f "${backups[i]}"
        print_color "$YELLOW" "🗑️  已删除旧备份: $(basename ${backups[i]})"
    done
}

# Backup .zshrc file with smart retention
backup_zshrc() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${ZSHRC_FILE}.backup_${timestamp}"
    cp "$ZSHRC_FILE" "$backup_file"
    print_color "$BLUE" "📦 备份已创建: $backup_file"
    
    # Clean old backups automatically (keep 5 most recent)
    clean_old_backups 5
}

# Manage backup files
manage_backups() {
    print_header
    print_color "$BLUE" "🗂️  备份文件管理："
    echo "----------------------------------------"
    
    local backups=($(list_backup_files))
    local total=${#backups[@]}
    
    if [[ $total -eq 0 ]]; then
        print_color "$YELLOW" "❌ 没有找到备份文件"
        echo
        read -p "按回车键继续..."
        return
    fi
    
    echo "当前备份文件 (按时间倒序):"
    echo
    
    for ((i=0; i<$total; i++)); do
        local backup_file="${backups[i]}"
        local basename_file=$(basename "$backup_file")
        local file_date=$(echo "$basename_file" | sed 's/.*backup_//' | sed 's/\(.*\)_\(.*\)/\1 \2/')
        local file_size=$(ls -lh "$backup_file" | awk '{print $5}')
        
        # Calculate age
        local backup_timestamp=$(echo "$basename_file" | sed 's/.*backup_//' | sed 's/_//')
        local current_timestamp=$(date +"%Y%m%d%H%M%S")
        local age_seconds=$(( (current_timestamp - backup_timestamp) ))
        local age_days=$(( age_seconds / 1000000 )) # Rough calculation
        
        echo "$((i+1)). $basename_file"
        echo "   时间: $file_date"
        echo "   大小: $file_size"
        if [[ $age_days -gt 0 ]]; then
            echo "   年龄: ${age_days}天前"
        else
            echo "   年龄: 今天"
        fi
        echo
    done
    
    echo "管理选项:"
    echo "1. 删除7天以前的备份"
    echo "2. 删除1天以前的备份" 
    echo "3. 只保留最新5个备份"
    echo "4. 只保留最新3个备份"
    echo "5. 手动选择删除"
    echo "0. 返回主菜单"
    echo
    
    while true; do
        read -p "请选择操作 (0-5): " choice
        
        case "$choice" in
            0)
                return
                ;;
            1)
                cleanup_backups_by_age 7
                break
                ;;
            2)
                cleanup_backups_by_age 1
                break
                ;;
            3)
                clean_old_backups 5
                print_color "$GREEN" "✅ 已保留最新5个备份"
                break
                ;;
            4)
                clean_old_backups 3
                print_color "$GREEN" "✅ 已保留最新3个备份"
                break
                ;;
            5)
                manual_delete_backups
                break
                ;;
            *)
                print_color "$RED" "❌ 无效选择，请输入 0-5"
                ;;
        esac
    done
    
    echo
    read -p "按回车键继续..."
}

# Clean backups by age (days)
cleanup_backups_by_age() {
    local days_ago="$1"
    local cutoff_date=$(date -v-${days_ago}d +"%Y%m%d%H%M%S" 2>/dev/null || date -d "-${days_ago} days" +"%Y%m%d%H%M%S" 2>/dev/null)
    
    if [[ -z "$cutoff_date" ]]; then
        print_color "$RED" "❌ 无法计算日期，请手动删除"
        return
    fi
    
    local backups=($(list_backup_files))
    local deleted_count=0
    
    for backup_file in "${backups[@]}"; do
        local basename_file=$(basename "$backup_file")
        local backup_timestamp=$(echo "$basename_file" | sed 's/.*backup_//' | sed 's/_//')
        
        if [[ "$backup_timestamp" < "$cutoff_date" ]]; then
            rm -f "$backup_file"
            print_color "$YELLOW" "🗑️  已删除: $basename_file"
            deleted_count=$((deleted_count + 1))
        fi
    done
    
    if [[ $deleted_count -eq 0 ]]; then
        print_color "$BLUE" "ℹ️  没有找到${days_ago}天前的备份文件"
    else
        print_color "$GREEN" "✅ 已删除 $deleted_count 个${days_ago}天前的备份文件"
    fi
}

# Manual delete specific backups
manual_delete_backups() {
    local backups=($(list_backup_files))
    local total=${#backups[@]}
    
    if [[ $total -eq 0 ]]; then
        print_color "$YELLOW" "❌ 没有备份文件可删除"
        return
    fi
    
    echo
    echo "选择要删除的备份文件 (多个选择用空格分隔, 如: 1 3 5):"
    echo
    
    for ((i=0; i<$total; i++)); do
        local backup_file="${backups[i]}"
        local basename_file=$(basename "$backup_file")
        echo "$((i+1)). $basename_file"
    done
    
    echo
    echo "0. 取消删除"
    echo
    
    read -p "请输入要删除的序号: " selections
    
    if [[ "$selections" == "0" || -z "$selections" ]]; then
        print_color "$BLUE" "❌ 删除操作已取消"
        return
    fi
    
    # Parse selections
    local to_delete=()
    for selection in $selections; do
        if [[ "$selection" =~ ^[1-9][0-9]*$ ]] && [[ $selection -le $total ]]; then
            to_delete+=("${backups[$((selection-1))]}")
        else
            print_color "$RED" "❌ 无效选择: $selection"
            return
        fi
    done
    
    # Confirm deletion
    echo
    print_color "$YELLOW" "⚠️  确定要删除以下备份文件吗?"
    for file in "${to_delete[@]}"; do
        echo "   - $(basename "$file")"
    done
    echo
    read -p "输入 'yes' 确认删除: " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        for file in "${to_delete[@]}"; do
            rm -f "$file"
            print_color "$YELLOW" "🗑️  已删除: $(basename "$file")"
        done
        print_color "$GREEN" "✅ 删除完成"
    else
        print_color "$BLUE" "❌ 删除操作已取消"
    fi
}

# Source .zshrc file
source_zshrc() {
    print_color "$GREEN" "🔄 正在重新加载 ~/.zshrc..."
    source "$ZSHRC_FILE" 2>/dev/null || true
    print_color "$GREEN" "✅ 配置已重新加载!"
}

# Main menu
show_menu() {
    print_header
    print_color "$BOLD" "请选择操作："
    echo
    echo "1. 📋 查看所有配置"
    echo "2. 🔍 查看当前激活配置"  
    echo "3. 🔄 切换配置"
    echo "4. ➕ 添加新配置"
    echo "5. 🗑️  删除配置"
    echo "6. 🗂️  管理备份文件"
    echo "7. 🚪 退出"
    echo
}

# Main function
main() {
    # Check if .zshrc exists
    if [[ ! -f "$ZSHRC_FILE" ]]; then
        print_color "$RED" "❌ 错误: ~/.zshrc 文件不存在"
        exit 1
    fi
    
    # Ensure config file exists
    ensure_config_file
    
    while true; do
        show_menu
        read -p "请输入选择 (1-7): " choice
        
        case "$choice" in
            1)
                list_configs
                ;;
            2)
                show_current
                ;;
            3)
                switch_config
                ;;
            4)
                add_config
                ;;
            5)
                delete_config
                ;;
            6)
                manage_backups
                ;;
            7)
                print_color "$GREEN" "👋 再见!"
                exit 0
                ;;
            *)
                print_color "$RED" "❌ 无效选择，请输入 1-7"
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@"