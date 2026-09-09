param(
    [Parameter(Mandatory)][string]$Path,
    [string]$CertificateThumbprint = $env:REYE_WINDOWS_CERT_THUMBPRINT,
    [string]$TimestampUrl = 'http://timestamp.digicert.com'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
if ([string]::IsNullOrWhiteSpace($CertificateThumbprint)) {
    throw 'Set REYE_WINDOWS_CERT_THUMBPRINT or pass -CertificateThumbprint.'
}

$signTool = Get-Command signtool.exe -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Source -First 1
if (-not $signTool) {
    $kitsRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
    if (Test-Path -LiteralPath $kitsRoot) {
        $signTool = Get-ChildItem -LiteralPath $kitsRoot -Recurse -Filter signtool.exe |
            Where-Object { $_.FullName -match '\\x64\\signtool\.exe$' } |
            Sort-Object FullName -Descending |
            Select-Object -ExpandProperty FullName -First 1
    }
}
if (-not $signTool) {
    throw 'signtool.exe was not found. Install the Windows SDK.'
}

& $signTool sign /sha1 $CertificateThumbprint /fd SHA256 /tr $TimestampUrl `
    /td SHA256 $resolvedPath
if ($LASTEXITCODE -ne 0) {
    throw "Authenticode signing failed: $resolvedPath"
}

& $signTool verify /pa /v $resolvedPath
if ($LASTEXITCODE -ne 0) {
    throw "Authenticode verification failed: $resolvedPath"
}
