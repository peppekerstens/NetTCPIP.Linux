<#
.Synopsis
    Displays the IPv4 and IPv6 routing table in a readable format.
.Description
    Uses Get-NetRoute to retrieve all routes and displays destination prefix,
    next hop, interface, and metric — sorted by destination prefix length (most specific first).
    Works identically on Windows (via NetTCPIP) and Linux (via NetTCPIP.Linux).
.Example
    .\Get-RoutingTable.ps1
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: NetTCPIP.Linux (Linux) or NetTCPIP (Windows)
#>

#Requires -Modules NetTCPIP.Linux

Write-Host "=== IPv4 Routes ===" -ForegroundColor Cyan
Get-NetRoute -AddressFamily IPv4 |
    Select-Object -Property DestinationPrefix, NextHop, InterfaceAlias, RouteMetric |
    Sort-Object   -Property @{ Expression = { ($_.DestinationPrefix -split '/')[1] -as [int] }; Descending = $true } |
    Format-Table  -AutoSize

Write-Host "=== IPv6 Routes ===" -ForegroundColor Cyan
Get-NetRoute -AddressFamily IPv6 |
    Select-Object -Property DestinationPrefix, NextHop, InterfaceAlias, RouteMetric |
    Sort-Object   -Property @{ Expression = { ($_.DestinationPrefix -split '/')[1] -as [int] }; Descending = $true } |
    Format-Table  -AutoSize
