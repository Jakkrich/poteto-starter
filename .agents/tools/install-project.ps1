param(
  [string]$TargetDir = '',
  [string]$SourceRepo = '',
  [string]$Branch = 'main',
  [switch]$Upgrade,
  [switch]$SkipPstackSync,
  [switch]$NoPause
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$DefaultSourceRepo = 'https://github.com/Jakkrich/poteto-starter.git'

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

function Write-Utf8File {
  param([string]$Path, [string]$Content)
  $parent = Split-Path -Parent $Path
  if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }
  [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Copy-ManagedDirectory {
  param([string]$Source, [string]$Dest)
  if (-not (Test-Path -LiteralPath $Source)) { return }
  Remove-TreeForce -Path $Dest
  $destParent = Split-Path -Parent $Dest
  if ($destParent) { New-Item -ItemType Directory -Force -Path $destParent | Out-Null }
  Copy-Item -LiteralPath $Source -Destination $Dest -Recurse -Force
}

function Copy-ManagedFile {
  param([string]$Source, [string]$Dest)
  if (-not (Test-Path -LiteralPath $Source)) { return }
  $destParent = Split-Path -Parent $Dest
  if ($destParent) { New-Item -ItemType Directory -Force -Path $destParent | Out-Null }
  Copy-Item -LiteralPath $Source -Destination $Dest -Force
}

function Assert-SafeTargetDir {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw 'TargetDir must not be empty.'
  }
  $full = [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
  $homeFull = [System.IO.Path]::GetFullPath($HOME).TrimEnd('\', '/')
  $rootFull = [System.IO.Path]::GetPathRoot($full).TrimEnd('\', '/')
  if ($full -ieq $homeFull -or $full -ieq $rootFull) {
    throw "Refusing unsafe TargetDir: $full (on-project installs only; never install into HOME or filesystem root)."
  }
  return $full
}

$StarterRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent (Split-Path -Parent $PSScriptRoot))).TrimEnd('\', '/')

if ($Upgrade -and [string]::IsNullOrWhiteSpace($TargetDir)) {
  $TargetDir = $StarterRoot
}
if ([string]::IsNullOrWhiteSpace($TargetDir)) {
  $TargetDir = (Get-Location).Path
}
if (-not (Test-Path -LiteralPath $TargetDir)) {
  New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}
$TargetFull = Assert-SafeTargetDir -Path $TargetDir

$ManifestPath = Join-Path $TargetFull '.agents\starter-kit.json'
if (-not $PSBoundParameters.ContainsKey('SourceRepo') -or [string]::IsNullOrWhiteSpace($SourceRepo)) {
  if (Test-Path -LiteralPath $ManifestPath) {
    try {
      $existingManifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
      if ($existingManifest.sourceRepo) { $SourceRepo = [string]$existingManifest.sourceRepo }
      if (-not $PSBoundParameters.ContainsKey('Branch') -and $existingManifest.branch) {
        $Branch = [string]$existingManifest.branch
      }
    }
    catch {}
  }
  if ([string]::IsNullOrWhiteSpace($SourceRepo)) {
    $SourceRepo = $DefaultSourceRepo
  }
}

# Self-upgrade delegation: fetch upstream source into temp dir and execute its installer
if ($Upgrade) {
  if (Test-Path -LiteralPath $SourceRepo -PathType Container) {
    $SourceFull = [System.IO.Path]::GetFullPath($SourceRepo).TrimEnd('\', '/')
    if ($SourceFull -ieq $TargetFull) {
      throw "Upgrade sourceRepo ($SourceFull) is identical to TargetDir ($TargetFull)."
    }
    $localInstaller = Join-Path $SourceFull '.agents\tools\install-project.ps1'
    if (-not (Test-Path -LiteralPath $localInstaller)) {
      throw "Installer not found at $localInstaller"
    }
    & $localInstaller -TargetDir $TargetFull -SourceRepo $SourceFull -Branch $Branch -SkipPstackSync:$SkipPstackSync -NoPause
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    exit 0
  }

  $TmpClone = Join-Path ([System.IO.Path]::GetTempPath()) ('starter-kit-upgrade-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
  try {
    Write-Host "Fetching latest agent-starter-kit from $SourceRepo ($Branch) ..."
    git clone --depth 1 --branch $Branch $SourceRepo $TmpClone
    if ($LASTEXITCODE -ne 0) {
      throw "git clone failed with exit code $LASTEXITCODE"
    }
    $remoteInstaller = Join-Path $TmpClone '.agents\tools\install-project.ps1'
    if (-not (Test-Path -LiteralPath $remoteInstaller)) {
      throw "Installer not found in cloned repo at $remoteInstaller"
    }
    & $remoteInstaller -TargetDir $TargetFull -SourceRepo $SourceRepo -Branch $Branch -SkipPstackSync:$SkipPstackSync -NoPause
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    exit 0
  }
  finally {
    Remove-TreeForce -Path $TmpClone
  }
}

$IsSelfTarget = ($TargetFull -ieq $StarterRoot)
$ProjectName = Split-Path -Leaf $TargetFull

if (-not $IsSelfTarget) {
  Write-Host "Installing/updating starter-kit files into $TargetFull ..."

  # 1. Managed starter-kit files (safe to overwrite on upgrade)
  Copy-ManagedFile -Source (Join-Path $StarterRoot '.agents\.gitignore') -Dest (Join-Path $TargetFull '.agents\.gitignore')
  Copy-ManagedFile -Source (Join-Path $StarterRoot '.agents\rules\chief-of-staff.md') -Dest (Join-Path $TargetFull '.agents\rules\chief-of-staff.md')
  Copy-ManagedFile -Source (Join-Path $StarterRoot '.agents\rules\pstack-antigravity.md') -Dest (Join-Path $TargetFull '.agents\rules\pstack-antigravity.md')

  Copy-ManagedDirectory -Source (Join-Path $StarterRoot '.agents\skills\chief-of-staff') -Dest (Join-Path $TargetFull '.agents\skills\chief-of-staff')
  Copy-ManagedDirectory -Source (Join-Path $StarterRoot '.agents\skills\make-bot-ui') -Dest (Join-Path $TargetFull '.agents\skills\make-bot-ui')
  Copy-ManagedDirectory -Source (Join-Path $StarterRoot '.agents\docs\pstack-guide-th') -Dest (Join-Path $TargetFull '.agents\docs\pstack-guide-th')
  Copy-ManagedDirectory -Source (Join-Path $StarterRoot '.agents\tools') -Dest (Join-Path $TargetFull '.agents\tools')

  # 2. Legacy .cursor cleanup (remove old chief-of-staff.mdc and empty .cursor dirs)
  $LegacyMdc = Join-Path $TargetFull '.cursor\rules\chief-of-staff.mdc'
  if (Test-Path -LiteralPath $LegacyMdc) {
    Remove-Item -LiteralPath $LegacyMdc -Force
    Write-Host 'Removed legacy .cursor/rules/chief-of-staff.mdc'
  }
  $LegacyRulesDir = Join-Path $TargetFull '.cursor\rules'
  if ((Test-Path -LiteralPath $LegacyRulesDir) -and ((Get-ChildItem -LiteralPath $LegacyRulesDir -Force | Measure-Object).Count -eq 0)) {
    Remove-Item -LiteralPath $LegacyRulesDir -Force
  }
  $LegacyCursorDir = Join-Path $TargetFull '.cursor'
  if ((Test-Path -LiteralPath $LegacyCursorDir) -and ((Get-ChildItem -LiteralPath $LegacyCursorDir -Force | Measure-Object).Count -eq 0)) {
    Remove-Item -LiteralPath $LegacyCursorDir -Force
    Write-Host 'Removed empty legacy .cursor directory'
  }

  # 3. Seed-once project-owned files (create ONLY if missing; never overwrite on upgrade)
  $TargetHandoff = Join-Path $TargetFull 'AI_HANDOFF.md'
  if (-not (Test-Path -LiteralPath $TargetHandoff)) {
    $tmplHandoff = Join-Path $StarterRoot '.agents\skills\chief-of-staff\templates\AI_HANDOFF.md'
    $rawHandoff = [System.IO.File]::ReadAllText($tmplHandoff, $Utf8NoBom)
    $seededHandoff = $rawHandoff.Replace('<project-name>', $ProjectName)
    Write-Utf8File -Path $TargetHandoff -Content $seededHandoff
  }

  $TargetBoard = Join-Path $TargetFull '.context\cos-board.md'
  if (-not (Test-Path -LiteralPath $TargetBoard)) {
    $tmplBoard = Join-Path $StarterRoot '.agents\skills\chief-of-staff\templates\cos-board.md'
    $rawBoard = [System.IO.File]::ReadAllText($tmplBoard, $Utf8NoBom)
    $today = Get-Date -Format 'yyyy-MM-dd'
    $seededBoard = $rawBoard.Replace('YYYY-MM-DD', $today).Replace('<repo>', $ProjectName)
    $seededBoard = [System.Text.RegularExpressions.Regex]::Replace(
      $seededBoard,
      '## Latest summary\r?\n',
      "## Latest summary`nStarter kit installed on-project. Waiting for project bootstrap (fill ``AI_HANDOFF.md`` and customize ``.agents/skills/verify-project/SKILL.md``).`n"
    )
    $emDash = [char]0x2014
    $seededBoard = [System.Text.RegularExpressions.Regex]::Replace(
      $seededBoard,
      '(\|---\|---\|---\|---\|---\|---\|---\|---\|\r?\n)',
      "`$1| bootstrap-repo | Populate ``AI_HANDOFF.md`` and customize ``verify-project`` skill from real codebase inspection | ``AI_HANDOFF.md`` has accurate build/test commands & invariants; ``verify-project`` runs cleanly | Investigation | root | queued | Inspect codebase and bootstrap | $emDash |`n"
    )
    Write-Utf8File -Path $TargetBoard -Content $seededBoard
  }

  $TargetVerify = Join-Path $TargetFull '.agents\skills\verify-project\SKILL.md'
  if (-not (Test-Path -LiteralPath $TargetVerify)) {
    Copy-ManagedFile -Source (Join-Path $StarterRoot '.agents\skills\verify-project\SKILL.md') -Dest $TargetVerify
  }

  $TargetModels = Join-Path $TargetFull '.agents\rules\pstack-models.md'
  if (-not (Test-Path -LiteralPath $TargetModels)) {
    Copy-ManagedFile -Source (Join-Path $StarterRoot '.agents\rules\pstack-models.md') -Dest $TargetModels
  }

  # 4. Managed marker block merge for AGENTS.md, CLAUDE.md, GEMINI.md
  $MarkerRegex = [System.Text.RegularExpressions.Regex]::new(
    '<!-- BEGIN AGENT-STARTER-KIT -->[\s\S]*?<!-- END AGENT-STARTER-KIT -->'
  )
  foreach ($entryName in @('AGENTS.md', 'CLAUDE.md', 'GEMINI.md')) {
    $srcEntry = Join-Path $StarterRoot $entryName
    $dstEntry = Join-Path $TargetFull $entryName
    $srcRaw = [System.IO.File]::ReadAllText($srcEntry, $Utf8NoBom).TrimEnd()
    $blockMatch = $MarkerRegex.Match($srcRaw)
    if (-not $blockMatch.Success) {
      throw "Missing BEGIN/END AGENT-STARTER-KIT markers in $srcEntry"
    }
    $managedBlock = $blockMatch.Value

    if (-not (Test-Path -LiteralPath $dstEntry)) {
      Write-Utf8File -Path $dstEntry -Content ($srcRaw + "`n")
    }
    else {
      $dstRaw = [System.IO.File]::ReadAllText($dstEntry, $Utf8NoBom)
      if ($MarkerRegex.IsMatch($dstRaw)) {
        $merged = $MarkerRegex.Replace($dstRaw, { param($m) $managedBlock }, 1)
        Write-Utf8File -Path $dstEntry -Content $merged
      }
      elseif ($dstRaw -match '# AI Agent Instructions & Chief of Staff') {
        Write-Utf8File -Path $dstEntry -Content ($srcRaw + "`n")
      }
      else {
        $merged = $managedBlock + "`n`n" + $dstRaw.TrimStart("`r", "`n")
        Write-Utf8File -Path $dstEntry -Content $merged
      }
    }
  }
}

# 5. Sync pstack-claude on-project
if (-not $SkipPstackSync) {
  $syncScript = Join-Path $TargetFull '.agents\tools\sync-pstack.ps1'
  & $syncScript -NoPause
  if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    throw "sync-pstack.ps1 failed with exit code $LASTEXITCODE"
  }
}

# 6. Write provenance manifest
$starterCommit = 'local'
if (Test-Path -LiteralPath (Join-Path $StarterRoot '.git')) {
  $rev = git -C $StarterRoot rev-parse --short HEAD 2>$null
  if ($LASTEXITCODE -eq 0 -and $rev) { $starterCommit = $rev.Trim() }
}

$pstackVersion = 'pending-sync'
foreach ($pj in @(
  (Join-Path $TargetFull '.agents\plugins\pstack\plugin.json'),
  (Join-Path $TargetFull '.agents\plugins\pstack\.antigravity-plugin\plugin.json')
)) {
  if (Test-Path -LiteralPath $pj) {
    try {
      $v = (Get-Content -LiteralPath $pj -Raw | ConvertFrom-Json).version
      if ($v) { $pstackVersion = [string]$v; break }
    }
    catch {}
  }
}

$manifestObj = [ordered]@{
  name             = 'agent-starter-kit'
  sourceRepo       = $SourceRepo
  branch           = $Branch
  starterKitCommit = $starterCommit
  pstackSource     = 'https://github.com/michael-denyer/pstack-claude.git'
  pstackVersion    = $pstackVersion
  updatedAt        = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}
$manifestJson = ($manifestObj | ConvertTo-Json -Depth 3) + "`n"
Write-Utf8File -Path $ManifestPath -Content $manifestJson

Write-Host "[OK] agent-starter-kit ready on-project at $TargetFull (commit: $starterCommit, pstack: $pstackVersion)" -ForegroundColor Green
