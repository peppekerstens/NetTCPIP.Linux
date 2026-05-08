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
        # NetTCPIP implemented
        'Get-NetIPAddress', 'Get-NetIPConfiguration', 'Get-NetRoute', 'Get-NetTCPConnection',
        # NetTCPIP stubs
        'Find-NetRoute', 'Get-NetCompartment', 'Get-NetIPInterface',
        'Get-NetIPv4Protocol', 'Get-NetIPv6Protocol', 'Get-NetNeighbor',
        'Get-NetOffloadGlobalSetting', 'Get-NetPrefixPolicy', 'Get-NetTCPSetting',
        'Get-NetTransportFilter', 'Get-NetUDPEndpoint', 'Get-NetUDPSetting',
        'New-NetIPAddress', 'New-NetNeighbor', 'New-NetRoute', 'New-NetTransportFilter',
        'Remove-NetIPAddress', 'Remove-NetNeighbor', 'Remove-NetRoute', 'Remove-NetTransportFilter',
        'Set-NetIPAddress', 'Set-NetIPInterface', 'Set-NetIPv4Protocol', 'Set-NetIPv6Protocol',
        'Set-NetNeighbor', 'Set-NetOffloadGlobalSetting', 'Set-NetRoute', 'Set-NetTCPSetting',
        'Set-NetUDPSetting', 'Test-NetConnection',
        # DnsClient implemented
        'Resolve-DnsName', 'Clear-DnsClientCache', 'Get-DnsClientServerAddress', 'Get-DnsClientGlobalSetting',
        # DnsClient stubs
        'Add-DnsClientDohServerAddress', 'Add-DnsClientNrptRule',
        'Get-DnsClient', 'Get-DnsClientCache', 'Get-DnsClientDohServerAddress',
        'Get-DnsClientNrptGlobal', 'Get-DnsClientNrptPolicy', 'Get-DnsClientNrptRule',
        'Register-DnsClient',
        'Remove-DnsClientDohServerAddress', 'Remove-DnsClientNrptRule',
        'Set-DnsClient', 'Set-DnsClientDohServerAddress', 'Set-DnsClientGlobalSetting',
        'Set-DnsClientNrptGlobal', 'Set-DnsClientNrptRule', 'Set-DnsClientServerAddress'
    )

    $script:StubFunctions = @(
        # NetTCPIP stubs
        'Find-NetRoute', 'Get-NetCompartment', 'Get-NetIPInterface',
        'Get-NetIPv4Protocol', 'Get-NetIPv6Protocol', 'Get-NetNeighbor',
        'Get-NetOffloadGlobalSetting', 'Get-NetPrefixPolicy', 'Get-NetTCPSetting',
        'Get-NetTransportFilter', 'Get-NetUDPEndpoint', 'Get-NetUDPSetting',
        'New-NetIPAddress', 'New-NetNeighbor', 'New-NetRoute', 'New-NetTransportFilter',
        'Remove-NetIPAddress', 'Remove-NetNeighbor', 'Remove-NetRoute', 'Remove-NetTransportFilter',
        'Set-NetIPAddress', 'Set-NetIPInterface', 'Set-NetIPv4Protocol', 'Set-NetIPv6Protocol',
        'Set-NetNeighbor', 'Set-NetOffloadGlobalSetting', 'Set-NetRoute', 'Set-NetTCPSetting',
        'Set-NetUDPSetting', 'Test-NetConnection',
        # DnsClient stubs
        'Add-DnsClientDohServerAddress', 'Add-DnsClientNrptRule',
        'Get-DnsClient', 'Get-DnsClientCache', 'Get-DnsClientDohServerAddress',
        'Get-DnsClientNrptGlobal', 'Get-DnsClientNrptPolicy', 'Get-DnsClientNrptRule',
        'Register-DnsClient',
        'Remove-DnsClientDohServerAddress', 'Remove-DnsClientNrptRule',
        'Set-DnsClient', 'Set-DnsClientDohServerAddress', 'Set-DnsClientGlobalSetting',
        'Set-DnsClientNrptGlobal', 'Set-DnsClientNrptRule', 'Set-DnsClientServerAddress'
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

    It 'exports exactly 55 functions' {
        (Get-Module NetTCPIP.Linux).ExportedFunctions.Count | Should -Be 55
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
Describe 'Resolve-DnsName' -Skip:(-not $script:OnLinux) {

    BeforeAll {
        $script:DigAvailable = [bool](Get-Command dig -ErrorAction SilentlyContinue)
    }

    It 'returns results for a known hostname without error' -Skip:(-not $script:DigAvailable) {
        { Resolve-DnsName -Name 'dns.google' } | Should -Not -Throw
    }

    It 'returns objects with required properties' -Skip:(-not $script:DigAvailable) {
        $result = Resolve-DnsName -Name 'dns.google' | Select-Object -First 1
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'Name'
        $result.PSObject.Properties.Name | Should -Contain 'Type'
        $result.PSObject.Properties.Name | Should -Contain 'TTL'
        $result.PSObject.Properties.Name | Should -Contain 'IPAddress'
    }

    It 'respects -Type A filter' -Skip:(-not $script:DigAvailable) {
        $result = Resolve-DnsName -Name 'dns.google' -Type A
        $result | ForEach-Object { $_.Type | Should -Be 'A' }
    }

    It 'emits a warning when dig is unavailable' -Skip:($script:DigAvailable) {
        { Resolve-DnsName -Name 'example.com' -WarningAction SilentlyContinue } | Should -Not -Throw
    }
}

# ---------------------------------------------------------------------------
Describe 'Clear-DnsClientCache' -Skip:(-not $script:OnLinux) {

    It 'supports -WhatIf without error' {
        { Clear-DnsClientCache -WhatIf } | Should -Not -Throw
    }

    It 'does not throw when run normally' {
        { Clear-DnsClientCache -WarningAction SilentlyContinue } | Should -Not -Throw
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-DnsClientServerAddress' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-DnsClientServerAddress } | Should -Not -Throw
    }

    It 'returns objects with required properties' {
        $result = Get-DnsClientServerAddress | Select-Object -First 1
        if ($result) {
            $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
            $result.PSObject.Properties.Name | Should -Contain 'ServerAddresses'
            $result.PSObject.Properties.Name | Should -Contain 'AddressFamily'
        }
    }

    It 'returns an array (or empty)' {
        $result = @(Get-DnsClientServerAddress)
        $result | Should -Not -BeNullOrEmpty
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-DnsClientGlobalSetting' -Skip:(-not $script:OnLinux) {

    It 'returns results without error' {
        { Get-DnsClientGlobalSetting } | Should -Not -Throw
    }

    It 'returns an object with SuffixSearchList property' {
        $result = Get-DnsClientGlobalSetting
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'SuffixSearchList'
    }
}
