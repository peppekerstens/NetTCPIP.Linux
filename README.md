# NetTCPIP.Linux

PowerShell module providing cmdlet parity with the Windows `NetTCPIP` module on Linux. Wraps native Linux networking tools (`ip`, `ss`) to deliver a familiar PowerShell experience.

## Status

| Cmdlet | Status | Linux tool |
|---|---|---|
| `Get-NetIPAddress` | ✅ Implemented | `ip addr` |
| `Get-NetIPConfiguration` | ✅ Implemented | `ip addr` + `ip route` |
| `Get-NetRoute` | ✅ Implemented | `ip route` |
| `Get-NetTCPConnection` | ✅ Implemented | `ss -tnap` |
| `Find-NetRoute` | ⚠️ Stub | — |
| `Get-NetCompartment` | ⚠️ Stub | — |
| `Get-NetIPInterface` | ⚠️ Stub | — |
| `Get-NetIPv4Protocol` | ⚠️ Stub | — |
| `Get-NetIPv6Protocol` | ⚠️ Stub | — |
| `Get-NetNeighbor` | ⚠️ Stub | `ip neigh` (future) |
| `Get-NetOffloadGlobalSetting` | ⚠️ Stub | — |
| `Get-NetPrefixPolicy` | ⚠️ Stub | — |
| `Get-NetTCPSetting` | ⚠️ Stub | — |
| `Get-NetTransportFilter` | ⚠️ Stub | — |
| `Get-NetUDPEndpoint` | ⚠️ Stub | `ss -unap` (future) |
| `Get-NetUDPSetting` | ⚠️ Stub | — |
| `New-NetIPAddress` | ⚠️ Stub | `ip addr add` (future) |
| `New-NetNeighbor` | ⚠️ Stub | `ip neigh add` (future) |
| `New-NetRoute` | ⚠️ Stub | `ip route add` (future) |
| `New-NetTransportFilter` | ⚠️ Stub | — |
| `Remove-NetIPAddress` | ⚠️ Stub | `ip addr del` (future) |
| `Remove-NetNeighbor` | ⚠️ Stub | `ip neigh del` (future) |
| `Remove-NetRoute` | ⚠️ Stub | `ip route del` (future) |
| `Remove-NetTransportFilter` | ⚠️ Stub | — |
| `Set-NetIPAddress` | ⚠️ Stub | — |
| `Set-NetIPInterface` | ⚠️ Stub | — |
| `Set-NetIPv4Protocol` | ⚠️ Stub | — |
| `Set-NetIPv6Protocol` | ⚠️ Stub | — |
| `Set-NetNeighbor` | ⚠️ Stub | — |
| `Set-NetOffloadGlobalSetting` | ⚠️ Stub | — |
| `Set-NetRoute` | ⚠️ Stub | — |
| `Set-NetTCPSetting` | ⚠️ Stub | — |
| `Set-NetUDPSetting` | ⚠️ Stub | — |
| `Test-NetConnection` | ⚠️ Stub | `ping` / `nc` (future) |

Legend: ✅ Implemented | ⚠️ Stub (warns on Linux, delegates on Windows) | ➖ Not applicable

## Requirements

- PowerShell 7.2+
- Linux with `iproute2` (`ip`) and `iproute2` (`ss`) — standard on Ubuntu 24.04

## Usage

```powershell
Import-Module ./NetTCPIP.Linux/NetTCPIP.Linux.psd1

# List all IP addresses
Get-NetIPAddress

# List only IPv4 addresses on eth0
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias eth0

# List all routes
Get-NetRoute

# List established TCP connections
Get-NetTCPConnection -State Established

# Get network configuration summary
Get-NetIPConfiguration
```

## Version History

| Version | Notes |
|---|---|
| 0.1.0 | Initial release. 4 implemented cmdlets, 30 stubs. |
