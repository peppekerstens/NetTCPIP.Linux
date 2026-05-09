#Requires -Version 7.2

# NetTCPIP.Linux.psm1
# Root module for NetTCPIP.Linux.
# Dot-sources all function files from the Functions\ subdirectory.

# Linux-only guard — this module wraps Linux CLI tools (ip, ss) and must not
# be loaded on Windows. On Windows, use the built-in NetTCPIP module instead:
#   Import-Module NetTCPIP
if (-not $IsLinux) {
    throw (
        "NetTCPIP.Linux cannot be loaded on Windows. " +
        "On Windows, use the built-in 'NetTCPIP' module: Import-Module NetTCPIP`n" +
        "NetTCPIP.Linux is a Linux-only peer module that wraps ip and ss."
    )
}

Get-ChildItem -Path "$PSScriptRoot\Functions" -Filter '*.ps1' |
    Where-Object { $_.Name -notlike '*.Tests.ps1' } |
    ForEach-Object { . $_.FullName }

# Load private ip wrapper as a nested module (not exported)
# Crescendo configuration: Crescendo/ip.crescendo.json
$ipModulePath = Join-Path $PSScriptRoot 'Crescendo' 'ip.psm1'
if (Test-Path $ipModulePath) {
    Import-Module $ipModulePath -Force -ErrorAction SilentlyContinue
}
