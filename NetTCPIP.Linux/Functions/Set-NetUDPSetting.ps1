function Set-NetUDPSetting {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetUDPSetting is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetUDPSetting @PSBoundParameters
    }
}
