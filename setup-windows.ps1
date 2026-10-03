# OpenMontage one-click setup for Windows
# Run in PowerShell:
#   Set-ExecutionPolicy -Scope Process Bypass -Force; .\setup-windows.ps1

$ErrorActionPreference = "Stop"

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User")
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Red
    exit 1
}

Write-Host "==> Installing prerequisites (Python, FFmpeg, Node.js, Git)..." -ForegroundColor Cyan
$packages = @("Python.Python.3.12", "Gyan.FFmpeg", "OpenJS.NodeJS.LTS", "Git.Git")
foreach ($p in $packages) {
    winget install --id $p -e --accept-source-agreements --accept-package-agreements --silent
}
Refresh-Path

Write-Host "==> Installing Claude Code..." -ForegroundColor Cyan
irm https://claude.ai/install.ps1 | iex
Refresh-Path

Write-Host "==> Cloning OpenMontage..." -ForegroundColor Cyan
$target = Join-Path $HOME "OpenMontage"
if (-not (Test-Path $target)) {
    git clone https://github.com/calesthio/OpenMontage.git $target
}
Set-Location $target

Write-Host "==> Creating Python virtual environment..." -ForegroundColor Cyan
if (-not (Test-Path ".venv")) { py -3 -m venv .venv }
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

Write-Host "==> Installing Remotion composer..." -ForegroundColor Cyan
Set-Location remotion-composer
try { npm install } catch { npx --yes npm install }
Set-Location ..

Write-Host "==> Installing Piper offline TTS..." -ForegroundColor Cyan
try { python -m pip install piper-tts } catch { Write-Host "  [skip] piper-tts failed; cloud TTS will be used" }

if (-not (Test-Path ".env")) { Copy-Item .env.example .env }

Write-Host ""
Write-Host "Done! OpenMontage is at $target" -ForegroundColor Green
Write-Host "Next:"
Write-Host "  cd $target"
Write-Host "  .\.venv\Scripts\Activate.ps1"
Write-Host "  claude        # then ask: Make a 60-second animated explainer about ..."
