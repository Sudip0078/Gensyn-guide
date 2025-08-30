#!/bin/bash
# ==================================================
# 🚀 Gensyn RL-Swarm Node Manager
# 💐 Theme: Electric Cyan by SPEEDO 🐈
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

# ===== PYTHON PACKAGE INSTALLER =====
install_python_packages() {
    TRANSFORMERS_VERSION=$(pip show transformers 2>/dev/null | grep ^Version: | awk '{print $2}')
    TRL_VERSION=$(pip show trl 2>/dev/null | grep ^Version: | awk '{print $2}')

    if [ "$TRANSFORMERS_VERSION" != "4.51.3" ] || [ "$TRL_VERSION" != "0.19.1" ]; then
        pip install --force-reinstall transformers==4.51.3 trl==0.19.1
    fi
    pip freeze | grep -E '^(transformers|trl)=='
}

# ===== MENU FUNCTIONS (PLACEHOLDER IMPLEMENTATIONS) =====
install_node() {
    echo -e "${CYAN}📥 Installing/Reinstalling Node...${NC}"
    sleep 2
}
run_node() {
    echo -e "${CYAN}🚀 Running Node...${NC}"
    sleep 2
}
update_node() {
    echo -e "${CYAN}⚙️ Updating Node...${NC}"
    sleep 2
}
reset_peer() {
    echo -e "${CYAN}♻️ Resetting Peer ID...${NC}"
    sleep 2
}
install_downgraded_node() {
    echo -e "${CYAN}📉 Installing Downgraded Version...${NC}"
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
        echo -e "${CYAN}6.${NC} 📉 Downgrade Version"
        echo -e "${CYAN}7.${NC} ❌ Exit"
        echo -e "${CYAN}===========================================================${NC}"

        read -p "$(echo -e ${BOLD}${YELLOW}➡️ Select option [1-7]: ${NC})" choice

        case $choice in
            1) install_node ;;
            2) run_node ;;
            3) update_node ;;
            4) reset_peer ;;
            5)
                echo -e "\n${RED}${BOLD}⚠️ WARNING: This will delete ALL node data!${NC}"
                read -p "$(echo -e ${BOLD}Are you sure you want to continue? [y/N]: ${NC})" confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    sudo rm -rf "$SWARM_DIR"
                    sudo rm -f ~/swarm.pem ~/userData.json ~/userApiKey.json
                    echo -e "${GREEN}✅ All node data deleted!${NC}"

                    echo -e "\n${YELLOW}➕ Do you want to reinstall the node now?${NC}"
                    read -p "$(echo -e ${BOLD}Proceed with fresh install? [Y/n]: ${NC})" reinstall_choice
                    if [[ ! "$reinstall_choice" =~ ^[Nn]$ ]]; then
                        install_node
                    else
                        echo -e "${CYAN}❗ Fresh install skipped.${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️ Operation canceled${NC}"
                fi
                ;;
            6) install_downgraded_node ;;
            7)
                echo -e "\n${GREEN}✅ Exiting... Thank you for using Gensyn Manager!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# ===== INIT =====
init() {
    echo -e "${CYAN}🔧 Initializing...${NC}"
    sleep 1
}

trap "echo -e '\n${GREEN}✅ Stopped gracefully${NC}'; exit 0" SIGINT
init
main_menu
