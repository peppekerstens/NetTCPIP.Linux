function Get-NetUDPEndpoint {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetUDPEndpoint is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetUDPEndpoint @PSBoundParameters
    }
}
