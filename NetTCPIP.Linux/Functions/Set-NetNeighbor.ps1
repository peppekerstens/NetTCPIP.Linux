function Set-NetNeighbor {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Set-NetNeighbor is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Set-NetNeighbor @PSBoundParameters
    }
}
