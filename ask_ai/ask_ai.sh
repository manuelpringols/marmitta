#!/bin/bash

# ==============================================================================
# Script by padmanuel - AI CLI Setup and Query with persistent chat
# Based on https://github.com/simonw/llm (llm)
# ==============================================================================

set -e

# -----------------------
# Define colors
# -----------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color



# -----------------------
echo -e "${YELLOW}"
echo "=============================================================================="
echo "# Script by padmanuel - AI CLI Setup and Query with persistent chat"
echo "# Based on https://github.com/simonw/llm (llm)"
echo "=============================================================================="
echo -e "${NC}"

# -----------------------
# Detect package manager
# -----------------------
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo -e "${BLUE}Detected apt${NC}"
        PM="apt"
    elif command -v dnf &> /dev/null; then
        echo -e "${BLUE}Detected dnf${NC}"
        PM="dnf"
    elif command -v pacman &> /dev/null; then
        echo -e "${BLUE}Detected pacman${NC}"
        PM="pacman"
    elif command -v brew &> /dev/null; then
        echo -e "${BLUE}Detected brew${NC}"
        PM="brew"
    else
        echo -e "${RED}No supported package manager found. Install manually.${NC}"
        exit 1
    fi
}

# -----------------------
# Install ollama
# -----------------------
install_ollama() {
    if ! command -v ollama &> /dev/null; then
        echo -e "${BLUE}Installing ollama...${NC}"
        case $PM in
            apt)
                curl -fsSL https://ollama.com/install.sh | sh
                ;;
            brew)
                brew install ollama
                ;;
            pacman|dnf)
                echo -e "${RED}Please install ollama manually from https://ollama.com/download${NC}"
                exit 1
                ;;
            *)
                echo -e "${RED}Unsupported package manager. Install ollama manually.${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}ollama already installed. Skipping.${NC}"
    fi
}

# -----------------------
# Start ollama serve if not running
# -----------------------
start_ollama_serve() {
    if ! pgrep -x "ollama" &> /dev/null; then
        echo -e "${BLUE}Starting ollama serve...${NC}"
        nohup ollama serve > /dev/null 2>&1 &
        sleep 2
        echo -e "${GREEN}ollama serve started.${NC}"
    else
        echo -e "${GREEN}ollama serve already running.${NC}"
    fi
}

# -----------------------
# Install llm
# -----------------------
install_llm() {
    if ! command -v llm &> /dev/null; then
        echo -e "${BLUE}Installing llm via uv (repo: https://github.com/simonw/llm)${NC}"
        
        if ! command -v uv &> /dev/null; then
            echo -e "${YELLOW}uv not found. Installing uv first...${NC}"
            case $PM in
                apt)
                    curl -LsSf https://astral.sh/uv/install.sh | sh
                    ;;
                brew)
                    brew install uv
                    ;;
                pacman|dnf)
                    echo -e "${RED}Please install uv manually.${NC}"
                    exit 1
                    ;;
                *)
                    echo -e "${RED}Unsupported package manager for uv.${NC}"
                    exit 1
                    ;;
            esac
        fi
        
   TMP_VENV="/tmp/uv_venv"

if [ ! -d "$TMP_VENV" ]; then
  echo -e "${BLUE}Creating uv venv in RAM (/tmp)...${NC}"
  uv venv "$TMP_VENV"
fi

# Activate the venv
source "$TMP_VENV/bin/activate"

        uv pip install llm
    else
        echo -e "${GREEN}llm already installed. Skipping.${NC}"
    fi
}

# -----------------------
# Install llm-ollama plugin
# -----------------------
install_llm_ollama() {
    if ! llm plugins | grep -q 'ollama'; then
        echo -e "${BLUE}Installing llm-ollama plugin...${NC}"
        uv pip install llm-ollama
    else
        echo -e "${GREEN}llm-ollama plugin already installed. Skipping.${NC}"
    fi
}

# -----------------------
# Pull llama3.2:latest model
# -----------------------
pull_model() {
    if ! ollama list | grep -q 'llama3.2'; then
        echo -e "${BLUE}Pulling llama3.2:latest model...${NC}"
        ollama pull llama3.2:latest
    else
        echo -e "${GREEN}llama3.2:latest model already pulled. Skipping.${NC}"
    fi
}

# -----------------------
# Main execution
# -----------------------
detect_package_manager
install_ollama
start_ollama_serve
install_llm
install_llm_ollama
pull_model

# -----------------------
# Start interactive chat
# -----------------------
echo -e "${GREEN}✅ All set up! Starting interactive chat with llama3.2...${NC}"
llm chat -m llama3.2:latest

