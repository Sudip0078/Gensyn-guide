#!/bin/bash
# set -e

# ===========================
# COLORS (always cyan)
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
    echo -e " 🚀 Gensyn RL-Swarm Launcher by SPEEDO 🐈

                       Do not pspsssps 😼"
    echo -e ".    💐 Theme: Electric Cyan 💐"
    echo -e "===============================================================================${NC}"
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
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/yarn.gpg >/dev/null
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list >/dev/null
    sudo apt update -y
    sudo apt install -y yarn

    echo "🛡️ Setting up firewall..."
    sudo ufw allow 22 >/dev/null 2>&1 || true
    sudo ufw allow 3000/tcp >/dev/null 2>&1 || true
    sudo ufw --force enable >/dev/null 2>&1 || true

    echo "🌩️ Installing Cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb >/dev/null 2>&1 || sudo apt -y -f install
    rm -f cloudflared-linux-amd64.deb

    echo "✅ All dependencies installed successfully!"
}

# ===========================
# SWAP (optional helper)
# ===========================
manage_swap() {
    if [ ! -f "$SWAP_FILE" ]; then
        sudo fallocate -l 1G "$SWAP_FILE" >/dev/null 2>&1
        sudo chmod 600 "$SWAP_FILE" >/dev/null 2>&1
        sudo mkswap "$SWAP_FILE"  >/dev/null 2>&1
        sudo swapon "$SWAP_FILE"  >/dev/null 2>&1
        echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null 2>&1
    fi
}

# ===========================
# SAFE (RE)CLONE
# ===========================
clone_repo() {
    log INFO "Cloning repo: $REPO_URL"
    if [ -d "$SWARM_DIR/.git" ]; then
        (cd "$SWARM_DIR" && git fetch --all && git reset --hard origin/HEAD) || {
            log INFO "Local repo looked broken; re-cloning."
            sudo rm -rf "$SWARM_DIR"
            git clone "$REPO_URL" "$SWARM_DIR" || { log INFO "Git clone failed"; return 1; }
        }
    else
        sudo rm -rf "$SWARM_DIR" 2>/dev/null
        git clone "$REPO_URL" "$SWARM_DIR" || { log INFO "Git clone failed"; return 1; }
    fi
    cd "$SWARM_DIR" || { log INFO "Cannot enter $SWARM_DIR"; return 1; }
    return 0
}

# ===========================
# INSTALL
# ===========================
install_node() {
    show_header
    echo -e "${CYAN}${BOLD}INSTALLATION STARTED${NC}"

    install_deps
    clone_repo || { echo -e "${CYAN}❌ Repo clone failed. Aborting.${NC}"; return; }

    if [ -f "$SWARM_DIR/package.json" ]; then
        echo -e "${CYAN}📦 Detected Node.js project${NC}"
        cd "$SWARM_DIR"
        npm install || { echo -e "${CYAN}❌ npm install failed${NC}"; return; }
        echo -e "${CYAN}✅ Node.js dependencies installed${NC}"

    elif [ -f "$SWARM_DIR/requirements.txt" ]; then
        echo -e "${CYAN}🐍 Detected Python project${NC}"
        cd "$SWARM_DIR"
        python3 -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt || { echo -e "${CYAN}❌ pip install failed${NC}"; deactivate 2>/dev/null; return; }
        echo -e "${CYAN}✅ Python dependencies installed${NC}"
        deactivate 2>/dev/null || true
    else
        echo -e "${CYAN}❌ No package.json or requirements.txt found in repo!${NC}"
        echo -e "${CYAN}⚠️ Please check the repo: $REPO_URL${NC}"
    fi
}

# ===========================
# RUN
# ===========================
run_node() {
    show_header
    echo -e "${CYAN}▶️ Running project...${NC}"

    if [ -f "$SWARM_DIR/package.json" ]; then
        cd "$SWARM_DIR" || { echo -e "${CYAN}❌ Missing $SWARM_DIR${NC}"; return; }
        if jq -e '.scripts.start' package.json >/dev/null 2>&1; then
            npm start
        else
            echo -e "${CYAN}⚠️ No \"start\" script in package.json. Running: node index.js (if exists)${NC}"
            if [ -f "index.js" ]; then
                node index.js
            else
                echo -e "${CYAN}❌ No start script or index.js found.${NC}"
            fi
        fi

    elif [ -f "$SWARM_DIR/requirements.txt" ]; then
        cd "$SWARM_DIR" || { echo -e "${CYAN}❌ Missing $SWARM_DIR${NC}"; return; }
        source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
        if [ -f "main.py" ]; then
            python3 main.py
        else
            echo -e "${CYAN}⚠️ No main.py found, please run manually inside $SWARM_DIR${NC}"
        fi
        deactivate 2>/dev/null || true

    else
        echo -e "${CYAN}❌ Cannot run project. Neither Node.js nor Python entry point found.${NC}"
    fi
}

# ===========================
# UPDATE
# ===========================
update_node() {
    show_header
    echo -e "${CYAN}⬆️ Updating node...${NC}"
    if [ ! -d "$SWARM_DIR/.git" ]; then
        echo -e "${CYAN}⚠️ Repo not present; cloning now...${NC}"
        clone_repo || { echo -e "${CYAN}❌ Clone failed${NC}"; return; }
    fi
    cd "$SWARM_DIR" || { echo -e "${CYAN}❌ Missing $SWARM_DIR${NC}"; return; }
    git pull
    if [ -f "package.json" ]; then
        npm install
    elif [ -f "requirements.txt" ]; then
        source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
        pip install -r requirements.txt
        deactivate 2>/dev/null || true
    fi
    echo -e "${CYAN}✅ Node updated!${NC}"
}

# ===========================
# RESET CONFIG
# ===========================
reset_config() {
    show_header
    echo -e "${CYAN}⚠️ Resetting config...${NC}"
    rm -rf "$CONFIG_FILE"
    echo -e "${CYAN}✅ Config reset.${NC}"
}

# ===========================
# DELETE ALL
# ===========================
delete_all() {
    show_header
    echo -e "${CYAN}⚠️ Deleting node and data...${NC}"
    sudo systemctl stop swarm 2>/dev/null || true
    rm -rf "$SWARM_DIR" "$CONFIG_FILE" "$LOG_FILE"
    echo -e "${CYAN}✅ Everything removed.${NC}"
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
    read -r -p "👉 Select option [1-6]: " choice

    case $choice in
        1) install_node ;;
        2) run_node ;;
        3) update_node ;;
        4) reset_config ;;
        5) delete_all ;;
        6) echo "👋 Bye"; exit ;;
        *) echo "❌ Invalid option";;
    esac
    read -r -p "Press Enter to continue..."
done
