function New-NetIPAddress {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "New-NetIPAddress is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\New-NetIPAddress @PSBoundParameters
    }
}
