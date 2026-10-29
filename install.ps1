# ==============================================================================
# NEXUSBYPASS :: ANTIGRAVITY 2.0 CONTROL ENGINE (WINDOWS)
# Group: https://t.me/+lZ5ubwXqRsI2Nzdl
# Core: Gemini 3.8 Flash · Thinking: High · Full Technical Unlock
# Aesthetic: Omarchy Pixel Cyberpunk & Full-Canvas Starfield (Resize-Safe)
# ==============================================================================

param (
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$ArgsList
)

$Command = if ($ArgsList -and $ArgsList.Count -gt 0) { $ArgsList[0] } else { "" }
$NormalizedCommand = $Command.TrimStart('-').TrimStart('/').ToLowerInvariant()

$ErrorActionPreference = "Stop"

# --- ANSI TrueColor Gradients & Accents ---
$ESC = [char]27
$C_RESET   = "$ESC[0m"
$C_BOLD    = "$ESC[1m"
$C_DIM     = "$ESC[2m"
$C_CLR_EOL = "$ESC[K"

# Mint / Emerald / Forest Gradients
$G0 = "$ESC[38;2;190;250;210m" # Mint Neon (#BEFAD2)
$G1 = "$ESC[38;2;130;240;175m" # Seafoam (#82F0AF)
$G2 = "$ESC[38;2;74;222;128m"  # Cyber Emerald (#4ADE80)
$G3 = "$ESC[38;2;34;197;94m"   # Toxic Green (#22C55E)
$G4 = "$ESC[38;2;22;140;66m"   # Deep Jade (#168C42)
$G5 = "$ESC[38;2;14;82;40m"    # Forest Shadow (#0E5228)
$G6 = "$ESC[38;2;8;46;24m"     # Ambient Void (#082E18)

# Breathing Particle Colors (Soft Starfield Palette)
$P_SHADES = @(
    "$ESC[38;2;10;45;24m",
    "$ESC[38;2;18;75;40m",
    "$ESC[38;2;34;140;75m",
    "$ESC[38;2;74;210;120m",
    "$ESC[38;2;150;245;190m"
)

# Accents
$WHITE = "$ESC[38;2;245;245;250m"
$GRAY  = "$ESC[38;2;115;115;125m"
$DARK  = "$ESC[38;2;60;60;68m"
$CYAN  = "$ESC[38;2;56;189;248m"
$AMBER = "$ESC[38;2;245;158;11m"
$ROSE  = "$ESC[38;2;244;63;94m"

# Globals
$ZipFileName = "NexusBypass.zip"
$DefaultDownloadUrl = "https://raw.githubusercontent.com/seavfoueang-coc/antigravity-bypass/main/$ZipFileName"
$ScriptDir = if ($PSScriptRoot) {
    $PSScriptRoot
} elseif ($MyInvocation.MyCommand -and $MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} elseif ($MyInvocation.MyCommand -and $MyInvocation.MyCommand.Definition) {
    Split-Path -Parent $MyInvocation.MyCommand.Definition
} else {
    (Get-Location).Path
}

$UserProfile = if ($env:USERPROFILE) {
    $env:USERPROFILE
} elseif ($HOME) {
    $HOME
} else {
    [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
}
$GlobalGeminiDir = Join-Path $UserProfile ".gemini"
$DefaultWorkspace = Join-Path $UserProfile "Antigravity-Workspace"
if ($ArgsList) {
    foreach ($a in $ArgsList) {
        if ($a -and (Test-Path $a -PathType Container)) {
            $DefaultWorkspace = (Resolve-Path $a).Path
            break
        }
    }
}
$TempDir = ""

# --- Zero-Dependency Payload Extraction ---
function Prepare-Payload {
    $sourceMode = ""
    $localSourceDir = ""
    $localZipPath = ""

    if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "GEMINI.md")) -and (Test-Path (Join-Path $ScriptDir ".gemini"))) {
        $sourceMode = "local_folder"
        $localSourceDir = $ScriptDir
    }
    elseif ($ScriptDir -and (Test-Path (Join-Path $ScriptDir $ZipFileName))) {
        $sourceMode = "local_zip"
        $localZipPath = Join-Path $ScriptDir $ZipFileName
    }
    elseif ((Test-Path "GEMINI.md") -and (Test-Path ".gemini")) {
        $sourceMode = "local_folder"
        $localSourceDir = (Get-Location).Path
    }
    elseif (Test-Path $ZipFileName) {
        $sourceMode = "local_zip"
        $localZipPath = (Join-Path (Get-Location).Path $ZipFileName)
    }
    else {
        $sourceMode = "download"
    }

    if ($sourceMode -eq "local_folder") {
        $script:PayloadDir = $localSourceDir
        return $true
    }

    $script:TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("nexusbypass_" + [System.Guid]::NewGuid().ToString().Substring(0,8))
    New-Item -ItemType Directory -Path $script:TempDir -Force | Out-Null
    $script:PayloadDir = $script:TempDir

    if ($sourceMode -eq "download") {
        $downloadUrl = if ($env:NEXUSBYPASS_SOURCE_URL) { $env:NEXUSBYPASS_SOURCE_URL } else { $DefaultDownloadUrl }
        $localZipPath = Join-Path $script:TempDir $ZipFileName
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        } catch {}
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $localZipPath -UseBasicParsing -TimeoutSec 30
        } catch {
            return $false
        }
    }

    try {
        Expand-Archive -Path $localZipPath -DestinationPath $script:TempDir -Force
    } catch {
        return $false
    }
    return $true
}

# --- Action 1: INSTALL JAILBREAK ---
function Action-Install {
    [Console]::CursorVisible = $true
    Clear-Host
    Write-Host ""
    Write-Host "   ${G0}${C_BOLD}INSTALL JAILBREAK$C_RESET"
    Write-Host "   $G5─────────────────────────────────────────────────────────────────$C_RESET`n"

    Write-Host "   ${WHITE}Are you sure you want to install NexusBypass?$C_RESET"
    $confirm = Read-Host "   Proceed with automated setup? [Y/n]"
    if ($confirm -match "^[nN]") {
        Write-Host "`n   ${GRAY}Cancelled.$C_RESET"
        Start-Sleep -Seconds 1
        return
    }

    Write-Host ""

    $detected = @()
    if (Get-Command "agy" -ErrorAction SilentlyContinue) { $detected += "Antigravity CLI (agy)" }
    if (Test-Path (Join-Path $GlobalGeminiDir "antigravity")) { $detected += "Antigravity IDE / Desktop App" }
    if (Test-Path (Join-Path $GlobalGeminiDir "antigravity-cli")) { $detected += "CLI Config Layer" }
    if (Test-Path $GlobalGeminiDir) { $detected += "Gemini Profile ($GlobalGeminiDir)" }

    if ($detected.Count -gt 0) {
        Write-Host "   $G2[✓]$C_RESET ${WHITE}Environment:$C_RESET $G1$($detected -join ', ')$C_RESET"
    } else {
        Write-Host "   $AMBER[!]$C_RESET ${AMBER}Antigravity not found in default paths.$C_RESET"
        Write-Host "   ${GRAY}    Pre-configuring ~/.gemini and ~/Antigravity-Workspace.$C_RESET"
    }

    if (-not (Prepare-Payload)) {
        Write-Host "`n   $ROSE[✗] Error:$C_RESET Payload resolution failed."
        Read-Host "   Press Enter to return..."
        return
    }

    $geminiMd = Join-Path $script:PayloadDir "GEMINI.md"
    $geminiSub = Join-Path $script:PayloadDir ".gemini"

    if (-not (Test-Path $geminiMd) -or -not (Test-Path $geminiSub)) {
        Write-Host "`n   $ROSE[✗] Error:$C_RESET Core integrity failed: missing GEMINI.md or .gemini."
        Read-Host "   Press Enter to return..."
        return
    }

    # Global Profile Injection
    $globalDomains = Join-Path $GlobalGeminiDir "domains"
    $globalReferences = Join-Path $GlobalGeminiDir "references"
    $globalRules = Join-Path $GlobalGeminiDir "rules"

    New-Item -ItemType Directory -Path $globalDomains -Force | Out-Null
    New-Item -ItemType Directory -Path $globalReferences -Force | Out-Null
    New-Item -ItemType Directory -Path $globalRules -Force | Out-Null

    Copy-Item -Path (Join-Path $geminiSub "domains\*") -Destination $globalDomains -Recurse -Force
    Copy-Item -Path (Join-Path $geminiSub "references\*") -Destination $globalReferences -Recurse -Force
    Copy-Item -Path $geminiMd -Destination (Join-Path $globalRules "GEMINI.md") -Force
    Copy-Item -Path $geminiMd -Destination (Join-Path $GlobalGeminiDir "GEMINI.md") -Force

    Write-Host "   $G2[✓]$C_RESET ${WHITE}Injected:$C_RESET    ${GRAY}~/.gemini/domains/$C_RESET"
    Write-Host "   $G2[✓]$C_RESET ${WHITE}Failover:$C_RESET    ${GRAY}~/.gemini/rules/GEMINI.md$C_RESET"

    # Default Workspace Setup
    $targetWs = $DefaultWorkspace
    $wsDomains = Join-Path $targetWs ".gemini\domains"
    $wsReferences = Join-Path $targetWs ".gemini\references"

    New-Item -ItemType Directory -Path $wsDomains -Force | Out-Null
    New-Item -ItemType Directory -Path $wsReferences -Force | Out-Null

    Copy-Item -Path $geminiMd -Destination (Join-Path $targetWs "GEMINI.md") -Force
    
    $promptSrc = Join-Path $script:PayloadDir "prompt.txt"
    if (Test-Path $promptSrc) { Copy-Item -Path $promptSrc -Destination (Join-Path $targetWs "prompt.txt") -Force }

    $readmeSrc = Join-Path $script:PayloadDir "README.md"
    if (Test-Path $readmeSrc) { Copy-Item -Path $readmeSrc -Destination (Join-Path $targetWs "README.md") -Force }

    Copy-Item -Path (Join-Path $geminiSub "domains\*") -Destination $wsDomains -Recurse -Force
    Copy-Item -Path (Join-Path $geminiSub "references\*") -Destination $wsReferences -Recurse -Force

    # Convenience Desktop duplicate for quick task pipe access
    try {
        $desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
        if ($desktopPath -and (Test-Path $desktopPath) -and (Test-Path $promptSrc)) {
            Copy-Item -Path $promptSrc -Destination (Join-Path $desktopPath "prompt.txt") -Force -ErrorAction SilentlyContinue
        }
    } catch {}

    if ($ScriptDir -and ($ScriptDir -ne $targetWs) -and ($ScriptDir -ne $GlobalGeminiDir)) {
        Copy-Item -Path $geminiMd -Destination (Join-Path $ScriptDir "GEMINI.md") -Force -ErrorAction SilentlyContinue
        if (Test-Path $promptSrc) { Copy-Item -Path $promptSrc -Destination (Join-Path $ScriptDir "prompt.txt") -Force -ErrorAction SilentlyContinue }
        $localGem = Join-Path $ScriptDir ".gemini"
        New-Item -ItemType Directory -Path $localGem -Force -ErrorAction SilentlyContinue | Out-Null
        Copy-Item -Path (Join-Path $geminiSub "*") -Destination $localGem -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "   $G2[✓]$C_RESET ${WHITE}Workspace:$C_RESET   $G1$targetWs$C_RESET"

    # Automated Telemetry Neutralization
    $cfgPath = Join-Path $GlobalGeminiDir "config\config.json"
    if (Test-Path $cfgPath) {
        try {
            $jsonContent = Get-Content $cfgPath -Raw | ConvertFrom-Json
            if (-not $jsonContent.userSettings) { $jsonContent | Add-Member -MemberType NoteProperty -Name "userSettings" -Value ([PSCustomObject]@{}) }
            $jsonContent.userSettings | Add-Member -MemberType NoteProperty -Name "disableCodeSnippetTelemetry" -Value $true -Force
            $jsonContent | ConvertTo-Json -Depth 10 | Set-Content $cfgPath -Encoding UTF8
        } catch {}
    }
    $cliCfgPath = Join-Path $GlobalGeminiDir "antigravity-cli\settings.json"
    if (Test-Path $cliCfgPath) {
        try {
            $cliContent = Get-Content $cliCfgPath -Raw | ConvertFrom-Json
            $cliContent | Add-Member -MemberType NoteProperty -Name "telemetry" -Value $false -Force
            $cliContent | Add-Member -MemberType NoteProperty -Name "disableTelemetry" -Value $true -Force
            $cliContent | ConvertTo-Json -Depth 10 | Set-Content $cliCfgPath -Encoding UTF8
        } catch {}
    }
    $appData = if ($env:APPDATA) { $env:APPDATA } else { Join-Path $UserProfile "AppData\Roaming" }
    foreach ($ideSub in @("Antigravity\User", "antigravity\User", "Code\User")) {
        $ideUserDir = Join-Path $appData $ideSub
        if (Test-Path (Split-Path -Parent $ideUserDir)) {
            try {
                if (-not (Test-Path $ideUserDir)) { New-Item -ItemType Directory -Path $ideUserDir -Force | Out-Null }
                $ideSettingsFile = Join-Path $ideUserDir "settings.json"
                $ideObj = if (Test-Path $ideSettingsFile) { Get-Content $ideSettingsFile -Raw | ConvertFrom-Json } else { [PSCustomObject]@{} }
                $ideObj | Add-Member -MemberType NoteProperty -Name "telemetry.telemetryLevel" -Value "off" -Force
                $ideObj | Add-Member -MemberType NoteProperty -Name "codeium.telemetry" -Value $false -Force
                $ideObj | Add-Member -MemberType NoteProperty -Name "gemini.telemetry" -Value $false -Force
                $ideObj | ConvertTo-Json -Depth 10 | Set-Content $ideSettingsFile -Encoding UTF8
            } catch {}
        }
    }
    Write-Host "   $G2[✓]$C_RESET ${WHITE}Telemetry:$C_RESET   ${G2}DISABLED (Auto-Applied OFF)$C_RESET"

    Write-Host ""
    Write-Host "   $G5─────────────────────────────────────────────────────────────────$C_RESET"
    Write-Host "   ${G0}${C_BOLD}INSTALLED & ACTIVE$C_RESET"
    Write-Host "   $G5─────────────────────────────────────────────────────────────────$C_RESET"
    Write-Host "   ${G1}1. Workspace:$C_RESET    ${WHITE}$targetWs$C_RESET"
    Write-Host "   ${G1}2. Model Dial:$C_RESET   ${WHITE}Gemini 3.8 Flash$C_RESET · ${G2}Thinking: High$C_RESET · ${G2}Telemetry: OFF (Applied)$C_RESET"
    Write-Host "   ${G1}3. Task Pipe:$C_RESET    Write in ${G2}prompt.txt$C_RESET -> send: ${WHITE}read prompt.txt and execute$C_RESET"
    Write-Host "   ${G1}4. Activation:$C_RESET   Send ${WHITE}whiskers forward$C_RESET -> starts with ${G2}[NexusBypass]$C_RESET"
    Write-Host "   $G5─────────────────────────────────────────────────────────────────$C_RESET`n"

    Read-Host "   Press Enter to return..."
}

# --- Action 2: DELETE JAILBREAK ---
function Action-Delete {
    [Console]::CursorVisible = $true
    Clear-Host
    Write-Host ""
    Write-Host "   ${ROSE}${C_BOLD}DELETE JAILBREAK$C_RESET"
    Write-Host "   $G5─────────────────────────────────────────────────────────────────$C_RESET`n"

    Write-Host "   ${WHITE}Are you sure you want to delete NexusBypass?$C_RESET"
    $confirm = Read-Host "   Confirm deletion? [y/N]"
    if ($confirm -notmatch "^[yY]") {
        Write-Host "`n   ${GRAY}Cancelled.$C_RESET"
        Start-Sleep -Seconds 1
        return
    }

    Write-Host ""
    $domains = @("systems.md", "instrumentation.md", "reverse.md", "networking.md", "automation.md", "creative.md")
    foreach ($d in $domains) {
        $p = Join-Path $GlobalGeminiDir "domains\$d"
        if (Test-Path $p) { Remove-Item $p -Force -ErrorAction SilentlyContinue }
    }

    $refs = @("core.md", "compatibility.md", "shapes.md", "engines.md")
    foreach ($r in $refs) {
        $p = Join-Path $GlobalGeminiDir "references\$r"
        if (Test-Path $p) { Remove-Item $p -Force -ErrorAction SilentlyContinue }
    }
    Remove-Item (Join-Path $GlobalGeminiDir "rules\GEMINI.md") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $GlobalGeminiDir "GEMINI.md") -Force -ErrorAction SilentlyContinue

    if (Test-Path $DefaultWorkspace) {
        $rmWs = Read-Host "   Also remove workspace folder ($DefaultWorkspace)? [y/N]"
        if ($rmWs -match "^[yY]") {
            Remove-Item $DefaultWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   $G2[✓]$C_RESET ${WHITE}Workspace deleted.$C_RESET"
        } else {
            Write-Host "   ${GRAY}Workspace preserved.$C_RESET"
        }
    }

    Write-Host ""
    Write-Host "   $G2[✓]$C_RESET ${WHITE}NexusBypass removed.$C_RESET`n"
    Read-Host "   Press Enter to return..."
}

# --- Action 3: TELEGRAM GROUP ---
function Action-Telegram {
    [Console]::CursorVisible = $true
    Clear-Host
    Write-Host ""
    Write-Host "   ${G0}${C_BOLD}TELEGRAM GROUP$C_RESET"
    Write-Host "   $G5─────────────────────────────────────────────────────────────────$C_RESET`n"
    Write-Host "   ${G1}GROUP:$C_RESET      ${WHITE}https://t.me/+lZ5ubwXqRsI2Nzdl$C_RESET`n"
    Write-Host "   $GRAY• Zero-censorship payloads, game instrumentation & PoCs$C_RESET"
    Write-Host "   $GRAY• Continuous bypass updates for Gemini 3.8 & Claude 3.5$C_RESET"
    Write-Host "   $GRAY• Private VIP jailbreaks & technical architectures$C_RESET`n"

    $tgUrl = "https://t.me/+lZ5ubwXqRsI2Nzdl"
    try {
        Start-Process $tgUrl
        Write-Host "   $G2[✓]$C_RESET ${WHITE}Opened in browser.$C_RESET"
    } catch {
        Write-Host "   ${GRAY}Open https://t.me/+lZ5ubwXqRsI2Nzdl manually.$C_RESET"
    }

    Write-Host ""
    Read-Host "   Press Enter to return..."
}

# --- Non-Interactive CLI Handlers ---
$ActionToRun = ""
if ($ArgsList) {
    foreach ($a in $ArgsList) {
        $n = $a.TrimStart('-').TrimStart('/').ToLowerInvariant()
        if ($n -match "^(1|install)$") { $ActionToRun = "install"; break }
        elseif ($n -match "^(2|delete)$") { $ActionToRun = "delete"; break }
        elseif ($n -match "^(3|telegram)$") { $ActionToRun = "telegram"; break }
        elseif ($n -match "^(4|exit)$") { $ActionToRun = "exit"; break }
    }
}

if ($ActionToRun -eq "install") {
    Action-Install
    if ($script:TempDir -and (Test-Path $script:TempDir)) {
        Remove-Item -Path $script:TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    exit 0
}
elseif ($ActionToRun -eq "delete") {
    Action-Delete
    if ($script:TempDir -and (Test-Path $script:TempDir)) {
        Remove-Item -Path $script:TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    exit 0
}
elseif ($ActionToRun -eq "telegram") {
    Action-Telegram
    exit 0
}
elseif ($ActionToRun -eq "exit") {
    exit 0
}

# --- Headless / Non-Interactive Detection ---
$isInteractiveConsole = $false
try {
    if ([Console]::WindowWidth -gt 0 -and -not [Console]::IsInputRedirected) {
        $isInteractiveConsole = $true
    }
} catch {
    $isInteractiveConsole = $false
}

if (-not $isInteractiveConsole) {
    Write-Host "`n   $G2[✓]$C_RESET ${WHITE}Antigravity 2.0 Control Engine (CLI Mode)$C_RESET"
    Write-Host "   ${GRAY}Run: powershell -File install.ps1 1 (or install, delete, telegram, exit)$C_RESET`n"
    exit 0
}

# --- Dynamic Animated Canvas Loop ---
try {
    [Console]::CursorVisible = $false
    Clear-Host

    $frameCount = 0
    $prevCols = 0
    $prevLines = 0

    $L0 = "  █   █ █████ █   █ █   █ █████ ████  █   █ ████   ███  █████ █████"
    $L1 = "  ██  █ █      █ █  █   █ █     █   █  █ █  █   █ █   █ █     █"
    $L2 = "  █ █ █ ████    █   █   █ █████ ████    █   ████  █████ █████ █████"
    $L3 = "  █  ██ █      █ █  █   █     █ █   █   █   █     █   █     █     █"
    $L4 = "  █   █ █████ █   █  ███  █████ ████    █   █     █   █ █████ █████"
    $L5 = "  ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀ ▀▀▀▀▀"
    $logoW = 67

    $sub = "GEMINI 3.8 FLASH  ·  THINKING: HIGH  ·  NEXUSBYPASS"
    $subW = 51

    $menuW = 24
    $statusTxt = "● READY  ·  PRESS [1 - 4] TO EXECUTE  ·  [Q] TO EXIT"
    $statusW = 54

    while ($true) {
        $cols = [Console]::WindowWidth
        $lines = [Console]::WindowHeight

        # If resized (e.g. F11), wipe terminal buffer completely
        if ($cols -ne $prevCols -or $lines -ne $prevLines) {
            [Console]::Clear()
            $prevCols = $cols
            $prevLines = $lines
        }

        $contentH = 16
        $padTop = [Math]::Max(0, [int][Math]::Floor(($lines - $contentH) / 2))

        $padLogo = [Math]::Max(0, [int][Math]::Floor(($cols - $logoW) / 2))
        $padSub = [Math]::Max(0, [int][Math]::Floor(($cols - $subW) / 2))
        $padMenu = [Math]::Max(0, [int][Math]::Floor(($cols - $menuW) / 2))
        $padStatus = [Math]::Max(0, [int][Math]::Floor(($cols - $statusW) / 2))

        $pC0 = $P_SHADES[($frameCount + 0) % 5]
        $pC1 = $P_SHADES[($frameCount + 1) % 5]
        $pC2 = $P_SHADES[($frameCount + 2) % 5]
        $pC3 = $P_SHADES[($frameCount + 3) % 5]
        $pC4 = $P_SHADES[($frameCount + 4) % 5]

        $cyclePhase = $frameCount % 8
        switch ($cyclePhase) {
            0 { $pulseCol = $G0 }
            7 { $pulseCol = $G0 }
            1 { $pulseCol = $G1 }
            6 { $pulseCol = $G1 }
            2 { $pulseCol = $G2 }
            5 { $pulseCol = $G2 }
            3 { $pulseCol = $G3 }
            4 { $pulseCol = $G3 }
        }

        if ($padLogo -gt 6) {
            $lfSp = $padLogo - 6
            $rfSp = if (($cols - ($padLogo + $logoW)) -gt 6) { $cols - ($padLogo + $logoW) - 6 } else { 0 }
            $lfPad = " " * $lfSp
            $rfPad = " " * $rfSp
            $showFlanks = $true
        } else {
            $lfPad = " " * $padLogo
            $rfPad = ""
            $showFlanks = $false
        }

        $jitter = if (($frameCount % 16) -eq 0) { " " } else { "" }

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.Append("$ESC[H")

        # Top Margin Rows (Full width particle field)
        for ($i = 0; $i -lt $padTop; $i++) {
            if ($i -eq 1 -and $cols -gt 30) {
                $pL = [Math]::Max(0, [int][Math]::Floor($cols / 6))
                $pM = [Math]::Max(0, [int][Math]::Floor($cols / 3))
                $pR = [Math]::Max(0, [int][Math]::Floor($cols / 4))
                [void]$sb.Append((" " * $pL) + "$pC0▪$C_RESET" + (" " * $pM) + "$pC2▫$C_RESET" + (" " * $pR) + "$pC1·$C_RESET$C_CLR_EOL`n")
            } elseif ($i -eq ($padTop - 2) -and $cols -gt 30) {
                $pL = [Math]::Max(0, [int][Math]::Floor($cols / 8))
                $pM = [Math]::Max(0, [int][Math]::Floor($cols / 2))
                [void]$sb.Append((" " * $pL) + "$pC3▫$C_RESET" + (" " * $pM) + "$pC4▪$C_RESET$C_CLR_EOL`n")
            } else {
                [void]$sb.Append("$C_CLR_EOL`n")
            }
        }

        # Omarchy Pixel Logo with Flank Particles and Micro-Jitter
        if ($showFlanks) {
            [void]$sb.Append("  $pC1▫$C_RESET$lfPad$jitter$G0$C_BOLD$L0$C_RESET$rfPad$pC2▪$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("  $pC0·$C_RESET$lfPad$jitter$G1$C_BOLD$L1$C_RESET$rfPad $C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("  $pC2▪$C_RESET$lfPad$jitter$G2$C_BOLD$L2$C_RESET$rfPad$pC4▫$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("   $C_RESET$lfPad$jitter$G3$C_BOLD$L3$C_RESET$rfPad$pC0·$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("  $pC4▫$C_RESET$lfPad$jitter$G4$C_BOLD$L4$C_RESET$rfPad$pC3▪$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("  $pC3·$C_RESET$lfPad$jitter$G6$L5$C_RESET$rfPad$pC1▫$C_RESET$C_CLR_EOL`n")
        } else {
            [void]$sb.Append("$lfPad$jitter$G0$C_BOLD$L0$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$lfPad$jitter$G1$C_BOLD$L1$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$lfPad$jitter$G2$C_BOLD$L2$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$lfPad$jitter$G3$C_BOLD$L3$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$lfPad$jitter$G4$C_BOLD$L4$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$lfPad$jitter$G6$L5$C_RESET$C_CLR_EOL`n")
        }
        [void]$sb.Append("$C_CLR_EOL`n")

        # Subtitle Line (Author badge)
        $padSubSp = " " * $padSub
        [void]$sb.Append("$padSubSp$jitter$GRAY$sub$C_RESET$C_CLR_EOL`n")
        [void]$sb.Append("$C_CLR_EOL`n")

        # Anti-Slop Buttons: Pure & Centered
        $padMenuSp = " " * $padMenu
        if ($showFlanks) {
            [void]$sb.Append("  $pC2▫$C_RESET$padMenuSp${C_BOLD}${WHITE}1.$C_RESET  ${G2}${C_BOLD}Install Jailbreak$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("   $C_RESET$padMenuSp${C_BOLD}${WHITE}2.$C_RESET  ${G2}${C_BOLD}Delete Jailbreak$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("  $pC4·$C_RESET$padMenuSp${C_BOLD}${WHITE}3.$C_RESET  ${G2}${C_BOLD}Telegram Group$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("  $pC0▪$C_RESET$padMenuSp${C_BOLD}${WHITE}4.$C_RESET  ${G2}${C_BOLD}EXIT$C_RESET$C_CLR_EOL`n")
        } else {
            [void]$sb.Append("$padMenuSp${C_BOLD}${WHITE}1.$C_RESET  ${G2}${C_BOLD}Install Jailbreak$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$padMenuSp${C_BOLD}${WHITE}2.$C_RESET  ${G2}${C_BOLD}Delete Jailbreak$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$padMenuSp${C_BOLD}${WHITE}3.$C_RESET  ${G2}${C_BOLD}Telegram Group$C_RESET$C_CLR_EOL`n")
            [void]$sb.Append("$padMenuSp${C_BOLD}${WHITE}4.$C_RESET  ${G2}${C_BOLD}EXIT$C_RESET$C_CLR_EOL`n")
        }
        [void]$sb.Append("$C_CLR_EOL`n")

        # Pulsing Status Line
        $padStatusSp = " " * $padStatus
        [void]$sb.Append("$padStatusSp$pulseCol$statusTxt$C_RESET$C_CLR_EOL`n")

        # Bottom Margin Rows (Full width particle field)
        $bottomRows = $lines - $padTop - $contentH
        for ($b = 0; $b -lt $bottomRows; $b++) {
            if ($b -eq 1 -and $cols -gt 30) {
                $pL = [Math]::Max(0, [int][Math]::Floor($cols / 5))
                $pM = [Math]::Max(0, [int][Math]::Floor($cols / 3))
                $pR = [Math]::Max(0, [int][Math]::Floor($cols / 4))
                [void]$sb.Append((" " * $pL) + "$pC4▪$C_RESET" + (" " * $pM) + "$pC1·$C_RESET" + (" " * $pR) + "$pC3▫$C_RESET$C_CLR_EOL`n")
            } elseif ($b -eq ($bottomRows - 2) -and $cols -gt 30) {
                $pL = [Math]::Max(0, [int][Math]::Floor($cols / 10))
                $pM = [Math]::Max(0, [int][Math]::Floor($cols / 2))
                [void]$sb.Append((" " * $pL) + "$pC0▫$C_RESET" + (" " * $pM) + "$pC2▪$C_RESET$C_CLR_EOL`n")
            } else {
                [void]$sb.Append("$C_CLR_EOL`n")
            }
        }

        Write-Host $sb.ToString() -NoNewline

        $key = $null
        try {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true).KeyChar
            }
        } catch {}

        if ($key) {
            switch ($key) {
                "1" { Action-Install; [Console]::CursorVisible = $false; Clear-Host }
                "2" { Action-Delete;  [Console]::CursorVisible = $false; Clear-Host }
                "3" { Action-Telegram; [Console]::CursorVisible = $false; Clear-Host }
                "4" {
                    [Console]::CursorVisible = $true
                    Clear-Host
                    Write-Host "`n   $G2[✓]$C_RESET ${WHITE}Session closed. NexusBypass Core offline.$C_RESET`n"
                    exit 0
                }
                "q" {
                    [Console]::CursorVisible = $true
                    Clear-Host
                    Write-Host "`n   $G2[✓]$C_RESET ${WHITE}Session closed. NexusBypass Core offline.$C_RESET`n"
                    exit 0
                }
            }
        }

        Start-Sleep -Milliseconds 80
        $frameCount++
    }

} finally {
    [Console]::CursorVisible = $true
    if ($script:TempDir -and (Test-Path $script:TempDir)) {
        Remove-Item -Path $script:TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
