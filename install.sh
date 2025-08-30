#!/bin/bash
# set -e

# ===========================
# COLORS
# ===========================
CYAN="\033[0;36m"
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

KEEP_TEMP_DATA=true

# ===========================
# LOGGING
# ===========================
log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
    echo -e "${CYAN}$msg${NC}"
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
    echo -e "===============================================================================${NC}"
}

# ===========================
# DEPENDENCIES
# ===========================
install_deps() {
    log INFO "🔄 Updating package list..."
    sudo apt update -y

    log INFO "📦 Installing dependencies..."
    sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof ufw jq perl gnupg

    log INFO "🟢 Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs

    log INFO "🧵 Installing Yarn..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/yarn.gpg >/dev/null
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list >/dev/null
    sudo apt update -y
    sudo apt install -y yarn

    log INFO "🛡️ Setting up firewall..."
    sudo ufw allow 22 >/dev/null 2>&1 || true
    sudo ufw allow 3000/tcp >/dev/null 2>&1 || true
    sudo ufw --force enable >/dev/null 2>&1 || true

    log INFO "🌩️ Installing Cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb >/dev/null 2>&1 || sudo apt -y -f install
    rm -f cloudflared-linux-amd64.deb

    log INFO "✅ All dependencies installed successfully!"
}

# ===========================
# SWAP (optional helper)
# ===========================
manage_swap() {
    if [ ! -f "$SWAP_FILE" ]; then
        log INFO "💾 Creating 1GB swap file..."
        sudo fallocate -l 1G "$SWAP_FILE" >/dev/null 2>&1
        sudo chmod 600 "$SWAP_FILE" >/dev/null 2>&1
        sudo mkswap "$SWAP_FILE" >/dev/null 2>&1
        sudo swapon "$SWAP_FILE" >/dev/null 2>&1
        echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null 2>&1
        log INFO "✅ Swap file created."
    else
        log INFO "ℹ️ Swap file already exists."
    fi
}

# ===========================
# SAFE (RE)CLONE
# ===========================
clone_repo() {
    log INFO "📥 Cloning repo: $REPO_URL"
    if [ -d "$SWARM_DIR/.git" ]; then
        (cd "$SWARM_DIR" && git fetch --all && git reset --hard origin/HEAD) || {
            log INFO "⚠️ Local repo broken; re-cloning."
            sudo rm -rf "$SWARM_DIR"
            git clone "$REPO_URL" "$SWARM_DIR" || { log ERROR "❌ Git clone failed"; return 1; }
        }
    else
        sudo rm -rf "$SWARM_DIR" 2>/dev/null
        git clone "$REPO_URL" "$SWARM_DIR" || { log ERROR "❌ Git clone failed"; return 1; }
    fi
    cd "$SWARM_DIR" || { log ERROR "❌ Cannot enter $SWARM_DIR"; return 1; }
    return 0
}

# ===========================
# INSTALL
# ===========================
install_node() {
    show_header
    log INFO "🚀 INSTALLATION STARTED"

    install_deps
    clone_repo || { log ERROR "❌ Repo clone failed. Aborting."; return; }

    if [ -f "$SWARM_DIR/package.json" ]; then
        log INFO "📦 Detected Node.js project"
        cd "$SWARM_DIR"
        npm install || { log ERROR "❌ npm install failed"; return; }
        log INFO "✅ Node.js dependencies installed"

    elif [ -f "$SWARM_DIR/requirements.txt" ]; then
        log INFO "🐍 Detected Python project"
        cd "$SWARM_DIR"
        python3 -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt || { log ERROR "❌ pip install failed"; deactivate 2>/dev/null; return; }
        log INFO "✅ Python dependencies installed"
        deactivate 2>/dev/null || true
    else
        log ERROR "❌ No package.json or requirements.txt found in repo!"
        log INFO "⚠️ Please check the repo: $REPO_URL"
    fi
}

# ===========================
# RUN
# ===========================
run_node() {
    show_header
    log INFO "▶️ Running project..."

    if [ -f "$SWARM_DIR/package.json" ]; then
        cd "$SWARM_DIR" || { log ERROR "❌ Missing $SWARM_DIR"; return; }
        if jq -e '.scripts.start' package.json >/dev/null 2>&1; then
            npm start
        else
            log INFO "⚠️ No \"start\" script in package.json. Running: node index.js"
            if [ -f "index.js" ]; then
                node index.js
            else
                log ERROR "❌ No start script or index.js found."
            fi
        fi

    elif [ -f "$SWARM_DIR/requirements.txt" ]; then
        cd "$SWARM_DIR" || { log ERROR "❌ Missing $SWARM_DIR"; return; }
        source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
        if [ -f "main.py" ]; then
            python3 main.py
        else
            log INFO "⚠️ No main.py found, please run manually inside $SWARM_DIR"
        fi
        deactivate 2>/dev/null || true
    else
        log ERROR "❌ Cannot run project. No Node.js or Python entry point found."
    fi
}

# ===========================
# UPDATE
# ===========================
update_node() {
    show_header
    log INFO "⬆️ Updating node..."
    if [ ! -d "$SWARM_DIR/.git" ]; then
        log INFO "⚠️ Repo not present; cloning now..."
        clone_repo || { log ERROR "❌ Clone failed"; return; }
    fi
    cd "$SWARM_DIR" || { log ERROR "❌ Missing $SWARM_DIR"; return; }
    git pull
    if [ -f "package.json" ]; then
        npm install
    elif [ -f "requirements.txt" ]; then
        source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
        pip install -r requirements.txt
        deactivate 2>/dev/null || true
    fi
    log INFO "✅ Node updated!"
}

# ===========================
# RESET CONFIG
# ===========================
reset_config() {
    show_header
    log INFO "⚠️ Resetting config..."
    rm -rf "$CONFIG_FILE"
    log INFO "✅ Config reset."
}

# ===========================
# DELETE ALL
# ===========================
delete_all() {
    show_header
    log INFO "⚠️ Deleting node and data..."
    sudo systemctl stop swarm 2>/dev/null || true
    rm -rf "$SWARM_DIR" "$CONFIG_FILE" "$LOG_FILE"
    log INFO "✅ Everything removed."
}

# ===========================
# MAIN MENU
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
