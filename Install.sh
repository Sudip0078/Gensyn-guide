#!/bin/bash

# Define colors
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Display menu
echo -e "${CYAN}📦 One-Command Menu${NC}"
echo -e "${CYAN}---------------------${NC}"
echo -e "${CYAN}1) Install${NC}"
echo -e "${CYAN}2) Update${NC}"
echo -e "${CYAN}3) Run${NC}"
echo -e "${CYAN}4) Delete Everything${NC}"
echo -e "${CYAN}5) Show Peer ID${NC}"
echo -e "${CYAN}6) Exit${NC}"
echo -e "${CYAN}---------------------${NC}"
read -p "Choose an option (1-6): " choice

case $choice in
  1)
    echo -e "${CYAN}🔧 Installing...${NC}"
    # Your install logic here
    ;;
  2)
    echo -e "${CYAN}⬆️ Updating...${NC}"
    # Your update logic here
    ;;
  3)
    echo -e "${CYAN}🚀 Running...${NC}"
    # Your run logic here
    ;;
  4)
    echo -e "${CYAN}⚠️ Deleting everything...${NC}"
    # Your delete logic here
    ;;
  5)
    echo -e "${CYAN}🆔 Peer ID:${NC}"
    echo -e "${CYAN}$(uuidgen)${NC}"  # Generates a random UUID
    ;;
  6)
    echo -e "${CYAN}👋 Exiting. Have a great day, Sudip!${NC}"
    exit 0
    ;;
  *)
    echo -e "${CYAN}❌ Invalid option. Please try again.${NC}"
    ;;
esac