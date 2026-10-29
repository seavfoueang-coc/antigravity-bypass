@echo off
chcp 65001 >nul
title NexusBypass - Antigravity 2.0 Control Console

:: Enable Virtual Terminal Processing for Windows conhost
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Check if PowerShell 7 (pwsh) is present, otherwise fallback to Windows PowerShell
where pwsh.exe >nul 2>&1
if %errorlevel% equ 0 (
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
)

if %errorlevel% neq 0 (
    echo.
    echo [!] Session terminated with exit code %errorlevel%.
    pause
)
