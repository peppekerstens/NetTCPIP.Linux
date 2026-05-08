#
# Module manifest for module 'NetTCPIP.Linux'
#

@{
    RootModule        = 'NetTCPIP.Linux.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Peppe Kerstens'
    CompanyName       = ''
    Copyright         = '(c) Peppe Kerstens. GPL-3.0 license.'
    Description       = 'PowerShell module for Linux providing cmdlet parity with NetTCPIP. Implements Get-NetIPAddress, Get-NetRoute, Get-NetTCPConnection, Get-NetIPConfiguration using ip and ss.'
    PowerShellVersion = '7.2'
    RequiredModules   = @()

    FunctionsToExport = @(
        # Fully implemented
        'Get-NetIPAddress',
        'Get-NetIPConfiguration',
        'Get-NetRoute',
        'Get-NetTCPConnection',
        # Stubs
        'Find-NetRoute',
        'Get-NetCompartment',
        'Get-NetIPInterface',
        'Get-NetIPv4Protocol',
        'Get-NetIPv6Protocol',
        'Get-NetNeighbor',
        'Get-NetOffloadGlobalSetting',
        'Get-NetPrefixPolicy',
        'Get-NetTCPSetting',
        'Get-NetTransportFilter',
        'Get-NetUDPEndpoint',
        'Get-NetUDPSetting',
        'New-NetIPAddress',
        'New-NetNeighbor',
        'New-NetRoute',
        'New-NetTransportFilter',
        'Remove-NetIPAddress',
        'Remove-NetNeighbor',
        'Remove-NetRoute',
        'Remove-NetTransportFilter',
        'Set-NetIPAddress',
        'Set-NetIPInterface',
        'Set-NetIPv4Protocol',
        'Set-NetIPv6Protocol',
        'Set-NetNeighbor',
        'Set-NetOffloadGlobalSetting',
        'Set-NetRoute',
        'Set-NetTCPSetting',
        'Set-NetUDPSetting',
        'Test-NetConnection'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Linux', 'Network', 'NetTCPIP', 'ip', 'ss', 'CrossPlatform')
            LicenseUri   = 'https://github.com/peppekerstens/NetTCPIP.Linux/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/peppekerstens/NetTCPIP.Linux'
            ReleaseNotes = @'
0.1.0 - Initial release. Get-NetIPAddress, Get-NetIPConfiguration, Get-NetRoute, Get-NetTCPConnection implemented. Stubs for remaining 30 cmdlets.
'@
        }
    }
}
