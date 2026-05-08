<#
.Synopsis
    Lists all TCP ports currently in the Listen state with their owning process.
.Description
    Uses Get-NetTCPConnection to retrieve all listening TCP sockets and displays
    the local address, port, and owning process ID. Useful for auditing exposed services.
    Works identically on Windows (via NetTCPIP) and Linux (via NetTCPIP.Linux).
.Example
    .\Get-OpenPorts.ps1
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: NetTCPIP.Linux (Linux) or NetTCPIP (Windows)
#>

#Requires -Modules NetTCPIP.Linux

Get-NetTCPConnection -State Listen |
    Select-Object -Property LocalAddress, LocalPort, OwningProcess |
    Sort-Object   -Property LocalPort |
    Format-Table  -AutoSize
