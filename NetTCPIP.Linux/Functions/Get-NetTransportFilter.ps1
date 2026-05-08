function Get-NetTransportFilter {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetTransportFilter is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetTransportFilter @PSBoundParameters
    }
}
