#!/bin/bash
# RL-Swarm Launcher by SPEEDO 🐈

# ===========================
# COLORS
# ===========================
CYAN="\033[0;96m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
GREEN="\033[1;32m"
BOLD="\033[1m"
NC="\033[0m"

# ===========================
# PATHS & VARIABLES
# ===========================
SWARM_DIR="$HOME/rl-swarm"
CONFIG_FILE="$SWARM_DIR/.swarm_config"
LOG_FILE="$HOME/swarm_log.txt"
SWAP_FILE="/swapfile"
REPO_URL="https://github.com/gensyn-ai/rl-swarm.git"

# ===========================
# LOGGING
# ===========================
log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
    case "$level" in
        INFO) echo -e "${CYAN}$msg${NC}" ;;
        WARN) echo -e "${YELLOW}$msg${NC}" ;;
        ERROR) echo -e "${RED}$msg${NC}" ;;
        SUCCESS) echo -e "${GREEN}$msg${NC}" ;;
    esac
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
    echo -e "================================================================${NC}"
}

# ===========================
# DEPENDENCIES
# ===========================
install_deps() {
    log INFO "🔄 Updating package list..."
    sudo apt update -y >/dev/null

    log INFO "📦 Installing dependencies..."
    sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof ufw jq perl gnupg >/dev/null

    log INFO "🟢 Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null
    sudo apt install -y nodejs >/dev/null

    log INFO "🧵 Installing Yarn..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/yarn.gpg >/dev/null
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list >/dev/null
    sudo apt update -y >/dev/null
    sudo apt install -y yarn >/dev/null

    log INFO "🛡️ Setting up firewall..."
    sudo ufw allow 22 >/dev/null 2>&1 || true
    sudo ufw allow 3000/tcp >/dev/null 2>&1 || true
    sudo ufw --force enable >/dev/null 2>&1 || true

    log INFO "🌩️ Installing Cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb >/dev/null 2>&1 || sudo apt -y -f install >/dev/null
    rm -f cloudflared-linux-amd64.deb

    log SUCCESS "✅ All dependencies installed successfully!"
}

# ===========================
# REPO CLONE
# ===========================
clone_repo() {
    log INFO "📥 Cloning repo: $REPO_URL"
    if [ -d "$SWARM_DIR/.git" ]; then
        (cd "$SWARM_DIR" && git fetch --all && git reset --hard origin/HEAD) || {
            log WARN "⚠️ Local repo broken; re-cloning."
            sudo rm -rf "$SWARM_DIR"
            git clone "$REPO_URL" "$SWARM_DIR" || { log ERROR "❌ Git clone failed"; return 1; }
        }
    else
        sudo rm -rf "$SWARM_DIR" 2>/dev/null
        git clone "$REPO_URL" "$SWARM_DIR" || { log ERROR "❌ Git clone failed"; return 1; }
    fi
    cd "$SWARM_DIR" || { log ERROR "❌ Cannot enter $SWARM_DIR"; return 1; }

    if [ ! -f "package.json" ] && [ ! -f "requirements.txt" ]; then
        log WARN "ℹ️ No package.json or requirements.txt found. This repo may just contain scripts or docs."
        if [ -f "README.md" ]; then
            log INFO "📖 A README.md file was found. Check it for manual setup instructions."
        fi
    fi
}

# ===========================
# INSTALL
# ===========================
install_node() {
    show_header
    log INFO "🚀 INSTALLATION STARTED"
    install_deps
    clone_repo
}

# ===========================
# RUN
# ===========================
run_node() {
    show_header
    log INFO "▶️ Running project..."
    cd "$SWARM_DIR" || { log ERROR "❌ Missing $SWARM_DIR"; return; }
    if [ -f "package.json" ]; then
        npm start || node index.js
    elif [ -f "requirements.txt" ]; then
        source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
        python3 main.py || log WARN "⚠️ No main.py found."
        deactivate 2>/dev/null || true
    else
        log WARN "⚠️ No entry point detected. Repo may just contain scripts."
    fi
}

# ===========================
# UPDATE
# ===========================
update_node() {
    show_header
    log INFO "⬆️ Updating node..."
    clone_repo
    log SUCCESS "✅ Node updated!"
}

# ===========================
# RESET CONFIG
# ===========================
reset_config() {
    show_header
    log WARN "⚠️ Resetting config..."
    rm -rf "$CONFIG_FILE"
    log SUCCESS "✅ Config reset."
}

# ===========================
# DELETE ALL
# ===========================
delete_all() {
    show_header
    log WARN "⚠️ Deleting node and data..."
    sudo systemctl stop swarm 2>/dev/null || true
    rm -rf "$SWARM_DIR" "$CONFIG_FILE" "$LOG_FILE"
    log SUCCESS "✅ Everything removed."
}

# ===========================
# MENU
# ===========================
while true; do
    show_header
    echo
    echo -e "${CYAN}${BOLD}1.${NC} Install Node"
    echo -e "${CYAN}${BOLD}2.${NC} Run Node"
    echo -e "${CYAN}${BOLD}3.${NC} Update Node"
    echo -e "${CYAN}${BOLD}4.${NC} Reset Config"
    echo -e "${CYAN}${BOLD}5.${NC} Delete Everything"
    echo -e "${CYAN}${BOLD}6.${NC} Exit"
    echo -e "${CYAN}==========================================${NC}"
    echo -ne "${CYAN}👉 Select option [1-6]: ${NC}"
    read -r choice

    case $choice in
        1) install_node ;;
        2) run_node ;;
        3) update_node ;;
        4) reset_config ;;
        5) delete_all ;;
        6) log INFO "👋 Bye"; exit ;;
        *) log ERROR "❌ Invalid option";;
    esac

    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
done
