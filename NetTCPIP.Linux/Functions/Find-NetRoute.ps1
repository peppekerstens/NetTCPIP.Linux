function Find-NetRoute {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Find-NetRoute is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Find-NetRoute @PSBoundParameters
    }
}
