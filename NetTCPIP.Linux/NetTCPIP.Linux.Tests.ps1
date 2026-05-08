#Requires -Modules Pester

<#
.SYNOPSIS
    Pester tests for NetTCPIP.Linux module.
.DESCRIPTION
    Tests module surface (function count, aliases) and implemented cmdlet behavior on Linux.
    Linux-only contexts are skipped when running on Windows.
#>

BeforeAll {
    $ModulePath = Join-Path $PSScriptRoot 'NetTCPIP.Linux.psd1'
    Import-Module $ModulePath -Force
}

AfterAll {
    Remove-Module NetTCPIP.Linux -ErrorAction SilentlyContinue
}

Describe 'NetTCPIP.Linux module surface' {
    It 'exports exactly 34 functions' {
        (Get-Module NetTCPIP.Linux).ExportedFunctions.Count | Should -Be 34
    }

    It 'exports 0 aliases' {
        (Get-Module NetTCPIP.Linux).ExportedAliases.Count | Should -Be 0
    }

    $expectedFunctions = @(
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

    foreach ($fn in $expectedFunctions) {
        It "exports function '$fn'" {
            (Get-Module NetTCPIP.Linux).ExportedFunctions.Keys | Should -Contain $fn
        }
    }
}

Describe 'Get-NetIPAddress' -Skip:(-not $IsLinux) {
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

    It 'returns IPv4 addresses' {
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

Describe 'Get-NetRoute' -Skip:(-not $IsLinux) {
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

Describe 'Get-NetTCPConnection' -Skip:(-not $IsLinux) {
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

Describe 'Get-NetIPConfiguration' -Skip:(-not $IsLinux) {
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

Describe 'Stub functions' {
    $stubs = @(
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

    foreach ($fn in $stubs) {
        It "'$fn' is exported" {
            (Get-Module NetTCPIP.Linux).ExportedFunctions.Keys | Should -Contain $fn
        }

        if ($IsLinux) {
            It "'$fn' does not throw on Linux" {
                { & $fn } | Should -Not -Throw
            }

            It "'$fn' emits a warning on Linux" {
                $warnings = & { & $fn } 3>&1 | Where-Object { $_ -is [System.Management.Automation.WarningRecord] }
                $warnings | Should -Not -BeNullOrEmpty
            }
        }
    }
}
