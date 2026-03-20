#!/bin/bash
 
# ==================================================
#  TAILSCALE MESH COMMANDER v3.2 — MULTI-METHOD
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
 
# --- HELPER FUNCTIONS ---
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
 
get_hostname() {
    if command -v hostname &>/dev/null; then hostname
    elif [ -f /etc/hostname ]; then head -n 1 /etc/hostname
    else echo "Unknown-Host"; fi
}
 
# ==================================================
#  BRANDING
# ==================================================
show_brand() {
    echo ""
    echo -e "${LBLUE}${BD}  ████████╗ █████╗ ██╗██╗      ███████╗ ██████╗ █████╗ ██╗     ███████╗${NC}"
    echo -e "${CYAN}${BD}  ╚══██╔══╝██╔══██╗██║██║      ██╔════╝██╔════╝██╔══██╗██║     ██╔════╝${NC}"
    echo -e "${TEAL}${BD}     ██║   ███████║██║██║      ███████╗██║     ███████║██║     █████╗  ${NC}"
    echo -e "${BLUE}${BD}     ██║   ██╔══██║██║██║      ╚════██║██║     ██╔══██║██║     ██╔══╝  ${NC}"
    echo -e "${PURPLE}${BD}     ██║   ██║  ██║██║███████╗███████║╚██████╗██║  ██║███████╗███████╗${NC}"
    echo -e "${PINK}${BD}     ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝${NC}"
    echo -e "  ${GOLD}${BD}                    MESH COMMANDER${NC}  ${DGRAY}v3.2  ⬡ Secure Network Overlay${NC}"
    echo ""
}
 
# ==================================================
#  HEADER
# ==================================================
draw_header() {
    clear
    local host_name os_info ts_status ts_ip exit_node health_check ts_version peer_count
 
    host_name=$(get_hostname)
    os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    [[ -z "$os_info" ]] && os_info="Unknown OS"
 
    ts_status="${RED}${BD}◉ NOT INSTALLED${NC}"
    ts_ip="${DGRAY}  ---${NC}"
    exit_node="${DGRAY}  INACTIVE${NC}"
    health_check="${RED}${BD}◉ DISCONNECTED${NC}"
    ts_version="${DGRAY}  ---${NC}"
    peer_count="${DGRAY}  0 peers${NC}"
 
    if command -v tailscale &>/dev/null; then
        ts_version="${TEAL}$(tailscale version 2>/dev/null | head -n1)${NC}"
        if systemctl is-active --quiet tailscaled 2>/dev/null; then
            ts_status="${LIME}${BD}◉ ACTIVE  ·  MESH ONLINE${NC}"
            local ip_fetch
            ip_fetch=$(tailscale ip -4 2>/dev/null)
            if [[ -n "$ip_fetch" ]]; then
                ts_ip="${CYAN}${BD}  $ip_fetch${NC}"
                health_check="${GREEN}${BD}◉ CONNECTED${NC}"
            else
                ts_ip="${YELLOW}  Needs Authentication${NC}"
                health_check="${YELLOW}${BD}◉ PENDING AUTH${NC}"
            fi
            tailscale status 2>/dev/null | grep -q "exit node" && \
                exit_node="${PURPLE}${BD}  ACTIVE${NC}"
            local pc
            pc=$(tailscale status 2>/dev/null | grep -c "^\s*[0-9]" 2>/dev/null || echo 0)
            peer_count="${ORANGE}${BD}  $pc peers${NC}"
        else
            ts_status="${RED}${BD}◉ SERVICE STOPPED${NC}"
        fi
    fi
 
    show_brand
 
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${GOLD}${BD}        ⚡  SECURE NETWORK OVERLAY SYSTEM  ⚡${NC}          ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}DEVICE   :${NC}  ${WHITE}${BD}$host_name${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}SYSTEM   :${NC}  ${GRAY}$os_info${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${DGRAY}VERSION  :${NC}  $ts_version"
    echo -e "  ${BLUE}${BD}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${PINK}${BD}  🔗  MESH STATUS${NC}"
    echo -e "  ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}STATUS    :${NC}  $ts_status"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}VIRTUAL IP:${NC}  $ts_ip"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}EXIT NODE :${NC}  $exit_node"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}PEERS     :${NC}  $peer_count"
    echo -e "  ${BLUE}${BD}║${NC}    ${DGRAY}HEALTH    :${NC}  $health_check"
    echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}
 
# ==================================================
#  DETECT OS INFO FOR APT REPO
# ==================================================
_get_os_codename() {
    # Returns e.g. "bookworm", "bullseye", "jammy", "focal"
    local codename=""
    codename=$(. /etc/os-release 2>/dev/null && echo "${VERSION_CODENAME:-}")
    [[ -z "$codename" ]] && codename=$(lsb_release -cs 2>/dev/null)
    [[ -z "$codename" ]] && codename="bookworm"   # safe Debian fallback
    echo "$codename"
}
 
_get_os_id() {
    local id=""
    id=$(. /etc/os-release 2>/dev/null && echo "${ID:-}")
    [[ -z "$id" ]] && id="debian"
    echo "$id"
}
 
# ==================================================
#  NET CHECK HELPER — tests multiple hosts
# ==================================================
_check_net() {
    local hosts=("1.1.1.1" "8.8.8.8" "google.com" "apt.releases.tailscale.com" "tailscale.com")
    for h in "${hosts[@]}"; do
        if curl -fsSL --max-time 6 --head "https://$h" >/dev/null 2>&1 || \
           curl -fsSL --max-time 6 "http://$h" >/dev/null 2>&1 || \
           ping -c 1 -W 3 "$h" >/dev/null 2>&1; then
            echo "$h"
            return 0
        fi
    done
    return 1
}
 
# ==================================================
#  METHOD A — Official install.sh (needs tailscale.com)
# ==================================================
_install_method_a() {
    echo -ne "  ${GOLD}${BD}  [A]${NC}  ${WHITE}Official install.sh (tailscale.com)...  ${NC}"
    curl -fsSL --max-time 30 https://tailscale.com/install.sh -o /tmp/ts_install.sh 2>/dev/null
    if [[ $? -ne 0 || ! -s /tmp/ts_install.sh ]]; then
        echo -e "${RED}${BD}✖ UNREACHABLE${NC}"
        rm -f /tmp/ts_install.sh
        return 1
    fi
    bash /tmp/ts_install.sh >/dev/null 2>&1
    rm -f /tmp/ts_install.sh
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"
    return 1
}
 
# ==================================================
#  METHOD B — apt repo (pkgs.tailscale.com) — works
#             even when tailscale.com is blocked
# ==================================================
_install_method_b() {
    echo -ne "  ${GOLD}${BD}  [B]${NC}  ${WHITE}APT package repo method...              ${NC}"
 
    if ! command -v apt-get &>/dev/null; then
        echo -e "${DGRAY}✖ NOT APT SYSTEM${NC}"
        return 1
    fi
 
    local codename os_id
    codename=$(_get_os_codename)
    os_id=$(_get_os_id)
 
    # Map Ubuntu/Debian to correct repo path
    # Tailscale uses same codenames for Ubuntu & Debian
    local repo_url="https://pkgs.tailscale.com/stable/${os_id}/${codename}"
 
    # Check if repo server reachable
    if ! curl -fsSL --max-time 8 --head "$repo_url" >/dev/null 2>&1; then
        echo -e "${RED}${BD}✖ REPO UNREACHABLE${NC}"
        return 1
    fi
 
    # Add GPG key
    mkdir -p /usr/share/keyrings
    curl -fsSL "https://pkgs.tailscale.com/stable/${os_id}/${codename}.noarmor.gpg" \
        -o /usr/share/keyrings/tailscale-archive-keyring.gpg 2>/dev/null || {
        echo -e "${RED}${BD}✖ GPG FAILED${NC}"
        return 1
    }
 
    # Add repo
    echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] \
https://pkgs.tailscale.com/stable/${os_id} ${codename} main" \
        > /etc/apt/sources.list.d/tailscale.list
 
    # Install
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq tailscale >/dev/null 2>&1
 
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"
    # Cleanup failed repo
    rm -f /etc/apt/sources.list.d/tailscale.list \
          /usr/share/keyrings/tailscale-archive-keyring.gpg 2>/dev/null
    return 1
}
 
# ==================================================
#  METHOD C — Direct .deb download from pkgs server
# ==================================================
_install_method_c() {
    echo -ne "  ${GOLD}${BD}  [C]${NC}  ${WHITE}Direct .deb binary download...          ${NC}"
 
    if ! command -v apt-get &>/dev/null; then
        echo -e "${DGRAY}✖ NOT APT SYSTEM${NC}"
        return 1
    fi
 
    local arch
    arch=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
    local codename
    codename=$(_get_os_codename)
    local os_id
    os_id=$(_get_os_id)
 
    # Fetch latest .deb URL from pkgs.tailscale.com
    local pkg_url="https://pkgs.tailscale.com/stable/${os_id}/${codename}/pool/tailscale_latest_${arch}.deb"
 
    curl -fsSL --max-time 60 "$pkg_url" -o /tmp/tailscale_latest.deb 2>/dev/null
    if [[ $? -ne 0 || ! -s /tmp/tailscale_latest.deb ]]; then
        echo -e "${RED}${BD}✖ DOWNLOAD FAILED${NC}"
        rm -f /tmp/tailscale_latest.deb
        return 1
    fi
 
    dpkg -i /tmp/tailscale_latest.deb >/dev/null 2>&1
    apt-get install -f -y -qq >/dev/null 2>&1   # fix any deps
    rm -f /tmp/tailscale_latest.deb
 
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"
    return 1
}
 
# ==================================================
#  METHOD D — dnf/yum (RHEL/CentOS/Fedora)
# ==================================================
_install_method_d() {
    echo -ne "  ${GOLD}${BD}  [D]${NC}  ${WHITE}DNF/YUM package manager...              ${NC}"
    if command -v dnf &>/dev/null; then
        dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo >/dev/null 2>&1
        dnf install -y tailscale >/dev/null 2>&1
    elif command -v yum &>/dev/null; then
        yum install -y yum-utils >/dev/null 2>&1
        yum-config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo >/dev/null 2>&1
        yum install -y tailscale >/dev/null 2>&1
    else
        echo -e "${DGRAY}✖ NOT DNF/YUM SYSTEM${NC}"
        return 1
    fi
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"
    return 1
}
 
# ==================================================
#  METHOD E — apk (Alpine)
# ==================================================
_install_method_e() {
    echo -ne "  ${GOLD}${BD}  [E]${NC}  ${WHITE}APK (Alpine) install...                 ${NC}"
    if ! command -v apk &>/dev/null; then
        echo -e "${DGRAY}✖ NOT ALPINE${NC}"
        return 1
    fi
    apk add tailscale >/dev/null 2>&1
    command -v tailscale &>/dev/null && echo -e "${GREEN}${BD}✔ DONE${NC}" && return 0
    echo -e "${RED}${BD}✖ FAILED${NC}"
    return 1
}
 
# ==================================================
#  START TAILSCALE DAEMON (handles no-systemd)
# ==================================================
_start_daemon() {
    echo -ne "  ${GOLD}${BD}  ···${NC}  ${WHITE}Starting tailscaled daemon...           ${NC}"
 
    # Try systemctl first
    if command -v systemctl &>/dev/null && systemctl enable --now tailscaled >/dev/null 2>&1; then
        echo -e "${GREEN}${BD}✔ SYSTEMD ACTIVE${NC}"
        return 0
    fi
 
    # Try service command
    if command -v service &>/dev/null && service tailscaled start >/dev/null 2>&1; then
        echo -e "${GREEN}${BD}✔ SERVICE ACTIVE${NC}"
        return 0
    fi
 
    # Try rc-service (Alpine)
    if command -v rc-service &>/dev/null && rc-service tailscale start >/dev/null 2>&1; then
        echo -e "${GREEN}${BD}✔ RC SERVICE ACTIVE${NC}"
        return 0
    fi
 
    # Manual daemon start as last resort
    mkdir -p /var/lib/tailscale
    tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock &>/dev/null &
    sleep 3
    if pgrep tailscaled &>/dev/null; then
        echo -e "${GREEN}${BD}✔ RUNNING (manual)${NC}"
        return 0
    fi
 
    echo -e "${RED}${BD}✖ FAILED — try: tailscaled &${NC}"
    return 1
}
 
# ==================================================
#  MAIN INSTALL FUNCTION
# ==================================================
install_tailscale() {
    clear
    draw_header
    divider
    echo -e "  ${LIME}${BD}  [ INSTALL & CONNECT TO MESH ]${NC}"
    divider
    echo ""
 
    # --- Already installed: offer re-auth ---
    if command -v tailscale &>/dev/null; then
        msg_warn "Tailscale is already installed."
        echo -ne "  ${PURPLE}${BD}  ➤  Re-authenticate instead? (y/N): ${NC}"
        read -r reauth
        echo ""
        if [[ "$reauth" =~ ^[Yy]$ ]]; then
            msg_info "Launching Authentication..."
            echo ""
            tailscale up 2>&1
            echo ""
            local ts_ip_r
            ts_ip_r=$(tailscale ip -4 2>/dev/null)
            if [[ -n "$ts_ip_r" ]]; then
                msg_ok "Connected! IP: ${CYAN}${BD}$ts_ip_r${NC}"
            else
                msg_warn "Complete auth via the link above, then re-run option 1."
            fi
        else
            msg_info "Operation Cancelled."
        fi
        pause
        return
    fi
 
    # --- Network diagnostic ---
    echo -e "  ${PINK}${BD}  🌐  NETWORK DIAGNOSTIC${NC}"
    echo ""
 
    echo -ne "  ${GOLD}${BD}  ···${NC}  ${WHITE}Testing internet connectivity...        ${NC}"
    local reachable_host
    reachable_host=$(_check_net)
    if [[ -n "$reachable_host" ]]; then
        echo -e "${GREEN}${BD}✔ ONLINE${NC}  ${DGRAY}(via $reachable_host)${NC}"
    else
        echo -e "${RED}${BD}✖ NO INTERNET${NC}"
        echo ""
        divider
        msg_err "No internet access detected on this server."
        echo ""
        echo -e "  ${YELLOW}${BD}  Diagnostics — run these manually:${NC}"
        echo -e "  ${WHITE}  ping -c 3 8.8.8.8${NC}          ${DGRAY}# test raw IP routing${NC}"
        echo -e "  ${WHITE}  ping -c 3 google.com${NC}       ${DGRAY}# test DNS resolution${NC}"
        echo -e "  ${WHITE}  curl -v https://tailscale.com${NC} ${DGRAY}# test HTTPS${NC}"
        echo -e "  ${WHITE}  cat /etc/resolv.conf${NC}       ${DGRAY}# check DNS config${NC}"
        echo ""
        echo -e "  ${YELLOW}  Common causes:${NC}"
        echo -e "  ${DGRAY}  · Pterodactyl/Docker container with no outbound access${NC}"
        echo -e "  ${DGRAY}  · VPS firewall blocking port 443/80${NC}"
        echo -e "  ${DGRAY}  · Missing nameserver in /etc/resolv.conf${NC}"
        echo ""
        echo -e "  ${CYAN}  Quick DNS fix to try:${NC}"
        echo -e "  ${WHITE}  echo 'nameserver 1.1.1.1' >> /etc/resolv.conf${NC}"
        divider
        pause
        return
    fi
 
    echo ""
    echo -e "  ${PINK}${BD}  📦  TRYING INSTALL METHODS (auto-fallback)${NC}"
    echo ""
 
    local installed=0
 
    # Try each method in order, stop at first success
    _install_method_a && installed=1
    [[ $installed -eq 0 ]] && _install_method_b && installed=1
    [[ $installed -eq 0 ]] && _install_method_c && installed=1
    [[ $installed -eq 0 ]] && _install_method_d && installed=1
    [[ $installed -eq 0 ]] && _install_method_e && installed=1
 
    echo ""
 
    if [[ $installed -eq 0 ]] || ! command -v tailscale &>/dev/null; then
        divider
        msg_err "All installation methods failed."
        echo ""
        echo -e "  ${YELLOW}${BD}  Manual install options:${NC}"
        echo -e "  ${WHITE}  # Debian/Ubuntu:${NC}"
        echo -e "  ${DGRAY}  curl -fsSL https://tailscale.com/install.sh | sh${NC}"
        echo ""
        echo -e "  ${WHITE}  # Or add repo manually:${NC}"
        echo -e "  ${DGRAY}  apt-get install -y apt-transport-https${NC}"
        echo -e "  ${DGRAY}  curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \\${NC}"
        echo -e "  ${DGRAY}    -o /usr/share/keyrings/tailscale-archive-keyring.gpg${NC}"
        echo -e "  ${DGRAY}  echo 'deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] \\${NC}"
        echo -e "  ${DGRAY}    https://pkgs.tailscale.com/stable/debian bookworm main' \\${NC}"
        echo -e "  ${DGRAY}    > /etc/apt/sources.list.d/tailscale.list${NC}"
        echo -e "  ${DGRAY}  apt-get update && apt-get install -y tailscale${NC}"
        divider
        pause
        return
    fi
 
    msg_ok "Tailscale installed: ${TEAL}$(tailscale version 2>/dev/null | head -n1)${NC}"
    echo ""
 
    # --- Start daemon ---
    _start_daemon
    echo ""
    sleep 2
 
    # --- Authenticate ---
    divider
    echo -e "  ${YELLOW}${BD}  ┌────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}  │  ➜  A URL will appear below. Open it in a browser   │${NC}"
    echo -e "  ${YELLOW}${BD}  │     to authenticate and join the Tailscale network. │${NC}"
    echo -e "  ${YELLOW}${BD}  │  ➜  If no URL shows, run: tailscale up              │${NC}"
    echo -e "  ${YELLOW}${BD}  └────────────────────────────────────────────────────┘${NC}"
    echo ""
 
    tailscale up 2>&1
 
    # --- Verify ---
    echo ""
    divider
    local ts_ip_check
    ts_ip_check=$(tailscale ip -4 2>/dev/null)
    if [[ -n "$ts_ip_check" ]]; then
        msg_ok "Connected! Tailscale IP: ${CYAN}${BD}$ts_ip_check${NC}"
        msg_ok "Device successfully joined the Mesh Network!"
    else
        msg_warn "Tailscale installed but authentication pending."
        msg_info "Complete auth in your browser, then select option 1 → re-authenticate."
    fi
    divider
    pause
}
 
# ==================================================
#  UNINSTALL
# ==================================================
uninstall_tailscale() {
    clear; draw_header
    divider
    echo -e "  ${RED}${BD}  [ UNINSTALL TAILSCALE ]${NC}"
    divider
    echo ""
 
    if ! command -v tailscale &>/dev/null; then
        msg_err "Tailscale is not installed."
        pause; return
    fi
 
    msg_warn "DESTRUCTIVE ACTION — This severs all mesh connections."
    echo ""
    echo -ne "  ${PURPLE}${BD}  ➤  Confirm Removal? (y/N): ${NC}"
    read -r confirm
    echo ""
 
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        msg_info "Disconnecting from Mesh..."
        tailscale down 2>/dev/null
 
        msg_info "Stopping Services..."
        systemctl stop tailscaled 2>/dev/null
        systemctl disable tailscaled 2>/dev/null
        rc-service tailscale stop 2>/dev/null || true
 
        msg_info "Removing Packages..."
        if command -v apt-get &>/dev/null; then
            apt-get purge -y -qq tailscale >/dev/null 2>&1
        elif command -v dnf &>/dev/null; then
            dnf remove -y tailscale >/dev/null 2>&1
        elif command -v yum &>/dev/null; then
            yum remove -y tailscale >/dev/null 2>&1
        elif command -v apk &>/dev/null; then
            apk del tailscale >/dev/null 2>&1
        fi
 
        msg_info "Wiping configs..."
        rm -rf /var/lib/tailscale /etc/tailscale \
               /etc/apt/sources.list.d/tailscale.list \
               /usr/share/keyrings/tailscale-archive-keyring.gpg 2>/dev/null
 
        echo ""
        divider
        msg_ok "Tailscale completely removed."
        divider
    else
        msg_info "Cancelled. No changes made."
    fi
    pause
}
 
# ==================================================
#  NETWORK MAP
# ==================================================
network_map() {
    clear; draw_header
    divider
    echo -e "  ${TEAL}${BD}  [ MESH NETWORK MAP ]${NC}"
    divider
    echo ""
 
    if ! command -v tailscale &>/dev/null; then
        msg_err "Tailscale is not installed."; pause; return
    fi
    if ! tailscale status &>/dev/null; then
        msg_err "Tailscale is not running or not authenticated."; pause; return
    fi
 
    msg_info "Scanning Mesh Peers..."
    echo ""
    printf "  ${GOLD}${BD}  %-22s %-18s %-12s %s${NC}\n" "HOSTNAME" "IP ADDRESS" "STATUS" "DETAIL"
    echo -e "  ${DGRAY}  ──────────────────────────────────────────────────────${NC}"
 
    local found=0
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        found=1
        local ip name status detail status_c
        ip=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        status=$(echo "$line" | awk '{print $4}')
        detail=$(echo "$line" | awk '{print $5, $6}')
        if [[ "$status" == "active" || "$status" == "online" ]]; then
            status_c="${GREEN}${BD}● $status${NC}"
        elif [[ "$status" == "idle" ]]; then
            status_c="${YELLOW}${BD}● $status${NC}"
        else
            status_c="${DGRAY}● $status${NC}"
        fi
        printf "  ${CYAN}  %-22s${NC} ${LCYAN}%-18s${NC} %-12b ${GRAY}%s${NC}\n" \
            "$name" "$ip" "$status_c" "$detail"
    done < <(tailscale status 2>/dev/null)
 
    [[ $found -eq 0 ]] && echo -e "  ${DGRAY}  No peers found.${NC}"
    echo ""
    divider
    pause
}
 
# ==================================================
#  DIAGNOSTICS
# ==================================================
run_netcheck() {
    clear; draw_header
    divider
    echo -e "  ${ORANGE}${BD}  [ NETWORK DIAGNOSTICS ]${NC}"
    divider
    echo ""
 
    # Basic connectivity tests (always run)
    echo -e "  ${PINK}${BD}  🌐  CONNECTIVITY TESTS${NC}"
    echo ""
 
    for host in "8.8.8.8" "google.com" "tailscale.com" "pkgs.tailscale.com"; do
        echo -ne "  ${DGRAY}  ping $host${NC}  "
        if ping -c 1 -W 3 "$host" >/dev/null 2>&1; then
            echo -e "${GREEN}${BD}✔ REACHABLE${NC}"
        else
            echo -e "${RED}${BD}✖ UNREACHABLE${NC}"
        fi
    done
 
    echo ""
    divider
    echo -e "  ${PINK}${BD}  🔍  DNS CONFIG${NC}"
    echo ""
    cat /etc/resolv.conf 2>/dev/null | grep -v "^#" | sed 's/^/  /' || echo "  N/A"
 
    echo ""
    divider
 
    if ! command -v tailscale &>/dev/null; then
        msg_warn "Tailscale not installed — skipping tailscale netcheck."
        pause; return
    fi
 
    echo ""
    echo -e "  ${PINK}${BD}  📡  TAILSCALE NETCHECK${NC}"
    echo ""
    tailscale netcheck 2>&1 | sed 's/^/  /'
    echo ""
    divider
    msg_ok "Diagnostics complete."
    pause
}
 
# ==================================================
#  MAIN LOOP
# ==================================================
while true; do
    draw_header
 
    echo -e "  ${CYAN}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}${BD}│  ${TEAL}◈  CORE OPERATIONS${NC}                                        ${CYAN}${BD}│${NC}"
    echo -e "  ${CYAN}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  1)${NC}  ${WHITE}Install & Connect     ${NC}${DGRAY}→  ${GREEN}Auto-detect & join mesh${NC}"
    echo -e "  ${GOLD}${BD}  2)${NC}  ${WHITE}Uninstall Completely  ${NC}${DGRAY}→  ${RED}Leave & remove Tailscale${NC}"
    echo ""
 
    echo -e "  ${YELLOW}${BD}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}${BD}│  ${ORANGE}◈  DIAGNOSTICS${NC}                                            ${YELLOW}${BD}│${NC}"
    echo -e "  ${YELLOW}${BD}└─────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${GOLD}${BD}  3)${NC}  ${WHITE}View Network Map      ${NC}${DGRAY}→  ${CYAN}List all mesh peers${NC}"
    echo -e "  ${GOLD}${BD}  4)${NC}  ${WHITE}Network Diagnostics   ${NC}${DGRAY}→  ${YELLOW}Ping tests + DNS + netcheck${NC}"
    echo ""
 
    echo -e "  ${BLUE}${BD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}${BD}║${NC}  ${RED}${BD}  0)  ↩  Exit Mesh Commander${NC}                              ${BLUE}${BD}║${NC}"
    echo -e "  ${BLUE}${BD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "  ${BLUE}${BD}  root@tailscale:~# ${NC}"
    read -r option
 
    case $option in
        1) install_tailscale ;;
        2) uninstall_tailscale ;;
        3) network_map ;;
        4) run_netcheck ;;
        0)
            clear
            echo -e "\n  ${GOLD}${BD}  👋  Mesh stays running. Goodbye!${NC}\n"
            sleep 1; exit 0 ;;
        *)
            msg_err "Invalid Option! Choose 0–4."
            sleep 1 ;;
    esac
done
