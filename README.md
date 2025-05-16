# Universal Execution Policy Manager

A cross-platform script to manage file execution permissions across macOS, Windows, and Linux systems.

## Overview

This utility provides an interactive way to:
- Make files executable
- Modify system security policies
- Change PowerShell execution policies
- Manage file permissions and ownership

The script automatically detects your operating system and provides the appropriate options for your platform.

## Download

Download the script from this repository:

```bash
# Using curl
curl -O https://your-repository-url/change_execution_policy.sh

# Using wget
wget https://your-repository-url/change_execution_policy.sh
```

## Installation

### macOS and Linux

1. Save the script as `change_execution_policy.sh`
2. Make it executable:
   ```bash
   chmod +x change_execution_policy.sh
   ```
3. Run the script:
   ```bash
   ./change_execution_policy.sh
   ```

### Windows

1. Save the script as `change_execution_policy.sh`
2. If you have Git Bash, WSL, or another Unix-like shell installed, you can run it like on Linux
3. Otherwise, you can run it with PowerShell:
   ```powershell
   bash ./change_execution_policy.sh
   ```
4. The script will create two Windows-specific files:
   - `change_execution_policy.ps1` (PowerShell script)
   - `run_policy_script.bat` (Batch file launcher)
5. Double-click the `run_policy_script.bat` file to run the Windows version

## Features by Operating System

### macOS Features
- Make individual files executable
- Allow applications from unidentified developers (via Gatekeeper settings)
- Reset Gatekeeper to default security settings
- Display current security settings for files and applications

### Linux Features
- Make files executable with custom permission levels (owner, group, everyone)
- Display detailed file permissions
- Change ownership of files
- Batch process directories to make multiple files executable

### Windows Features
- Set PowerShell execution policy:
  - Unrestricted: Allow all scripts to run
  - RemoteSigned: Allow local scripts, require signing for downloaded scripts
  - AllSigned: Require digital signatures on all scripts
  - Restricted: No scripts allowed
- Apply policies system-wide (administrator) or per-user
- Bypass execution policy for current session
- Test execution policy with a sample script
- Display detailed information about current policies

## Security Considerations

- **Unrestricted settings**: Be cautious when allowing unrestricted execution of files or scripts, as this can pose security risks
- **Administrator privileges**: Some operations require administrator/sudo privileges
- **Temporary policy changes**: Consider reverting to more secure settings after completing your task
- **macOS Gatekeeper**: Disabling Gatekeeper removes a security layer - only do this temporarily

## Troubleshooting

### Common Issues on macOS
- "Operation not permitted": You need to run with `sudo` for some operations
- Gatekeeper changes require a password and may reset after a system update

### Common Issues on Linux
- Permission denied: Run with `sudo` when changing system files
- Cannot find file: Make sure the path is correct and absolute paths may work better

### Common Issues on Windows
- "Cannot run scripts": The script creates a workaround with a .bat file
- Access denied: Right-click and "Run as administrator" for system-wide changes
- Policy doesn't persist: Make sure you're running as administrator

## Limitations

- The Windows portion requires PowerShell 3.0 or later
- Some macOS features require administrator permissions
- Script detection relies on standard Unix/Windows commands

## Security Warning

⚠️ **IMPORTANT**: Modifying execution policies can expose your system to security risks. Only use these settings when needed, and consider reverting to more secure settings when finished.

## License

This script is provided under the MIT License. See LICENSE for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
