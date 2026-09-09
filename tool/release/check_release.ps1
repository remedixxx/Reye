. (Join-Path $PSScriptRoot 'common.ps1')

$version = Get-ReyeVersion
$requiredFiles = @(
    'CHANGELOG.md',
    'LICENSE',
    'PRIVACY.md',
    'README.md',
    'README_FA.md',
    'THIRD_PARTY_NOTICES.md',
    'android/key.properties.example',
    'assets/fonts/vazirmatn/OFL.txt'
)

foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $script:ReyeRepositoryRoot $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required release file is missing: $relativePath"
    }
}

$changelog = Get-Content -Raw -Encoding UTF8 (
    Join-Path $script:ReyeRepositoryRoot 'CHANGELOG.md'
)
if ($changelog -notmatch [regex]::Escape("## $($version.Name)")) {
    throw "CHANGELOG.md has no entry for $($version.Name)."
}

$sourceFiles = @('android', 'lib', 'windows') |
    ForEach-Object { Get-ChildItem (Join-Path $script:ReyeRepositoryRoot $_) -Recurse -File }
$staleBrandReferences = $sourceFiles | Select-String -Pattern (
    'com\.eyebreak\.app|flutter_local_notifications_windows|' +
    'android\.permission\.SYSTEM_ALERT_WINDOW'
)
if ($staleBrandReferences) {
    $staleBrandReferences
    throw 'Stale production identifiers or removed platform dependencies remain.'
}

Write-Host "Release metadata is consistent for $($version.Full) ($($version.Tag))."
