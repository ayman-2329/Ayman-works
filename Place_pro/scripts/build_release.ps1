# Build Release Script for Windows

# Check Flutter installation
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

# Check if in project root
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "Please run this script from the project root directory"
    exit 1
}

# Get version info
$versionLine = Get-Content "pubspec.yaml" | Where-Object { $_ -match '^version:' }
$version = $versionLine -replace 'version: ', '' -split '\+' | Select-Object -First 1
$buildNumber = $versionLine -replace '.*\+', ''

Write-Host "`n=== Preparing Release Build v$version+$buildNumber ===`n" -ForegroundColor Green

# Check for uncommitted changes
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Warning "You have uncommitted changes. Please commit or stash them before releasing."
    git status
    exit 1
}

# Pull latest changes
Write-Host "Pulling latest changes..." -ForegroundColor Cyan
git pull

# Install dependencies
Write-Host "`nInstalling dependencies..." -ForegroundColor Cyan
flutter pub get

# Run tests
Write-Host "`nRunning tests..." -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Error "Tests failed"
    exit 1
}

# Run static analysis
Write-Host "`nRunning static analysis..." -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Static analysis found issues"
    $continue = Read-Host "Continue with build? (y/N)"
    if ($continue -ne 'y') { exit 1 }
}

# Build app bundle
Write-Host "`nBuilding app bundle..." -ForegroundColor Cyan
flutter build appbundle --release

# Verify the bundle was created
$bundlePath = "build\app\outputs\bundle\release\app-release.aab"
if (-not (Test-Path $bundlePath)) {
    Write-Error "App bundle not found at $bundlePath"
    exit 1
}

# Show build info
$bundleSize = (Get-Item $bundlePath).Length / 1MB
$bundleSize = [math]::Round($bundleSize, 2)

Write-Host "`n✅ Build successful!" -ForegroundColor Green
Write-Host "App bundle: $((Get-Item $bundlePath).FullName)"
Write-Host "Size: $bundleSize MB"

# Open build directory
explorer "/select,$((Get-Item $bundlePath).FullName)"
