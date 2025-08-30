#!/bin/bash
# set -e

if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then
    BOLD=$(tput bold)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    NC=$(tput sgr0)
else
    BOLD=""
    RED=""
    GREEN=""
    YELLOW=""
    CYAN=""
    BLUE=""
    MAGENTA=""
    NC=""
fi

# Paths
SWARM_DIR="$HOME/rl-swarm"
CONFIG_FILE="$SWARM_DIR/.swarm_config"
LOG_FILE="$HOME/swarm_log.txt"
SWAP_FILE="/swapfile"
REPO_URL="https://github.com/gensyn-ai/rl-swarm.git"

# Global Variables
KEEP_TEMP_DATA=true

# Logging
log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
    case "$level" in
        ERROR) echo -e "${RED}$msg${NC}" ;;
        WARN) echo -e "${YELLOW}$msg${NC}" ;;
        INFO) echo -e "${CYAN}$msg${NC}" ;;
    esac
}

# Initialize
init() {
    clear
    touch "$LOG_FILE"
    log "INFO" "=== SPEEDO RL-SWARM MANAGER STARTED ==="
}

# Display Header
show_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "┌───────────────────────────────────────────────────────────────┐"
    echo "│   ███████╗██████╗ ███████╗███████╗██████╗  ██████╗             │"
    echo "│   ██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██╔═══██╗            │"
    echo "│   █████╗  ██████╔╝█████╗  █████╗  ██████╔╝██║   ██║            │"
    echo "│   ██╔══╝  ██╔═══╝ ██╔══╝  ██╔══╝  ██╔═══╝ ██║   ██║            │"
    echo "│   ██║     ██║     ███████╗███████╗██║     ╚██████╔╝            │"
    echo "│   ╚═╝     ╚═╝     ╚══════╝╚══════╝╚═╝      ╚═════╝             │"
    echo "└───────────────────────────────────────────────────────────────┘"
    echo -e "${YELLOW}           🚀 Gensyn RL-Swarm Launcher by SPEEDO 🚀${NC}"
    echo -e "${GREEN}===============================================================================${NC}"
}

# Dependencies
install_deps() {
    echo "🔄 Updating package list..."
    sudo apt update -y

    echo "📦 Installing essential packages..."
    sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof ufw jq perl gnupg

    echo "🟢 Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs

    echo "🧵 Installing Yarn..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/yarn.gpg
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update -y
    sudo apt install -y yarn

    echo "🛡️ Setting up firewall..."
    sudo ufw allow 22
    sudo ufw allow 3000/tcp
    sudo ufw --force enable

    echo "🌩️ Installing Cloudflared..."
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb || sudo apt install -f
    rm -f cloudflared-linux-amd64.deb

    echo "✅ All dependencies installed successfully!"
}

# Swap Management
manage_swap() {
    if [ ! -f "$SWAP_FILE" ]; then
        sudo fallocate -l 1G "$SWAP_FILE" >/dev/null 2>&1
        sudo chmod 600 "$SWAP_FILE" >/dev/null 2>&1
        sudo mkswap "$SWAP_FILE" >/dev/null 2>&1
        sudo swapon "$SWAP_FILE" >/dev/null 2>&1
        echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null 2>&1
    fi
}

disable_swap() {
    if [ -f "$SWAP_FILE" ]; then
        sudo swapoff "$SWAP_FILE"
        sudo rm -f "$SWAP_FILE"
        sudo sed -i "\|$SWAP_FILE|d" /etc/fstab
    fi
}

# Fixall Script (cleaned)
run_fixall() {
    echo -e "${CYAN}🔧 Applying fixes...${NC}"
    # Placeholder: Add Speedo’s custom fix script here if available
    echo -e "${GREEN}✅ Fixall complete (placeholder).${NC}"
    sleep 3
}

# Clone Repository
clone_repo() {
    sudo rm -rf "$SWARM_DIR" 2>/dev/null
    git clone "$REPO_URL" "$SWARM_DIR" >/dev/null 2>&1
    cd "$SWARM_DIR"
}

clone_downgraded_repo() {
    sudo rm -rf "$SWARM_DIR" 2>/dev/null
    git clone "$REPO_URL" "$SWARM_DIR" >/dev/null 2>&1
    cd "$SWARM_DIR"
    git checkout 305d3f3227d9ca27f6b4127a5379fc6a40143525 >/dev/null 2>&1
}

# --- rest of your functions (config, install, run, update, etc.) stay as in your script ---
# (All Hustle references already cleaned; banner, log headers, fixall done above)
