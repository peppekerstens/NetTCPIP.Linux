#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }
<#
.Synopsis
    Pester tests for NetTCPIP.Linux example scripts.
.Description
    Validates that each example script in the Examples\ folder:
      - exists on disk
      - has no syntax errors (parses cleanly)
    Linux-only execution tests are guarded with -Skip:(-not $IsLinux).
    All tests run on Windows (syntax/structure checks); live execution
    tests are skipped on Windows.
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Run with: Invoke-Pester .\Examples.Tests.ps1 -Output Detailed
#>

BeforeDiscovery {
    $script:ExamplesDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $PSCommandPath -Parent }
    $script:ExampleFiles = @(
        'Get-NetworkSummary.ps1'
        'Get-OpenPorts.ps1'
        'Get-ActiveConnections.ps1'
        'Get-RoutingTable.ps1'
        'Find-PortOwner.ps1'
    )
}

BeforeAll {
    $script:ExamplesDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $PSCommandPath -Parent }
    if ($IsLinux) {
        $modulePath = Join-Path (Split-Path $script:ExamplesDir -Parent) 'NetTCPIP.Linux' 'NetTCPIP.Linux.psd1'
        if (Test-Path $modulePath) {
            Import-Module $modulePath -Force -ErrorAction Stop
        }
    }
}

Describe 'Example script files exist' {
    It 'Examples directory contains <_>' -ForEach $script:ExampleFiles {
        Join-Path $script:ExamplesDir $_ | Should -Exist
    }
}

Describe 'Example scripts have no syntax errors' {
    It '<_> parses without errors' -ForEach $script:ExampleFiles {
        $filePath = Join-Path $script:ExamplesDir $_
        $errors   = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$null, [ref]$errors)
        $errors | Should -BeNullOrEmpty
    }
}

# ---------------------------------------------------------------------------
# Get-NetworkSummary
# ---------------------------------------------------------------------------

Describe 'Get-NetworkSummary' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-NetworkSummary.ps1' | Should -Exist
    }

    It 'Get-NetIPConfiguration returns at least one interface' -Skip:(-not $IsLinux) {
        $result = Get-NetIPConfiguration
        $result | Should -Not -BeNullOrEmpty
    }

    It 'Get-NetIPConfiguration objects have InterfaceAlias and InterfaceIndex' -Skip:(-not $IsLinux) {
        $result = Get-NetIPConfiguration | Select-Object -First 1
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
        $result.PSObject.Properties.Name | Should -Contain 'InterfaceIndex'
    }

    It 'Get-NetIPAddress returns at least one address' -Skip:(-not $IsLinux) {
        $result = Get-NetIPAddress
        $result | Should -Not -BeNullOrEmpty
    }

    It 'Get-NetIPAddress objects have IPAddress, AddressFamily, PrefixLength' -Skip:(-not $IsLinux) {
        $result = Get-NetIPAddress | Select-Object -First 1
        $result.PSObject.Properties.Name | Should -Contain 'IPAddress'
        $result.PSObject.Properties.Name | Should -Contain 'AddressFamily'
        $result.PSObject.Properties.Name | Should -Contain 'PrefixLength'
    }
}

# ---------------------------------------------------------------------------
# Get-OpenPorts
# ---------------------------------------------------------------------------

Describe 'Get-OpenPorts' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-OpenPorts.ps1' | Should -Exist
    }

    It 'Get-NetTCPConnection -State Listen returns at least one listening port' -Skip:(-not $IsLinux) {
        $result = Get-NetTCPConnection -State Listen
        $result | Should -Not -BeNullOrEmpty
    }

    It 'all results from -State Listen have State = Listen' -Skip:(-not $IsLinux) {
        Get-NetTCPConnection -State Listen | ForEach-Object {
            $_.State | Should -Be 'Listen'
        }
    }

    It 'listening ports have LocalPort greater than 0' -Skip:(-not $IsLinux) {
        Get-NetTCPConnection -State Listen | ForEach-Object {
            $_.LocalPort | Should -BeGreaterThan 0
        }
    }
}

# ---------------------------------------------------------------------------
# Get-ActiveConnections
# ---------------------------------------------------------------------------

Describe 'Get-ActiveConnections' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-ActiveConnections.ps1' | Should -Exist
    }

    It 'Get-NetTCPConnection returns objects with required properties' -Skip:(-not $IsLinux) {
        $result = Get-NetTCPConnection | Select-Object -First 1
        $result | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'LocalAddress'
        $result.PSObject.Properties.Name | Should -Contain 'LocalPort'
        $result.PSObject.Properties.Name | Should -Contain 'RemoteAddress'
        $result.PSObject.Properties.Name | Should -Contain 'RemotePort'
        $result.PSObject.Properties.Name | Should -Contain 'State'
        $result.PSObject.Properties.Name | Should -Contain 'OwningProcess'
    }

    It 'Established connections have non-empty RemoteAddress' -Skip:(-not $IsLinux) {
        Get-NetTCPConnection -State Established | ForEach-Object {
            $_.RemoteAddress | Should -Not -BeNullOrEmpty
        }
    }
}

# ---------------------------------------------------------------------------
# Get-RoutingTable
# ---------------------------------------------------------------------------

Describe 'Get-RoutingTable' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-RoutingTable.ps1' | Should -Exist
    }

    It 'Get-NetRoute returns at least one IPv4 route' -Skip:(-not $IsLinux) {
        $result = Get-NetRoute -AddressFamily IPv4
        $result | Should -Not -BeNullOrEmpty
    }

    It 'IPv4 routes have DestinationPrefix containing a slash' -Skip:(-not $IsLinux) {
        Get-NetRoute -AddressFamily IPv4 | ForEach-Object {
            $_.DestinationPrefix | Should -Match '/'
        }
    }

    It 'Get-NetRoute objects have required properties' -Skip:(-not $IsLinux) {
        $route = Get-NetRoute | Select-Object -First 1
        $route.PSObject.Properties.Name | Should -Contain 'DestinationPrefix'
        $route.PSObject.Properties.Name | Should -Contain 'NextHop'
        $route.PSObject.Properties.Name | Should -Contain 'InterfaceAlias'
        $route.PSObject.Properties.Name | Should -Contain 'RouteMetric'
    }
}

# ---------------------------------------------------------------------------
# Find-PortOwner
# ---------------------------------------------------------------------------

Describe 'Find-PortOwner' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Find-PortOwner.ps1' | Should -Exist
    }

    It 'Get-NetTCPConnection -LocalPort filter returns only matching ports' -Skip:(-not $IsLinux) {
        # Find any port that is listening and verify the filter works
        $anyPort = (Get-NetTCPConnection -State Listen | Select-Object -First 1).LocalPort
        if ($anyPort) {
            $result = Get-NetTCPConnection -State Listen -LocalPort $anyPort
            $result | ForEach-Object { $_.LocalPort | Should -Be $anyPort }
        }
    }

    It 'querying a port nobody listens on returns empty result' -Skip:(-not $IsLinux) {
        # Port 65534 is virtually never in use; using 0 would be falsy and skip the filter
        $result = Get-NetTCPConnection -State Listen -LocalPort 65534
        $result | Should -BeNullOrEmpty
    }
}

Describe 'Scenario: Network interface audit' -Skip:(-not $IsLinux) {
    BeforeAll {
        $modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'NetTCPIP.Linux' 'NetTCPIP.Linux.psd1'
        Import-Module $modulePath -Force -ErrorAction Stop
    }
    AfterAll {
        Remove-Module 'NetTCPIP.Linux' -Force -ErrorAction SilentlyContinue
    }

    It 'Get-NetIPAddress returns at least the loopback address' {
        $addrs = Get-NetIPAddress
        $addrs | Should -Not -BeNullOrEmpty
        $addrs.IPAddress | Should -Contain '127.0.0.1'
    }
    It 'Get-NetRoute returns at least one route' {
        $routes = Get-NetRoute
        $routes | Should -Not -BeNullOrEmpty
    }
    It 'Find-NetRoute returns a route object for loopback' {
        $route = Find-NetRoute -RemoteIPAddress '127.0.0.1'
        $route | Should -Not -BeNullOrEmpty
    }
    It 'Get-NetIPInterface returns interfaces with InterfaceIndex' {
        $ifaces = Get-NetIPInterface
        $ifaces | Should -Not -BeNullOrEmpty
        $ifaces[0].PSObject.Properties.Name | Should -Contain 'InterfaceIndex'
    }
    It 'Get-NetNeighbor returns results or empty array (no error)' {
        { Get-NetNeighbor } | Should -Not -Throw
    }
    It 'Test-NetConnection to loopback succeeds' {
        $result = Test-NetConnection -ComputerName '127.0.0.1'
        $result.PingSucceeded | Should -Be $true
    }
    It 'Get-NetIPv4Protocol returns sysctl network settings' {
        $proto = Get-NetIPv4Protocol
        $proto | Should -Not -BeNullOrEmpty
    }
}
