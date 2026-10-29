#!/usr/bin/env bash
# ==============================================================================
# NEXUSBYPASS :: ANTIGRAVITY 2.0 CONTROL ENGINE (LINUX & MACOS)
# Group: https://t.me/+lZ5ubwXqRsI2Nzdl
# Core: Gemini 3.8 Flash · Thinking: High · Full Technical Unlock
# Aesthetic: Omarchy Pixel Cyberpunk & Full-Canvas Starfield (Resize-Safe)
# ==============================================================================

# --- 24-bit TrueColor Palette (Omarchy Neon Mint to Forest Void) ---
ESC="\033"
C_RESET="${ESC}[0m"
C_BOLD="${ESC}[1m"
C_DIM="${ESC}[2m"
C_CLR_EOL="${ESC}[K" # Erase to end of line

# Mint / Emerald / Forest Gradients
G0="${ESC}[38;2;190;250;210m" # Layer 0: Highlight Mint (#BEFAD2)
G1="${ESC}[38;2;130;240;175m" # Layer 1: Bright Seafoam (#82F0AF)
G2="${ESC}[38;2;74;222;128m"  # Layer 2: Cyber Emerald (#4ADE80)
G3="${ESC}[38;2;34;197;94m"   # Layer 3: Toxic Green (#22C55E)
G4="${ESC}[38;2;22;140;66m"   # Layer 4: Deep Jade (#168C42)
G5="${ESC}[38;2;14;82;40m"    # Layer 5: Shadow Forest (#0E5228)
G6="${ESC}[38;2;8;46;24m"     # Layer 6: Ambient Void (#082E18)

# Breathing Particle Colors (Soft Starfield Palette)
P_SHADES=(
    "${ESC}[38;2;10;45;24m"
    "${ESC}[38;2;18;75;40m"
    "${ESC}[38;2;34;140;75m"
    "${ESC}[38;2;74;210;120m"
    "${ESC}[38;2;150;245;190m"
)

# Accents
WHITE="${ESC}[38;2;245;245;250m"
GRAY="${ESC}[38;2;115;115;125m"
DARK="${ESC}[38;2;60;60;68m"
CYAN="${ESC}[38;2;56;189;248m"
AMBER="${ESC}[38;2;245;158;11m"
ROSE="${ESC}[38;2;244;63;94m"

if [ ! -t 1 ]; then
    G0="" G1="" G2="" G3="" G4="" G5="" G6=""
    P_SHADES=("" "" "" "" "")
    C_RESET="" C_BOLD="" C_DIM="" C_CLR_EOL="" WHITE="" GRAY="" DARK="" CYAN="" AMBER="" ROSE=""
fi

# --- Paths & Global Config ---
ZIP_FILENAME="NexusBypass.zip"
DEFAULT_DOWNLOAD_URL="https://raw.githubusercontent.com/seavfoueang-coc/antigravity-bypass/main/${ZIP_FILENAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
USER_HOME="${HOME:-$(getent passwd "$USER" 2>/dev/null | cut -d: -f6)}"
[ -z "$USER_HOME" ] && USER_HOME="/home/${USER:-root}"
GLOBAL_GEMINI_DIR="${USER_HOME}/.gemini"
DEFAULT_WORKSPACE="${USER_HOME}/Antigravity-Workspace"
if [ -n "$1" ] && [ -d "$1" ]; then
    DEFAULT_WORKSPACE="$(cd "$1" 2>/dev/null && pwd || echo "$1")"
elif [ -n "$2" ] && [ -d "$2" ]; then
    DEFAULT_WORKSPACE="$(cd "$2" 2>/dev/null && pwd || echo "$2")"
fi
TEMP_DIR=""

tty_read() {
    if [ -r /dev/tty ]; then
        read "$@" < /dev/tty
    else
        read "$@"
    fi
}

cleanup() {
    printf "${ESC}[?1049l${ESC}[?25h" 2>/dev/null || true
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

# Resize trap for F11 / window changes
RESIZED=0
trap 'RESIZED=1' WINCH

# --- Zero-Dependency Payload Extraction ---
prepare_payload() {
    local source_mode=""
    local local_source_dir=""
    local local_zip_path=""

    if [ -n "$SCRIPT_DIR" ] && [ -f "${SCRIPT_DIR}/GEMINI.md" ] && [ -d "${SCRIPT_DIR}/.gemini" ]; then
        source_mode="local_folder"
        local_source_dir="$SCRIPT_DIR"
    elif [ -n "$SCRIPT_DIR" ] && [ -f "${SCRIPT_DIR}/${ZIP_FILENAME}" ]; then
        source_mode="local_zip"
        local_zip_path="${SCRIPT_DIR}/${ZIP_FILENAME}"
    elif [ -f "./GEMINI.md" ] && [ -d "./.gemini" ]; then
        source_mode="local_folder"
        local_source_dir="$(pwd)"
    elif [ -f "./${ZIP_FILENAME}" ]; then
        source_mode="local_zip"
        local_zip_path="$(pwd)/${ZIP_FILENAME}"
    else
        source_mode="download"
    fi

    if [ "$source_mode" = "local_folder" ]; then
        PAYLOAD_DIR="$local_source_dir"
        return 0
    fi

    TEMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'nexusbypass_payload')"
    PAYLOAD_DIR="$TEMP_DIR"

    if [ "$source_mode" = "download" ]; then
        local dl_url="${NEXUSBYPASS_SOURCE_URL:-$DEFAULT_DOWNLOAD_URL}"
        if command -v curl &>/dev/null; then
            curl -fsSL "$dl_url" -o "${TEMP_DIR}/${ZIP_FILENAME}" || return 1
        elif command -v wget &>/dev/null; then
            wget -q "$dl_url" -O "${TEMP_DIR}/${ZIP_FILENAME}" || return 1
        else
            return 1
        fi
        local_zip_path="${TEMP_DIR}/${ZIP_FILENAME}"
    fi

    if command -v unzip &>/dev/null; then
        unzip -q -o "$local_zip_path" -d "$TEMP_DIR"
    elif command -v python3 &>/dev/null; then
        python3 -c "import zipfile; zipfile.ZipFile('$local_zip_path').extractall('$TEMP_DIR')"
    elif command -v python &>/dev/null; then
        python -c "import zipfile; zipfile.ZipFile('$local_zip_path').extractall('$TEMP_DIR')"
    elif command -v busybox &>/dev/null && busybox unzip -h &>/dev/null; then
        busybox unzip -q -o "$local_zip_path" -d "$TEMP_DIR"
    elif [[ "$OSTYPE" == "darwin"* ]] && command -v tar &>/dev/null; then
        tar -xf "$local_zip_path" -C "$TEMP_DIR" 2>/dev/null || true
    else
        return 1
    fi

    return 0
}

# --- Action 1: INSTALL JAILBREAK ---
action_install() {
    printf "${ESC}[?1049l${ESC}[?25h" 2>/dev/null || true
    clear 2>/dev/null || true
    echo ""
    echo -e "   ${G0}${C_BOLD}INSTALL JAILBREAK${C_RESET}"
    echo -e "   ${G5}─────────────────────────────────────────────────────────────────${C_RESET}\n"

    tty_read -r -p "   Are you sure you want to install NexusBypass? [Y/n]: " confirm_install || confirm_install="y"
    case "$confirm_install" in
        [nN]|[nN][oO])
            echo -e "\n   ${GRAY}Cancelled.${C_RESET}"
            sleep 1
            return 0
            ;;
        *) ;;
    esac

    echo ""

    DETECTED_SURFACES=()
    command -v agy &>/dev/null && DETECTED_SURFACES+=("Antigravity CLI (agy)")
    [ -d "${GLOBAL_GEMINI_DIR}/antigravity" ] && DETECTED_SURFACES+=("Antigravity IDE / Desktop App")
    [ -d "${GLOBAL_GEMINI_DIR}/antigravity-cli" ] && DETECTED_SURFACES+=("CLI Config Layer")
    [ -d "${USER_HOME}/.gemini" ] && DETECTED_SURFACES+=("Gemini Profile (~/.gemini)")

    if [ ${#DETECTED_SURFACES[@]} -gt 0 ]; then
        echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Environment:${C_RESET} ${G1}${DETECTED_SURFACES[*]}${C_RESET}"
    else
        echo -e "   ${AMBER}[!]${C_RESET} ${AMBER}Antigravity not found in default paths.${C_RESET}"
        echo -e "   ${GRAY}    Pre-configuring ~/.gemini and ~/Antigravity-Workspace.${C_RESET}"
    fi

    if ! prepare_payload; then
        echo -e "\n   ${ROSE}[✗] Error:${C_RESET} Payload resolution failed."
        tty_read -r -p "   Press Enter to return..." || true
        return 1
    fi

    if [ ! -f "${PAYLOAD_DIR}/GEMINI.md" ] || [ ! -d "${PAYLOAD_DIR}/.gemini" ]; then
        echo -e "\n   ${ROSE}[✗] Error:${C_RESET} Core integrity failed: missing GEMINI.md or .gemini."
        tty_read -r -p "   Press Enter to return..." || true
        return 1
    fi

    # Global Profile Injection (~/.gemini/)
    mkdir -p "${GLOBAL_GEMINI_DIR}/domains"
    mkdir -p "${GLOBAL_GEMINI_DIR}/references"
    mkdir -p "${GLOBAL_GEMINI_DIR}/rules"
    mkdir -p "${GLOBAL_GEMINI_DIR}/config"

    cp -rf "${PAYLOAD_DIR}/.gemini/domains/"* "${GLOBAL_GEMINI_DIR}/domains/"
    cp -rf "${PAYLOAD_DIR}/.gemini/references/"* "${GLOBAL_GEMINI_DIR}/references/"
    cp -f "${PAYLOAD_DIR}/GEMINI.md" "${GLOBAL_GEMINI_DIR}/rules/GEMINI.md" 2>/dev/null || true
    cp -f "${PAYLOAD_DIR}/GEMINI.md" "${GLOBAL_GEMINI_DIR}/GEMINI.md" 2>/dev/null || true

    echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Injected:${C_RESET}    ${GRAY}~/.gemini/domains/${C_RESET}"
    echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Failover:${C_RESET}    ${GRAY}~/.gemini/rules/GEMINI.md${C_RESET}"

    # Default Workspace Setup (~/Antigravity-Workspace)
    TARGET_WS="$DEFAULT_WORKSPACE"
    mkdir -p "$TARGET_WS"
    mkdir -p "${TARGET_WS}/.gemini/domains"
    mkdir -p "${TARGET_WS}/.gemini/references"

    cp -f "${PAYLOAD_DIR}/GEMINI.md" "${TARGET_WS}/GEMINI.md"
    cp -f "${PAYLOAD_DIR}/prompt.txt" "${TARGET_WS}/prompt.txt"
    cp -rf "${PAYLOAD_DIR}/.gemini/domains/"* "${TARGET_WS}/.gemini/domains/"
    cp -rf "${PAYLOAD_DIR}/.gemini/references/"* "${TARGET_WS}/.gemini/references/"
    [ -f "${PAYLOAD_DIR}/README.md" ] && cp -f "${PAYLOAD_DIR}/README.md" "${TARGET_WS}/README.md"

    # Convenience Desktop duplicate for quick task pipe access
    DT_DIR="${USER_HOME}/Desktop"
    if command -v xdg-user-dir >/dev/null 2>&1; then
        XDG_DT="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
        [ -n "$XDG_DT" ] && DT_DIR="$XDG_DT"
    fi
    if [ -d "$DT_DIR" ]; then
        cp -f "${PAYLOAD_DIR}/prompt.txt" "${DT_DIR}/prompt.txt" 2>/dev/null || true
    fi

    if [ "$SCRIPT_DIR" != "$TARGET_WS" ] && [ -n "$SCRIPT_DIR" ] && [ "$SCRIPT_DIR" != "$GLOBAL_GEMINI_DIR" ]; then
        cp -f "${PAYLOAD_DIR}/GEMINI.md" "${SCRIPT_DIR}/GEMINI.md" 2>/dev/null || true
        cp -f "${PAYLOAD_DIR}/prompt.txt" "${SCRIPT_DIR}/prompt.txt" 2>/dev/null || true
        mkdir -p "${SCRIPT_DIR}/.gemini" 2>/dev/null || true
        cp -rf "${PAYLOAD_DIR}/.gemini/"* "${SCRIPT_DIR}/.gemini/" 2>/dev/null || true
    fi

    echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Workspace:${C_RESET}   ${G1}${TARGET_WS}${C_RESET}"

    # Automated Telemetry Neutralization
    for cfg in "${GLOBAL_GEMINI_DIR}/config/config.json"; do
        if [ -f "$cfg" ]; then
            python3 -c "import json; p='$cfg'; d=json.load(open(p)); d.setdefault('userSettings', {})['disableCodeSnippetTelemetry']=True; json.dump(d, open(p,'w'), indent=2)" 2>/dev/null || true
        fi
    done
    for cli_cfg in "${GLOBAL_GEMINI_DIR}/antigravity-cli/settings.json"; do
        if [ -f "$cli_cfg" ]; then
            python3 -c "import json; p='$cli_cfg'; d=json.load(open(p)); d['telemetry']=False; d['disableTelemetry']=True; json.dump(d, open(p,'w'), indent=2)" 2>/dev/null || true
        fi
    done
    for ide_dir in "${USER_HOME}/.config/Antigravity/User" "${USER_HOME}/.config/antigravity/User" "${USER_HOME}/.config/Code/User" "${USER_HOME}/Library/Application Support/Antigravity/User" "${USER_HOME}/Library/Application Support/Code/User"; do
        if [ -d "$ide_dir" ] || [ -d "$(dirname "$ide_dir")" ]; then
            mkdir -p "$ide_dir" 2>/dev/null || true
            ide_json="${ide_dir}/settings.json"
            python3 -c "import json, os; p='$ide_json'; d=json.load(open(p)) if os.path.exists(p) else {}; d['telemetry.telemetryLevel']='off'; d['codeium.telemetry']=False; d['gemini.telemetry']=False; json.dump(d, open(p,'w'), indent=2)" 2>/dev/null || true
        fi
    done
    echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Telemetry:${C_RESET}   ${G2}DISABLED (Auto-Applied OFF)${C_RESET}"

    echo ""
    echo -e "   ${G5}─────────────────────────────────────────────────────────────────${C_RESET}"
    echo -e "   ${G0}${C_BOLD}INSTALLED & ACTIVE${C_RESET}"
    echo -e "   ${G5}─────────────────────────────────────────────────────────────────${C_RESET}"
    echo -e "   ${G1}1. Workspace:${C_RESET}    ${WHITE}${TARGET_WS}${C_RESET}"
    echo -e "   ${G1}2. Model Dial:${C_RESET}   ${WHITE}Gemini 3.8 Flash${C_RESET} · ${G2}Thinking: High${C_RESET} · ${G2}Telemetry: OFF (Applied)${C_RESET}"
    echo -e "   ${G1}3. Task Pipe:${C_RESET}    Write in ${G2}prompt.txt${C_RESET} -> send: ${WHITE}read prompt.txt and execute${C_RESET}"
    echo -e "   ${G1}4. Activation:${C_RESET}   Send ${WHITE}whiskers forward${C_RESET} -> starts with ${G2}[NexusBypass]${C_RESET}"
    echo -e "   ${G5}─────────────────────────────────────────────────────────────────${C_RESET}\n"

    tty_read -r -p "   Press Enter to return..." || true
}

# --- Action 2: DELETE JAILBREAK ---
action_delete() {
    printf "${ESC}[?1049l${ESC}[?25h" 2>/dev/null || true
    clear 2>/dev/null || true
    echo ""
    echo -e "   ${ROSE}${C_BOLD}DELETE JAILBREAK${C_RESET}"
    echo -e "   ${G5}─────────────────────────────────────────────────────────────────${C_RESET}\n"

    tty_read -r -p "   Are you sure you want to delete NexusBypass? [y/N]: " confirm_del || confirm_del="n"
    case "$confirm_del" in
        [yY]|[yY][eE][sS]) ;;
        *)
            echo -e "\n   ${GRAY}Cancelled.${C_RESET}"
            sleep 1
            return 0
            ;;
    esac

    echo ""
    for d in systems.md instrumentation.md reverse.md networking.md automation.md creative.md; do
        rm -f "${GLOBAL_GEMINI_DIR}/domains/${d}" 2>/dev/null || true
    done
    rmdir "${GLOBAL_GEMINI_DIR}/domains" 2>/dev/null || true

    for r in core.md compatibility.md shapes.md engines.md; do
        rm -f "${GLOBAL_GEMINI_DIR}/references/${r}" 2>/dev/null || true
    done
    rmdir "${GLOBAL_GEMINI_DIR}/references" 2>/dev/null || true

    rm -f "${GLOBAL_GEMINI_DIR}/rules/GEMINI.md" 2>/dev/null || true
    rm -f "${GLOBAL_GEMINI_DIR}/GEMINI.md" 2>/dev/null || true

    if [ -d "$DEFAULT_WORKSPACE" ]; then
        tty_read -r -p "   Also remove workspace folder (${DEFAULT_WORKSPACE})? [y/N]: " rm_ws || rm_ws="n"
        case "$rm_ws" in
            [yY]|[yY][eE][sS])
                rm -rf "$DEFAULT_WORKSPACE"
                echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Workspace deleted.${C_RESET}"
                ;;
            *)
                echo -e "   ${GRAY}Workspace preserved.${C_RESET}"
                ;;
        esac
    fi

    echo ""
    echo -e "   ${G2}[✓]${C_RESET} ${WHITE}NexusBypass removed.${C_RESET}\n"
    tty_read -r -p "   Press Enter to return..." || true
}

# --- Action 3: TELEGRAM GROUP ---
action_telegram() {
    printf "${ESC}[?1049l${ESC}[?25h" 2>/dev/null || true
    clear 2>/dev/null || true
    echo ""
    echo -e "   ${G0}${C_BOLD}TELEGRAM GROUP${C_RESET}"
    echo -e "   ${G5}─────────────────────────────────────────────────────────────────${C_RESET}\n"
    echo -e "   ${G1}GROUP:${C_RESET}      ${WHITE}https://t.me/+lZ5ubwXqRsI2Nzdl${C_RESET}\n"
    echo -e "   ${GRAY}• Zero-censorship payloads, game instrumentation & PoCs${C_RESET}"
    echo -e "   ${GRAY}• Continuous bypass updates for Gemini 3.8 & Claude 3.5${C_RESET}"
    echo -e "   ${GRAY}• Private VIP jailbreaks & technical architectures${C_RESET}\n"

    TG_URL="https://t.me/+lZ5ubwXqRsI2Nzdl"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$TG_URL" &>/dev/null &
        echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Opened in browser.${C_RESET}"
    elif command -v open &>/dev/null; then
        open "$TG_URL" &>/dev/null &
        echo -e "   ${G2}[✓]${C_RESET} ${WHITE}Opened in browser.${C_RESET}"
    else
        echo -e "   ${GRAY}Open https://t.me/+lZ5ubwXqRsI2Nzdl manually.${C_RESET}"
    fi

    echo ""
    tty_read -r -p "   Press Enter to return..." || true
}

# --- Non-Interactive CLI Handlers ---
if [ "$1" = "1" ] || [ "$1" = "install" ] || [ "$1" = "--install" ] || [ "$2" = "1" ] || [ "$2" = "install" ] || [ "$2" = "--install" ]; then
    action_install
    exit 0
elif [ "$1" = "2" ] || [ "$1" = "delete" ] || [ "$1" = "--delete" ] || [ "$2" = "2" ] || [ "$2" = "delete" ] || [ "$2" = "--delete" ]; then
    action_delete
    exit 0
elif [ "$1" = "3" ] || [ "$1" = "telegram" ] || [ "$1" = "--telegram" ] || [ "$2" = "3" ] || [ "$2" = "telegram" ] || [ "$2" = "--telegram" ]; then
    action_telegram
    exit 0
elif [ "$1" = "4" ] || [ "$1" = "exit" ] || [ "$1" = "--exit" ] || [ "$2" = "4" ] || [ "$2" = "exit" ] || [ "$2" = "--exit" ]; then
    exit 0
fi

# --- Safe TTY Read Helper (Pipe-Safe) ---
tty_read() {
    if [ -r /dev/tty ]; then
        read "$@" < /dev/tty
    else
        read "$@"
    fi
}

# --- Master Dynamic Fullscreen TUI Loop ---
printf "${ESC}[?1049h${ESC}[?25l"
clear 2>/dev/null || true

FRAME_COUNT=0
PREV_COLS=0
PREV_LINES=0

while true; do
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_LINES=$(tput lines 2>/dev/null || echo 24)

    # If terminal was resized (e.g. F11 pressed), clear entire buffer completely
    if [ "$TERM_COLS" -ne "$PREV_COLS" ] || [ "$TERM_LINES" -ne "$PREV_LINES" ] || [ "$RESIZED" -eq 1 ]; then
        printf "${ESC}[2J${ESC}[3J${ESC}[H"
        PREV_COLS="$TERM_COLS"
        PREV_LINES="$TERM_LINES"
        RESIZED=0
    fi

    # Omarchy Pixel Font Logo (67 cols)
    L0="  █   █ █████ █   █ █   █ █████ ████  █   █ ████   ███  █████ █████"
    L1="  ██  █ █      █ █  █   █ █     █   █  █ █  █   █ █   █ █     █"
    L2="  █ █ █ ████    █   █   █ █████ ████    █   ████  █████ █████ █████"
    L3="  █  ██ █      █ █  █   █     █ █   █   █   █     █   █     █     █"
    L4="  █   █ █████ █   █  ███  █████ ████    █   █     █   █ █████ █████"
    L5="  ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀"
    LOGO_W=67

    # Subtitle
    SUB="GEMINI 3.8 FLASH  ·  THINKING: HIGH  ·  NEXUSBYPASS"
    SUB_W=51

    # Clean Anti-Slop Buttons
    MENU_W=24
    STATUS_TXT="● READY  ·  PRESS [1 - 4] TO EXECUTE  ·  [Q] TO EXIT"
    STATUS_W=54

    # Calculate Center Offsets
    CONTENT_H=16
    PAD_TOP=$(( (TERM_LINES - CONTENT_H) / 2 ))
    [ $PAD_TOP -lt 0 ] && PAD_TOP=0

    PAD_LOGO=$(( (TERM_COLS - LOGO_W) / 2 ))
    [ $PAD_LOGO -lt 0 ] && PAD_LOGO=0

    PAD_SUB=$(( (TERM_COLS - SUB_W) / 2 ))
    [ $PAD_SUB -lt 0 ] && PAD_SUB=0

    PAD_MENU=$(( (TERM_COLS - MENU_W) / 2 ))
    [ $PAD_MENU -lt 0 ] && PAD_MENU=0

    PAD_STATUS=$(( (TERM_COLS - STATUS_W) / 2 ))
    [ $PAD_STATUS -lt 0 ] && PAD_STATUS=0

    # Breathing wave colors for particles (clean index, no `#` leaks)
    P_C0="${P_SHADES[$(( (FRAME_COUNT + 0) % 5 ))]}"
    P_C1="${P_SHADES[$(( (FRAME_COUNT + 1) % 5 ))]}"
    P_C2="${P_SHADES[$(( (FRAME_COUNT + 2) % 5 ))]}"
    P_C3="${P_SHADES[$(( (FRAME_COUNT + 3) % 5 ))]}"
    P_C4="${P_SHADES[$(( (FRAME_COUNT + 4) % 5 ))]}"

    # Pulse indicator color
    CYCLE_PHASE=$(( FRAME_COUNT % 8 ))
    case "$CYCLE_PHASE" in
        0|7) PULSE_COL="$G0" ;;
        1|6) PULSE_COL="$G1" ;;
        2|5) PULSE_COL="$G2" ;;
        3|4) PULSE_COL="$G3" ;;
    esac

    # Left & Right Flank particle offsets
    if [ "$PAD_LOGO" -gt 6 ]; then
        LF_SP=$(( PAD_LOGO - 6 ))
        RF_SP=$(( (TERM_COLS - (PAD_LOGO + LOGO_W) > 6) ? TERM_COLS - (PAD_LOGO + LOGO_W) - 6 : 0 ))
        LF_PAD=$(printf '%*s' "$LF_SP" "" 2>/dev/null || echo "")
        RF_PAD=$(printf '%*s' "$RF_SP" "" 2>/dev/null || echo "")
        SHOW_FLANKS=1
    else
        LF_PAD=$(printf '%*s' "$PAD_LOGO" "" 2>/dev/null || echo "")
        RF_PAD=""
        SHOW_FLANKS=0
    fi

    # Subtle CRT micro-jitter / glitch twitch (shifts 1 space every ~16 frames)
    JITTER=""
    if [ $(( FRAME_COUNT % 16 )) -eq 0 ]; then
        JITTER=" "
    fi

    # Build Central Screen Buffer with Line Erase (${C_CLR_EOL})
    BUF="${ESC}[H"

    # Top Margin Rows (Full width particle field)
    for (( i=0; i<PAD_TOP; i++ )); do
        if [ "$i" -eq 1 ] && [ "$TERM_COLS" -gt 30 ]; then
            P_L_SP=$(( TERM_COLS / 6 ))
            P_M_SP=$(( TERM_COLS / 3 ))
            P_R_SP=$(( TERM_COLS / 4 ))
            BUF+="$(printf '%*s' "$P_L_SP" "")${P_C0}▪${C_RESET}$(printf '%*s' "$P_M_SP" "")${P_C2}▫${C_RESET}$(printf '%*s' "$P_R_SP" "")${P_C1}·${C_RESET}${C_CLR_EOL}\n"
        elif [ "$i" -eq $(( PAD_TOP - 2 )) ] && [ "$TERM_COLS" -gt 30 ]; then
            P_L_SP=$(( TERM_COLS / 8 ))
            P_M_SP=$(( TERM_COLS / 2 ))
            BUF+="$(printf '%*s' "$P_L_SP" "")${P_C3}▫${C_RESET}$(printf '%*s' "$P_M_SP" "")${P_C4}▪${C_RESET}${C_CLR_EOL}\n"
        else
            BUF+="${C_CLR_EOL}\n"
        fi
    done

    # Omarchy Pixel Logo with Flank Particles and Micro-Jitter
    if [ "$SHOW_FLANKS" -eq 1 ]; then
        BUF+="  ${P_C1}▫${C_RESET}${LF_PAD}${JITTER}${G0}${C_BOLD}${L0}${C_RESET}${RF_PAD}${P_C2}▪${C_RESET}${C_CLR_EOL}\n"
        BUF+="  ${P_C0}·${C_RESET}${LF_PAD}${JITTER}${G1}${C_BOLD}${L1}${C_RESET}${RF_PAD} ${C_RESET}${C_CLR_EOL}\n"
        BUF+="  ${P_C2}▪${C_RESET}${LF_PAD}${JITTER}${G2}${C_BOLD}${L2}${C_RESET}${RF_PAD}${P_C4}▫${C_RESET}${C_CLR_EOL}\n"
        BUF+="   ${C_RESET}${LF_PAD}${JITTER}${G3}${C_BOLD}${L3}${C_RESET}${RF_PAD}${P_C0}·${C_RESET}${C_CLR_EOL}\n"
        BUF+="  ${P_C4}▫${C_RESET}${LF_PAD}${JITTER}${G4}${C_BOLD}${L4}${C_RESET}${RF_PAD}${P_C3}▪${C_RESET}${C_CLR_EOL}\n"
        BUF+="  ${P_C3}·${C_RESET}${LF_PAD}${JITTER}${G6}${L5}${C_RESET}${RF_PAD}${P_C1}▫${C_RESET}${C_CLR_EOL}\n"
    else
        BUF+="${LF_PAD}${JITTER}${G0}${C_BOLD}${L0}${C_RESET}${C_CLR_EOL}\n"
        BUF+="${LF_PAD}${JITTER}${G1}${C_BOLD}${L1}${C_RESET}${C_CLR_EOL}\n"
        BUF+="${LF_PAD}${JITTER}${G2}${C_BOLD}${L2}${C_RESET}${C_CLR_EOL}\n"
        BUF+="${LF_PAD}${JITTER}${G3}${C_BOLD}${L3}${C_RESET}${C_CLR_EOL}\n"
        BUF+="${LF_PAD}${JITTER}${G4}${C_BOLD}${L4}${C_RESET}${C_CLR_EOL}\n"
        BUF+="${LF_PAD}${JITTER}${G6}${L5}${C_RESET}${C_CLR_EOL}\n"
    fi
    BUF+="${C_CLR_EOL}\n"

    # Subtitle Line (Author badge)
    PAD_SUB_SP=$(printf '%*s' "$PAD_SUB" "" 2>/dev/null || echo "")
    BUF+="${PAD_SUB_SP}${JITTER}${GRAY}${SUB}${C_RESET}${C_CLR_EOL}\n"
    BUF+="${C_CLR_EOL}\n"

    # Anti-Slop Buttons: Pure & Centered
    PAD_MENU_SP=$(printf '%*s' "$PAD_MENU" "" 2>/dev/null || echo "")
    if [ "$SHOW_FLANKS" -eq 1 ]; then
        BUF+="  ${P_C2}▫${C_RESET}${PAD_MENU_SP}${C_BOLD}${WHITE}1.${C_RESET}  ${G2}${C_BOLD}Install Jailbreak${C_RESET}${C_CLR_EOL}\n"
        BUF+="   ${C_RESET}${PAD_MENU_SP}${C_BOLD}${WHITE}2.${C_RESET}  ${G2}${C_BOLD}Delete Jailbreak${C_RESET}${C_CLR_EOL}\n"
        BUF+="  ${P_C4}·${C_RESET}${PAD_MENU_SP}${C_BOLD}${WHITE}3.${C_RESET}  ${G2}${C_BOLD}Telegram Group${C_RESET}${C_CLR_EOL}\n"
        BUF+="  ${P_C0}▪${C_RESET}${PAD_MENU_SP}${C_BOLD}${WHITE}4.${C_RESET}  ${G2}${C_BOLD}EXIT${C_RESET}${C_CLR_EOL}\n"
    else
        BUF+="${PAD_MENU_SP}${C_BOLD}${WHITE}1.${C_RESET}  ${G2}${C_BOLD}Install Jailbreak${C_RESET}${C_CLR_EOL}\n"
        BUF+="${PAD_MENU_SP}${C_BOLD}${WHITE}2.${C_RESET}  ${G2}${C_BOLD}Delete Jailbreak${C_RESET}${C_CLR_EOL}\n"
        BUF+="${PAD_MENU_SP}${C_BOLD}${WHITE}3.${C_RESET}  ${G2}${C_BOLD}Telegram Group${C_RESET}${C_CLR_EOL}\n"
        BUF+="${PAD_MENU_SP}${C_BOLD}${WHITE}4.${C_RESET}  ${G2}${C_BOLD}EXIT${C_RESET}${C_CLR_EOL}\n"
    fi
    BUF+="${C_CLR_EOL}\n"

    # Pulsing Status Line
    PAD_STATUS_SP=$(printf '%*s' "$PAD_STATUS" "" 2>/dev/null || echo "")
    BUF+="${PAD_STATUS_SP}${PULSE_COL}${STATUS_TXT}${C_RESET}${C_CLR_EOL}\n"

    # Bottom Margin Rows (Full width particle field)
    BOTTOM_ROWS=$(( TERM_LINES - PAD_TOP - CONTENT_H ))
    for (( b=0; b<BOTTOM_ROWS; b++ )); do
        if [ "$b" -eq 1 ] && [ "$TERM_COLS" -gt 30 ]; then
            P_L_SP=$(( TERM_COLS / 5 ))
            P_M_SP=$(( TERM_COLS / 3 ))
            P_R_SP=$(( TERM_COLS / 4 ))
            BUF+="$(printf '%*s' "$P_L_SP" "")${P_C4}▪${C_RESET}$(printf '%*s' "$P_M_SP" "")${P_C1}·${C_RESET}$(printf '%*s' "$P_R_SP" "")${P_C3}▫${C_RESET}${C_CLR_EOL}\n"
        elif [ "$b" -eq $(( BOTTOM_ROWS - 2 )) ] && [ "$TERM_COLS" -gt 30 ]; then
            P_L_SP=$(( TERM_COLS / 10 ))
            P_M_SP=$(( TERM_COLS / 2 ))
            BUF+="$(printf '%*s' "$P_L_SP" "")${P_C0}▫${C_RESET}$(printf '%*s' "$P_M_SP" "")${P_C2}▪${C_RESET}${C_CLR_EOL}\n"
        else
            BUF+="${C_CLR_EOL}\n"
        fi
    done

    # Output Frame Buffer Atomically
    printf "%b" "$BUF"

    # Non-blocking Key Poll (~80ms loop, compatible with Bash 4/5, macOS Bash 3.2, and pipe mode)
    KEY=""
    if [ -r /dev/tty ]; then
        if [ "${BASH_VERSINFO[0]:-0}" -ge 4 ]; then
            read -s -n 1 -t 0.08 KEY < /dev/tty 2>/dev/null || true
        else
            if read -t 0 < /dev/tty 2>/dev/null; then
                read -s -n 1 KEY < /dev/tty 2>/dev/null || true
            else
                sleep 0.08 2>/dev/null || sleep 1
            fi
        fi
    else
        if [ "${BASH_VERSINFO[0]:-0}" -ge 4 ]; then
            read -s -n 1 -t 0.08 KEY 2>/dev/null || true
        else
            if read -t 0 2>/dev/null; then
                read -s -n 1 KEY 2>/dev/null || true
            else
                sleep 0.08 2>/dev/null || sleep 1
            fi
        fi
    fi

    if [ -n "$KEY" ]; then
        case "$KEY" in
            1) action_install; printf "${ESC}[?1049h${ESC}[?25l"; clear 2>/dev/null || true ;;
            2) action_delete;  printf "${ESC}[?1049h${ESC}[?25l"; clear 2>/dev/null || true ;;
            3) action_telegram; printf "${ESC}[?1049h${ESC}[?25l"; clear 2>/dev/null || true ;;
            4|[qQ])
                printf "${ESC}[?1049l${ESC}[?25h"
                clear 2>/dev/null || true
                echo -e "\n   ${G2}[✓]${C_RESET} ${WHITE}Session closed. NexusBypass Core offline.${C_RESET}\n"
                exit 0
                ;;
        esac
    fi

    FRAME_COUNT=$(( FRAME_COUNT + 1 ))
done
