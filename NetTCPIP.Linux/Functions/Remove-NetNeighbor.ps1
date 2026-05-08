function Remove-NetNeighbor {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "Remove-NetNeighbor is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\Remove-NetNeighbor @PSBoundParameters
    }
}
