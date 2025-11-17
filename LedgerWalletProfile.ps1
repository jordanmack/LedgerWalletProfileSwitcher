<#
Switch the Ledger Wallet data folder (junction) between profiles.
Profiles are folders like:
  %APPDATA%\Ledger Wallet Profile 1
  %APPDATA%\Ledger Wallet Profile 2
The junction at %APPDATA%\Ledger Wallet points directly to the chosen profile.
#>

# ========= SETTINGS (edit if needed) =========
$BasePath     = Join-Path $env:APPDATA 'Ledger Wallet'                 			# Junction path Ledger Wallet uses
$ProfilesBase = $env:APPDATA                                          			# Where "Ledger Wallet Profile *" folders live
$LedgerExe    = 'C:\Program Files\Ledger Live\Ledger Wallet\Ledger Wallet.exe'  # Ledger Wallet executable
$LaunchTimeoutSec = 30                                                			# How long to wait for Ledger Wallet to appear
# ============================================

# Suppress confirmation prompts
$ConfirmPreference = 'None'

Write-Host '=== LedgerWalletProfile.ps1 ===' -ForegroundColor Cyan
Write-Host ''

# Verify Ledger Wallet executable
if (-not (Test-Path -LiteralPath $LedgerExe)) {
    Write-Host "Error: Ledger Wallet not found at '$LedgerExe'." -ForegroundColor Red
    exit 1
}

# Show current junction target (if any)
if (Test-Path -LiteralPath $BasePath) {
    try {
        $cur = Get-Item -LiteralPath $BasePath -ErrorAction Stop
        if ($cur.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host ("Current target: {0}" -f ($cur.Target)) -ForegroundColor Yellow
        } else {
            Write-Host "Current path is a real folder (not a junction)." -ForegroundColor Yellow
        }
    } catch {}
}

# Find profile folders
$profiles = Get-ChildItem -Path $ProfilesBase -Directory |
    Where-Object { $_.Name -like 'Ledger Wallet Profile*' } |
    Sort-Object Name

if (-not $profiles -or $profiles.Count -eq 0) {
    Write-Host "No profile folders found under: $ProfilesBase" -ForegroundColor Yellow
    Write-Host "Create folders like:"
    Write-Host "  $ProfilesBase\Ledger Wallet Profile 1"
    Write-Host "  $ProfilesBase\Ledger Wallet Profile 2"
    exit 1
}

Write-Host 'Available profiles:'; Write-Host ''
for ($i = 0; $i -lt $profiles.Count; $i++) {
    Write-Host ("[{0}] {1}" -f ($i + 1), $profiles[$i].Name)
}

Write-Host ''
$choice = Read-Host 'Enter the number of the profile to activate'
if (-not ($choice -as [int])) { Write-Host 'Invalid selection.' -ForegroundColor Red; exit 1 }
$idx = [int]$choice
if ($idx -lt 1 -or $idx -gt $profiles.Count) { Write-Host 'Out of range.' -ForegroundColor Red; exit 1 }

$selectedProfile   = $profiles[$idx - 1]
$targetProfilePath = $selectedProfile.FullName  # point directly to profile root

Write-Host ''
Write-Host "Selected: $($selectedProfile.Name)"
Write-Host "New target: $targetProfilePath"
Write-Host ''

# Check if already pointing to this profile
$needsSwitch = $true
if (Test-Path -LiteralPath $BasePath) {
    try {
        $curItem = Get-Item -LiteralPath $BasePath -ErrorAction Stop
        if ($curItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $curTarget = $curItem.Target
            if ($curTarget) {
                $resolvedCur = (Resolve-Path -LiteralPath $curTarget).Path
                $resolvedNew = (Resolve-Path -LiteralPath $targetProfilePath).Path
                if ($resolvedCur -eq $resolvedNew) {
                    Write-Host "Already pointing to: $resolvedNew" -ForegroundColor Green
                    $needsSwitch = $false
                }
            }
        }
    } catch {}
}

# Stop any running Ledger Wallet instances and wait for them to close
$runningProcesses = Get-Process -Name 'Ledger Wallet' -ErrorAction SilentlyContinue
if ($runningProcesses) {
    Write-Host "Stopping running Ledger Wallet instances..." -ForegroundColor Yellow
    $runningProcesses | Stop-Process -Force -ErrorAction SilentlyContinue

    # Wait for processes to close (with timeout)
    $stopDeadline = (Get-Date).AddSeconds(10)
    while ((Get-Process -Name 'Ledger Wallet' -ErrorAction SilentlyContinue) -and ((Get-Date) -lt $stopDeadline)) {
        Start-Sleep -Milliseconds 200
    }
}

# Switch junction if needed
if ($needsSwitch) {
    # Replace existing junction/folder at $BasePath
    if (Test-Path -LiteralPath $BasePath) {
        $item = Get-Item -LiteralPath $BasePath -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            # Remove junction silently (no confirmation)
            Remove-Item -LiteralPath $BasePath -Force -Recurse -ErrorAction SilentlyContinue
        } else {
            # Real folder -> back it up (timestamped)
            $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
            $backup = "$BasePath-backup-$stamp"
            Rename-Item -LiteralPath $BasePath -NewName $backup
            Write-Host "Existing real folder renamed to: $backup" -ForegroundColor Yellow
        }
    }

    # Create new junction pointing directly to the selected profile
    New-Item -ItemType Junction -Path $BasePath -Target $targetProfilePath | Out-Null

    # Validate junction creation
    if (-not (Test-Path -LiteralPath $BasePath)) {
        Write-Host "Error: Failed to create junction at '$BasePath'." -ForegroundColor Red
        exit 1
    }

    $newItem = Get-Item -LiteralPath $BasePath -ErrorAction SilentlyContinue
    if (-not $newItem -or -not ($newItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        Write-Host "Error: Junction creation failed." -ForegroundColor Red
        exit 1
    }

    Write-Host 'Junction updated successfully.' -ForegroundColor Green

    # Show final target
    try {
        $final = (Get-Item -LiteralPath $BasePath).Target
        if ($final) { Write-Host "Now pointing to: $final" -ForegroundColor Green }
    } catch {}
}

# Launch Ledger Wallet and close when it exits
Write-Host ''
Write-Host 'Launching Ledger Wallet...'
Start-Process -FilePath $LedgerExe | Out-Null

# Wait until the process appears (handles slow starts), then wait for it to exit
$deadline = (Get-Date).AddSeconds($LaunchTimeoutSec)
do {
    $proc = Get-Process -Name 'Ledger Wallet' -ErrorAction SilentlyContinue
    if ($proc) { break }
    Start-Sleep -Milliseconds 200
} while ((Get-Date) -lt $deadline)

if ($proc) {
    while (Get-Process -Name 'Ledger Wallet' -ErrorAction SilentlyContinue) {
        Start-Sleep 1
    }
}

exit 0
