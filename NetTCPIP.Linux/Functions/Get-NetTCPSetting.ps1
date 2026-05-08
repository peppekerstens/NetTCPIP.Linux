function Get-NetTCPSetting {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetTCPSetting is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetTCPSetting @PSBoundParameters
    }
}
