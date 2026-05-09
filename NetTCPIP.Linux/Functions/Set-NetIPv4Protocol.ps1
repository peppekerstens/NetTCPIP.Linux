function Set-NetIPv4Protocol {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetIPv4Protocol is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetIPv4Protocol @PSBoundParameters
    }
}
