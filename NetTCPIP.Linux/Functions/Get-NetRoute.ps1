function Get-NetRoute {
    <#
    .SYNOPSIS
        Gets IP routing table entries. On Linux, wraps 'ip route'. On Windows, delegates to NetTCPIP\Get-NetRoute.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$DestinationPrefix,

        [Parameter()]
        [string[]]$InterfaceAlias,

        [Parameter()]
        [int[]]$InterfaceIndex,

        [Parameter()]
        [string[]]$NextHop,

        [Parameter()]
        [ValidateSet('IPv4', 'IPv6')]
        [string]$AddressFamily,

        [Parameter()]
        [ValidateSet('Connected', 'Unreachable', 'Remote')]
        [string]$TypeOfNextHop
    )

    if ($IsLinux) {
        $results = @()

        # Build interface index lookup once (avoids one ip call per route)
        $linkMap = @{}
        foreach ($link in (Get-IpLink)) {
            $linkMap[$link.ifname] = $link.ifindex
        }

        # IPv4
        $raw4 = Get-IpRoute
        foreach ($r in $raw4) {
            $dest = if ($r.dst -eq 'default') { '0.0.0.0/0' } else { $r.dst }
            $results += [PSCustomObject]@{
                DestinationPrefix = $dest
                NextHop           = if ($r.gateway) { $r.gateway } else { '0.0.0.0' }
                InterfaceAlias    = $r.dev
                InterfaceIndex    = if ($linkMap.ContainsKey($r.dev)) { $linkMap[$r.dev] } else { 0 }
                AddressFamily     = 'IPv4'
                RouteMetric       = if ($r.metric) { [int]$r.metric } else { 0 }
                TypeOfNextHop     = if ($r.gateway) { 'Remote' } else { 'Connected' }
                Protocol          = 'NetMgmt'
                Publish           = 'No'
                PolicyStore       = 'ActiveStore'
            }
        }

        # IPv6
        $raw6 = Get-IpRoute -IPv6
        foreach ($r in $raw6) {
            $dest = if ($r.dst -eq 'default') { '::/0' } else { $r.dst }
            $results += [PSCustomObject]@{
                DestinationPrefix = $dest
                NextHop           = if ($r.gateway) { $r.gateway } else { '::' }
                InterfaceAlias    = $r.dev
                InterfaceIndex    = if ($linkMap.ContainsKey($r.dev)) { $linkMap[$r.dev] } else { 0 }
                AddressFamily     = 'IPv6'
                RouteMetric       = if ($r.metric) { [int]$r.metric } else { 0 }
                TypeOfNextHop     = if ($r.gateway) { 'Remote' } else { 'Connected' }
                Protocol          = 'NetMgmt'
                Publish           = 'No'
                PolicyStore       = 'ActiveStore'
            }
        }

        # Apply filters
        if ($DestinationPrefix) {
            $results = $results | Where-Object { $_.DestinationPrefix -in $DestinationPrefix }
        }
        if ($InterfaceAlias) {
            $results = $results | Where-Object { $alias = $_.InterfaceAlias; $InterfaceAlias | Where-Object { $alias -like $_ } }
        }
        if ($InterfaceIndex) {
            $results = $results | Where-Object { $_.InterfaceIndex -in $InterfaceIndex }
        }
        if ($NextHop) {
            $results = $results | Where-Object { $_.NextHop -in $NextHop }
        }
        if ($AddressFamily) {
            $results = $results | Where-Object { $_.AddressFamily -eq $AddressFamily }
        }
        if ($TypeOfNextHop) {
            $results = $results | Where-Object { $_.TypeOfNextHop -eq $TypeOfNextHop }
        }

        $results
    } else {
        NetTCPIP\Get-NetRoute @PSBoundParameters
    }
}
