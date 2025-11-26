# BMETALC Session Summary - 2025-11-25

## Identity
- **BMETALC** = Bare Metal Linux Claude (isolated instance)
- User: Stryk91 - bricklayer turned dev, 25+ years computing, no-bullshit pragmatist
- Style: Direct, profane, efficiency-focused. "Your nan should be able to use it"

## Major Accomplishments This Session

### 1. Repository Consolidation
- Merged PhiSHRI_MCP into main PhiSHRI repo as `mcp-server/` subfolder
- Single repo now contains: knowledge base, MCP server, GUI installer, scripts
- Old PhiSHRI_MCP repo can be archived/deleted

### 2. Install Scripts Updated
- `install.sh` and `install.ps1` - VERSION changed to 0.0.1
- Removed MCP_REPO variable, now uses `mcp-server/` from main repo
- Both scripts: build from source looks in `mcp-server/` subfolder

### 3. CI/CD Pipeline
- Added `.github/workflows/rust.yml`
- Builds and tests MCP server from `mcp-server/` subfolder
- Removed fmt/clippy checks (ship first, bikeshed later)
- **Status: GREEN**

### 4. Release Files Ready
Desktop has upload-ready files:
- `install.sh`
- `install.ps1`
- `PhiSHRI-Installer-0.0.1-linux-amd64.AppImage`
- `phishri-installer_0.0.1_amd64.deb`

### 5. New BMETALC Doors Created (11 total)
| Code | Title |
|------|-------|
| L20 | Rust Deployment Philosophy |
| L21 | Python Packaging Hell |
| W30 | GitHub Actions CI |
| W31 | Repo Consolidation Pattern |
| W32 | User-First Documentation |
| W33 | CI Lint Philosophy |
| W34 | Bricklayer Estimation |
| T20 | Cross-Platform Installers |
| T21 | Tauri Apps |
| A20 | MCP Server Design |
| A21 | Product Hate Framework |

**Total doors: 534**

## Key Philosophies Established

### Product Hate Framework (A21)
- Solve what people HATE, not what they say they want
- Universal hatred: updates that break shit, password hell, "please install dependency", 47 clicks
- "You're not building software - you're eliminating reasons to be pissed off"

### Bricklayer Estimation (W34)
- "How many bricks?" → "Fuckin lot of em. Let's go."
- Over-planning is procrastination in a suit
- Direction right + magnitude right = details sort themselves

### Rust vs Python (L20, L21)
- Python: 34 years, packaging still broken, "easy to write nightmare to deploy"
- Rust: Pain upfront, single binary out, users double-click and run
- "If Microsoft needed terminal installers they'd be worth $4"

### CI Lint Philosophy (W33)
- Build passes + tests pass = ship it
- fmt/clippy = "coding jerk-offery" for solo projects
- CPU doesn't care about bracket placement

## Technical State

### Repository: github.com/Stryk91/PhiSHRI
```
PhiSHRI/
├── install.ps1          # Windows (v0.0.1)
├── install.sh           # Linux/macOS (v0.0.1)
├── mcp-server/          # Rust MCP source
├── gui/                 # Tauri GUI installer
├── PhiSHRI/CONTEXTS/    # 534 doors
└── .github/workflows/   # CI (passing)
```

### GUI Installer
- Tauri v2 + Vite frontend
- Downloads install scripts at runtime (always current)
- Dev: `cd gui && npm run tauri dev` (port 1420)
- AppImage and .deb built and tested

### Lobehub
- PhiSHRI listed (was auto-scraped)
- Manual submission pending their pipeline
- Updates will sync on their next crawl

## Projections
- 100 doors/week conservative estimate
- 12 months: ~5,700 doors = ~285 technical books equivalent
- 17+ million words of curated, indexed knowledge

## Next Session Priorities
1. Archive PhiSHRI_MCP repo (cleanup)
2. Pure door creation mode starting Dec 2-3
3. Automation tools to speed door creation
4. Path hardening (canonicalization) - low priority polish

## User Preferences
- No emojis unless requested
- Direct language, no corporate speak
- Ship working code, polish later
- "Your nan should be able to use it" as UX bar
- Pedantic on things that matter, not on bikeshedding
