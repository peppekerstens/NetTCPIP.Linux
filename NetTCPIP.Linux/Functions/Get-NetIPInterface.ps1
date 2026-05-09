function Get-NetIPInterface {
    <#
    .SYNOPSIS
        Gets IP interface properties. On Linux, wraps 'ip -json link show'.
    .PARAMETER InterfaceAlias
        Filter by interface name (supports wildcards).
    .PARAMETER InterfaceIndex
        Filter by interface index.
    .PARAMETER AddressFamily
        Filter by address family: IPv4 or IPv6.
    .LINK
        https://learn.microsoft.com/powershell/module/nettcpip/get-netipinterface
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0)]
        [string[]]$InterfaceAlias,

        [Parameter()]
        [int[]]$InterfaceIndex,

        [Parameter()]
        [ValidateSet('IPv4', 'IPv6')]
        [string]$AddressFamily
    )
    process {
        if ($IsLinux) {
            $raw = & ip -json link show 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "ip link show failed: $raw"
                return
            }
            $links = $raw | ConvertFrom-Json

            # Each link produces one entry per address family (or filtered)
            $families = if ($AddressFamily) { @($AddressFamily) } else { @('IPv4', 'IPv6') }

            $results = foreach ($link in $links) {
                foreach ($family in $families) {
                    [PSCustomObject]@{
                        InterfaceAlias      = $link.ifname
                        InterfaceIndex      = $link.ifindex
                        AddressFamily       = $family
                        NlMtu               = $link.mtu
                        InterfaceMetric     = 256
                        Dhcp                = 'Enabled'
                        ConnectionState     = if ('UP' -in $link.flags) { 'Connected' } else { 'Disconnected' }
                        RouterDiscovery     = 'ControlledByDHCP'
                        AutomaticMetric     = 'Enabled'
                        OperationalStatus   = $link.operstate
                    }
                }
            }

            if ($InterfaceAlias) {
                $results = $results | Where-Object {
                    $_alias = $_.InterfaceAlias
                    $InterfaceAlias | Where-Object { $_alias -like $_ }
                }
            }
            if ($InterfaceIndex) {
                $results = $results | Where-Object { $_.InterfaceIndex -in $InterfaceIndex }
            }
            $results
        } else {
            NetTCPIP\Get-NetIPInterface @PSBoundParameters
        }
    }
}
