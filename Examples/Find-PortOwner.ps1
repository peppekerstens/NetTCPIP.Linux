<#
.Synopsis
    Finds which process is listening on a given TCP port.
.Description
    Accepts a port number and uses Get-NetTCPConnection to find any process
    listening on that port. Displays the local address, port, and process ID.
    Works identically on Windows (via NetTCPIP) and Linux (via NetTCPIP.Linux).
.Parameter Port
    The TCP port number to query. Defaults to 22 (SSH).
.Example
    .\Find-PortOwner.ps1 -Port 80
.Example
    .\Find-PortOwner.ps1
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: NetTCPIP.Linux (Linux) or NetTCPIP (Windows)
#>

#Requires -Modules NetTCPIP.Linux

param(
    [int]$Port = 22
)

$listener = Get-NetTCPConnection -State Listen -LocalPort $Port

if ($listener) {
    Write-Host "Port $Port is in use:" -ForegroundColor Green
    $listener |
        Select-Object -Property LocalAddress, LocalPort, OwningProcess |
        Format-Table -AutoSize
} else {
    Write-Host "No process is listening on port $Port." -ForegroundColor Yellow
}
