# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ledger Wallet Profile Switcher is a PowerShell script for Windows that manages multiple isolated Ledger Wallet profiles using NTFS junctions. It switches the `%APPDATA%\Ledger Wallet` folder between profile directories to maintain separate data sets for multiple hardware wallets or users.

## Repository Structure

- **LedgerWalletProfile.ps1**: Main PowerShell script that handles profile switching and Ledger Wallet launching.
- **README.md**: User-facing documentation with installation, usage, and troubleshooting information.
- **screenshot-1.png**: Screenshot of the profile selection interface used in README.
- **LICENSE**: MIT license.
- **.gitignore**: Excludes OS and editor temporary files.

## Architecture

The script operates by:
1. Creating/managing NTFS junctions at `%APPDATA%\Ledger Wallet` that point to profile folders.
2. Presenting an interactive menu to select profiles.
3. Stopping any running Ledger Wallet instances before switching profiles.
4. Backing up existing real folders with timestamps before replacing with junctions.
5. Validating junction creation before proceeding.
6. Launching Ledger Wallet and waiting for it to exit before terminating.

## Key Components

### LedgerWalletProfile.ps1

Single-file PowerShell script with these sections:
- **Settings block**: Configurable paths and timeout settings.
- **Executable validation**: Verifies Ledger Wallet executable exists.
- **Junction detection**: Checks if current path is a junction and displays target.
- **Profile discovery**: Finds folders matching `Ledger Wallet Profile*` pattern.
- **User selection**: Interactive menu with input validation.
- **Switch detection**: Determines if junction switch is needed.
- **Process cleanup**: Stops running instances with 10-second timeout.
- **Junction switching**: Conditionally removes old junction, backs up real folders with timestamps, creates and validates new junction.
- **Process launch**: Launches Ledger Wallet with 30-second startup timeout and monitors until exit.

## Testing

To test the script manually:
```powershell
powershell.exe -ExecutionPolicy Bypass -File "LedgerWalletProfile.ps1"
```

The script requires:
- Windows 10 or 11.
- PowerShell 5.1+.
- Ledger Wallet installed at `C:\Program Files\Ledger Live\Ledger Wallet\Ledger Wallet.exe`.
- Profile folders created in `%APPDATA%` with naming pattern `Ledger Wallet Profile*`.

## Important Behaviors

- The script uses `-ConfirmPreference = 'None'` to suppress confirmation prompts.
- Running Ledger Wallet instances are stopped before switching profiles (10-second timeout).
- Real folders at the junction path are backed up with timestamps rather than deleted.
- Junction creation is validated before launching the application.
- The script manages exactly one Ledger Wallet instance from launch to termination.
- The script terminates when Ledger Wallet closes.
- Junction creation does not require administrator rights.
