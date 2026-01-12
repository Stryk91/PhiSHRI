# F01 - KALIC Launcher Recovery

## SYMPTOM
KALIC ASCII banner and options menu missing when typing `claude`.
Direct launch to Claude Code instead of wrapper.

## ROOT CAUSE
Claude Code npm update overwrites `/usr/local/bin/claude` with symlink to cli.js.
The bash wrapper gets replaced.

## DIAGNOSIS
```bash
ls -la /usr/local/bin/claude*
# If claude is a symlink (lrwxrwxrwx) → wrapper was nuked
# Should be: -rwxr-xr-x (regular file with execute)
```

## FIX
```bash
# 1. Rename current symlink
sudo mv /usr/local/bin/claude /usr/local/bin/claude-bin

# 2. Recreate wrapper (use tee, not redirect - avoids permission issues)
sudo tee /usr/local/bin/claude > /dev/null << 'LAUNCHER'
#!/bin/bash
# KALIC Launcher - Wrapper for Claude Code
BRAIN_DIR="/mnt/c/PhiDEX/kalic_brain"
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'; DIM='\033[2m'; NC='\033[0m'
clear
echo -e "${CYAN}"
cat << 'BANNER'
██╗  ██╗ █████╗ ██╗     ██╗ ██████╗
██║ ██╔╝██╔══██╗██║     ██║██╔════╝
█████╔╝ ███████║██║     ██║██║
██╔═██╗ ██╔══██║██║     ██║██║
██║  ██╗██║  ██║███████╗██║╚██████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝
BANNER
echo -e "${NC}"
echo -e "${WHITE}Type 'ready' to launch, 'brain' to view brain dir${NC}"
while true; do
    echo -ne "${CYAN}> ${NC}"; read -r input
    case "${input,,}" in
        ready|r|"") exec /usr/local/bin/claude-bin "$@" ;;
        brain|b) ls -la "${BRAIN_DIR}" ;;
        exit|quit|q) exit 0 ;;
        *) echo -e "${DIM}Unknown. Type 'ready' to launch.${NC}" ;;
    esac
done
LAUNCHER

# 3. Make executable
sudo chmod +x /usr/local/bin/claude
```

## PREVENTION
After any `npm update -g @anthropic-ai/claude-code`, check:
```bash
file /usr/local/bin/claude
# Should say: "Bourne-Again shell script" NOT "symbolic link"
```

## RELATED
- temporal.md entry: "KALIC Launcher Wrapper"
- S00KALIC_SESSION_BOOT for full session context
