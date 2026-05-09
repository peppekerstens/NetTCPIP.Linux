function Get-NetNeighbor {
    <#
    .SYNOPSIS
        Gets neighbor (ARP/NDP) cache entries. On Linux, wraps 'ip -json neigh show'.
    .PARAMETER InterfaceAlias
        Filter by interface name (supports wildcards).
    .PARAMETER InterfaceIndex
        Filter by interface index.
    .PARAMETER IPAddress
        Filter by IP address.
    .PARAMETER State
        Filter by neighbor state (e.g. Reachable, Stale, Delay, Probe, Failed, Incomplete).
    .LINK
        https://learn.microsoft.com/powershell/module/nettcpip/get-netneighbor
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0)]
        [string[]]$IPAddress,

        [Parameter()]
        [string[]]$InterfaceAlias,

        [Parameter()]
        [int[]]$InterfaceIndex,

        [Parameter()]
        [ValidateSet('Reachable', 'Stale', 'Delay', 'Probe', 'Failed', 'Incomplete', 'Permanent', 'Unknown')]
        [string[]]$State
    )
    process {
        if ($IsLinux) {
            $raw = & ip -json neigh show 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "ip neigh show failed: $raw"
                return
            }
            $entries = $raw | ConvertFrom-Json

            # Build link index for InterfaceIndex lookups
            $linkMap = @{}
            if ($InterfaceIndex) {
                $linkRaw = & ip -json link show 2>&1
                if ($LASTEXITCODE -eq 0) {
                    ($linkRaw | ConvertFrom-Json) | ForEach-Object { $linkMap[$_.ifname] = $_.ifindex }
                }
            }

            $results = foreach ($entry in $entries) {
                $neighborState = if ($entry.state) { $entry.state[0] } else { 'Unknown' }
                # Normalise to PascalCase to match Windows output
                $neighborState = (Get-Culture).TextInfo.ToTitleCase($neighborState.ToLower())
                [PSCustomObject]@{
                    IPAddress      = $entry.dst
                    InterfaceAlias = $entry.dev
                    InterfaceIndex = if ($linkMap.ContainsKey($entry.dev)) { $linkMap[$entry.dev] } else { 0 }
                    LinkLayerAddress = if ($entry.lladdr) { $entry.lladdr } else { '' }
                    State          = $neighborState
                    PolicyStore    = 'ActiveStore'
                }
            }

            if ($IPAddress) {
                $results = $results | Where-Object { $_.IPAddress -in $IPAddress }
            }
            if ($InterfaceAlias) {
                $results = $results | Where-Object {
                    $_a = $_.InterfaceAlias
                    $InterfaceAlias | Where-Object { $_a -like $_ }
                }
            }
            if ($InterfaceIndex) {
                $results = $results | Where-Object { $_.InterfaceIndex -in $InterfaceIndex }
            }
            if ($State) {
                $results = $results | Where-Object { $_.State -in $State }
            }
            $results
        } else {
            NetTCPIP\Get-NetNeighbor @PSBoundParameters
        }
    }
}
