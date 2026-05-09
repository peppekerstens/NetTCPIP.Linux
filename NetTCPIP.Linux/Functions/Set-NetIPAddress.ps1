function Set-NetIPAddress {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetIPAddress is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetIPAddress @PSBoundParameters
    }
}
