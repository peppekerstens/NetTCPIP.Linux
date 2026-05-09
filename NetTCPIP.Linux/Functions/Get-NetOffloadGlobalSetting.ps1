function Get-NetOffloadGlobalSetting {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetOffloadGlobalSetting is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetOffloadGlobalSetting @PSBoundParameters
    }
}
