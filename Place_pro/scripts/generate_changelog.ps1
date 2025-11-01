# Generate Changelog Script

# Get the current version from pubspec.yaml
$versionLine = Get-Content "pubspec.yaml" | Where-Object { $_ -match '^version:' }
$version = $versionLine -replace 'version: ', '' -split '\+' | Select-Object -First 1

# Create changelog directory if it doesn't exist
$changelogDir = "fastlane\metadata\android\en-US\changelogs"
if (-not (Test-Path $changelogDir)) {
    New-Item -ItemType Directory -Path $changelogDir -Force | Out-Null
}

# Create a default changelog file
$changelogFile = "$changelogDir\${version}.txt"
if (Test-Path $changelogFile) {
    Write-Host "Changelog for version $version already exists." -ForegroundColor Yellow
    notepad $changelogFile
} else {
    @"
- Initial release
- Added core functionality
- Fixed various bugs
"@ | Out-File -FilePath $changelogFile -Encoding utf8
    
    Write-Host "Created changelog file: $changelogFile" -ForegroundColor Green
    notepad $changelogFile
}
