# NetTCPIP.Linux — private ip wrapper
# Crescendo configuration: ip.crescendo.json
# Hand-written for reliability; mirrors the Crescendo JSON spec exactly.
# NOT exported — loaded as a nested module from NetTCPIP.Linux.psm1.

function Get-IpAddr {
    <#
    .SYNOPSIS
        Gets IP address information for all network interfaces.
    .DESCRIPTION
        Private helper. Wraps 'ip -json addr show'. Returns parsed PSObjects.
        Called by Get-NetIPAddress and Get-NetIPConfiguration.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param()
    process {
        $raw = & ip -json addr show 2>&1
        if ($LASTEXITCODE -ne 0) {
            $ex = [System.InvalidOperationException]::new("ip addr show failed: $raw")
            $er = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'NetTCPIP.Linux.IpAddrFailed',
                [System.Management.Automation.ErrorCategory]::InvalidOperation, $null)
            $PSCmdlet.ThrowTerminatingError($er)
        }
        $raw | ConvertFrom-Json
    }
}

function Get-IpRoute {
    <#
    .SYNOPSIS
        Gets IP routing table entries.
    .DESCRIPTION
        Private helper. Wraps 'ip -json route show' (IPv4) or 'ip -6 -json route show' (IPv6).
        Called by Get-NetRoute and Get-NetIPConfiguration.
    .PARAMETER IPv6
        When specified, queries the IPv6 routing table.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param(
        [Parameter()]
        [switch] $IPv6
    )
    process {
        $ipArgs = if ($IPv6) { @('-6', '-json', 'route', 'show') } else { @('-json', 'route', 'show') }
        $raw = & ip @ipArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            $ex = [System.InvalidOperationException]::new("ip route show failed: $raw")
            $er = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'NetTCPIP.Linux.IpRouteFailed',
                [System.Management.Automation.ErrorCategory]::InvalidOperation, $null)
            $PSCmdlet.ThrowTerminatingError($er)
        }
        $raw | ConvertFrom-Json
    }
}

function Get-IpLink {
    <#
    .SYNOPSIS
        Gets network link information for all interfaces.
    .DESCRIPTION
        Private helper. Wraps 'ip -json link show' or 'ip -s -json link show'.
        Called by Get-NetIPConfiguration.
    .PARAMETER Statistics
        When specified, includes per-interface RX/TX statistics.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param(
        [Parameter()]
        [switch] $Statistics
    )
    process {
        $ipArgs = if ($Statistics) { @('-s', '-json', 'link', 'show') } else { @('-json', 'link', 'show') }
        $raw = & ip @ipArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            $ex = [System.InvalidOperationException]::new("ip link show failed: $raw")
            $er = [System.Management.Automation.ErrorRecord]::new(
                $ex, 'NetTCPIP.Linux.IpLinkFailed',
                [System.Management.Automation.ErrorCategory]::InvalidOperation, $null)
            $PSCmdlet.ThrowTerminatingError($er)
        }
        $raw | ConvertFrom-Json
    }
}
