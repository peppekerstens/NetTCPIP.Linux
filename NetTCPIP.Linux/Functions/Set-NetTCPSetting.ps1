function Set-NetTCPSetting {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetTCPSetting is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetTCPSetting @PSBoundParameters
    }
}
