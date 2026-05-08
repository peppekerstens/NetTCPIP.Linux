#
# Module manifest for module 'NetTCPIP.Linux'
#

@{
    RootModule        = 'NetTCPIP.Linux.psm1'
    ModuleVersion     = '0.3.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Peppe Kerstens'
    CompanyName       = ''
    Copyright         = '(c) Peppe Kerstens. GPL-3.0 license.'
    Description       = 'PowerShell module for Linux providing cmdlet parity with the Windows NetTCPIP and DnsClient modules. Implements Get-NetIPAddress, Get-NetRoute, Get-NetTCPConnection, Get-NetIPConfiguration, Resolve-DnsName, Clear-DnsClientCache, Get-DnsClientServerAddress, Get-DnsClientGlobalSetting using ip, ss, and dig/resolvectl.'
    PowerShellVersion = '7.2'
    RequiredModules   = @()

    FunctionsToExport = @(
        # Fully implemented — NetTCPIP
        'Get-NetIPAddress',
        'Get-NetIPConfiguration',
        'Get-NetRoute',
        'Get-NetTCPConnection',
        # Fully implemented — DnsClient
        'Resolve-DnsName',
        'Clear-DnsClientCache',
        'Get-DnsClientServerAddress',
        'Get-DnsClientGlobalSetting',
        # Stubs — NetTCPIP
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
        'Test-NetConnection',
        # Stubs — DnsClient
        'Add-DnsClientDohServerAddress',
        'Add-DnsClientNrptRule',
        'Get-DnsClient',
        'Get-DnsClientCache',
        'Get-DnsClientDohServerAddress',
        'Get-DnsClientNrptGlobal',
        'Get-DnsClientNrptPolicy',
        'Get-DnsClientNrptRule',
        'Register-DnsClient',
        'Remove-DnsClientDohServerAddress',
        'Remove-DnsClientNrptRule',
        'Set-DnsClient',
        'Set-DnsClientDohServerAddress',
        'Set-DnsClientGlobalSetting',
        'Set-DnsClientNrptGlobal',
        'Set-DnsClientNrptRule',
        'Set-DnsClientServerAddress'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Linux', 'Network', 'NetTCPIP', 'DnsClient', 'DNS', 'ip', 'ss', 'dig', 'resolvectl', 'CrossPlatform')
            LicenseUri   = 'https://github.com/peppekerstens/NetTCPIP.Linux/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/peppekerstens/NetTCPIP.Linux'
            ReleaseNotes = @'
0.3.0 - DnsClient module cmdlets merged in. Resolve-DnsName (dig), Clear-DnsClientCache (resolvectl flush-caches), Get-DnsClientServerAddress (/etc/resolv.conf + resolvectl), Get-DnsClientGlobalSetting (search domains) implemented. 17 DnsClient stubs added (NRPT, DoH, Register-DnsClient, Set-* cmdlets).
0.2.0 - Linux-only guard. #Requires -Version 7.2. Pester 5.2+ test rewrite.
0.1.0 - Initial release. Get-NetIPAddress, Get-NetIPConfiguration, Get-NetRoute, Get-NetTCPConnection implemented. Stubs for remaining 30 cmdlets.
'@
        }
    }
}
