function Get-NetIPv6Protocol {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetIPv6Protocol is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetIPv6Protocol @PSBoundParameters
    }
}
