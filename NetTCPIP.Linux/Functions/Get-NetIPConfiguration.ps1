function Get-NetIPConfiguration {
    <#
    .SYNOPSIS
        Gets IP network configuration summary per interface. On Linux, combines 'ip addr' and 'ip route'. On Windows, delegates to NetTCPIP\Get-NetIPConfiguration.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$InterfaceAlias,

        [Parameter()]
        [int[]]$InterfaceIndex,

        [Parameter()]
        [switch]$Detailed,

        [Parameter()]
        [switch]$All
    )

    if ($IsLinux) {
        $addrData  = ip -json addr show 2>/dev/null | ConvertFrom-Json
        $routeData = ip -json route show 2>/dev/null | ConvertFrom-Json

        # Default gateway
        $defaultGw = ($routeData | Where-Object { $_.dst -eq 'default' } | Select-Object -First 1).gateway

        $results = foreach ($iface in $addrData) {
            # Skip loopback unless -All specified
            if (-not $All -and $iface.ifname -eq 'lo') { continue }

            $ipv4 = $iface.addr_info | Where-Object { $_.family -eq 'inet' } | Select-Object -First 1
            $ipv6 = $iface.addr_info | Where-Object { $_.family -eq 'inet6' -and $_.scope -ne 'link' } | Select-Object -First 1

            [PSCustomObject]@{
                InterfaceAlias       = $iface.ifname
                InterfaceIndex       = $iface.ifindex
                InterfaceDescription = $iface.ifname
                NetProfile           = 'Unknown'
                IPv4Address          = if ($ipv4) { $ipv4.local } else { $null }
                IPv4DefaultGateway   = $defaultGw
                DNSServer            = @()
                IPv6Address          = if ($ipv6) { $ipv6.local } else { $null }
                NetAdapter           = $null
            }
        }

        if ($InterfaceAlias) {
            $results = $results | Where-Object { $alias = $_.InterfaceAlias; $InterfaceAlias | Where-Object { $alias -like $_ } }
        }
        if ($InterfaceIndex) {
            $results = $results | Where-Object { $_.InterfaceIndex -in $InterfaceIndex }
        }

        $results
    } else {
        NetTCPIP\Get-NetIPConfiguration @PSBoundParameters
    }
}
