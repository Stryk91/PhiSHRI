# PhiLaunch Dashboard

Beautiful real-time monitoring dashboard for PhiLaunch automation system.

![Dashboard](https://img.shields.io/badge/Status-Active-green)
![Version](https://img.shields.io/badge/Version-1.0-blue)

---

## Features

### 📊 **Real-time Metrics**
- CPU, Memory, Disk usage with live graphs
- Network connectivity status
- System uptime tracking
- Auto-refreshes every 5 seconds

### 🔄 **Background Tasks**
- View all running tmux sessions
- Monitor task status
- Quick task management

### 🎮 **WoW Server Monitor**
- Real-time latency tracking
- Jitter and packet loss detection
- Historical data from logs
- Color-coded performance indicators

### 📝 **Activity Logs**
- Recent system activity
- Error tracking
- Quick log access

### 💻 **System Information**
- Hostname and IP address
- OS and kernel version
- Hardware details

---

## Quick Start

### Start Dashboard

```bash
# From PhiLaunch root
./start-dashboard.sh

# Or directly
cd dashboard
./serve.sh
```

The dashboard will be available at:
- **Local:** http://localhost:8080
- **Network:** http://YOUR_IP:8080

### Custom Port

```bash
DASHBOARD_PORT=8081 ./start-dashboard.sh
```

### Stop Dashboard

Press `Ctrl+C` in the terminal running the dashboard.

---

## Architecture

```
dashboard/
├── index.html              # Main dashboard page
├── serve.sh                # HTTP server + API updater
├── static/
│   ├── css/
│   │   └── dashboard.css   # Styles (dark theme)
│   └── js/
│       └── dashboard.js    # Real-time updates logic
└── api/
    ├── status.sh           # System status JSON
    ├── metrics.sh          # CPU/Mem/Disk metrics
    ├── tasks.sh            # Background tasks
    ├── wow.sh              # WoW server stats
    ├── logs.sh             # Recent logs
    └── info.sh             # System information
```

### How It Works

1. **Server** (`serve.sh`):
   - Starts Python HTTP server on port 8080
   - Runs API update loop in background
   - Generates JSON files every 5 seconds

2. **API Scripts**:
   - Bash scripts that collect system data
   - Output JSON to `api/*.json` files
   - Frontend fetches these JSON files

3. **Frontend**:
   - Pure HTML/CSS/JavaScript (no frameworks)
   - Fetches JSON every 5 seconds
   - Updates UI in real-time
   - Responsive design (mobile-friendly)

---

## API Endpoints

All API endpoints return JSON:

### `api/status.json`
```json
{
  "system": {"online": true, "warning": false},
  "services": {"online": true, "warning": false},
  "tasks": {"online": true, "warning": false},
  "uptime": "2 days, 5 hours",
  "timestamp": "2025-11-12T14:30:00Z"
}
```

### `api/metrics.json`
```json
{
  "cpu": {"percent": 25.5, "cores": 8},
  "memory": {"percent": 62.3, "total": "16G", "used": "10G"},
  "disk": {"percent": 45, "total": "500G", "used": "225G"},
  "network": {"status": "Connected", "connected": true}
}
```

### `api/tasks.json`
```json
{
  "tasks": [
    {"name": "wow-monitor", "status": "running", "windows": 1},
    {"name": "backup", "status": "running", "windows": 2}
  ],
  "count": 2
}
```

### `api/wow.json`
```json
{
  "enabled": true,
  "server": "103.4.115.248",
  "stats": {
    "avg_latency": "105.2",
    "best_latency": "98.5",
    "worst_latency": "125.3",
    "jitter": "12.4",
    "loss": "0.0"
  }
}
```

### `api/logs.json`
```json
{
  "logs": [
    {"timestamp": "2025-11-12 14:25:00", "message": "System started"},
    {"timestamp": "2025-11-12 14:30:15", "message": "Backup completed"}
  ]
}
```

### `api/info.json`
```json
{
  "hostname": "philaunch-server",
  "os": "Ubuntu 24.04.3 LTS",
  "kernel": "6.5.0-generic",
  "ip": "192.168.50.149"
}
```

---

## Customization

### Change Refresh Rate

Edit `dashboard/serve.sh`:
```bash
UPDATE_INTERVAL=10  # Change to 10 seconds
```

Edit `dashboard/static/js/dashboard.js`:
```javascript
const REFRESH_RATE = 10000;  // Change to 10 seconds
```

### Change Theme Colors

Edit `dashboard/static/css/dashboard.css`:
```css
:root {
    --primary: #00d4ff;      /* Change primary color */
    --success: #00ff88;      /* Change success color */
    --card-bg: #141829;      /* Change card background */
}
```

### Add Custom Metrics

1. **Create API script:**
```bash
# dashboard/api/custom.sh
#!/bin/bash
echo '{"custom_metric": "value"}'
```

2. **Update server to generate it:**
```bash
# In dashboard/serve.sh, add:
api/custom.sh > api/custom.json
```

3. **Fetch in frontend:**
```javascript
// In dashboard/static/js/dashboard.js
async function loadCustomMetric() {
    const response = await fetch('api/custom.json');
    const data = await response.json();
    // Update UI
}
```

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 8080
lsof -i :8080

# Kill it
kill <PID>

# Or use different port
DASHBOARD_PORT=8081 ./start-dashboard.sh
```

### Dashboard Not Loading

**Check server is running:**
```bash
ps aux | grep "python.*http.server"
```

**Check API files are generated:**
```bash
ls -la dashboard/api/*.json
```

**Check for errors:**
```bash
# Run API scripts manually
cd dashboard/api
./status.sh
./metrics.sh
```

### Metrics Not Updating

**Check update loop is running:**
```bash
ps aux | grep "update_api_data"
```

**Check browser console:**
- Open Developer Tools (F12)
- Look for JavaScript errors
- Check Network tab for failed requests

### WoW Monitor Not Working

**Check log file exists:**
```bash
ls -la ~/PhiLaunch/logs/wow_connection_*.log
```

**Start WoW monitor:**
```bash
./wow_monitor.sh
```

---

## Access from Phone

### On Same Network (LAN)

1. **Start dashboard** on PC
2. **Get PC's IP:**
   ```bash
   hostname -I
   # Example: 192.168.50.149
   ```
3. **Open on phone:**
   ```
   http://192.168.50.149:8080
   ```

### Over Internet (WAN)

**Option 1: WireGuard VPN**
1. Connect to WireGuard on phone
2. Access via PC's LAN IP

**Option 2: Port Forwarding**
1. Forward port 8080 on router to PC
2. Access via public IP:
   ```
   http://YOUR_PUBLIC_IP:8080
   ```

**⚠️ Security Warning:** Don't expose dashboard to internet without authentication!

---

## Integration

### Add to Systemd (Run on Boot)

```bash
# Create service file
sudo nano /etc/systemd/system/philaunch-dashboard.service
```

```ini
[Unit]
Description=PhiLaunch Dashboard
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/home/YOUR_USERNAME/PhiLaunch
ExecStart=/home/YOUR_USERNAME/PhiLaunch/start-dashboard.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
sudo systemctl enable philaunch-dashboard
sudo systemctl start philaunch-dashboard

# Check status
sudo systemctl status philaunch-dashboard
```

### Add to Crontab (Start on Reboot)

```bash
crontab -e
```

Add:
```cron
@reboot cd /home/YOUR_USERNAME/PhiLaunch && ./start-dashboard.sh > /dev/null 2>&1 &
```

---

## Performance

### Resource Usage

- **CPU:** ~1-2% (API updates)
- **Memory:** ~50MB (HTTP server + scripts)
- **Network:** Minimal (local JSON files)

### Optimization

**Reduce Update Frequency:**
```bash
# For slower systems
UPDATE_INTERVAL=30  # Update every 30 seconds
```

**Disable Unused Features:**
```bash
# Comment out in serve.sh
# api/wow.sh > api/wow.json
```

---

## Screenshots

### Desktop View
```
╔══════════════════════════════════════════════╗
║  🚀 PhiLaunch Dashboard                      ║
║  Uptime: 2 days, 5 hours                     ║
╠══════════════════════════════════════════════╣
║  Status: ✓ Online  ✓ Services  ✓ Tasks      ║
╠══════════════════════════════════════════════╣
║  📊 Metrics    CPU: 25%   MEM: 62%  DISK: 45% ║
║  🔄 Tasks      wow-monitor, backup            ║
║  🎮 WoW        105ms avg, 0% loss             ║
╚══════════════════════════════════════════════╝
```

### Mobile View
- Responsive design
- Touch-friendly buttons
- Scrollable metrics
- Works on any screen size

---

## Security

### Recommendations

✅ **DO:**
- Run on private network
- Use WireGuard for remote access
- Keep dashboard on LAN only
- Use strong firewall rules

❌ **DON'T:**
- Expose to public internet without auth
- Use default ports in production
- Share your IP publicly

### Add Basic Auth (Optional)

Use nginx as reverse proxy with auth:
```nginx
location / {
    auth_basic "PhiLaunch Dashboard";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:8080;
}
```

---

## Roadmap

### Planned Features

- [ ] Historical graphs (CPU/Memory over time)
- [ ] Alerts and notifications
- [ ] Dark/Light theme toggle
- [ ] Mobile app
- [ ] Authentication system
- [ ] Multi-server support
- [ ] Export data (CSV, JSON)

---

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

---

## License

Part of PhiLaunch - Personal use automation system.

---

**Version:** 1.0
**Last Updated:** 2025-11-12
**Maintained By:** PhiLaunch Contributors
