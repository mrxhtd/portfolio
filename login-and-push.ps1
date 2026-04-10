# Run in PowerShell:  cd to this folder, then:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force   # once, if blocked
#   .\login-and-push.ps1
#
# Completes GitHub login in the browser/device flow, creates the repo if needed, and pushes main.

$ErrorActionPreference = "Stop"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "=== GitHub CLI login ===" -ForegroundColor Cyan
Write-Host "If a code and URL appear, open the URL in your browser and paste the code."
Write-Host ""
gh auth login -h github.com -p https -w

gh auth status
if ($LASTEXITCODE -ne 0) {
  Write-Host "Login failed or was cancelled." -ForegroundColor Red
  exit 1
}

$repo = "portfolio"
$user = (gh api user --jq .login)
if (-not $user) {
  Write-Host "Could not read GitHub username." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "Logged in as: $user" -ForegroundColor Green
Write-Host "Creating repo '$repo' (if it does not exist) and pushing..." -ForegroundColor Cyan

# Drop broken origin so gh can create + attach a working remote
if (git remote get-url origin 2>$null) {
  git remote remove origin
}

gh repo create $repo --public --source=. --remote=origin --push

Write-Host ""
Write-Host "Done. Repo: https://github.com/$user/$repo" -ForegroundColor Green
