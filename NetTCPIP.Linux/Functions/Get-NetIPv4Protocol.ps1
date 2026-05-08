function Get-NetIPv4Protocol {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetIPv4Protocol is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetIPv4Protocol @PSBoundParameters
    }
}
