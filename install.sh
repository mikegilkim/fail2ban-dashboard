#!/bin/bash

# Fail2ban Dashboard Installer
# One-line install: curl -sSL https://raw.githubusercontent.com/mikegilkim/fail2ban-dashboard/main/install.sh | sudo bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${RED}${BOLD}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Fail2ban Dashboard Installer v1.0                      ║"
echo "║         Beautiful terminal dashboard for fail2ban              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Check if fail2ban is installed
echo -e "${BLUE}[1/4]${NC} Checking for fail2ban..."
if ! command -v fail2ban-client &> /dev/null; then
    echo -e "${YELLOW}⚠ Warning: fail2ban is not installed${NC}"
    echo -e "${YELLOW}   The dashboard will install, but you need fail2ban to see data${NC}"
    echo -e "${WHITE}   Install fail2ban with: ${CYAN}sudo apt install fail2ban -y${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓ fail2ban is installed${NC}"
fi

# Download the dashboard script
echo -e "${BLUE}[2/4]${NC} Installing fail2ban dashboard..."

cat > /usr/local/bin/f2b-dashboard << 'F2B_SCRIPT'
#!/bin/bash

# Fail2ban Dashboard
# Beautiful display of fail2ban statistics and banned IPs

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Box drawing characters
TL='╔'
TR='╗'
BL='╚'
BR='╝'
H='═'
V='║'

print_line() {
    local width=$1
    local char=$2
    printf "${char}%.0s" $(seq 1 $width)
}

print_header() {
    local text="$1"
    local width=80
    local text_len=${#text}
    local padding=$(( (width - text_len - 2) / 2 ))
    
    echo -e "${RED}${TL}$(print_line $((width-2)) $H)${TR}${NC}"
    printf "${RED}${V}${NC}"
    printf "%*s" $padding
    echo -ne "${WHITE}${BOLD}${text}${NC}"
    printf "%*s" $((width - text_len - padding - 2))
    echo -e "${RED}${V}${NC}"
    echo -e "${RED}${BL}$(print_line $((width-2)) $H)${BR}${NC}"
}

print_section() {
    local text="$1"
    echo ""
    echo -e "${YELLOW}${BOLD}▶ ${text}${NC}"
    echo -e "${YELLOW}$(print_line 80 '─')${NC}"
}

print_stat() {
    local label="$1"
    local value="$2"
    local color="$3"
    printf "  ${WHITE}%-35s${NC} ${color}${BOLD}%s${NC}\n" "$label:" "$value"
}

if ! command -v fail2ban-client &> /dev/null; then
    clear
    print_header "FAIL2BAN DASHBOARD"
    echo ""
    echo -e "${RED}${BOLD}Error: fail2ban is not installed!${NC}"
    echo ""
    echo -e "${WHITE}Install fail2ban with:${NC}"
    echo -e "  ${CYAN}sudo apt install fail2ban -y${NC}"
    echo ""
    exit 1
fi

if [ "$EUID" -ne 0 ]; then 
    clear
    print_header "FAIL2BAN DASHBOARD"
    echo ""
    echo -e "${RED}${BOLD}Error: This script requires root privileges${NC}"
    echo ""
    echo -e "${WHITE}Run with:${NC}"
    echo -e "  ${CYAN}sudo f2b${NC}"
    echo ""
    exit 1
fi

clear

if systemctl is-active --quiet fail2ban; then
    STATUS="${GREEN}●${NC} ${BOLD}ACTIVE${NC}"
    UPTIME=$(systemctl show fail2ban --property=ActiveEnterTimestamp --value)
else
    STATUS="${RED}●${NC} ${BOLD}INACTIVE${NC}"
    UPTIME="N/A"
fi

F2B_VERSION=$(fail2ban-client version 2>/dev/null | head -1)

print_header "FAIL2BAN SECURITY DASHBOARD"

print_section "SERVICE STATUS"
echo -e "  Status: $STATUS"
echo -e "  ${WHITE}Version:${NC} $F2B_VERSION"
if [ "$UPTIME" != "N/A" ]; then
    echo -e "  ${WHITE}Running since:${NC} $UPTIME"
fi

JAILS=$(fail2ban-client status 2>/dev/null | grep "Jail list:" | sed 's/.*://; s/,//g')

if [ -z "$JAILS" ]; then
    print_section "WARNING"
    echo -e "  ${YELLOW}No jails are currently configured${NC}"
    echo ""
    exit 0
fi

TOTAL_BANNED=0
TOTAL_CURRENT_BANNED=0
TOTAL_FAILED=0

for jail in $JAILS; do
    JAIL_STATUS=$(fail2ban-client status $jail 2>/dev/null)
    CURRENT_BANNED=$(echo "$JAIL_STATUS" | grep "Currently banned:" | awk '{print $NF}')
    TOTAL_BANNED_JAIL=$(echo "$JAIL_STATUS" | grep "Total banned:" | awk '{print $NF}')
    TOTAL_FAILED_JAIL=$(echo "$JAIL_STATUS" | grep "Currently failed:" | awk '{print $NF}')
    
    TOTAL_CURRENT_BANNED=$((TOTAL_CURRENT_BANNED + CURRENT_BANNED))
    TOTAL_BANNED=$((TOTAL_BANNED + TOTAL_BANNED_JAIL))
    TOTAL_FAILED=$((TOTAL_FAILED + TOTAL_FAILED_JAIL))
done

ACTIVE_JAILS=$(echo $JAILS | wc -w)

print_section "OVERVIEW STATISTICS"
print_stat "Active Jails" "$ACTIVE_JAILS" "$CYAN"
print_stat "Currently Banned IPs" "$TOTAL_CURRENT_BANNED" "$RED"
print_stat "Total Bans (All Time)" "$TOTAL_BANNED" "$MAGENTA"
print_stat "Current Failed Attempts" "$TOTAL_FAILED" "$YELLOW"

print_section "JAIL STATUS"
printf "  ${WHITE}%-20s ${CYAN}%-12s ${RED}%-12s ${MAGENTA}%-12s ${YELLOW}%s${NC}\n" \
    "JAIL NAME" "ENABLED" "BANNED NOW" "TOTAL BANS" "FAILED"
echo -e "  ${WHITE}$(print_line 78 '─')${NC}"

for jail in $JAILS; do
    JAIL_STATUS=$(fail2ban-client status $jail 2>/dev/null)
    CURRENT_BANNED=$(echo "$JAIL_STATUS" | grep "Currently banned:" | awk '{print $NF}')
    TOTAL_BANNED_JAIL=$(echo "$JAIL_STATUS" | grep "Total banned:" | awk '{print $NF}')
    TOTAL_FAILED_JAIL=$(echo "$JAIL_STATUS" | grep "Currently failed:" | awk '{print $NF}')
    
    if [ "$CURRENT_BANNED" -gt 0 ]; then
        JAIL_COLOR=$RED
    else
        JAIL_COLOR=$GREEN
    fi
    
    printf "  ${JAIL_COLOR}%-20s${NC} ${CYAN}%-12s${NC} ${RED}%-12s${NC} ${MAGENTA}%-12s${NC} ${YELLOW}%s${NC}\n" \
        "$jail" "✓" "$CURRENT_BANNED" "$TOTAL_BANNED_JAIL" "$TOTAL_FAILED_JAIL"
done

print_section "CURRENTLY BANNED IPs"

BANNED_COUNT=0
for jail in $JAILS; do
    BANNED_IPS=$(fail2ban-client status $jail 2>/dev/null | grep "Banned IP list:" | sed 's/.*://; s/\t//g')
    
    if [ ! -z "$BANNED_IPS" ]; then
        echo -e "  ${CYAN}${BOLD}[$jail]${NC}"
        for ip in $BANNED_IPS; do
            COUNTRY=""
            if command -v geoiplookup &> /dev/null; then
                COUNTRY=$(geoiplookup $ip 2>/dev/null | head -1 | awk -F': ' '{print $2}' | cut -d',' -f1)
                if [ ! -z "$COUNTRY" ] && [ "$COUNTRY" != "IP Address not found" ]; then
                    COUNTRY=" ${WHITE}(${COUNTRY})${NC}"
                else
                    COUNTRY=""
                fi
            fi
            echo -e "    ${RED}●${NC} ${WHITE}$ip${NC}$COUNTRY"
            BANNED_COUNT=$((BANNED_COUNT + 1))
        done
    fi
done

if [ $BANNED_COUNT -eq 0 ]; then
    echo -e "  ${GREEN}No IPs are currently banned${NC}"
fi

print_section "RECENT BAN ACTIVITY (Last 10)"

RECENT_BANS=$(grep "Ban " /var/log/fail2ban.log 2>/dev/null | tail -10)

if [ ! -z "$RECENT_BANS" ]; then
    echo "$RECENT_BANS" | while read line; do
        TIMESTAMP=$(echo "$line" | awk '{print $1, $2}')
        JAIL=$(echo "$line" | grep -oP '\[\K[^\]]+' | head -1)
        IP=$(echo "$line" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
        
        if [ ! -z "$IP" ]; then
            echo -e "  ${WHITE}$TIMESTAMP${NC} ${CYAN}[$JAIL]${NC} ${RED}Banned:${NC} ${WHITE}$IP${NC}"
        fi
    done
else
    echo -e "  ${GREEN}No recent ban activity${NC}"
fi

print_section "RECENT UNBAN ACTIVITY (Last 5)"

RECENT_UNBANS=$(grep "Unban " /var/log/fail2ban.log 2>/dev/null | tail -5)

if [ ! -z "$RECENT_UNBANS" ]; then
    echo "$RECENT_UNBANS" | while read line; do
        TIMESTAMP=$(echo "$line" | awk '{print $1, $2}')
        JAIL=$(echo "$line" | grep -oP '\[\K[^\]]+' | head -1)
        IP=$(echo "$line" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
        
        if [ ! -z "$IP" ]; then
            echo -e "  ${WHITE}$TIMESTAMP${NC} ${CYAN}[$JAIL]${NC} ${GREEN}Unbanned:${NC} ${WHITE}$IP${NC}"
        fi
    done
else
    echo -e "  ${GREEN}No recent unban activity${NC}"
fi

print_section "QUICK ACTIONS"
echo -e "  ${WHITE}View live logs:${NC}         ${CYAN}sudo tail -f /var/log/fail2ban.log${NC}"
echo -e "  ${WHITE}Unban an IP:${NC}            ${CYAN}sudo fail2ban-client set <jail> unbanip <ip>${NC}"
echo -e "  ${WHITE}Ban an IP manually:${NC}     ${CYAN}sudo fail2ban-client set <jail> banip <ip>${NC}"
echo -e "  ${WHITE}Reload fail2ban:${NC}        ${CYAN}sudo fail2ban-client reload${NC}"
echo -e "  ${WHITE}Check specific jail:${NC}    ${CYAN}sudo fail2ban-client status <jail>${NC}"

echo ""
echo -e "${RED}$(print_line 80 '═')${NC}"
echo -e "${WHITE}  Protecting your server from brute-force attacks  |  Press Ctrl+C to exit${NC}"
echo -e "${RED}$(print_line 80 '═')${NC}"
echo ""
echo -e "${CYAN}                        ╔══════════════════════════════╗${NC}"
echo -e "${CYAN}                        ║${NC} ${BOLD}${MAGENTA}★${NC} ${BOLD}${WHITE}Created by${NC} ${BOLD}${CYAN}mikegilkim${NC} ${BOLD}${MAGENTA}★${NC} ${CYAN}║${NC}"
echo -e "${CYAN}                        ║${NC}   ${BLUE}facebook.com/mikegilkim${NC}   ${CYAN}║${NC}"
echo -e "${CYAN}                        ╚══════════════════════════════╝${NC}"
echo ""
F2B_SCRIPT

echo -e "${GREEN}✓ Dashboard script installed${NC}"

# Make script executable
echo -e "${BLUE}[3/4]${NC} Making script executable..."
chmod +x /usr/local/bin/f2b-dashboard
echo -e "${GREEN}✓ Script is now executable${NC}"

# Add alias
echo -e "${BLUE}[4/4]${NC} Adding 'f2b' alias..."

add_alias() {
    local file=$1
    if [ -f "$file" ]; then
        if ! grep -q "alias f2b=" "$file"; then
            echo "" >> "$file"
            echo "# Fail2ban Dashboard alias" >> "$file"
            echo "alias f2b='sudo /usr/local/bin/f2b-dashboard'" >> "$file"
            echo -e "${GREEN}  ✓ Added alias to $file${NC}"
        else
            echo -e "${YELLOW}  ⚠ Alias already exists in $file${NC}"
        fi
    fi
}

add_alias "/root/.bashrc"

for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        username=$(basename "$user_home")
        add_alias "$user_home/.bashrc"
        if grep -q "alias f2b=" "$user_home/.bashrc" 2>/dev/null; then
            chown $username:$username "$user_home/.bashrc" 2>/dev/null || true
        fi
    fi
done

if [ -f /etc/bash.bashrc ]; then
    add_alias "/etc/bash.bashrc"
fi

# Final message
echo ""
echo -e "${GREEN}${BOLD}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Installation Complete! 🎉 🛡️                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${WHITE}To use the dashboard, run:${NC}"
echo -e "  ${CYAN}${BOLD}f2b${NC}"
echo ""
echo -e "${WHITE}Or directly:${NC}"
echo -e "  ${CYAN}sudo /usr/local/bin/f2b-dashboard${NC}"
echo ""
echo -e "${YELLOW}Note: You may need to reload your shell:${NC}"
echo -e "  ${CYAN}source ~/.bashrc${NC}"
echo ""
echo -e "${WHITE}Quick commands:${NC}"
echo -e "  ${CYAN}sudo fail2ban-client status${NC}           - View all jails"
echo -e "  ${CYAN}sudo fail2ban-client status sshd${NC}      - Check SSH jail"
echo -e "  ${CYAN}sudo tail -f /var/log/fail2ban.log${NC}    - Live logs"
echo ""
echo -e "${GREEN}Your server is now more secure! 🔒${NC}"
echo ""
