<#
.Synopsis
    Summarises all network interfaces with their IP addresses and default gateway.
.Description
    Combines Get-NetIPAddress and Get-NetIPConfiguration to display a per-interface
    summary: index, alias, IPv4 address, prefix length, and default gateway.
    Works identically on Windows (via NetTCPIP) and Linux (via NetTCPIP.Linux).
.Example
    .\Get-NetworkSummary.ps1
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: NetTCPIP.Linux (Linux) or NetTCPIP (Windows)
#>

#Requires -Modules NetTCPIP.Linux

Get-NetIPConfiguration |
    Select-Object -Property `
        InterfaceIndex,
        InterfaceAlias,
        @{ Name = 'IPv4Address'; Expression = { $_.IPv4Address.IPAddress } },
        @{ Name = 'PrefixLength'; Expression = { $_.IPv4Address.PrefixLength } },
        @{ Name = 'DefaultGateway'; Expression = { $_.IPv4DefaultGateway.NextHop } } |
    Format-Table -AutoSize
