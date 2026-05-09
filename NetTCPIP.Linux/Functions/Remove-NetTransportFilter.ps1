function Remove-NetTransportFilter {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Remove-NetTransportFilter is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Remove-NetTransportFilter @PSBoundParameters
    }
}
