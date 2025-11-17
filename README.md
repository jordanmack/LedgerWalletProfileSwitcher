# Ledger Wallet Profile Switcher

A PowerShell script for Windows that manages multiple isolated Ledger Wallet profiles on a single computer.

![Profile selection screen](screenshot-1.png)

Uses NTFS junctions to switch the Ledger Wallet data folder (`%APPDATA%\Ledger Wallet`) between profile directories:

```
%APPDATA%\Ledger Wallet Profile 1
%APPDATA%\Ledger Wallet Profile 2
%APPDATA%\Ledger Wallet Profile 3
```

Keeps accounts from different hardware wallets or users separate.

---

## Why use this

Ledger Wallet does not support multiple user profiles. By default, every connected device shares the same portfolio view and account data.

This script lets you:
- Maintain separate data sets for multiple hardware wallets or users.
- Prevent mixing accounts and balances across devices.
- Switch profiles without reinstalling or clearing app data.

---

## Requirements

- Windows 10 or 11
- PowerShell 5.1+
- Ledger Wallet installed at `C:\Program Files\Ledger Live\Ledger Wallet\Ledger Wallet.exe`

---

## Installation and Setup

1. **Download the script**
   Save `LedgerWalletProfile.ps1`:
   ```
   C:\Users\<YourName>\Documents\LedgerWalletProfile.ps1
   ```

2. **Create profile folders**
   In `%APPDATA%` (`C:\Users\<You>\AppData\Roaming`), create:

   ```
   Ledger Wallet Profile 1
   Ledger Wallet Profile 2
   Ledger Wallet Profile 3
   ```

3. **(Optional) Migrate existing installation**
   - Close Ledger Wallet.
   - Navigate to `C:\Users\<You>\AppData\Roaming\`.
   - Rename `Ledger Wallet` to `Ledger Wallet Profile 1`.
   - Run the script and select Profile 1.

4. **First-time PowerShell setup**
   Windows may block scripts by default:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

---

## Usage

### Launch via PowerShell
Run:
```powershell
& "C:\Users\<YourName>\Documents\LedgerWalletProfile.ps1"
```

You'll see a list of profiles like:

```
Available profiles:

[1] Ledger Wallet Profile 1
[2] Ledger Wallet Profile 2
[3] Ledger Wallet Profile 3
```

The script will:
1. Stop running Ledger Wallet instances.
2. Switch the junction to the chosen profile.
3. Launch Ledger Wallet.
4. Wait until closed and exit.

---

## Creating a Windows Shortcut

1. Right-click Desktop → **New → Shortcut**.
2. Enter:
   ```
   powershell.exe -ExecutionPolicy Bypass -File "C:\Users\<YourName>\Documents\LedgerWalletProfile.ps1"
   ```
3. Click **Next**, name it `Ledger Wallet Profile Switcher`.
4. Click **Finish**.

For Start Menu: Press **Win + R**, type `shell:programs`, press Enter, and move the shortcut there.

---

## How it works

Ledger Wallet stores user data in `%APPDATA%\Ledger Wallet`.

This script replaces that folder with a junction (symbolic link) pointing to the selected profile.

When you choose a profile:
- Running instances are stopped.
- The junction switches to that profile folder.
- Ledger Wallet launches using that profile's data.
- The script exits when Ledger Wallet closes.

---

## Troubleshooting

| Issue | Solution |
|--------|-----------|
| **Script won't run** | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| **"Repair" or "Fresh install" message** | Empty profile selected. Switch back to your main profile. |
| **Existing folder blocks switching** | Script automatically backs up real folders with timestamps. |
| **Window stays open after exit** | Remove `-NoExit` from shortcut. |
| **Missing profiles** | Only folders matching `Ledger Wallet Profile*` are listed. |
| **Security warning** | PowerShell warns about unsigned scripts. Safe to ignore if you reviewed the code. |

---

## Notes

- Each profile has its own wallets, accounts, and settings.
- The script only modifies the junction, never profile contents.
- Running instances are stopped automatically before switching.
- Junction creation does not require administrator rights.
- Confirm active profile:
  ```powershell
  (Get-Item "$env:APPDATA\Ledger Wallet").Target
  ```

---

## Example Folder Structure

```
C:\Users\<You>\AppData\Roaming\
├─ Ledger Wallet               → Junction → Ledger Wallet Profile 1
├─ Ledger Wallet Profile 1\
├─ Ledger Wallet Profile 2\
├─ Ledger Wallet Profile 3\
```

---

## Uninstalling

1. Close Ledger Wallet.
2. Delete the junction:
   ```powershell
   Remove-Item "$env:APPDATA\Ledger Wallet" -Force
   ```
3. Rename your preferred profile folder to `Ledger Wallet`.

---

## License

MIT
