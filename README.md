# 🛡️ Fail2ban Dashboard

A beautiful, colorful terminal dashboard to monitor your fail2ban security in real-time. Track banned IPs, view jail statistics, and monitor brute-force attacks with an elegant command-line interface.

## ✨ Features

- 🎨 **Beautiful Interface** - Color-coded statistics with elegant box design
- 🔍 **Real-time Monitoring** - Live view of your fail2ban protection
- 📊 **Overview Statistics** - Total bans, failed attempts, active jails
- 🚫 **Banned IPs List** - Currently banned IPs with optional country detection
- 📈 **Jail Status Table** - All configured jails with detailed statistics
- ⏱️ **Recent Activity** - Last ban and unban events with timestamps
- ⚡ **Quick Actions** - Common fail2ban commands at your fingertips
- 🚀 **One-line Installation** - Quick and easy setup with auto-alias
- ⌨️ **Simple Command** - Just type `f2b` to view dashboard

## 📸 UI Samplingerz

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                      FAIL2BAN SECURITY DASHBOARD                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

▶ SERVICE STATUS
────────────────────────────────────────────────────────────────────────────────
  Status: ● ACTIVE
  Version: Fail2Ban v1.0.2
  Running since: Sun 2025-11-30 00:39:41 PST

▶ OVERVIEW STATISTICS
────────────────────────────────────────────────────────────────────────────────
  Active Jails:                       2
  Currently Banned IPs:               5
  Total Bans (All Time):              127
  Current Failed Attempts:            12

▶ JAIL STATUS
────────────────────────────────────────────────────────────────────────────────
  JAIL NAME            ENABLED      BANNED NOW   TOTAL BANS   FAILED
  ──────────────────────────────────────────────────────────────────────────────
  sshd                 ✓            3            98           8
  nginx-limit-req      ✓            2            29           4

▶ CURRENTLY BANNED IPs
────────────────────────────────────────────────────────────────────────────────
  [sshd]
    ● 103.45.12.89 (China)
    ● 185.234.219.45 (Russia)
    ● 92.118.39.106 (Ukraine)
```

## 🚀 Quick Installation

**One-line install command:**

```bash
curl -sSL https://raw.githubusercontent.com/mikegilkim/fail2ban-dashboard/main/install.sh | sudo bash
```

That's it! The installer will:
- ✅ Check for fail2ban installation
- ✅ Download and install the dashboard
- ✅ Make it executable
- ✅ Add the `f2b` alias for all users
- ✅ Test the installation

## 📋 Requirements

- **Linux** system (Ubuntu, Debian, CentOS, RHEL, etc.)
- **fail2ban** installed and configured
- **systemd** (for service management)
- **Root or sudo access**
- **Bash 4.0+**

### Installing fail2ban

If you don't have fail2ban installed:

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**CentOS/RHEL:**
```bash
sudo yum install epel-release -y
sudo yum install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 🎯 Usage

After installation, simply run:

```bash
f2b
```

Or use the full path:

```bash
sudo /usr/local/bin/f2b-dashboard
```

### First Time Setup

If the `f2b` alias doesn't work immediately, reload your shell:

```bash
source ~/.bashrc
```

Or open a new terminal session.

## 📦 Manual Installation

If you prefer to install manually:

**1. Download the dashboard script:**
```bash
sudo wget -O /usr/local/bin/f2b-dashboard https://raw.githubusercontent.com/mikegilkim/fail2ban-dashboard/main/f2b-dashboard.sh
```

**2. Make it executable:**
```bash
sudo chmod +x /usr/local/bin/f2b-dashboard
```

**3. Add the alias:**
```bash
echo "alias f2b='sudo /usr/local/bin/f2b-dashboard'" >> ~/.bashrc
source ~/.bashrc
```

## 🔧 Fail2ban Configuration

### Basic Configuration

Create or edit `/etc/fail2ban/jail.local`:

```ini
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
destemail = your-email@example.com
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
maxretry = 5
bantime = 1h
```

### Recommended Jails

Common jails to enable:

```ini
[sshd]
enabled = true
port = 22
maxretry = 5

[nginx-http-auth]
enabled = true
port = http,https

[nginx-botsearch]
enabled = true
port = http,https

[apache-auth]
enabled = true
port = http,https
```

### Apply Configuration

After editing configuration:

```bash
sudo fail2ban-client reload
```

## 📊 Dashboard Sections Explained

### Service Status
Shows whether fail2ban is running, version info, and uptime

### Overview Statistics
- **Active Jails**: Number of configured and enabled jails
- **Currently Banned IPs**: Total IPs banned right now across all jails
- **Total Bans**: Cumulative bans since fail2ban started
- **Current Failed Attempts**: Ongoing failed login attempts being monitored

### Jail Status Table
Detailed view of each jail showing:
- Jail name and status
- Currently banned IPs per jail
- Total historical bans
- Current failed attempts

### Currently Banned IPs
Lists all IPs currently banned, organized by jail. Includes country detection if `geoiplookup` is installed.

### Recent Ban Activity
Last 10 ban events with timestamps, jail names, and IP addresses

### Recent Unban Activity
Last 5 unban events showing when IPs were released

### Quick Actions
Common fail2ban commands for quick reference

## 🔍 Common Commands

### View Live Logs
```bash
sudo tail -f /var/log/fail2ban.log
```

### Unban a Specific IP
```bash
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

### Unban All IPs
```bash
sudo fail2ban-client unban --all
```

### Ban an IP Manually
```bash
sudo fail2ban-client set sshd banip 192.168.1.100
```

### Check Specific Jail Status
```bash
sudo fail2ban-client status sshd
```

### Reload fail2ban
```bash
sudo fail2ban-client reload
```

### Restart fail2ban Service
```bash
sudo systemctl restart fail2ban
```

## 🌍 Optional: Country Detection

For country information next to banned IPs, install GeoIP:

**Ubuntu/Debian:**
```bash
sudo apt install geoip-bin geoip-database -y
```

**CentOS/RHEL:**
```bash
sudo yum install GeoIP GeoIP-data -y
```

The dashboard will automatically detect and use it!

## 🛡️ Security Best Practices

1. **Change Default SSH Port**
   ```bash
   # Edit /etc/ssh/sshd_config
   Port 2024
   ```

2. **Use SSH Keys** instead of passwords
   ```bash
   ssh-keygen -t ed25519
   ssh-copy-id user@server
   ```

3. **Configure Email Alerts**
   ```ini
   # In /etc/fail2ban/jail.local
   destemail = admin@yourdomain.com
   action = %(action_mwl)s
   ```

4. **Adjust Ban Times** based on your needs
   ```ini
   bantime = 24h    # Ban for 24 hours
   maxretry = 3     # Ban after 3 attempts
   ```

5. **Monitor Regularly** using this dashboard!
   ```bash
   f2b
   ```

## 🧹 Maintenance

### Clear All Bans and Reset Counters

If you want to start fresh:

```bash
# Stop fail2ban
sudo systemctl stop fail2ban

# Remove database
sudo rm /var/lib/fail2ban/fail2ban.sqlite3

# Start fail2ban
sudo systemctl start fail2ban
```

### Update the Dashboard

To update to the latest version:

```bash
curl -sSL https://raw.githubusercontent.com/mikegilkim/fail2ban-dashboard/main/install.sh | sudo bash
```

## 🐛 Troubleshooting

### Dashboard shows "fail2ban not installed"
```bash
# Install fail2ban
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### "Command not found: f2b"
```bash
# Reload your shell
source ~/.bashrc

# Or use the full path
sudo /usr/local/bin/f2b-dashboard
```

### No jails showing up
```bash
# Check if jails are enabled
sudo fail2ban-client status

# Enable SSH jail
sudo nano /etc/fail2ban/jail.local
# Add [sshd] section with enabled = true

# Reload fail2ban
sudo fail2ban-client reload
```

### Permission denied
```bash
# Run with sudo
sudo f2b
```

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit pull requests
- ⭐ Star the repository
- 📖 Improve documentation

## 📝 License

MIT License - Feel free to use and modify!

## 🔗 Related Projects

- [sshesame-dashboard](https://github.com/mikegilkim/sshesame-dashboard) - SSH Honeypot Dashboard
- [fail2ban](https://github.com/fail2ban/fail2ban) - The original fail2ban project

## ⭐ Show Your Support

If you find this useful, please **star the repository**!

[![GitHub stars](https://img.shields.io/github/stars/mikegilkim/fail2ban-dashboard?style=social)](https://github.com/mikegilkim/fail2ban-dashboard)

## 🙏 Credits

- Built with ❤️ for the sysadmin community
- Designed for [fail2ban](https://www.fail2ban.org)
- Created by [mikegilkim](https://facebook.com/mikegilkim)

---

<div align="center">

**Keep your server secure with Fail2ban Dashboard!** 🛡️✨

Made with ❤️ by [mikegilkim](https://facebook.com/mikegilkim)

</div>
