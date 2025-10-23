# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ledger Live Profile Switcher is a PowerShell script for Windows that manages multiple isolated Ledger Live profiles using NTFS junctions. It switches the `%APPDATA%\Ledger Live` folder between profile directories to maintain separate data sets for multiple hardware wallets or users.

## Repository Structure

- **LedgerLiveProfile.ps1**: Main PowerShell script that handles profile switching and Ledger Live launching.
- **README.md**: User-facing documentation with installation, usage, and troubleshooting information.
- **screenshot-1.png**: Screenshot of the profile selection interface used in README.
- **LICENSE**: MIT license.
- **.gitignore**: Excludes OS and editor temporary files.

## Architecture

The script operates by:
1. Creating/managing NTFS junctions at `%APPDATA%\Ledger Live` that point to profile folders like `%APPDATA%\Ledger Live Profile 1`, `%APPDATA%\Ledger Live Profile 2`, etc.
2. Presenting an interactive menu to select profiles.
3. Handling existing real folders by backing them up with timestamps before replacing with junctions.
4. Launching Ledger Live and waiting for it to exit before terminating.

## Key Components

### LedgerLiveProfile.ps1

Single-file PowerShell script with these sections:
- **Settings block (lines 9-14)**: Configurable paths and timeout settings.
- **Junction detection (lines 29-38)**: Checks if current path is a junction and displays target.
- **Profile discovery (lines 41-51)**: Finds folders matching `Ledger Live Profile*` pattern.
- **Junction switching (lines 108-124)**: Removes old junction, backs up real folders, creates new junction.
- **Process management (lines 86-93, 137-149)**: Waits for Ledger Live process to start and monitors until exit.

## Testing

To test the script manually:
```powershell
powershell.exe -ExecutionPolicy Bypass -File "LedgerLiveProfile.ps1"
```

The script requires:
- Windows 10 or 11.
- PowerShell 5.1+.
- Ledger Live installed at `C:\Program Files\Ledger Live\Ledger Live.exe`.
- Profile folders created in `%APPDATA%` with naming pattern `Ledger Live Profile*`.

## Important Behaviors

- The script uses `-ConfirmPreference = 'None'` to suppress confirmation prompts.
- Real folders at the junction path are automatically backed up with timestamp suffixes rather than deleted.
- The script terminates automatically when Ledger Live closes.
- Junction creation does not require administrator rights on modern Windows.
