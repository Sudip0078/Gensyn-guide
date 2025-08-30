#!/bin/bash
# set -e

# ===========================
# COLORS
# ===========================
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

# ===========================
# PATHS & VARIABLES
# ===========================
SWARM_DIR="$HOME/rl-swarm"
CONFIG_FILE="$SWARM_DIR/.swarm_config"
LOG_FILE="$HOME/swarm_log.txt"
SWAP_FILE="/swapfile"
REPO_URL="https://github.com/gensyn-ai/rl-swarm.git"

KEEP_TEMP_DATA=true

# ===========================
# LOGGING
# ===========================
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

# ===========================
# HEADER
# ===========================
show_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "┌───────────────────────────────────────────────────────────────┐"
    echo "│    _____ ____  ________________  ____                         │"
    echo "│   / ___// __ \/ ____/ ____/ __ \/ __ \                        │"
    echo "│   \__ \/ /_/ / __/ / __/ / / / / / / /                        │"
    echo "│  ___/ / ____/ /___/ /___/ /_/ / /_/ /                         │"
    echo "│ /____/_/   /_____/_____/_____/\____/                          │"
    echo "└───────────────────────────────────────────────────────────────┘"
    echo -e "${YELLOW} 🚀 Gensyn RL-Swarm Launcher by SPEEDO ✨${NC}"
    echo -e "${CYAN} ✨ Theme: Ice Blue (Electric Blue) ✨${NC}"
    echo -e "${GREEN}===============================================================================${NC}"
}

# ===========================
# DEPENDENCIES
# ===========================
install_deps() {
    echo "🔄 Updating package list..."
    sudo apt update -y
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

# ===========================
# SWAP
# ===========================
manage_swap() {
    if [ ! -f "$SWAP_FILE" ]; then
        sudo fallocate -l 1G "$SWAP_FILE" >/dev/null 2>&1
        sudo chmod 600 "$SWAP_FILE" >/dev/null 2>&1
        sudo mkswap "$SWAP_FILE" >/dev/null 2>&1
        sudo swapon "$SWAP_FILE" >/dev/null 2>&1
        echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null 2>&1
    fi
}

# ===========================
# CLONE REPO
# ===========================
clone_repo() {
    sudo rm -rf "$SWARM_DIR" 2>/dev/null
    git clone "$REPO_URL" "$SWARM_DIR"
    cd "$SWARM_DIR"
}

# ===========================
# INSTALL (Smart Detection)
# ===========================
install_node() {
    show_header
    echo -e "${CYAN}${BOLD}INSTALLATION STARTED${NC}"

    install_deps
    clone_repo

    if [ -f "$SWARM_DIR/package.json" ]; then
        echo -e "${CYAN}📦 Detected Node.js project${NC}"
        cd "$SWARM_DIR"
        npm install
        echo -e "${GREEN}✅ Node.js dependencies installed${NC}"

    elif [ -f "$SWARM_DIR/requirements.txt" ]; then
        echo -e "${CYAN}🐍 Detected Python project${NC}"
        cd "$SWARM_DIR"
        python3 -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
        echo -e "${GREEN}✅ Python dependencies installed${NC}"

    else
        echo -e "${RED}❌ No package.json or requirements.txt found in repo!${NC}"
        echo -e "${YELLOW}⚠️ Please check the repo: $REPO_URL${NC}"
    fi
}

# ===========================
# RUN (Smart Detection)
# ===========================
run_node() {
    show_header
    echo -e "${CYAN}▶️ Running project...${NC}"

    if [ -f "$SWARM_DIR/package.json" ]; then
        cd "$SWARM_DIR"
        npm start

    elif [ -f "$SWARM_DIR/requirements.txt" ]; then
        cd "$SWARM_DIR"
        source venv/bin/activate
        if [ -f "main.py" ]; then
            python3 main.py
        else
            echo -e "${YELLOW}⚠️ No main.py found, please run manually inside $SWARM_DIR${NC}"
        fi

    else
        echo -e "${RED}❌ Cannot run project. Neither Node.js nor Python entry point found.${NC}"
    fi
}

# ===========================
# UPDATE
# ===========================
update_node() {
    show_header
    echo -e "${CYAN}⬆️ Updating node...${NC}"
    cd "$SWARM_DIR"
    git pull
    if [ -f "package.json" ]; then
        npm install
    elif [ -f "requirements.txt" ]; then
        source venv/bin/activate
        pip install -r requirements.txt
    fi
    echo -e "${GREEN}✅ Node updated!${NC}"
}

# ===========================
# RESET CONFIG
# ===========================
reset_config() {
    show_header
    echo -e "${RED}⚠️ Resetting config...${NC}"
    rm -rf "$CONFIG_FILE"
    echo -e "${GREEN}✅ Config reset.${NC}"
}

# ===========================
# DELETE ALL
# ===========================
delete_all() {
    show_header
    echo -e "${RED}⚠️ Deleting node and data...${NC}"
    sudo systemctl stop swarm || true
    rm -rf "$SWARM_DIR" "$CONFIG_FILE" "$LOG_FILE"
    echo -e "${GREEN}✅ Everything removed.${NC}"
}

# ===========================
# MAIN MENU
# ===========================
while true; do
    show_header
    echo "1. Install Node"
    echo "2. Run Node"
    echo "3. Update Node"
    echo "4. Reset Config"
    echo "5. Delete Everything"
    echo "6. Exit"
    echo "=========================================="
    read -p "👉 Select option [1-6]: " choice

    case $choice in
        1) install_node ;;
        2) run_node ;;
        3) update_node ;;
        4) reset_config ;;
        5) delete_all ;;
        6) echo "👋 Bye"; exit ;;
        *) echo "❌ Invalid option";;
    esac
    read -p "Press Enter to continue..."
done
