#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }

<#
.SYNOPSIS
    Pester tests for NetTCPIP.Linux module.
.DESCRIPTION
    Tests module surface (function count), implemented cmdlet behaviour on Linux,
    and per-stub exported/no-throw/emits-warning checks.
    All tests require Linux — the module refuses to load on Windows by design.
    Describe blocks that require the module are skipped automatically on Windows.
    Run with: Invoke-Pester ./NetTCPIP.Linux.Tests.ps1 -Output Detailed
#>

BeforeDiscovery {
    $script:OnLinux = $IsLinux

    $script:ExpectedFunctions = @(
        'Get-NetIPAddress', 'Get-NetIPConfiguration', 'Get-NetRoute', 'Get-NetTCPConnection',
        'Find-NetRoute', 'Get-NetCompartment', 'Get-NetIPInterface',
        'Get-NetIPv4Protocol', 'Get-NetIPv6Protocol', 'Get-NetNeighbor',
        'Get-NetOffloadGlobalSetting', 'Get-NetPrefixPolicy', 'Get-NetTCPSetting',
        'Get-NetTransportFilter', 'Get-NetUDPEndpoint', 'Get-NetUDPSetting',
        'New-NetIPAddress', 'New-NetNeighbor', 'New-NetRoute', 'New-NetTransportFilter',
        'Remove-NetIPAddress', 'Remove-NetNeighbor', 'Remove-NetRoute', 'Remove-NetTransportFilter',
        'Set-NetIPAddress', 'Set-NetIPInterface', 'Set-NetIPv4Protocol', 'Set-NetIPv6Protocol',
        'Set-NetNeighbor', 'Set-NetOffloadGlobalSetting', 'Set-NetRoute', 'Set-NetTCPSetting',
        'Set-NetUDPSetting', 'Test-NetConnection'
    )

    $script:StubFunctions = @(
        'Get-NetCompartment',
        'Get-NetOffloadGlobalSetting', 'Get-NetPrefixPolicy', 'Get-NetTCPSetting',
        'Get-NetTransportFilter', 'Get-NetUDPEndpoint', 'Get-NetUDPSetting',
        'New-NetIPAddress', 'New-NetNeighbor', 'New-NetRoute', 'New-NetTransportFilter',
        'Remove-NetIPAddress', 'Remove-NetNeighbor', 'Remove-NetRoute', 'Remove-NetTransportFilter',
        'Set-NetIPAddress', 'Set-NetIPInterface', 'Set-NetIPv4Protocol', 'Set-NetIPv6Protocol',
        'Set-NetNeighbor', 'Set-NetOffloadGlobalSetting', 'Set-NetRoute', 'Set-NetTCPSetting',
        'Set-NetUDPSetting'
    )
}

BeforeAll {
    if ($IsLinux) {
        $ModulePath = Join-Path $PSScriptRoot 'NetTCPIP.Linux.psd1'
        Import-Module $ModulePath -Force
    }
}

AfterAll {
    if ($IsLinux) {
        Remove-Module NetTCPIP.Linux -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
Describe 'NetTCPIP.Linux module surface' -Skip:(-not $script:OnLinux) {

    It 'exports exactly 34 functions' {
        (Get-Module NetTCPIP.Linux).ExportedFunctions.Count | Should -Be 34
    }

    It 'exports 0 aliases' {
        (Get-Module NetTCPIP.Linux).ExportedAliases.Count | Should -Be 0
    }

    It "exports function '<Name>'" -ForEach ($script:ExpectedFunctions | ForEach-Object { @{ Name = $_ } }) {
        (Get-Module NetTCPIP.Linux).ExportedFunctions.Keys | Should -Contain $Name
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetIPAddress' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-NetIPAddress } | Should -Not -Throw
    }

    It 'returns objects with required properties' {
        $result = Get-NetIPAddress | Select-Object -First 1
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'IPAddress'
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
        $result.PSObject.Properties.Name | Should -Contain 'AddressFamily'
        $result.PSObject.Properties.Name | Should -Contain 'PrefixLength'
    }

    It 'returns IPv4 addresses when filtered' {
        $result = Get-NetIPAddress -AddressFamily IPv4
        $result | Should -Not -BeNullOrEmpty
        $result | ForEach-Object { $_.AddressFamily | Should -Be 'IPv4' }
    }

    It 'filters by InterfaceAlias' {
        $iface = (Get-NetIPAddress | Select-Object -First 1).InterfaceAlias
        $result = Get-NetIPAddress -InterfaceAlias $iface
        $result | Should -Not -BeNullOrEmpty
        $result | ForEach-Object { $_.InterfaceAlias | Should -Be $iface }
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetRoute' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-NetRoute } | Should -Not -Throw
    }

    It 'returns objects with required properties' {
        $result = Get-NetRoute | Select-Object -First 1
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'DestinationPrefix'
        $result.PSObject.Properties.Name | Should -Contain 'NextHop'
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
        $result.PSObject.Properties.Name | Should -Contain 'AddressFamily'
        $result.PSObject.Properties.Name | Should -Contain 'RouteMetric'
    }

    It 'returns IPv4 routes when filtered' {
        $result = Get-NetRoute -AddressFamily IPv4
        $result | Should -Not -BeNullOrEmpty
        $result | ForEach-Object { $_.AddressFamily | Should -Be 'IPv4' }
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetTCPConnection' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-NetTCPConnection } | Should -Not -Throw
    }

    It 'returns objects with required properties' {
        $result = Get-NetTCPConnection | Select-Object -First 1
        if ($result) {
            $result.PSObject.Properties.Name | Should -Contain 'LocalAddress'
            $result.PSObject.Properties.Name | Should -Contain 'LocalPort'
            $result.PSObject.Properties.Name | Should -Contain 'RemoteAddress'
            $result.PSObject.Properties.Name | Should -Contain 'RemotePort'
            $result.PSObject.Properties.Name | Should -Contain 'State'
            $result.PSObject.Properties.Name | Should -Contain 'OwningProcess'
        }
    }

    It 'can filter by State' {
        { Get-NetTCPConnection -State Listen } | Should -Not -Throw
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetIPConfiguration' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-NetIPConfiguration } | Should -Not -Throw
    }

    It 'returns objects with required properties' {
        $result = Get-NetIPConfiguration | Select-Object -First 1
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceIndex'
        $result.PSObject.Properties.Name | Should -Contain 'IPv4Address'
        $result.PSObject.Properties.Name | Should -Contain 'IPv4DefaultGateway'
    }
}

# ---------------------------------------------------------------------------
Describe 'Stub functions' -Skip:(-not $script:OnLinux) {

    It "'<Name>' is exported" -ForEach ($script:StubFunctions | ForEach-Object { @{ Name = $_ } }) {
        (Get-Module NetTCPIP.Linux).ExportedFunctions.Keys | Should -Contain $Name
    }

    It "'<Name>' does not throw" -ForEach ($script:StubFunctions | ForEach-Object { @{ Name = $_ } }) {
        { & $Name -WarningAction SilentlyContinue } | Should -Not -Throw
    }

    It "'<Name>' emits a not-implemented warning" -ForEach ($script:StubFunctions | ForEach-Object { @{ Name = $_ } }) {
        & $Name -WarningVariable w -WarningAction SilentlyContinue
        $w | Should -Not -BeNullOrEmpty
    }
}

# ---------------------------------------------------------------------------
Describe 'Find-NetRoute' -Skip:(-not $script:OnLinux) {

    It 'returns a result without error' {
        { Find-NetRoute -RemoteIPAddress '8.8.8.8' } | Should -Not -Throw
    }

    It 'returns an object with required properties' {
        $result = Find-NetRoute -RemoteIPAddress '8.8.8.8'
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'DestinationPrefix'
        $result.PSObject.Properties.Name | Should -Contain 'NextHop'
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
        $result.PSObject.Properties.Name | Should -Contain 'SourceAddress'
    }

    It 'SourceAddress is a valid IP' {
        $result = Find-NetRoute -RemoteIPAddress '8.8.8.8'
        $result.SourceAddress | Should -Match '^\d+\.\d+\.\d+\.\d+$'
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetIPInterface' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-NetIPInterface } | Should -Not -Throw
    }

    It 'returns objects with required properties' {
        $result = Get-NetIPInterface | Select-Object -First 1
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceIndex'
        $result.PSObject.Properties.Name | Should -Contain 'AddressFamily'
        $result.PSObject.Properties.Name | Should -Contain 'NlMtu'
    }

    It 'returns IPv4 and IPv6 entries for each interface' {
        $results = Get-NetIPInterface
        $results | Where-Object AddressFamily -eq 'IPv4' | Should -Not -BeNullOrEmpty
        $results | Where-Object AddressFamily -eq 'IPv6' | Should -Not -BeNullOrEmpty
    }

    It 'filters by AddressFamily IPv4' {
        $results = Get-NetIPInterface -AddressFamily IPv4
        $results | ForEach-Object { $_.AddressFamily | Should -Be 'IPv4' }
    }

    It 'filters by InterfaceAlias' {
        $alias = (Get-NetIPInterface | Select-Object -First 1).InterfaceAlias
        $results = Get-NetIPInterface -InterfaceAlias $alias
        $results | Should -Not -BeNullOrEmpty
        $results | ForEach-Object { $_.InterfaceAlias | Should -Be $alias }
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetNeighbor' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-NetNeighbor } | Should -Not -Throw
    }

    It 'returns objects with required properties' {
        $result = Get-NetNeighbor | Select-Object -First 1
        if ($result) {
            $result.PSObject.Properties.Name | Should -Contain 'IPAddress'
            $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
            $result.PSObject.Properties.Name | Should -Contain 'LinkLayerAddress'
            $result.PSObject.Properties.Name | Should -Contain 'State'
        }
    }
}

# ---------------------------------------------------------------------------
Describe 'Test-NetConnection' -Skip:(-not $script:OnLinux) {

    It 'returns a result without error' {
        { Test-NetConnection -ComputerName '8.8.8.8' } | Should -Not -Throw
    }

    It 'returns an object with required properties' {
        $result = Test-NetConnection -ComputerName '8.8.8.8'
        $result.PSObject.Properties.Name | Should -Contain 'ComputerName'
        $result.PSObject.Properties.Name | Should -Contain 'PingSucceeded'
        $result.PSObject.Properties.Name | Should -Contain 'TcpTestSucceeded'
    }

    It 'ping succeeds for 8.8.8.8' {
        $result = Test-NetConnection -ComputerName '8.8.8.8'
        $result.PingSucceeded | Should -Be $true
    }

    It 'TCP port test succeeds for 8.8.8.8:443' {
        $result = Test-NetConnection -ComputerName '8.8.8.8' -Port 443
        $result.TcpTestSucceeded | Should -Be $true
    }

    It 'returns boolean true with -InformationLevel Quiet and ping succeeds' {
        $result = Test-NetConnection -ComputerName '8.8.8.8' -InformationLevel Quiet
        $result | Should -Be $true
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetIPv4Protocol' -Skip:(-not $script:OnLinux) {

    It 'returns a result without error' {
        { Get-NetIPv4Protocol } | Should -Not -Throw
    }

    It 'returns an object with required properties' {
        $result = Get-NetIPv4Protocol
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'DefaultHopLimit'
        $result.PSObject.Properties.Name | Should -Contain 'Forwarding'
    }

    It 'Forwarding is Enabled or Disabled' {
        $result = Get-NetIPv4Protocol
        $result.Forwarding | Should -BeIn @('Enabled', 'Disabled')
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-NetIPv6Protocol' -Skip:(-not $script:OnLinux) {

    It 'returns a result without error' {
        { Get-NetIPv6Protocol } | Should -Not -Throw
    }

    It 'returns an object with required properties' {
        $result = Get-NetIPv6Protocol
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'DefaultHopLimit'
        $result.PSObject.Properties.Name | Should -Contain 'Forwarding'
        $result.PSObject.Properties.Name | Should -Contain 'Disabled'
    }

    It 'Forwarding is Enabled or Disabled' {
        $result = Get-NetIPv6Protocol
        $result.Forwarding | Should -BeIn @('Enabled', 'Disabled')
    }
}
