[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$InstallPath,

    [Parameter(Mandatory = $false)]
    [switch]$EnableTelemetry,

    [Parameter(Mandatory = $false)]
    [string]$Features = "analytics,notifications"
)

$ErrorActionPreference = "Stop"

Write-Output "=== DevTest Labs Custom Artifact: Install Custom Progressive Tool ==="
Write-Output "Version: $Version"
Write-Output "Install Path: $InstallPath"
Write-Output "Telemetry: $EnableTelemetry"
Write-Output "Features: $Features"

# Create installation directory
if (-not (Test-Path $InstallPath)) {
    Write-Output "Creating installation directory: $InstallPath"
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

# Simulate downloading the tool (replace URL with actual download source)
$toolExe = Join-Path $InstallPath "progressive-tool.exe"
$configFile = Join-Path $InstallPath "config.json"

Write-Output "Downloading Progressive Tool version $Version..."
# In a real scenario, replace this with actual download logic:
# Invoke-WebRequest -Uri "https://releases.example.com/progressive-tool/$Version/progressive-tool.exe" -OutFile $toolExe
# For demo purposes, create a placeholder
Set-Content -Path $toolExe -Value "Progressive Tool v$Version placeholder"
Write-Output "Download complete."

# Parse feature flags
$featureList = $Features -split ',' | ForEach-Object { $_.Trim() }
Write-Output "Enabling features: $($featureList -join ', ')"

# Generate configuration file
$config = @{
    version          = $Version
    installPath      = $InstallPath
    telemetryEnabled = [bool]$EnableTelemetry
    features         = $featureList
    installedAt      = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
}

$config | ConvertTo-Json -Depth 3 | Set-Content -Path $configFile -Encoding UTF8
Write-Output "Configuration written to: $configFile"

# Add to system PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$InstallPath*") {
    Write-Output "Adding $InstallPath to system PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$InstallPath", "Machine")
    Write-Output "PATH updated."
} else {
    Write-Output "Install path already in system PATH."
}

# Register Windows scheduled task for auto-updates (progressive enhancement)
Write-Output "Registering auto-update scheduled task..."
$action = New-ScheduledTaskAction -Execute $toolExe -Argument "--check-updates"
$trigger = New-ScheduledTaskTrigger -Daily -At "3:00AM"
Register-ScheduledTask -TaskName "ProgressiveToolAutoUpdate" -Action $action -Trigger $trigger -Description "Auto-update check for Progressive Tool" -RunLevel Highest -Force | Out-Null
Write-Output "Scheduled task registered."

Write-Output ""
Write-Output "=== Installation Summary ==="
Write-Output "  Tool: Custom Progressive Tool"
Write-Output "  Version: $Version"
Write-Output "  Location: $InstallPath"
Write-Output "  Features: $($featureList -join ', ')"
Write-Output "  Telemetry: $EnableTelemetry"
Write-Output "  Auto-Update: Enabled (daily at 3:00 AM)"
Write-Output "=== Artifact completed successfully ==="
