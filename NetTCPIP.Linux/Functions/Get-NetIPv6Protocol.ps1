function Get-NetIPv6Protocol {
    <#
    .SYNOPSIS
        Gets IPv6 protocol settings. On Linux, reads from sysctl.
    .LINK
        https://learn.microsoft.com/powershell/module/nettcpip/get-netipv6protocol
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    process {
        if ($IsLinux) {
            $fwd      = (& sysctl -n net.ipv6.conf.all.forwarding 2>/dev/null).Trim()
            $disabled = (& sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null).Trim()
            $ttl      = (& sysctl -n net.ipv6.conf.all.hop_limit 2>/dev/null).Trim()
            [PSCustomObject]@{
                DefaultHopLimit            = if ($ttl) { [int]$ttl } else { 128 }
                Forwarding                 = if ($fwd -eq '1') { 'Enabled' } else { 'Disabled' }
                IcmpRedirects              = 'Enabled'
                NlMtuDiscovery             = 'Enabled'
                MulticastForwarding        = 'Disabled'
                GroupForwardedFragments    = 'Disabled'
                RandomizeIdentifiers       = 'Enabled'
                UseTemporaryAddresses      = 'Enabled'
                MaxTemporaryDadAttempts    = 3
                MaxTemporaryPreferredLifetime = [TimeSpan]::FromDays(1)
                MaxTemporaryValidLifetime  = [TimeSpan]::FromDays(7)
                TemporaryRegenerateTime    = [TimeSpan]::FromSeconds(5)
                MaxTemporaryDesyncFactor   = [TimeSpan]::FromMinutes(10)
                Disabled                   = ($disabled -eq '1')
            }
        } else {
            NetTCPIP\Get-NetIPv6Protocol @PSBoundParameters
        }
    }
}
