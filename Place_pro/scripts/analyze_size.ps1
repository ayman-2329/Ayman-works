# App Size Analysis Script

# Check if Flutter is installed
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

# Build the app in profile mode for analysis
Write-Host "Building app in profile mode..." -ForegroundColor Cyan
flutter build apk --split-per-abi --profile --analyze-size

# Find the generated APK files
$apkFiles = Get-ChildItem -Path "build\app\outputs\flutter-apk" -Filter "*.apk" -Recurse

if ($apkFiles.Count -eq 0) {
    Write-Error "No APK files found in build directory"
    exit 1
}

# Show APK information
Write-Host "`nGenerated APK files:" -ForegroundColor Green
$apkFiles | ForEach-Object {
    $size = [math]::Round(($_.Length / 1MB), 2)
    Write-Host "- $($_.Name) ($size MB)" -ForegroundColor White
}

# Open the DevTools for detailed analysis
Write-Host "`nLaunching DevTools for detailed analysis..." -ForegroundColor Cyan
Start-Process "https://dart.dev/tools/dart-devtools"

# Run the app in profile mode for performance analysis
$runApp = Read-Host "`nDo you want to run the app in profile mode for performance analysis? (y/N)"
if ($runApp -eq 'y') {
    Write-Host "`nRunning app in profile mode..." -ForegroundColor Cyan
    Write-Host "Press 'r' to hot restart, 'h' for help, or 'q' to quit." -ForegroundColor Yellow
    flutter run --profile
}

# Suggest optimizations
Write-Host "`n=== Optimization Suggestions ===" -ForegroundColor Green
@"
1. Check for large assets in assets/ directory
2. Run 'flutter clean' and rebuild
3. Use '--split-debug-info' and '--obfuscate' flags for release builds
4. Remove unused dependencies from pubspec.yaml
5. Run 'flutter pub deps' to analyze dependencies
"@ | Write-Host -ForegroundColor White
