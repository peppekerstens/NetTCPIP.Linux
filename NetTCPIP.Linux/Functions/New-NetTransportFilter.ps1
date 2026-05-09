function New-NetTransportFilter {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "New-NetTransportFilter is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\New-NetTransportFilter @PSBoundParameters
    }
}
