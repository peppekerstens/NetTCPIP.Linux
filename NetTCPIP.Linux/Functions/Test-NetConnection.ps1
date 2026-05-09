function Test-NetConnection {
    <#
    .SYNOPSIS
        Tests network connectivity. On Linux, uses ping and nc (netcat).
    .PARAMETER ComputerName
        The host to test connectivity to. Defaults to 'internetbeacon.msedge.net'.
    .PARAMETER Port
        TCP port to test. When specified, uses nc to test TCP connectivity.
    .PARAMETER InformationLevel
        'Detailed' returns additional properties. 'Quiet' suppresses all output
        and returns only a boolean.
    .PARAMETER TraceRoute
        Not supported on Linux. Emits a warning when specified.
    .LINK
        https://learn.microsoft.com/powershell/module/nettcpip/test-netconnection
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject], [bool])]
    param(
        [Parameter(Position = 0)]
        [string]$ComputerName = 'internetbeacon.msedge.net',

        [Parameter()]
        [int]$Port,

        [Parameter()]
        [ValidateSet('Quiet', 'Detailed')]
        [string]$InformationLevel = 'Detailed',

        [Parameter()]
        [switch]$TraceRoute
    )
    process {
        if ($IsLinux) {
            if ($TraceRoute) {
                Write-Warning 'Test-NetConnection: -TraceRoute is not supported on Linux.'
            }

            # ICMP ping check
            $pingSuccess = $false
            $pingOutput = & ping -c 1 -W 2 $ComputerName 2>&1
            if ($LASTEXITCODE -eq 0) {
                $pingSuccess = $true
            }

            # Parse round-trip time from ping output
            $rttMs = $null
            if ($pingSuccess) {
                $rttLine = $pingOutput | Where-Object { $_ -match 'time=' }
                if ($rttLine -match 'time=([\d.]+)') {
                    $rttMs = [double]$Matches[1]
                }
            }

            # TCP port check (nc -z -w 2)
            $tcpSuccess = $false
            if ($Port) {
                $null = & nc -z -w 2 $ComputerName $Port 2>&1
                $tcpSuccess = $LASTEXITCODE -eq 0
            }

            if ($InformationLevel -eq 'Quiet') {
                if ($Port) { return $tcpSuccess } else { return $pingSuccess }
            }

            [PSCustomObject]@{
                ComputerName           = $ComputerName
                RemoteAddress          = $ComputerName
                PingSucceeded          = $pingSuccess
                PingReplyDetails       = if ($null -ne $rttMs) { "RTT=$($rttMs)ms" } else { $null }
                TcpTestSucceeded       = if ($Port) { $tcpSuccess } else { $false }
                RemotePort             = if ($Port) { $Port } else { 0 }
            }
        } else {
            NetTCPIP\Test-NetConnection @PSBoundParameters
        }
    }
}
