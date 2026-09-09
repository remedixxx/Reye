param(
    [string]$OutputDirectory = ''
)

. (Join-Path $PSScriptRoot 'common.ps1')

$version = Get-ReyeVersion
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $script:ReyeRepositoryRoot 'dist'
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$sourceApk = Join-Path $script:ReyeRepositoryRoot `
    'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path -LiteralPath $sourceApk -PathType Leaf)) {
    throw 'Release APK not found. Run flutter build apk --release first.'
}

$sdkRoot = $env:ANDROID_SDK_ROOT
if ([string]::IsNullOrWhiteSpace($sdkRoot)) {
    $localProperties = Join-Path $script:ReyeRepositoryRoot 'android\local.properties'
    if (Test-Path -LiteralPath $localProperties) {
        $sdkLine = Get-Content -LiteralPath $localProperties -Encoding UTF8 |
            Where-Object { $_ -match '^sdk\.dir=' } |
            Select-Object -First 1
        if ($sdkLine) {
            $sdkRoot = ($sdkLine -replace '^sdk\.dir=', '') -replace '\\\\', '\'
        }
    }
}

if ([string]::IsNullOrWhiteSpace($sdkRoot)) {
    throw 'ANDROID_SDK_ROOT is not set and sdk.dir was not found.'
}

$buildToolsRoot = Join-Path $sdkRoot 'build-tools'
$apksigner = Get-ChildItem -LiteralPath $buildToolsRoot -Directory |
    Sort-Object { try { [version]$_.Name } catch { [version]'0.0' } } -Descending |
    ForEach-Object { Join-Path $_.FullName 'apksigner.bat' } |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1

if (-not $apksigner) {
    throw 'apksigner.bat was not found in the Android SDK build-tools.'
}

& $apksigner verify --verbose --print-certs $sourceApk
if ($LASTEXITCODE -ne 0) {
    throw 'APK signature verification failed.'
}

$destination = Join-Path $OutputDirectory "Reye-Android-v$($version.Name).apk"
Copy-Item -LiteralPath $sourceApk -Destination $destination -Force
$checksum = Write-ReyeSha256 -Path $destination

Write-Host "Android package: $destination"
Write-Host "SHA-256: $checksum"
