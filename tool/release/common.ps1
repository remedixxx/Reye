Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ReyeRepositoryRoot = (
    Resolve-Path (Join-Path $PSScriptRoot '..\..')
).Path

function Get-ReyeVersion {
    $pubspecPath = Join-Path $script:ReyeRepositoryRoot 'pubspec.yaml'
    $versionLine = Get-Content -LiteralPath $pubspecPath -Encoding UTF8 |
        Where-Object { $_ -match '^version:\s*' } |
        Select-Object -First 1

    if ($null -eq $versionLine -or
        $versionLine -notmatch '^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$') {
        throw 'pubspec.yaml must contain version: major.minor.patch+build'
    }

    [PSCustomObject]@{
        Name = $Matches[1]
        Build = [int]$Matches[2]
        Full = "$($Matches[1])+$($Matches[2])"
        Tag = "v$($Matches[1])"
    }
}

function Write-ReyeSha256 {
    param([Parameter(Mandatory)][string]$Path)

    $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
    $hash = (Get-FileHash -LiteralPath $resolvedPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $checksumPath = "$resolvedPath.sha256"
    $line = "$hash  $([System.IO.Path]::GetFileName($resolvedPath))`n"
    [System.IO.File]::WriteAllText(
        $checksumPath,
        $line,
        [System.Text.UTF8Encoding]::new($false)
    )
    return $checksumPath
}
