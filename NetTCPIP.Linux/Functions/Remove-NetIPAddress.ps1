function Remove-NetIPAddress {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Remove-NetIPAddress is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Remove-NetIPAddress @PSBoundParameters
    }
}
