function Set-NetIPInterface {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetIPInterface is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetIPInterface @PSBoundParameters
    }
}
