function Get-NetPrefixPolicy {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetPrefixPolicy is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetPrefixPolicy @PSBoundParameters
    }
}
