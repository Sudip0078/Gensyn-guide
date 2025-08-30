#!/bin/bash

# Define colors
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Display menu
echo -e "${CYAN}📦 Gensyn Node Manager${NC}"
echo -e "${CYAN}---------------------------${NC}"
echo -e "${CYAN}1) Install Gensyn Node${NC}"
echo -e "${CYAN}2) Update Node${NC}"
echo -e "${CYAN}3) Run Node${NC}"
echo -e "${CYAN}4) Delete Everything${NC}"
echo -e "${CYAN}5) Reset Peer ID${NC}"
echo -e "${CYAN}6) Exit${NC}"
echo -e "${CYAN}---------------------------${NC}"
read -p "Choose an option (1-6): " choice

# Route to menu_speedo.sh functions
case $choice in
  1)
    echo -e "${CYAN}🔧 Installing Gensyn Node...${NC}"
    bash <(curl -s https://raw.githubusercontent.com/Sudip0078/Gensyn-guide/main/menu_speedo.sh) --install
    ;;
  2)
    echo -e "${CYAN}⬆️ Updating Node...${NC}"
    bash <(curl -s https://raw.githubusercontent.com/Sudip0078/Gensyn-guide/main/menu_speedo.sh) --update
    ;;
  3)
    echo -e "${CYAN}🚀 Running Node...${NC}"
    bash <(curl -s https://raw.githubusercontent.com/Sudip0078/Gensyn-guide/main/menu_speedo.sh) --run
    ;;
  4)
    echo -e "${CYAN}⚠️ Deleting Everything...${NC}"
    bash <(curl -s https://raw.githubusercontent.com/Sudip0078/Gensyn-guide/main/menu_speedo.sh) --delete
    ;;
  5)
    echo -e "${CYAN}🆔 Resetting Peer ID...${NC}"
    bash <(curl -s https://raw.githubusercontent.com/Sudip0078/Gensyn-guide/main/menu_speedo.sh) --reset-peer
    ;;
  6)
    echo -e "${CYAN}👋 Exiting. Have a great day, Sudip!${NC}"
    exit 0
    ;;
  *)
    echo -e "${CYAN}❌ Invalid option. Please try again.${NC}"
    ;;
esac