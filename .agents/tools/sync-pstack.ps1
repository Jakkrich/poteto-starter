param(
  [switch]$Reinstall,
  [switch]$NoPause
)

$ErrorActionPreference = 'Stop'

$AgentsDir = Split-Path -Parent $PSScriptRoot
$PluginsDir = Join-Path $AgentsDir 'plugins'
$PstackDir = Join-Path $PluginsDir 'pstack'
$CacheDir = Join-Path $AgentsDir '.cache\pstack-claude'
$RepoUrl = 'https://github.com/michael-denyer/pstack-claude.git'
$Branch = 'main'

function Remove-TreeForce {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return }
  Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
      $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
    }
  }
  Remove-Item -LiteralPath $Path -Recurse -Force
}

function Get-PstackVersion {
  param([string]$Dir, [string]$Cache)
  foreach ($pj in @(
    (Join-Path $Dir 'plugin.json'),
    (Join-Path $Dir '.antigravity-plugin\plugin.json'),
    (Join-Path $Dir '.claude-plugin\plugin.json')
  )) {
    if (Test-Path -LiteralPath $pj) {
      try {
        $v = (Get-Content -LiteralPath $pj -Raw | ConvertFrom-Json).version
        if ($v) { return $v }
      }
      catch {}
    }
  }
  $verFile = Join-Path $Cache 'VERSION'
  if (Test-Path -LiteralPath $verFile) {
    return (Get-Content -LiteralPath $verFile -Raw).Trim()
  }
  return 'unknown'
}

New-Item -ItemType Directory -Force -Path $PluginsDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $CacheDir) | Out-Null

# Clean up legacy cursor/plugins sparse-checkout metadata if present
$LegacyGitDir = Join-Path $PluginsDir '.git'
if (Test-Path -LiteralPath $LegacyGitDir) {
  Remove-TreeForce -Path $LegacyGitDir
}

if (-not $Reinstall -and (Test-Path -LiteralPath (Join-Path $CacheDir '.git'))) {
  Write-Host "Updating pstack-claude cache in $CacheDir ..."
  git -C $CacheDir pull --ff-only origin $Branch
  if ($LASTEXITCODE -ne 0) {
    throw "git pull failed with exit code $LASTEXITCODE (pass -Reinstall for a clean clone)"
  }
}
else {
  Remove-TreeForce -Path $CacheDir
  Write-Host "Cloning pstack-claude (sparse checkout) from $RepoUrl ($Branch) ..."
  git clone --depth 1 --branch $Branch --filter=blob:none --no-checkout $RepoUrl $CacheDir
  if ($LASTEXITCODE -ne 0) {
    throw "git clone failed with exit code $LASTEXITCODE"
  }

  Push-Location $CacheDir
  try {
    git sparse-checkout init --cone
    if ($LASTEXITCODE -ne 0) { throw "git sparse-checkout init failed with exit code $LASTEXITCODE" }
    git sparse-checkout set plugins/pstack VERSION
    if ($LASTEXITCODE -ne 0) { throw "git sparse-checkout set failed with exit code $LASTEXITCODE" }
    git checkout $Branch
    if ($LASTEXITCODE -ne 0) { throw "git checkout $Branch failed with exit code $LASTEXITCODE" }
  }
  finally {
    Pop-Location
  }
}

$SourcePstack = Join-Path $CacheDir 'plugins\pstack'
if (-not (Test-Path -LiteralPath (Join-Path $SourcePstack 'skills\poteto-mode\SKILL.md'))) {
  throw "Expected plugins/pstack/skills/poteto-mode/SKILL.md not found in $CacheDir"
}

Remove-TreeForce -Path $PstackDir
Copy-Item -LiteralPath $SourcePstack -Destination $PstackDir -Recurse -Force

# Ensure Antigravity workspace plugin manifest exists at root of .agents/plugins/pstack/
$AgyManifest = Join-Path $PstackDir '.antigravity-plugin\plugin.json'
$RootManifest = Join-Path $PstackDir 'plugin.json'
if ((Test-Path -LiteralPath $AgyManifest) -and -not (Test-Path -LiteralPath $RootManifest)) {
  Copy-Item -LiteralPath $AgyManifest -Destination $RootManifest -Force
}

# Remove SessionStart / PreToolUse hook manifests inside the mirrored tree so Windows hosts
# do not attempt to execute ./hooks/session-start.sh or duplicate Chief of Staff routing.
foreach ($hookFile in @(
  'hooks.json',
  'hooks\hooks.json',
  'hooks\codex-hooks.json',
  'hooks\copilot-hooks.json'
)) {
  $hp = Join-Path $PstackDir $hookFile
  if (Test-Path -LiteralPath $hp) {
    Remove-Item -LiteralPath $hp -Force
  }
}

$ver = Get-PstackVersion -Dir $PstackDir -Cache $CacheDir
$sha = (git -C $CacheDir rev-parse --short HEAD).Trim()
Write-Host "[OK] pstack-claude (version $ver, commit $sha) ready at $PstackDir" -ForegroundColor Green
