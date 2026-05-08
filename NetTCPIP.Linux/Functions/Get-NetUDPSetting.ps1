function Get-NetUDPSetting {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetUDPSetting is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetUDPSetting @PSBoundParameters
    }
}
