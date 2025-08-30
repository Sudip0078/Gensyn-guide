#!/bin/bash
# ==================================================
# 🚀 Gensyn RL-Swarm Node Manager (Fixed)
# 💐 Theme: Electric Cyan
# ==================================================

# ===== COLORS =====
CYAN="\033[0;36m"
BOLD="\033[1m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[0;35m"
NC="\033[0m"

# ===== PATHS =====
SWARM_DIR="$HOME/rl-swarm"
VENV_DIR="$SWARM_DIR/.venv"

# ===== HEADER =====
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
    echo -e " 🚀 ${CYAN}Gensyn RL-Swarm Launcher${NC}"
    echo -e " 💐 ${CYAN}Theme: Electric Cyan${NC}"
    echo -e "${CYAN}================================================================${NC}"
}

# ===== INSTALL NODE =====
install_node() {
    echo -e "${CYAN}📥 Installing/Reinstalling Node...${NC}"
    if [ -d "$SWARM_DIR" ]; then
        echo -e "${YELLOW}⚠️ Repo exists. Pulling latest changes...${NC}"
        cd "$SWARM_DIR" && git pull
    else
        git clone https://github.com/gensyn-ai/rl-swarm.git "$SWARM_DIR"
    fi

    cd "$SWARM_DIR" || exit 1

    # Python Virtual Environment
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${CYAN}🔧 Creating Python virtual environment...${NC}"
        python3 -m venv "$VENV_DIR"
    fi
    source "$VENV_DIR/bin/activate"

    # Check for dependencies
    if [ -f "requirements.txt" ]; then
        echo -e "${CYAN}📦 Installing Python dependencies...${NC}"
        pip install -r requirements.txt
    elif [ -f "package.json" ]; then
        echo -e "${CYAN}📦 Installing NodeJS dependencies...${NC}"
        npm install
    else
        echo -e "${YELLOW}ℹ️ No package.json or requirements.txt found. This repo may be scripts only.${NC}"
    fi

    echo -e "${GREEN}✅ Node setup complete!${NC}"
    deactivate
    sleep 2
}

# ===== RUN NODE =====
run_node() {
    if [ ! -d "$SWARM_DIR" ]; then
        echo -e "${RED}❌ Node not installed. Install it first.${NC}"
        sleep 2
        return
    fi
    echo -e "${CYAN}🚀 Running Node...${NC}"
    cd "$SWARM_DIR" || exit 1
    source "$VENV_DIR/bin/activate"
    if [ -f "main.py" ]; then
        python main.py
    elif [ -f "index.js" ]; then
        node index.js
    else
        echo -e "${YELLOW}⚠️ No main.py or index.js found. Run manually from $SWARM_DIR.${NC}"
    fi
    deactivate
    sleep 2
}

# ===== UPDATE NODE =====
update_node() {
    if [ ! -d "$SWARM_DIR" ]; then
        echo -e "${RED}❌ Node not installed.${NC}"
        sleep 2
        return
    fi
    echo -e "${CYAN}⚙️ Updating Node...${NC}"
    cd "$SWARM_DIR" && git pull
    echo -e "${GREEN}✅ Node updated!${NC}"
    sleep 2
}

# ===== RESET PEER ID =====
reset_peer() {
    echo -e "${CYAN}♻️ Resetting Peer ID...${NC}"
    rm -f ~/swarm.pem
    echo -e "${GREEN}✅ Peer ID reset!${NC}"
    sleep 2
}

# ===== DELETE EVERYTHING =====
delete_all() {
    echo -e "\n${RED}${BOLD}⚠️ WARNING: This will delete ALL node data!${NC}"
    read -p "$(echo -e ${BOLD}Are you sure you want to continue? [y/N]: ${NC})" confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$SWARM_DIR" ~/swarm.pem ~/userData.json ~/userApiKey.json
        echo -e "${GREEN}✅ All node data deleted!${NC}"
    else
        echo -e "${YELLOW}⚠️ Operation canceled${NC}"
    fi
    sleep 2
}

# ===== MAIN MENU =====
main_menu() {
    while true; do
        show_header
        echo -e "${BOLD}${MAGENTA}==================== 🧠 GENSYN MAIN MENU ====================${NC}"
        echo -e "${CYAN}1.${NC} 🛠 Install/Reinstall Node"
        echo -e "${CYAN}2.${NC} 🚀 Run Node"
        echo -e "${CYAN}3.${NC} ⚙️ Update Node"
        echo -e "${CYAN}4.${NC} ♻️ Reset Peer ID"
        echo -e "${CYAN}5.${NC} 🗑️ Delete Everything & Start New"
        echo -e "${CYAN}6.${NC} ❌ Exit"
        echo -e "${CYAN}===========================================================${NC}"

        read -p "$(echo -e ${BOLD}${YELLOW}➡️ Select option [1-6]: ${NC})" choice
        case $choice in
            1) install_node ;;
            2) run_node ;;
            3) update_node ;;
            4) reset_peer ;;
            5) delete_all ;;
            6) echo -e "${GREEN}✅ Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}

trap "echo -e '\n${GREEN}✅ Stopped gracefully${NC}'; exit 0" SIGINT
main_menu
