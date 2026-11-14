# Sprint Helpers for Windows PowerShell
# Usage: . .\scripts\sprint-helpers.ps1

$ErrorActionPreference = "Stop"

function Set-GitEmailIfNeeded {
    param(
        [Parameter(Mandatory = $true)][string[]]$Repos,
        [Parameter(Mandatory = $true)][string]$Email,
        [string]$FallbackName = ""
    )
    foreach ($repo in $Repos) {
        if (-not (Test-Path $repo)) {
            throw "Khong tim thay repo: $repo"
        }
        git -C $repo config user.email $Email
        $currentName = git -C $repo config user.name 2>$null
        if (-not $currentName -and $FallbackName) {
            git -C $repo config user.name $FallbackName
        }
    }
}

function Copy-Rel {
    param(
        [Parameter(Mandatory = $true)][string]$SrcRoot,
        [Parameter(Mandatory = $true)][string]$DstRoot,
        [Parameter(Mandatory = $true)][string[]]$Paths
    )
    foreach ($p in $Paths) {
        $src = Join-Path $SrcRoot ($p -replace '/', '\')
        $dst = Join-Path $DstRoot ($p -replace '/', '\')
        if (-not (Test-Path $src)) {
            throw "Khong tim thay: $src"
        }
        if (Test-Path $src -PathType Container) {
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
            Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force
        } else {
            $parent = Split-Path $dst -Parent
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Copy-Item -Path $src -Destination $dst -Force
        }
    }
}

function Sync-IconsIndex {
    param(
        [Parameter(Mandatory = $true)][string]$SrcRoot,
        [Parameter(Mandatory = $true)][string]$DstRoot
    )
    $srcIndex = Join-Path $SrcRoot "src\components\icons\index.ts"
    $dstDir   = Join-Path $DstRoot "src\components\icons"
    $dstIndex = Join-Path $dstDir "index.ts"
    if (-not (Test-Path $srcIndex)) {
        throw "Khong tim thay: $srcIndex"
    }
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    $kept = @()
    foreach ($line in Get-Content $srcIndex) {
        if ($line -match '\./([A-Za-z0-9_-]+)') {
            $mod = $Matches[1]
            if ((Test-Path (Join-Path $dstDir "$mod.tsx")) -or (Test-Path (Join-Path $dstDir "$mod.ts"))) {
                $kept += $line
            }
        }
    }
    [System.IO.File]::WriteAllLines($dstIndex, $kept, (New-Object System.Text.UTF8Encoding $false))
}

function Fake-Commit {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$IsoDate,
        [Parameter(Mandatory = $true)][string]$Message
    )
    git -C $RepoPath add -A
    git -C $RepoPath reset -q HEAD -- AGENTS.md opencode.json 2>$null
    $changes = git -C $RepoPath status --porcelain
    if (-not $changes) {
        Write-Host "Bo qua (khong co thay doi): $Message"
        return
    }
    $env:GIT_AUTHOR_DATE = $IsoDate
    $env:GIT_COMMITTER_DATE = $IsoDate
    try {
        git -C $RepoPath commit -m $Message
    } finally {
        Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
        Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
    }
}
