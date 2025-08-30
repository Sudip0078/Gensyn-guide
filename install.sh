#!/bin/bash

# ===========================
# COLORS
# ===========================
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[96m"
GREEN="\033[92m"
YELLOW="\033[93m"
RED="\033[91m"

# ===========================
# VARIABLES
# ===========================
REPO_URL="https://github.com/gensyn-ai/rl-swarm.git"
SWARM_DIR="$HOME/rl-swarm"
CONFIG_FILE="$SWARM_DIR/.swarm_config"
LOG_FILE="$HOME/swarm_log.txt"

# ===========================
# LOGGING FUNCTION
# ===========================
log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        INFO) color=$GREEN ;;
        WARN) color=$YELLOW ;;
        ERROR) color=$RED ;;
        *) color=$RESET ;;
    esac

    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
    echo -e "${color}$msg${RESET}"
}

# ===========================
# HEADER
# ===========================
show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "┌───────────────────────────────────────────────────────────────┐"
    echo "│    _____ ____  ________________  ____                         │"
    echo "│   / ___// __ \/ ____/ ____/ __ \/ __ \                        │"
    echo "│   \__ \/ /_/ / __/ / __/ / / / / / / /                        │"
    echo "│  ___/ / ____/ /___/ /___/ /_/ / /_/ /                         │"
    echo "│ /____/_/   /_____/_____/_____/\____/                          │"
    echo "└───────────────────────────────────────────────────────────────┘"
    echo -e " 🚀 Gensyn RL-Swarm Launcher by SPEEDO 🐈"
    echo -e "    Do not pspsssps 😼"
    echo -e " 💐 Theme: Electric Cyan 💐"
    echo -e "================================================================${RESET}"
}

# ===========================
# FUNCTIONS
# ===========================

install_node() {
    log INFO "📥 Cloning repo: $REPO_URL"
    if [ -d "$SWARM_DIR" ]; then
        log WARN "⚠️ Directory already exists. Pulling latest changes..."
        cd "$SWARM_DIR" && git pull
    else
        git clone "$REPO_URL" "$SWARM_DIR" || { log ERROR "❌ Failed to clone repo."; return; }
    fi

    cd "$SWARM_DIR" || { log ERROR "❌ Failed to enter directory."; return; }

    # Dependency check
    if [ -f "package.json" ]; then
        log INFO "📦 Installing Node.js dependencies..."
        npm install || log ERROR "❌ Failed to install npm packages."
    elif [ -f "requirements.txt" ]; then
        log INFO "🐍 Installing Python dependencies..."
        pip install -r requirements.txt || log ERROR "❌ Failed to install Python packages."
    else
        echo -e "${CYAN}ℹ️ No package.json or requirements.txt found. This repo may just contain scripts or docs.${RESET}"
        if [ -f "README.md" ]; then
            echo -e "${CYAN}📖 A README.md file was found. Check it for manual setup instructions.${RESET}"
        else
            echo -e "${CYAN}❓ No README.md detected either. This may be a bare repo.${RESET}"
        fi
        log INFO "ℹ️ No dependency files detected."
    fi
}

run_node() {
    if [ ! -d "$SWARM_DIR" ]; then
        log ERROR "❌ Node not installed. Install it first."
        return
    fi
    log INFO "▶️ Running node..."
    cd "$SWARM_DIR" || return
    # Placeholder: Replace this with actual start command
    echo -e "${CYAN}Node started (replace with your command)${RESET}"
}

update_node() {
    if [ ! -d "$SWARM_DIR" ]; then
        log ERROR "❌ Node not installed. Install it first."
        return
    fi
    log INFO "⬆️ Updating node..."
    cd "$SWARM_DIR" && git pull || log ERROR "❌ Update failed."
}

reset_config() {
    if [ -f "$CONFIG_FILE" ]; then
        rm -f "$CONFIG_FILE"
        log WARN "⚠️ Config file reset."
    else
        log WARN "⚠️ No config file found to reset."
    fi
}

delete_all() {
    if [ -d "$SWARM_DIR" ]; then
        rm -rf "$SWARM_DIR"
        log WARN "🗑️ Node files deleted."
    else
        log WARN "⚠️ No files found to delete."
    fi
}

# ===========================
# MENU
# ===========================
while true; do
    show_header
    echo
    echo -e "${CYAN}${BOLD}1.${RESET} Install Node"
    echo -e "${CYAN}${BOLD}2.${RESET} Run Node"
    echo -e "${CYAN}${BOLD}3.${RESET} Update Node"
    echo -e "${CYAN}${BOLD}4.${RESET} Reset Config"
    echo -e "${CYAN}${BOLD}5.${RESET} Delete Everything"
    echo -e "${CYAN}${BOLD}6.${RESET} Exit"
    echo -e "${CYAN}==========================================${RESET}"
    echo -ne "${YELLOW}👉 Select option [1-6]: ${RESET}"
    read -r choice

    case $choice in
        1) install_node ;;
        2) run_node ;;
        3) update_node ;;
        4) reset_config ;;
        5) delete_all ;;
        6) log INFO "👋 Bye"; exit ;;
        *) log ERROR "❌ Invalid option" ;;
    esac

    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read -r
done
