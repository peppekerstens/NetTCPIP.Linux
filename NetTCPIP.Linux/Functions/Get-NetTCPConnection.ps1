function Get-NetTCPConnection {
    <#
    .SYNOPSIS
        Gets TCP connections. On Linux, wraps 'ss'. On Windows, delegates to NetTCPIP\Get-NetTCPConnection.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$LocalAddress,

        [Parameter()]
        [uint16[]]$LocalPort,

        [Parameter()]
        [string[]]$RemoteAddress,

        [Parameter()]
        [uint16[]]$RemotePort,

        [Parameter()]
        [ValidateSet('Closed', 'Listen', 'SynSent', 'SynReceived', 'Established', 'FinWait1', 'FinWait2', 'CloseWait', 'Closing', 'LastAck', 'TimeWait', 'DeleteTCB', 'Bound')]
        [string[]]$State,

        [Parameter()]
        [uint32[]]$OwningProcess
    )

    if ($IsLinux) {
        # ss -tnap gives TCP connections with process info
        $ssOutput = ss -tnap 2>/dev/null | Select-Object -Skip 1

        $results = foreach ($line in $ssOutput) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            $parts = $line -split '\s+', 6
            if ($parts.Count -lt 5) { continue }

            $stateRaw  = $parts[0]
            $localFull  = $parts[3]
            $remoteFull = $parts[4]
            $processPart = if ($parts.Count -ge 6) { $parts[5] } else { '' }

            # Parse local addr:port
            $localAddr = $localPort = $null
            if ($localFull -match '^(.*):(\d+)$') {
                $localAddr = $Matches[1]
                $localPort = [uint16]$Matches[2]
            } elseif ($localFull -match '^\[(.+)\]:(\d+)$') {
                $localAddr = $Matches[1]
                $localPort = [uint16]$Matches[2]
            } else { continue }

            # Parse remote addr:port
            $remoteAddr = $remotePort = $null
            if ($remoteFull -match '^(.*):(\d+)$') {
                $remoteAddr = $Matches[1]
                $remotePort = [uint16]$Matches[2]
            } elseif ($remoteFull -match '^\[(.+)\]:(\d+)$') {
                $remoteAddr = $Matches[1]
                $remotePort = [uint16]$Matches[2]
            } else { continue }

            # Map ss state to Windows TCP state names
            $stateMap = @{
                'ESTAB'       = 'Established'
                'LISTEN'      = 'Listen'
                'TIME-WAIT'   = 'TimeWait'
                'CLOSE-WAIT'  = 'CloseWait'
                'FIN-WAIT-1'  = 'FinWait1'
                'FIN-WAIT-2'  = 'FinWait2'
                'LAST-ACK'    = 'LastAck'
                'CLOSING'     = 'Closing'
                'SYN-SENT'    = 'SynSent'
                'SYN-RECV'    = 'SynReceived'
                'CLOSED'      = 'Closed'
                'UNCONN'      = 'Closed'
            }
            $stateMapped = if ($stateMap.ContainsKey($stateRaw)) { $stateMap[$stateRaw] } else { $stateRaw }

            # Parse PID from users:(("name",pid=NNN,...))
            $pid = 0
            if ($processPart -match 'pid=(\d+)') {
                $pid = [uint32]$Matches[1]
            }

            [PSCustomObject]@{
                LocalAddress   = $localAddr
                LocalPort      = $localPort
                RemoteAddress  = $remoteAddr
                RemotePort     = $remotePort
                State          = $stateMapped
                OwningProcess  = $pid
                CreationTime   = $null
                OffloadState   = 'InHost'
            }
        }

        # Apply filters
        if ($LocalAddress) {
            $results = $results | Where-Object { $_.LocalAddress -in $LocalAddress }
        }
        if ($LocalPort) {
            $results = $results | Where-Object { $_.LocalPort -in $LocalPort }
        }
        if ($RemoteAddress) {
            $results = $results | Where-Object { $_.RemoteAddress -in $RemoteAddress }
        }
        if ($RemotePort) {
            $results = $results | Where-Object { $_.RemotePort -in $RemotePort }
        }
        if ($State) {
            $results = $results | Where-Object { $_.State -in $State }
        }
        if ($OwningProcess) {
            $results = $results | Where-Object { $_.OwningProcess -in $OwningProcess }
        }

        $results
    } else {
        NetTCPIP\Get-NetTCPConnection @PSBoundParameters
    }
}
