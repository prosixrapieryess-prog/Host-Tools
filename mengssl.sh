#!/bin/bash
 
# ==================================================
#  NGINX SSL PANEL v2.0
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
 
# --- CONFIG ---
DIR="/etc/nginx/sites-available"
ENABLED_DIR="/etc/nginx/sites-enabled"
 
# --- HELPERS ---
msg_info() { echo -e "  ${CYAN}${BD}  ➜  ${NC}${WHITE}$1${NC}"; }
msg_ok()   { echo -e "  ${GREEN}${BD}  ✔  ${NC}${LGREEN}$1${NC}"; }
msg_warn() { echo -e "  ${YELLOW}${BD}  ⚠  ${NC}${YELLOW}$1${NC}"; }
msg_err()  { echo -e "  ${RED}${BD}  ✖  ${NC}${LRED}$1${NC}"; }
 
divider() {
    echo -e "  ${DGRAY}  ─────────────────────────────────────────────────────${NC}"
}
 
pause() {
    echo ""
    divider
    echo -ne "  ${CYAN}  Press any key to return...${NC}"
    read -n 1 -s -r
    echo ""
}
 
# --- ROOT CHECK ---
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo -e "  ${RED}${BD}  ╔══════════════════════════════════════╗${NC}"
    echo -e "  ${RED}${BD}  ║   ✖  ROOT PRIVILEGES REQUIRED        ║${NC}"
    echo -e "  ${RED}${BD}  ╚══════════════════════════════════════╝${NC}"
    echo -e "  ${YELLOW}  Run with: ${WHITE}sudo bash $0${NC}"
    echo ""
    exit 1
fi
 
# ==================================================
#  BRANDING
# ==================================================
show_brand() {
    echo ""
    echo -e "${LBLUE}${BD}  ███╗   ██╗ ██████╗ ██╗███╗   ██╗██╗  ██╗${NC}"
    echo -e "${CYAN}${BD}  ████╗  ██║██╔════╝ ██║████╗  ██║╚██╗██╔╝${NC}"
    echo -e "${TEAL}${BD}  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║ ╚███╔╝ ${NC}"
    echo -e "${BLUE}${BD}  ██║╚██╗██║██║   ██║██║██║╚██╗██║ ██╔██╗ ${NC}"
    echo -e "${PURPLE}${BD}  ██║ ╚████║╚██████╔╝██║██║ ╚████║██╔╝ ██╗${NC}"
    echo -e "${PINK}${BD}  ╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝${NC}"
    echo -e "  ${GOLD}${BD}            SSL PANEL${NC}  ${DGRAY}v2.0  ·  Nginx Virtual Host Manager${NC}"
    echo ""
}
 
# ==================================================
#  NGINX STATUS BADGE
# ==================================================
nginx_badge() {
    if systemctl is-active --quiet nginx 2>/dev/null; then
        echo -e "${LIME}${BD}◉ RUNNING${NC}"
    else
        echo -e "${RED}${BD}◉ STOPPED${NC}"
    fi
}
 
# ==================================================
#  HEADER
# ==================================================
draw_header() {
    clear
    show_brand
 
    local count
    count=$(ls "$DIR"/*.conf 2>/dev/null | wc -l)
    [[ "$count" -eq 0 ]] && count="0"
 
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${GOLD}${BD}        ⚡  NGINX SSL CONTROL PANEL  ⚡${NC}              ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}HOST    :${NC}  ${WHITE}${BD}$(hostname)${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}NGINX   :${NC}  $(nginx_badge)"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}SITES   :${NC}  ${ORANGE}${BD}$count configured${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}CONFIG  :${NC}  ${GRAY}$DIR${NC}"
    echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}
 
# ==================================================
#  SHOW SITES — BUG FIX: arr is global, reset each call
# ==================================================
declare -A arr
 
show_sites() {
    # Reset array each time to avoid stale entries
    unset arr
    declare -gA arr
 
    echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}${BD}│  ${TEAL}◈  CONFIGURED SITES${NC}                                       ${CYAN}${BD}│${NC}"
    echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
 
    # BUG FIX: Check if any .conf files actually exist before globbing
    local files=("$DIR"/*.conf)
    if [[ ! -e "${files[0]}" ]]; then
        echo -e "    ${DGRAY}  No .conf sites found in $DIR${NC}"
        echo ""
        return 1
    fi
 
    local i=1
    for f in "${files[@]}"; do
        local name
        name=$(basename "$f")
 
        # Check if site is enabled (symlink exists in sites-enabled)
        local enabled_badge="${DGRAY}  disabled${NC}"
        [[ -L "$ENABLED_DIR/$name" ]] && enabled_badge="${LIME}${BD}◉ enabled${NC}"
 
        printf "  ${GOLD}${BD}  %-3s${NC}  ${WHITE}%-35s${NC}  %b\n" "$i)" "$name" "$enabled_badge"
        arr[$i]="$f"
        ((i++))
    done
 
    echo ""
    return 0
}
 
# ==================================================
#  SELECT SITE HELPER
# ==================================================
select_site() {
    local prompt="$1"
    show_sites || return 1
 
    divider
    echo -ne "  ${CYAN}${BD}  ➜  $prompt: ${NC}"
    read -r num
 
    if [[ -z "$num" || -z "${arr[$num]}" ]]; then
        msg_err "Invalid selection."
        return 1
    fi
 
    SELECTED_FILE="${arr[$num]}"
    SELECTED_NAME=$(basename "$SELECTED_FILE")
    return 0
}
 
# ==================================================
#  1 — CREATE SSL PANEL
# ==================================================
create_panel() {
    clear; draw_header
    divider
    echo -e "  ${LIME}${BD}  [ CREATE NEW SSL SITE ]${NC}"
    divider
    echo ""
    msg_info "Launching SSL creation wizard..."
    echo ""
    bash <(curl -s https://raw.githubusercontent.com/nobita329/hub/refs/heads/main/Codinghub/toolbox/cssl.sh) 2>/dev/null \
        || msg_err "Could not fetch creation script. Check your connection."
    pause
}
 
# ==================================================
#  2 — MANAGE PANEL (nginx service controls)
# ==================================================
manage_panel() {
    clear; draw_header
 
    divider
    echo -e "  ${TEAL}${BD}  [ MANAGE NGINX SERVICE ]${NC}"
    divider
    echo ""
 
    echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}${BD}│  ${TEAL}◈  SERVICE CONTROLS${NC}                                       ${CYAN}${BD}│${NC}"
    echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Start Nginx      ${NC}${DGRAY}→  ${LIME}Launch nginx service${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Stop Nginx       ${NC}${DGRAY}→  ${ORANGE}Halt nginx service${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}Restart Nginx    ${NC}${DGRAY}→  ${CYAN}Full service restart${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}Reload Nginx     ${NC}${DGRAY}→  ${BLUE}Hot-reload config${NC}"
    echo -e "  ${GOLD}${BD}  5)${NC}  ${WHITE}Enable on boot   ${NC}${DGRAY}→  ${GREEN}Enable systemd unit${NC}"
    echo -e "  ${GOLD}${BD}  6)${NC}  ${WHITE}Disable on boot  ${NC}${DGRAY}→  ${RED}Disable systemd unit${NC}"
    echo -e "  ${GOLD}${BD}  7)${NC}  ${WHITE}Test Config      ${NC}${DGRAY}→  ${YELLOW}Validate nginx.conf${NC}"
    echo ""
    echo -e "  ${RED}${BD}  0)${NC}${LRED}  ↩  Back${NC}"
    echo ""
    divider
    echo -ne "  ${BLUE}${BD}  ➤  Choose action: ${NC}"
    read -r m
 
    echo ""
    case $m in
        1) msg_info "Starting Nginx...";  systemctl start nginx   && msg_ok "Nginx started."   || msg_err "Failed." ;;
        2) msg_info "Stopping Nginx...";  systemctl stop nginx    && msg_ok "Nginx stopped."   || msg_err "Failed." ;;
        3) msg_info "Restarting Nginx..."; systemctl restart nginx && msg_ok "Nginx restarted." || msg_err "Failed." ;;
        4) msg_info "Reloading config..."; nginx -t 2>/dev/null && systemctl reload nginx && msg_ok "Config reloaded." || msg_err "Config test failed — not reloaded." ;;
        5) msg_info "Enabling Nginx on boot..."; systemctl enable nginx && msg_ok "Nginx enabled." || msg_err "Failed." ;;
        6) msg_info "Disabling Nginx on boot..."; systemctl disable nginx && msg_ok "Nginx disabled." || msg_err "Failed." ;;
        7) echo ""
           divider
           echo -e "  ${YELLOW}${BD}  Config Test Output:${NC}"
           divider
           nginx -t 2>&1 | sed 's/^/  /'
           divider ;;
        0) return ;;
        *) msg_err "Invalid option." ;;
    esac
    pause
}
 
# ==================================================
#  3 — DELETE PANEL
# ==================================================
delete_panel() {
    clear; draw_header
    divider
    echo -e "  ${RED}${BD}  [ DELETE SITE ]${NC}"
    divider
    echo ""
 
    select_site "Select site number to delete" || { pause; return; }
 
    echo ""
    echo -e "  ${YELLOW}${BD}  ⚠  You are about to delete:${NC}"
    echo -e "    ${WHITE}${BD}$SELECTED_NAME${NC}"
    echo ""
    echo -ne "  ${RED}${BD}  ➤  Confirm deletion? (y/N): ${NC}"
    read -r confirm
    echo ""
 
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        msg_info "Deletion cancelled."
        pause
        return
    fi
 
    # BUG FIX: original code did:
    #   rm -f ${arr[$num]}                          — removes full path (correct)
    #   rm -f /etc/nginx/sites-available/${arr[$num]} — WRONG: double path
    #   rm -f /etc/nginx/sites-enabled/${arr[$num]}   — WRONG: double path
    # Fixed: use basename for sites-enabled, full path for sites-available
 
    local base_name
    base_name=$(basename "$SELECTED_FILE")
 
    msg_info "Removing site config from sites-available..."
    rm -f "$SELECTED_FILE" && msg_ok "Removed: $DIR/$base_name"
 
    msg_info "Removing symlink from sites-enabled..."
    rm -f "$ENABLED_DIR/$base_name" && msg_ok "Removed symlink: $ENABLED_DIR/$base_name" || msg_warn "No symlink found in sites-enabled."
 
    msg_info "Testing and reloading nginx..."
    if nginx -t >/dev/null 2>&1; then
        systemctl reload nginx
        msg_ok "Nginx reloaded successfully."
    else
        msg_err "Nginx config test failed after deletion — manual fix may be needed."
        nginx -t 2>&1 | sed 's/^/  /'
    fi
 
    echo ""
    divider
    msg_ok "Site '$base_name' deleted."
    divider
    pause
}
 
# ==================================================
#  4 — EDIT PANEL
# ==================================================
edit_panel() {
    clear; draw_header
    divider
    echo -e "  ${YELLOW}${BD}  [ EDIT SITE CONFIG ]${NC}"
    divider
    echo ""
 
    select_site "Select site number to edit" || { pause; return; }
 
    # Check editor availability
    local editor="nano"
    command -v nano &>/dev/null || { command -v vi &>/dev/null && editor="vi"; } || {
        msg_err "No text editor found (nano/vi). Install nano first."
        pause
        return
    }
 
    msg_info "Opening: ${CYAN}$SELECTED_NAME${NC} in $editor"
    echo ""
    sleep 0.5
    $editor "$SELECTED_FILE"
 
    echo ""
    msg_info "Testing nginx config after edit..."
    if nginx -t >/dev/null 2>&1; then
        msg_ok "Config valid. Reloading nginx..."
        systemctl reload nginx && msg_ok "Nginx reloaded with new config."
    else
        echo ""
        divider
        msg_err "Config test FAILED — nginx NOT reloaded. Fix the errors:"
        divider
        nginx -t 2>&1 | sed 's/^/  /'
        divider
    fi
    pause
}
 
# ==================================================
#  5 — VIEW SITE DETAILS
# ==================================================
view_details() {
    clear; draw_header
    divider
    echo -e "  ${PURPLE}${BD}  [ VIEW SITE DETAILS ]${NC}"
    divider
    echo ""
 
    select_site "Select site number to view" || { pause; return; }
 
    echo ""
    echo -e "  ${PINK}${BD}  File: ${CYAN}$SELECTED_NAME${NC}"
    divider
    cat "$SELECTED_FILE" 2>/dev/null | sed 's/^/  /' | \
    while IFS= read -r line; do
        # Highlight server_name, listen, ssl lines
        if echo "$line" | grep -q "server_name"; then
            echo -e "${GOLD}$line${NC}"
        elif echo "$line" | grep -q "listen"; then
            echo -e "${CYAN}$line${NC}"
        elif echo "$line" | grep -q "ssl_certificate"; then
            echo -e "${LIME}$line${NC}"
        elif echo "$line" | grep -q "#"; then
            echo -e "${DGRAY}$line${NC}"
        else
            echo -e "${GRAY}$line${NC}"
        fi
    done
    divider
    pause
}
 
# ==================================================
#  MAIN MENU LOOP
# ==================================================
while true; do
    draw_header
 
    # Sites Overview
    show_sites
 
    # Menu
    echo -e "  ${BLUE}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${BLUE}${BD}│  ${TEAL}◈  PANEL ACTIONS${NC}                                           ${BLUE}${BD}│${NC}"
    echo -e "  ${BLUE}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Create SSL Site  ${NC}${DGRAY}→  ${GREEN}Add a new virtual host${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Manage Nginx     ${NC}${DGRAY}→  ${CYAN}Start · Stop · Restart · Reload${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}Delete Site      ${NC}${DGRAY}→  ${RED}Remove a virtual host config${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}Edit Site        ${NC}${DGRAY}→  ${YELLOW}Open config in nano/vi${NC}"
    echo -e "  ${GOLD}${BD}  5)${NC}  ${WHITE}View Site Config ${NC}${DGRAY}→  ${PURPLE}Preview with syntax highlighting${NC}"
    echo ""
    echo -e "  ${CYAN}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${CYAN}${BD}║${NC}  ${RED}${BD}  0)  ↩  Exit SSL Panel${NC}                                   ${CYAN}${BD}║${NC}"
    echo -e "  ${CYAN}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "  ${BLUE}${BD}  root@nginx:~# ${NC}"
    read -r opt
 
    case $opt in
        1) create_panel ;;
        2) manage_panel ;;
        3) delete_panel ;;
        4) edit_panel ;;
        5) view_details ;;
        0)
            clear
            echo ""
            echo -e "  ${GOLD}${BD}  👋  Nginx SSL Panel offline. Stay secure!${NC}"
            echo ""
            sleep 1
            exit 0 ;;
        *)
            msg_err "Invalid option. Choose 0–5."
            sleep 1 ;;
    esac
done
