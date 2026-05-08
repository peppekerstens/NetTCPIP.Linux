<#
.Synopsis
    Shows all currently established TCP connections with remote endpoints.
.Description
    Uses Get-NetTCPConnection to list Established connections grouped by remote address.
    Useful for spotting unexpected outbound connections or active clients.
    Works identically on Windows (via NetTCPIP) and Linux (via NetTCPIP.Linux).
.Example
    .\Get-ActiveConnections.ps1
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: NetTCPIP.Linux (Linux) or NetTCPIP (Windows)
#>

#Requires -Modules NetTCPIP.Linux

$connections = Get-NetTCPConnection -State Established

if ($connections) {
    Write-Host "Established TCP connections: $($connections.Count)" -ForegroundColor Cyan
    $connections |
        Select-Object -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess |
        Sort-Object   -Property RemoteAddress, RemotePort |
        Format-Table  -AutoSize
} else {
    Write-Host "No established TCP connections found." -ForegroundColor Yellow
}
