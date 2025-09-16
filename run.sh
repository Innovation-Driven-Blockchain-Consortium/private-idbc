#!/bin/bash

# Configuration
NETWORK_NAME="private-testnet-idbc"

# Color palette
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to check and install Kurtosis
check_install_kurtosis() {
    echo -e "${BLUE}🔍 Checking if Kurtosis is installed...${NC}"
    
    if command -v kurtosis &> /dev/null; then
        echo -e "${GREEN}✅ Kurtosis is already installed!${NC}"
        kurtosis version
    else
        echo -e "${YELLOW}⚠️  Kurtosis not found. Installing Kurtosis...${NC}"
        
        echo -e "${CYAN}📦 Adding Kurtosis repository...${NC}"
        echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
        
        echo -e "${CYAN}🔄 Updating package list...${NC}"
        sudo apt update
        
        echo -e "${CYAN}⬇️  Installing Kurtosis CLI...${NC}"
        sudo apt install kurtosis-cli
        
        # Verify installation
        if command -v kurtosis &> /dev/null; then
            echo -e "${GREEN}✅ Kurtosis successfully installed!${NC}"
            kurtosis version
        else
            echo -e "${RED}❌ Failed to install Kurtosis${NC}"
            exit 1
        fi
    fi
    echo ""
}

# Function to check and install make
check_install_make() {
    echo -e "${BLUE}🔍 Checking if make is installed...${NC}"
    
    if command -v make &> /dev/null; then
        echo -e "${GREEN}✅ Make is already installed!${NC}"
        make --version | head -n 1
    else
        echo -e "${YELLOW}⚠️  Make not found. Installing make...${NC}"
        
        echo -e "${CYAN}🔄 Updating package list...${NC}"
        sudo apt update
        
        echo -e "${CYAN}⬇️  Installing build-essential (includes make)...${NC}"
        sudo apt install -y build-essential
        
        # Verify installation
        if command -v make &> /dev/null; then
            echo -e "${GREEN}✅ Make successfully installed!${NC}"
            make --version | head -n 1
        else
            echo -e "${RED}❌ Failed to install make${NC}"
            return 1
        fi
    fi
    echo ""
    return 0
}

# Function to start the network
start_network() {
    echo -e "${CYAN}🚀 Spinning up private testing network...${NC}"
    echo -e "${YELLOW}⚙️  Running Kurtosis with Ethereum package...${NC}"
    kurtosis run --enclave ${NETWORK_NAME} github.com/ethpandaops/ethereum-package --args-file ./kurostis_config/network_params.yaml --image-download always
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Private testing network successfully started!${NC}"
    else
        echo -e "${RED}❌ Failed to start private testing network${NC}"
        exit 1
    fi
}

# Function to tear down the network
teardown_network() {
    echo -e "${CYAN}🧹 Tearing down private testing network...${NC}"
    echo -e "${YELLOW}⚙️  Removing enclave: ${NETWORK_NAME}${NC}"
    kurtosis enclave rm -f ${NETWORK_NAME}
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Private testing network successfully torn down!${NC}"
    else
        echo -e "${RED}❌ Failed to tear down private testing network${NC}"
        exit 1
    fi
}

# Function to show network status
show_status() {
    echo -e "${BLUE}📊 Checking network status...${NC}"
    kurtosis enclave ls
}

# Function to run local explorer
run_explorer() {
    echo -e "${CYAN}🔍 Starting local Dora explorer...${NC}"
    
    # Check if make is installed
    if ! check_install_make; then
        echo -e "${RED}❌ Cannot proceed without make installed${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⚙️  Running explorer in dora directory...${NC}"
    
    # Check if dora directory exists
    if [ ! -d "./dora" ]; then
        echo -e "${RED}❌ Dora directory not found at ./dora${NC}"
        echo -e "${YELLOW}💡 Make sure the dora folder is in the current directory${NC}"
        return 1
    fi
    
    # Change to dora directory and run make devnet-run
    cd ./dora
    echo -e "${BLUE}📁 Changed to dora directory${NC}"
    make devnet-run
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Dora explorer started successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to start Dora explorer${NC}"
    fi
    
    # Return to original directory
    cd ..
}

# Main dashboard
show_dashboard() {
    clear
    echo -e "${WHITE}================================${NC}"
    echo -e "${CYAN}   🏗️  IDBC Network Manager   ${NC}"
    echo -e "${WHITE}================================${NC}"
    echo -e "${YELLOW}Network: ${NETWORK_NAME}${NC}"
    echo -e "${WHITE}================================${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} 🚀 Start Private Network"
    echo -e "${RED}2.${NC} 🧹 Tear Down Network"
    echo -e "${BLUE}3.${NC} 📊 Show Network Status"
    echo -e "${MAGENTA}4.${NC} � Run Local Explorer (Dora)"
    echo -e "${CYAN}5.${NC} �🚪 Exit"
    echo ""
    echo -e "${WHITE}================================${NC}"
    echo -n -e "${CYAN}Please select an option (1-5): ${NC}"
}

# Check and install Kurtosis if needed
check_install_kurtosis

# Main loop
while true; do
    show_dashboard
    read -r choice
    
    case $choice in
        1)
            echo ""
            start_network
            echo ""
            echo -e "${YELLOW}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        2)
            echo ""
            teardown_network
            echo ""
            echo -e "${YELLOW}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        3)
            echo ""
            show_status
            echo ""
            echo -e "${YELLOW}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        4)
            echo ""
            run_explorer
            echo ""
            echo -e "${YELLOW}Press any key to continue...${NC}"
            read -n 1 -s
            ;;
        5)
            echo ""
            echo -e "${CYAN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}❌ Invalid option. Please select 1-5.${NC}"
            sleep 2
            ;;
    esac
done