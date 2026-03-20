#!/bin/bash
 
# ==================================================
#  LOCALTONET AUTO-RUN PRO v2.0
# ==================================================
 
# --- THEME & COLORS ---
RED='\033[1;31m'
LRED='\033[0;31m'
GREEN='\033[1;32m'
LGREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
LBLUE='\033[0;34m'
PURPLE='\033[1;35m'
LPURPLE='\033[0;35m'
CYAN='\033[1;36m'
LCYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DGRAY='\033[1;30m'
ORANGE='\033[38;5;214m'
PINK='\033[38;5;213m'
GOLD='\033[38;5;220m'
TEAL='\033[38;5;87m'
LIME='\033[38;5;154m'
NC='\033[0m'
BD='\033[1m'
 
# --- HELPERS ---
msg_info() { echo -e "  ${CYAN}${BD}  ➜  ${NC}${WHITE}$1${NC}"; }
msg_ok()   { echo -e "  ${GREEN}${BD}  ✔  ${NC}${LGREEN}$1${NC}"; }
msg_warn() { echo -e "  ${YELLOW}${BD}  ⚠  ${NC}${YELLOW}$1${NC}"; }
msg_err()  { echo -e "  ${RED}${BD}  ✖  ${NC}${LRED}$1${NC}"; }
 
divider() {
    echo -e "  ${DGRAY}  ─────────────────────────────────────────────────────${NC}"
}
 
# --- BRANDING ---
show_brand() {
    clear
    echo ""
    echo -e "${LBLUE}${BD}  ██╗      ██████╗  ██████╗ █████╗ ██╗  ████████╗ ██████╗ ███╗   ██╗███████╗████████╗${NC}"
    echo -e "${CYAN}${BD}  ██║     ██╔═══██╗██╔════╝██╔══██╗██║  ╚══██╔══╝██╔═══██╗████╗  ██║██╔════╝╚══██╔══╝${NC}"
    echo -e "${TEAL}${BD}  ██║     ██║   ██║██║     ███████║██║     ██║   ██║   ██║██╔██╗ ██║█████╗     ██║   ${NC}"
    echo -e "${BLUE}${BD}  ██║     ██║   ██║██║     ██╔══██║██║     ██║   ██║   ██║██║╚██╗██║██╔══╝     ██║   ${NC}"
    echo -e "${PURPLE}${BD}  ███████╗╚██████╔╝╚██████╗██║  ██║███████╗██║   ╚██████╔╝██║ ╚████║███████╗   ██║   ${NC}"
    echo -e "${PINK}${BD}  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝   ${NC}"
    echo -e "  ${GOLD}${BD}                       AUTO-RUN PRO${NC}  ${DGRAY}v2.0  ·  Instant TCP/UDP/HTTP Tunnels${NC}"
    echo ""
}
 
# =============================================
#  SHOW BRAND
# =============================================
show_brand
 
echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${BLUE}${BD}║${NC}  ${GOLD}${BD}       ⚡  LOCALTONET TUNNEL LAUNCHER  ⚡${NC}             ${BLUE}${BD}║${NC}"
echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}HOST   :${NC}  ${WHITE}${BD}$(hostname)${NC}"
echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}USER   :${NC}  ${CYAN}$(whoami)${NC}"
echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}SYSTEM :${NC}  ${GRAY}$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || uname -o)${NC}"
echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
 
# =============================================
#  STEP 1 — INSTALL CHECK
# =============================================
divider
echo -e "  ${TEAL}${BD}  [ STEP 1 of 4 ]  SYSTEM CHECK${NC}"
divider
echo ""
 
msg_info "Checking for LocalToNet installation..."
echo ""
 
if ! command -v localtonet &>/dev/null; then
    msg_warn "LocalToNet not found. Starting installation..."
    echo ""
 
    echo -ne "  ${GOLD}${BD}  [1/2]${NC}  ${WHITE}Downloading installer...              ${NC}"
    if curl -fsSL https://localtonet.com/install.sh | sh >/dev/null 2>&1; then
        echo -e "${GREEN}${BD}✔ DONE${NC}"
    else
        echo -e "${RED}${BD}✖ FAILED${NC}"
        echo ""
        msg_err "Installation failed. Check your internet connection."
        exit 1
    fi
 
    echo -ne "  ${GOLD}${BD}  [2/2]${NC}  ${WHITE}Verifying binary...                   ${NC}"
    if command -v localtonet &>/dev/null; then
        echo -e "${GREEN}${BD}✔ VERIFIED${NC}"
    else
        echo -e "${RED}${BD}✖ NOT FOUND${NC}"
        msg_err "LocalToNet binary not found after install. Try manually."
        exit 1
    fi
 
    echo ""
    msg_ok "LocalToNet installed successfully!"
else
    local_ver=$(localtonet --version 2>/dev/null | head -n1 || echo "Installed")
    msg_ok "LocalToNet is already installed  →  ${TEAL}$local_ver${NC}"
fi
 
echo ""
 
# =============================================
#  STEP 2 — AUTH TOKEN
# =============================================
divider
echo -e "  ${TEAL}${BD}  [ STEP 2 of 4 ]  AUTHENTICATION${NC}"
divider
echo ""
 
echo -e "  ${YELLOW}${BD}  ┌────────────────────────────────────────────────────┐${NC}"
echo -e "  ${YELLOW}${BD}  │  ➜  Enter your LocalToNet Auth-Token below.         │${NC}"
echo -e "  ${YELLOW}${BD}  │     Find it at: https://localtonet.com/usertoken    │${NC}"
echo -e "  ${YELLOW}${BD}  └────────────────────────────────────────────────────┘${NC}"
echo ""
echo -ne "  ${CYAN}${BD}  ➤  Auth-Token: ${NC}"
read -r USER_TOKEN
 
echo ""
 
# Validate token
if [[ -z "$USER_TOKEN" ]]; then
    msg_err "No token entered. Exiting."
    exit 1
fi
 
if [[ ${#USER_TOKEN} -lt 10 ]]; then
    msg_warn "Token looks too short — double-check it's correct."
fi
 
msg_info "Applying authentication token..."
if localtonet authtoken "$USER_TOKEN" >/dev/null 2>&1; then
    msg_ok "Token saved and authenticated successfully!"
else
    msg_err "Authentication failed. Please verify your token."
    exit 1
fi
 
echo ""
 
# =============================================
#  STEP 3 — TUNNEL TYPE
# =============================================
divider
echo -e "  ${TEAL}${BD}  [ STEP 3 of 4 ]  TUNNEL TYPE${NC}"
divider
echo ""
 
echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "  ${CYAN}${BD}│  ${TEAL}◈  SELECT TUNNEL PROTOCOL${NC}                                 ${CYAN}${BD}│${NC}"
echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}TCP     ${NC}${DGRAY}→  ${GREEN}General TCP port forwarding${NC}"
echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}UDP     ${NC}${DGRAY}→  ${BLUE}UDP-based services (games, VoIP)${NC}"
echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}HTTP    ${NC}${DGRAY}→  ${CYAN}Plain HTTP web services${NC}"
echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}HTTPS   ${NC}${DGRAY}→  ${PURPLE}Secure HTTPS web services${NC}"
echo ""
echo -ne "  ${CYAN}${BD}  ➤  Choose type (1-4): ${NC}"
read -r TYPE_CHOICE
 
echo ""
 
case $TYPE_CHOICE in
    1) TUNNEL_TYPE="tcp"   ; TYPE_LABEL="${GREEN}TCP${NC}"   ;;
    2) TUNNEL_TYPE="udp"   ; TYPE_LABEL="${BLUE}UDP${NC}"   ;;
    3) TUNNEL_TYPE="http"  ; TYPE_LABEL="${CYAN}HTTP${NC}"  ;;
    4) TUNNEL_TYPE="https" ; TYPE_LABEL="${PURPLE}HTTPS${NC}" ;;
    *)
        msg_warn "Invalid choice. Defaulting to TCP."
        TUNNEL_TYPE="tcp"
        TYPE_LABEL="${GREEN}TCP${NC}"
        ;;
esac
 
msg_ok "Tunnel type set to: $TYPE_LABEL"
echo ""
 
# =============================================
#  STEP 4 — PORT INPUT
# =============================================
divider
echo -e "  ${TEAL}${BD}  [ STEP 4 of 4 ]  PORT CONFIGURATION${NC}"
divider
echo ""
 
echo -e "  ${YELLOW}${BD}  ┌────────────────────────────────────────────────────┐${NC}"
echo -e "  ${YELLOW}${BD}  │  ➜  Enter the local port you want to expose.        │${NC}"
echo -e "  ${YELLOW}${BD}  │     Examples: 80 (HTTP), 3000 (Node), 8080 (Web)   │${NC}"
echo -e "  ${YELLOW}${BD}  └────────────────────────────────────────────────────┘${NC}"
echo ""
echo -ne "  ${CYAN}${BD}  ➤  Local Port: ${NC}"
read -r USER_PORT
 
echo ""
 
# Validate port
if [[ -z "$USER_PORT" ]]; then
    msg_err "No port entered. Exiting."
    exit 1
fi
 
if ! [[ "$USER_PORT" =~ ^[0-9]+$ ]] || (( USER_PORT < 1 || USER_PORT > 65535 )); then
    msg_err "Invalid port: '$USER_PORT'. Must be a number between 1 and 65535."
    exit 1
fi
 
msg_ok "Port configured: ${GOLD}${BD}$USER_PORT${NC}"
echo ""
 
# =============================================
#  LAUNCH TUNNEL
# =============================================
divider
echo ""
echo -e "  ${PURPLE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${PURPLE}${BD}║${NC}  ${GOLD}${BD}           🚀  LAUNCHING TUNNEL  🚀${NC}                      ${PURPLE}${BD}║${NC}"
echo -e "  ${PURPLE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${PURPLE}${BD}║${NC}  ${DGRAY}PROTOCOL  :${NC}  $TYPE_LABEL"
echo -e "  ${PURPLE}${BD}║${NC}  ${DGRAY}LOCAL PORT:${NC}  ${GOLD}${BD}$USER_PORT${NC}"
echo -e "  ${PURPLE}${BD}║${NC}  ${DGRAY}STATUS    :${NC}  ${LIME}${BD}◉ STARTING...${NC}"
echo -e "  ${PURPLE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${DGRAY}  Press CTRL+C to stop the tunnel at any time.${NC}"
divider
echo ""
 
# Launch tunnel with type and port
localtonet "$TUNNEL_TYPE" --portnumber "$USER_PORT"
