function Get-NetIPAddress {
    <#
    .SYNOPSIS
        Gets IP address configuration. On Linux, wraps 'ip addr'. On Windows, delegates to NetTCPIP\Get-NetIPAddress.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Position = 0)]
        [string[]]$IPAddress,

        [Parameter()]
        [string[]]$InterfaceAlias,

        [Parameter()]
        [int[]]$InterfaceIndex,

        [Parameter()]
        [ValidateSet('IPv4', 'IPv6')]
        [string]$AddressFamily,

        [Parameter()]
        [ValidateSet('Unicast', 'Anycast', 'Multicast', 'Broadcast', 'Invalid', 'Unknown')]
        [string]$Type,

        [Parameter()]
        [ValidateSet('Valid', 'Invalid', 'Tentative', 'Duplicate', 'Deprecated', 'Preferred', 'Unknown')]
        [string]$PrefixOrigin,

        [Parameter()]
        [ValidateSet('Connected', 'Disconnected', 'NotApplicable')]
        [string]$SuffixOrigin
    )

    if ($IsLinux) {
        $raw = ip -json addr show 2>/dev/null | ConvertFrom-Json

        $results = foreach ($iface in $raw) {
            foreach ($addrInfo in $iface.addr_info) {
                $family = if ($addrInfo.family -eq 'inet') { 'IPv4' } else { 'IPv6' }

                [PSCustomObject]@{
                    IPAddress         = $addrInfo.local
                    InterfaceAlias    = $iface.ifname
                    InterfaceIndex    = $iface.ifindex
                    AddressFamily     = $family
                    PrefixLength      = $addrInfo.prefixlen
                    Type              = 'Unicast'
                    PrefixOrigin      = 'Manual'
                    SuffixOrigin      = 'Manual'
                    AddressState      = 'Preferred'
                    ValidLifetime     = if ($addrInfo.valid_life_time -ge 4294967295) { [TimeSpan]::MaxValue } else { [TimeSpan]::FromSeconds($addrInfo.valid_life_time) }
                    PreferredLifetime = if ($addrInfo.preferred_life_time -ge 4294967295) { [TimeSpan]::MaxValue } else { [TimeSpan]::FromSeconds($addrInfo.preferred_life_time) }
                    SkipAsSource      = $false
                    PolicyStore       = 'ActiveStore'
                }
            }
        }

        # Apply filters
        if ($IPAddress) {
            $results = $results | Where-Object { $_.IPAddress -in $IPAddress }
        }
        if ($InterfaceAlias) {
            $results = $results | Where-Object { $alias = $_.InterfaceAlias; $InterfaceAlias | Where-Object { $alias -like $_ } }
        }
        if ($InterfaceIndex) {
            $results = $results | Where-Object { $_.InterfaceIndex -in $InterfaceIndex }
        }
        if ($AddressFamily) {
            $results = $results | Where-Object { $_.AddressFamily -eq $AddressFamily }
        }

        $results
    } else {
        NetTCPIP\Get-NetIPAddress @PSBoundParameters
    }
}
