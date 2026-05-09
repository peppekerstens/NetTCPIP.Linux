function Set-NetOffloadGlobalSetting {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetOffloadGlobalSetting is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetOffloadGlobalSetting @PSBoundParameters
    }
}
