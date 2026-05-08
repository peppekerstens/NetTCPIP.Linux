function Test-NetConnection {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Test-NetConnection is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Test-NetConnection @PSBoundParameters
    }
}
