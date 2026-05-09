function New-NetRoute {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "New-NetRoute is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\New-NetRoute @PSBoundParameters
    }
}
