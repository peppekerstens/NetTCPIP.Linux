function Get-NetIPInterface {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetIPInterface is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetIPInterface @PSBoundParameters
    }
}
