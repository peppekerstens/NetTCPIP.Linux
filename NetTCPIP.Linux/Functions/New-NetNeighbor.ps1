function New-NetNeighbor {
    [CmdletBinding()]
    param()
    if ($IsLinux) {
        Write-Warning "New-NetNeighbor is not implemented in NetTCPIP.Linux."
    } else {
        NetTCPIP\New-NetNeighbor @PSBoundParameters
    }
}
