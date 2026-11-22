param(
  [switch]$Reinstall,
  [switch]$NoPause
)

$ErrorActionPreference = 'Stop'

$AgentsDir = Split-Path -Parent $PSScriptRoot
$PluginsDir = Join-Path $AgentsDir 'plugins'
$PstackDir = Join-Path $PluginsDir 'pstack'
$RepoUrl = 'https://github.com/cursor/plugins.git'

function Get-PstackVersion {
  param([string]$Dir)
  $pj = Join-Path $Dir 'plugin.json'
  if (-not (Test-Path $pj)) { return 'unknown' }
  try {
    return ((Get-Content $pj -Raw | ConvertFrom-Json).version)
  }
  catch {
    return 'unknown'
  }
}

New-Item -ItemType Directory -Force -Path $PluginsDir | Out-Null

$GitDir = Join-Path $PluginsDir '.git'

if (-not $Reinstall -and (Test-Path $GitDir)) {
  Write-Host "Updating pstack in $PluginsDir ..."
  git -C $PluginsDir pull --ff-only origin main
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] git pull failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
  }
  $ver = Get-PstackVersion -Dir $PstackDir
  Write-Host "[OK] pstack is ready (version $ver) at $PstackDir" -ForegroundColor Green
  exit 0
}

$TmpDir = Join-Path $PluginsDir 'pstack-only'
if (Test-Path $TmpDir) {
  Remove-Item -Recurse -Force $TmpDir
}

Write-Host "Cloning pstack (sparse checkout) from $RepoUrl ..."
git clone --filter=blob:none --no-checkout $RepoUrl $TmpDir
if ($LASTEXITCODE -ne 0) {
  Write-Host "[ERROR] git clone failed with exit code $LASTEXITCODE" -ForegroundColor Red
  exit $LASTEXITCODE
}

Push-Location $TmpDir
try {
  git sparse-checkout init --cone
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  git sparse-checkout set pstack
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  git checkout main
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
  Pop-Location
}

if ($Reinstall -and (Test-Path $GitDir)) {
  Remove-Item -Recurse -Force $GitDir
}
if (Test-Path $PstackDir) {
  Remove-Item -Recurse -Force $PstackDir
}

foreach ($item in Get-ChildItem $TmpDir -Force) {
  $dest = Join-Path $PluginsDir $item.Name
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  Move-Item -Force $item.FullName $dest
}

Remove-Item -Recurse -Force $TmpDir

$ver = Get-PstackVersion -Dir $PstackDir
Write-Host "[OK] Installed pstack (version $ver) into $PstackDir" -ForegroundColor Green
