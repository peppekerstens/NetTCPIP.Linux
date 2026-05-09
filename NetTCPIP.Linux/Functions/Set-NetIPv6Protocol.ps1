function Set-NetIPv6Protocol {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetIPv6Protocol is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetIPv6Protocol @PSBoundParameters
    }
}
