function Get-NetNeighbor {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Get-NetNeighbor is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Get-NetNeighbor @PSBoundParameters
    }
}
