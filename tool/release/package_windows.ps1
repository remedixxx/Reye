param(
    [string]$OutputDirectory = '',
    [switch]$SkipInstaller
)

. (Join-Path $PSScriptRoot 'common.ps1')

$version = Get-ReyeVersion
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $script:ReyeRepositoryRoot 'dist'
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$releaseDirectory = Join-Path $script:ReyeRepositoryRoot `
    'build\windows\x64\runner\Release'
$executable = Join-Path $releaseDirectory 'Reye.exe'
if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
    throw 'Windows release not found. Run flutter build windows --release first.'
}

if (-not [string]::IsNullOrWhiteSpace($env:REYE_WINDOWS_CERT_THUMBPRINT)) {
    & (Join-Path $PSScriptRoot 'sign_windows.ps1') -Path $executable
}

$portableZip = Join-Path $OutputDirectory `
    "Reye-Windows-x64-Portable-v$($version.Name).zip"
Compress-Archive -Path (Join-Path $releaseDirectory '*') `
    -DestinationPath $portableZip -CompressionLevel Optimal -Force
$portableChecksum = Write-ReyeSha256 -Path $portableZip
Write-Host "Windows portable package: $portableZip"
Write-Host "SHA-256: $portableChecksum"

if ($SkipInstaller) {
    return
}

$iscc = Get-Command ISCC.exe -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Source -First 1
if (-not $iscc) {
    $knownIsccPaths = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
        (Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe')
    )
    $iscc = $knownIsccPaths |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1
    if (-not $iscc -and (Test-Path -LiteralPath 'C:\Users')) {
        $iscc = Get-ChildItem 'C:\Users\*\AppData\Local\Programs\Inno Setup 6' `
            -Filter ISCC.exe -File -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName -First 1
    }
}
if (-not $iscc) {
    Write-Warning 'Inno Setup 6 was not found. Portable ZIP was created; installer was skipped.'
    return
}

$installerScript = Join-Path $script:ReyeRepositoryRoot 'installer\reye.iss'
& $iscc "/DMyAppVersion=$($version.Name)" `
    "/DSourceDir=$releaseDirectory" `
    "/DOutputDir=$OutputDirectory" `
    $installerScript
if ($LASTEXITCODE -ne 0) {
    throw 'Inno Setup failed to build the Windows installer.'
}

$installer = Join-Path $OutputDirectory `
    "Reye-Windows-x64-Setup-v$($version.Name).exe"
if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
    throw 'Inno Setup completed but the expected installer was not found.'
}
if (-not [string]::IsNullOrWhiteSpace($env:REYE_WINDOWS_CERT_THUMBPRINT)) {
    & (Join-Path $PSScriptRoot 'sign_windows.ps1') -Path $installer
}
$installerChecksum = Write-ReyeSha256 -Path $installer
Write-Host "Windows installer: $installer"
Write-Host "SHA-256: $installerChecksum"
