function Remove-NetRoute {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Remove-NetRoute is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Remove-NetRoute @PSBoundParameters
    }
}
