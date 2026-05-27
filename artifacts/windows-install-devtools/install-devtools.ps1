[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Packages,

    [Parameter(Mandatory = $false)]
    [switch]$InstallVSCodeExtensions
)

$ErrorActionPreference = "Stop"

Write-Output "=== DevTest Labs Custom Artifact: Install Developer Tools ==="
Write-Output "Packages requested: $Packages"
Write-Output "Install VS Code Extensions: $InstallVSCodeExtensions"

# Install Chocolatey if not present
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
    Write-Output "Chocolatey installed successfully."
} else {
    Write-Output "Chocolatey already installed."
}

# Install each package
$packageList = $Packages -split '\s+'
foreach ($pkg in $packageList) {
    if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
    Write-Output "Installing package: $pkg"
    choco install $pkg -y --no-progress --limit-output
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install package: $pkg"
        exit 1
    }
    Write-Output "Successfully installed: $pkg"
}

# Refresh PATH after installations
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Install VS Code extensions if requested and VS Code was installed
if ($InstallVSCodeExtensions) {
    $codePath = Get-Command code -ErrorAction SilentlyContinue
    if ($codePath) {
        Write-Output "Installing VS Code extensions..."
        $extensions = @(
            "ms-python.python",
            "ms-vscode.powershell",
            "ms-azuretools.vscode-azureresourcegroups"
        )
        foreach ($ext in $extensions) {
            Write-Output "  Installing extension: $ext"
            code --install-extension $ext --force 2>&1 | Out-Null
        }
        Write-Output "VS Code extensions installed."
    } else {
        Write-Output "VS Code not found in PATH - skipping extension installation."
    }
}

Write-Output "=== Artifact completed successfully ==="
