function Set-NetRoute {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetRoute is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetRoute @PSBoundParameters
    }
}
