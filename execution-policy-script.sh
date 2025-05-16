#!/bin/bash
# Universal Execution Policy Script
# This script helps change execution policies across macOS, Windows, and Linux
# Save this file as "change_execution_policy.sh" 

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function for macOS execution policy
macos_execution() {
    echo -e "${BOLD}${BLUE}macOS Execution Policy Settings${NC}"
    echo "------------------------------------"
    echo -e "${YELLOW}Select an operation:${NC}"
    echo "1. Make a file executable"
    echo "2. Allow applications from unidentified developers"
    echo "3. Reset Gatekeeper settings to default"
    echo "4. Show current security settings"
    echo "q. Quit"
    
    read -p "Enter your choice: " choice
    
    case "$choice" in
        1)
            read -p "Enter path to file: " filepath
            if [ -f "$filepath" ]; then
                chmod +x "$filepath"
                echo -e "${GREEN}File is now executable!${NC}"
                ls -la "$filepath"
            else
                echo -e "${RED}File not found!${NC}"
            fi
            ;;
        2)
            echo -e "${YELLOW}WARNING: This will temporarily disable Gatekeeper.${NC}"
            read -p "Are you sure you want to continue? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                echo "Requesting sudo access to modify security settings..."
                sudo spctl --master-disable
                echo -e "${GREEN}Gatekeeper disabled. You can now run applications from unidentified developers.${NC}"
                echo -e "${YELLOW}To re-enable security, choose option 3 when finished.${NC}"
            fi
            ;;
        3)
            echo "Requesting sudo access to reset security settings..."
            sudo spctl --master-enable
            echo -e "${GREEN}Gatekeeper security settings restored to default.${NC}"
            ;;
        4)
            echo "Current Gatekeeper status:"
            spctl --status
            echo ""
            echo "To check a specific application:"
            read -p "Enter path to application: " app_path
            if [ -e "$app_path" ]; then
                spctl --assess --verbose "$app_path"
            else
                echo -e "${RED}Application not found!${NC}"
            fi
            ;;
        q|Q)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# Function for Linux execution policy
linux_execution() {
    echo -e "${BOLD}${BLUE}Linux Execution Policy Settings${NC}"
    echo "------------------------------------"
    echo -e "${YELLOW}Select an operation:${NC}"
    echo "1. Make a file executable"
    echo "2. Show file permissions"
    echo "3. Change ownership of a file"
    echo "4. Add executable permission to all scripts in a directory"
    echo "q. Quit"
    
    read -p "Enter your choice: " choice
    
    case "$choice" in
        1)
            read -p "Enter path to file: " filepath
            if [ -f "$filepath" ]; then
                echo "Select permission level:"
                echo "1. Owner only (u+x)"
                echo "2. Owner and group (ug+x)"
                echo "3. Everyone (a+x)"
                read -p "Enter choice (1-3): " perm_choice
                
                case "$perm_choice" in
                    1) chmod u+x "$filepath" ;;
                    2) chmod ug+x "$filepath" ;;
                    3) chmod a+x "$filepath" ;;
                    *) echo -e "${RED}Invalid choice, using owner only (u+x)${NC}"; chmod u+x "$filepath" ;;
                esac
                
                echo -e "${GREEN}File permissions updated!${NC}"
                ls -la "$filepath"
            else
                echo -e "${RED}File not found!${NC}"
            fi
            ;;
        2)
            read -p "Enter path to file or directory: " path
            if [ -e "$path" ]; then
                ls -la "$path"
            else
                echo -e "${RED}Path not found!${NC}"
            fi
            ;;
        3)
            read -p "Enter path to file: " filepath
            if [ -e "$filepath" ]; then
                read -p "Enter new owner: " owner
                read -p "Enter new group (leave blank to keep current): " group
                
                if [ -z "$group" ]; then
                    sudo chown "$owner" "$filepath"
                else
                    sudo chown "$owner":"$group" "$filepath"
                fi
                
                echo -e "${GREEN}Ownership changed!${NC}"
                ls -la "$filepath"
            else
                echo -e "${RED}File not found!${NC}"
            fi
            ;;
        4)
            read -p "Enter directory path: " dirpath
            if [ -d "$dirpath" ]; then
                read -p "File extension to make executable (e.g., sh, py): " ext
                find "$dirpath" -name "*.$ext" -exec chmod +x {} \;
                echo -e "${GREEN}All .$ext files in $dirpath are now executable!${NC}"
            else
                echo -e "${RED}Directory not found!${NC}"
            fi
            ;;
        q|Q)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# Function for Windows execution policy
windows_execution() {
    echo -e "${BOLD}${BLUE}Windows Execution Policy Settings${NC}"
    echo "------------------------------------"
    echo -e "${YELLOW}This will create and run a PowerShell script to modify execution policies.${NC}"
    echo "1. Create and run PowerShell script for execution policy"
    echo "2. Make a batch file to enable PowerShell script execution"
    echo "q. Quit"
    
    read -p "Enter your choice: " choice
    
    case "$choice" in
        1)
            echo "Creating PowerShell script..."
            cat > change_execution_policy.ps1 << 'EOF'
# PowerShell Script to Change Execution Policy
# Run this as Administrator

function Show-Menu {
    param (
        [string]$Title = 'Windows PowerShell Execution Policy Manager'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host ""
    Write-Host "Current execution policy: " -NoNewline
    Write-Host "$(Get-ExecutionPolicy)" -ForegroundColor Cyan
    Write-Host "Current execution policy scope: " -NoNewline
    Write-Host "$(Get-ExecutionPolicy -Scope CurrentUser)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1: Set to Unrestricted (least secure, allows all scripts)"
    Write-Host "2: Set to RemoteSigned (moderate security, local scripts run without signing)"
    Write-Host "3: Set to AllSigned (more secure, all scripts must be signed)"
    Write-Host "4: Set to Restricted (most secure, no scripts allowed)"
    Write-Host "5: Bypass execution policy for current session only"
    Write-Host "6: Display execution policy information"
    Write-Host "Q: Quit"
}

function Set-UserExecutionPolicy {
    param (
        [string]$Policy
    )
    try {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if ($isAdmin) {
            Set-ExecutionPolicy -ExecutionPolicy $Policy -Force
            Write-Host "Execution policy set to $Policy for all users" -ForegroundColor Green
        } else {
            Set-ExecutionPolicy -ExecutionPolicy $Policy -Scope CurrentUser -Force
            Write-Host "Execution policy set to $Policy for current user only" -ForegroundColor Yellow
            Write-Host "Note: Run as administrator to apply system-wide" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Test-PolicyWithScript {
    $testScript = "$env:TEMP\test_execution_policy.ps1"
    
    # Create a simple test script
    @"
Write-Host "Script execution successful!" -ForegroundColor Green
Write-Host "Current execution policy is: `$(Get-ExecutionPolicy)"
"@ | Out-File -FilePath $testScript
    
    Write-Host ""
    Write-Host "Testing execution policy with a sample script..." -ForegroundColor Cyan
    
    try {
        & $testScript
        Write-Host "Test completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Test failed. Policy may prevent script execution." -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Clean up
    Remove-Item -Path $testScript -Force -ErrorAction SilentlyContinue
}

function Show-PolicyInfo {
    Write-Host ""
    Write-Host "Execution Policy Information:" -ForegroundColor Cyan
    Write-Host "----------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Current policies by scope:"
    Get-ExecutionPolicy -List | Format-Table -AutoSize
    
    Write-Host ""
    Write-Host "Policy descriptions:" -ForegroundColor Yellow
    Write-Host "  Restricted: No scripts can be run. Windows PowerShell can be used only in interactive mode."
    Write-Host "  AllSigned: Only scripts signed by a trusted publisher can be run."
    Write-Host "  RemoteSigned: Downloaded scripts must be signed by a trusted publisher before they can be run."
    Write-Host "  Unrestricted: All scripts can be run. Displays a warning for scripts downloaded from the internet."
    Write-Host "  Bypass: Nothing is blocked and there are no warnings or prompts during script execution."
    Write-Host ""
    
    # Check if we're running as admin
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "Note: Running as standard user. Some policy changes require administrator rights." -ForegroundColor Yellow
    } else {
        Write-Host "Running with administrator privileges. All policy changes are available." -ForegroundColor Green
    }
}

# Main loop
do {
    Show-Menu
    Write-Host ""
    $selection = Read-Host "Please make a selection"
    
    switch ($selection) {
        '1' {
            Set-UserExecutionPolicy -Policy "Unrestricted"
            Test-PolicyWithScript
        }
        '2' {
            Set-UserExecutionPolicy -Policy "RemoteSigned"
            Test-PolicyWithScript
        }
        '3' {
            Set-UserExecutionPolicy -Policy "AllSigned"
        }
        '4' {
            Set-UserExecutionPolicy -Policy "Restricted"
        }
        '5' {
            Write-Host "This will only affect the current PowerShell session"
            Write-Host "For scripts outside this session, you'll need a permanent policy change"
            Write-Host "Bypassing execution policy for this session..." -ForegroundColor Yellow
            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
            Test-PolicyWithScript
        }
        '6' {
            Show-PolicyInfo
        }
        'q' {
            return
        }
        'Q' {
            return
        }
    }
    
    Write-Host ""
    pause
} until ($selection -eq 'q' -or $selection -eq 'Q')
EOF
            echo -e "${GREEN}PowerShell script created: change_execution_policy.ps1${NC}"
            echo -e "${YELLOW}You need to run this script with PowerShell:${NC}"
            echo -e "  ${BOLD}Right-click the script and select 'Run with PowerShell'${NC}"
            echo -e "  ${BOLD}For system-wide changes, run PowerShell as Administrator${NC}"
            ;;
        2)
            echo "Creating batch file to run PowerShell script..."
            cat > run_policy_script.bat << 'EOF'
@echo off
echo Windows PowerShell Execution Policy Manager
echo =========================================
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges.
) else (
    echo WARNING: Not running as administrator. Some options may be limited.
    echo For full functionality, right-click this batch file and select "Run as administrator"
    echo.
    pause
)

echo Creating temporary PowerShell script...
echo.

:: Detect script location
set "SCRIPT_PATH=%~dp0change_execution_policy.ps1"

:: Check if the script exists, otherwise create it
if not exist "%SCRIPT_PATH%" (
    echo PowerShell script not found, creating it now...
    
    (
        echo # PowerShell Script to Change Execution Policy
        echo # Run this as Administrator
        echo.
        echo function Show-Menu {
        echo     param (
        echo         [string]$Title = 'Windows PowerShell Execution Policy Manager'
        echo     ^)
        echo     Clear-Host
        echo     Write-Host "================ $Title ================"
        echo     Write-Host ""
        echo     Write-Host "Current execution policy: " -NoNewline
        echo     Write-Host "$(Get-ExecutionPolicy^)" -ForegroundColor Cyan
        echo     Write-Host "Current execution policy scope: " -NoNewline
        echo     Write-Host "$(Get-ExecutionPolicy -Scope CurrentUser^)" -ForegroundColor Cyan
        echo     Write-Host ""
        echo     Write-Host "1: Set to Unrestricted (least secure, allows all scripts^)"
        echo     Write-Host "2: Set to RemoteSigned (moderate security, local scripts run without signing^)"
        echo     Write-Host "3: Set to AllSigned (more secure, all scripts must be signed^)"
        echo     Write-Host "4: Set to Restricted (most secure, no scripts allowed^)"
        echo     Write-Host "5: Bypass execution policy for current session only"
        echo     Write-Host "6: Display execution policy information"
        echo     Write-Host "Q: Quit"
        echo }
        echo.
        echo function Set-UserExecutionPolicy {
        echo     param (
        echo         [string]$Policy
        echo     ^)
        echo     try {
        echo         $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent(^)^)
        echo         $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator^)
        echo         
        echo         if ($isAdmin^) {
        echo             Set-ExecutionPolicy -ExecutionPolicy $Policy -Force
        echo             Write-Host "Execution policy set to $Policy for all users" -ForegroundColor Green
        echo         } else {
        echo             Set-ExecutionPolicy -ExecutionPolicy $Policy -Scope CurrentUser -Force
        echo             Write-Host "Execution policy set to $Policy for current user only" -ForegroundColor Yellow
        echo             Write-Host "Note: Run as administrator to apply system-wide" -ForegroundColor Yellow
        echo         }
        echo     }
        echo     catch {
        echo         Write-Host "Error: $($_.Exception.Message^)" -ForegroundColor Red
        echo     }
        echo }
        echo.
        echo function Test-PolicyWithScript {
        echo     $testScript = "$env:TEMP\test_execution_policy.ps1"
        echo     
        echo     # Create a simple test script
        echo     @"
        echo Write-Host "Script execution successful!" -ForegroundColor Green
        echo Write-Host "Current execution policy is: `$(Get-ExecutionPolicy^)"
        echo "@ ^| Out-File -FilePath $testScript
        echo     
        echo     Write-Host ""
        echo     Write-Host "Testing execution policy with a sample script..." -ForegroundColor Cyan
        echo     
        echo     try {
        echo         ^& $testScript
        echo         Write-Host "Test completed successfully." -ForegroundColor Green
        echo     }
        echo     catch {
        echo         Write-Host "Test failed. Policy may prevent script execution." -ForegroundColor Red
        echo         Write-Host "Error: $($_.Exception.Message^)" -ForegroundColor Red
        echo     }
        echo     
        echo     # Clean up
        echo     Remove-Item -Path $testScript -Force -ErrorAction SilentlyContinue
        echo }
        echo.
        echo function Show-PolicyInfo {
        echo     Write-Host ""
        echo     Write-Host "Execution Policy Information:" -ForegroundColor Cyan
        echo     Write-Host "----------------------------" -ForegroundColor Cyan
        echo     Write-Host ""
        echo     
        echo     Write-Host "Current policies by scope:"
        echo     Get-ExecutionPolicy -List ^| Format-Table -AutoSize
        echo     
        echo     Write-Host ""
        echo     Write-Host "Policy descriptions:" -ForegroundColor Yellow
        echo     Write-Host "  Restricted: No scripts can be run. Windows PowerShell can be used only in interactive mode."
        echo     Write-Host "  AllSigned: Only scripts signed by a trusted publisher can be run."
        echo     Write-Host "  RemoteSigned: Downloaded scripts must be signed by a trusted publisher before they can be run."
        echo     Write-Host "  Unrestricted: All scripts can be run. Displays a warning for scripts downloaded from the internet."
        echo     Write-Host "  Bypass: Nothing is blocked and there are no warnings or prompts during script execution."
        echo     Write-Host ""
        echo     
        echo     # Check if we're running as admin
        echo     $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent(^)^)
        echo     $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator^)
        echo     
        echo     if (-not $isAdmin^) {
        echo         Write-Host "Note: Running as standard user. Some policy changes require administrator rights." -ForegroundColor Yellow
        echo     } else {
        echo         Write-Host "Running with administrator privileges. All policy changes are available." -ForegroundColor Green
        echo     }
        echo }
        echo.
        echo # Main loop
        echo do {
        echo     Show-Menu
        echo     Write-Host ""
        echo     $selection = Read-Host "Please make a selection"
        echo     
        echo     switch ($selection^) {
        echo         '1' {
        echo             Set-UserExecutionPolicy -Policy "Unrestricted"
        echo             Test-PolicyWithScript
        echo         }
        echo         '2' {
        echo             Set-UserExecutionPolicy -Policy "RemoteSigned"
        echo             Test-PolicyWithScript
        echo         }
        echo         '3' {
        echo             Set-UserExecutionPolicy -Policy "AllSigned"
        echo         }
        echo         '4' {
        echo             Set-UserExecutionPolicy -Policy "Restricted"
        echo         }
        echo         '5' {
        echo             Write-Host "This will only affect the current PowerShell session"
        echo             Write-Host "For scripts outside this session, you'll need a permanent policy change"
        echo             Write-Host "Bypassing execution policy for this session..." -ForegroundColor Yellow
        echo             Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        echo             Test-PolicyWithScript
        echo         }
        echo         '6' {
        echo             Show-PolicyInfo
        echo         }
        echo         'q' {
        echo             return
        echo         }
        echo         'Q' {
        echo             return
        echo         }
        echo     }
        echo     
        echo     Write-Host ""
        echo     pause
        echo } until ($selection -eq 'q' -or $selection -eq 'Q'^)
    ) > "%SCRIPT_PATH%"
)

echo Running PowerShell script with bypass to ensure it can execute...
PowerShell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

echo.
echo Script execution complete.
pause
EOF
            echo -e "${GREEN}Batch file created: run_policy_script.bat${NC}"
            echo -e "${YELLOW}Double-click the batch file to run it. For system-wide changes, right-click and select 'Run as administrator'${NC}"
            ;;
        q|Q)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# Main script
echo -e "${BOLD}${GREEN}Universal Execution Policy Script${NC}"
echo "------------------------------------"
echo -e "${YELLOW}This script helps manage execution policies across different operating systems.${NC}"
echo ""

OS=$(detect_os)
echo -e "Detected OS: ${BOLD}${BLUE}$OS${NC}"
echo ""

case "$OS" in
    macos)
        macos_execution
        ;;
    linux)
        linux_execution
        ;;
    windows)
        windows_execution
        ;;
    *)
        echo -e "${RED}Unsupported operating system. Please run this on macOS, Linux, or Windows.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Execution policy management completed.${NC}"
