# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a single-file bash script repository containing an interactive ANTHROPIC API configuration manager for macOS. The script (`anthropic_config.sh`) provides a complete configuration management system with the following core components:

- **Configuration Storage**: Uses `~/.anthropic_configs` file with INI-style format to store multiple API configurations
- **Shell Integration**: Manages ANTHROPIC environment variables in `~/.zshrc` 
- **Backup System**: Automatic backup and restoration of .zshrc with timestamp-based file management
- **Interactive CLI**: Chinese-language menu-driven interface for all operations

## Core Functionality

The script manages ANTHROPIC API configurations through these main operations:

1. **Configuration CRUD**: Add, list, switch, and delete API configurations
2. **Environment Management**: Updates `ANTHROPIC_AUTH_TOKEN` and `ANTHROPIC_BASE_URL` in .zshrc
3. **Backup Management**: Creates timestamped backups of .zshrc and provides cleanup utilities
4. **Active State Tracking**: Maintains which configuration is currently active

## Key Data Structures

- **Config File Format**: `[config_name]` sections with `token=`, `url=`, and `active=` fields
- **Configuration Array**: Internal format `name|token|url|active` for processing
- **Backup Naming**: `.zshrc.backup_YYYYMMDD_HHMMSS` format

## Development Commands

Run the script directly:
```bash
bash anthropic_config.sh
```

The script requires no build process, dependencies, or compilation. It's a standalone bash script that manages system configuration files.

## File Structure

- `anthropic_config.sh`: Main script containing all functionality
- No additional dependencies or configuration files needed
- Creates and manages `~/.anthropic_configs` and modifies `~/.zshrc`

## Configuration Management Pattern

The script uses a state machine approach where:
1. All configurations are stored with `active=false` except the current one
2. Switching configurations updates both the config file and .zshrc atomically
3. Backup operations happen before any destructive changes
4. The active configuration is the source of truth for environment variables