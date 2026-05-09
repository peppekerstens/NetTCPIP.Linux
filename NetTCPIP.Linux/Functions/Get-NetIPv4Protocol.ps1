function Get-NetIPv4Protocol {
    <#
    .SYNOPSIS
        Gets IPv4 protocol settings. On Linux, reads from sysctl.
    .LINK
        https://learn.microsoft.com/powershell/module/nettcpip/get-netipv4protocol
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    process {
        if ($IsLinux) {
            $fwd      = (& sysctl -n net.ipv4.ip_forward 2>/dev/null).Trim()
            $ttl      = (& sysctl -n net.ipv4.ip_default_ttl 2>/dev/null).Trim()
            [PSCustomObject]@{
                DefaultHopLimit            = if ($ttl) { [int]$ttl } else { 128 }
                Forwarding                 = if ($fwd -eq '1') { 'Enabled' } else { 'Disabled' }
                IcmpRedirects              = 'Enabled'
                SourceRoutingBehavior      = 'DontForward'
                NlMtuDiscovery             = 'Enabled'
                MulticastForwarding        = 'Disabled'
                GroupForwardedFragments    = 'Disabled'
                RandomizeIdentifiers       = 'Enabled'
                AddressMaskReply           = 'Disabled'
                MinimumMtu                 = 576
                DHCPMediaSense             = 'Enabled'
                MediaSenseEventLog         = 'Disabled'
                IGMPLevel                  = 'Version3'
                IGMPVersion                = 3
                UseTemporaryAddresses      = 'Disabled'
            }
        } else {
            NetTCPIP\Get-NetIPv4Protocol @PSBoundParameters
        }
    }
}
