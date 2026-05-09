function Find-NetRoute {
    <#
    .SYNOPSIS
        Finds the best route to a destination. On Linux, wraps 'ip route get'.
    .PARAMETER RemoteIPAddress
        The destination IP address to find a route for.
    .PARAMETER InterfaceIndex
        (Ignored on Linux - route is determined by the routing table.)
    .LINK
        https://learn.microsoft.com/powershell/module/nettcpip/find-netroute
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$RemoteIPAddress,

        [Parameter()]
        [int]$InterfaceIndex
    )
    process {
        if ($IsLinux) {
            if ($InterfaceIndex) {
                Write-Warning 'Find-NetRoute: -InterfaceIndex is ignored on Linux.'
            }
            $raw = & ip -json route get $RemoteIPAddress 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "ip route get failed: $raw"
                return
            }
            $entry = ($raw | ConvertFrom-Json) | Select-Object -First 1
            [PSCustomObject]@{
                DestinationPrefix = $RemoteIPAddress
                NextHop           = if ($entry.gateway) { $entry.gateway } else { '0.0.0.0' }
                InterfaceAlias    = $entry.dev
                SourceAddress     = $entry.prefsrc
                RouteMetric       = 0
                PolicyStore       = 'ActiveStore'
            }
        } else {
            NetTCPIP\Find-NetRoute @PSBoundParameters
        }
    }
}
