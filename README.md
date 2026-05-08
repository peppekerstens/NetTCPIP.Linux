# NetTCPIP.Linux

PowerShell 7.x module providing cmdlet parity with the Windows `NetTCPIP` module on Linux. Wraps native Linux networking tools (`ip`, `ss`) to deliver a familiar PowerShell experience for IP address, routing and TCP connection management.

Part of the **Linux PowerShell Cmdlet Parity** project — inspired by Evgenij Smirnov's [2025 European PowerShell Summit session](https://www.youtube.com/watch?v=RlzinWYIjBY) and documented in the blog series at [peppekerstens.github.io](https://peppekerstens.github.io/linux-command-wrapping-part-1/).

---

## What it does

On **Linux**, wraps `ip` and `ss` to provide PowerShell cmdlets matching the Windows `NetTCPIP` module API as closely as possible. All 34 cmdlets that the Windows module exports are present — 4 are fully implemented, the remaining 30 are stubs that emit a warning on Linux.

On **Windows**, every function delegates transparently to the built-in `NetTCPIP` cmdlet — no behavioral change.

---

## Requirements

- PowerShell 7.2+
- Linux with `iproute2` (`ip`, `ss`) — installed by default on Ubuntu 24.04

---

## Installation

```powershell
# Clone or copy the module folder to a PSModulePath location, then:
Import-Module NetTCPIP.Linux
```

---

## Usage

```powershell
# List all IP addresses
Get-NetIPAddress

# IPv4 addresses only on a specific interface
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias eth0

# Show the routing table
Get-NetRoute

# IPv4 routes only
Get-NetRoute -AddressFamily IPv4

# List established TCP connections
Get-NetTCPConnection -State Established

# Show all listening ports
Get-NetTCPConnection -State Listen

# Network configuration summary per interface
Get-NetIPConfiguration
```

---

## Cmdlet Status

Legend: ✅ Implemented &nbsp;|&nbsp; ⚠️ Stub

| Cmdlet | Status | Linux tool | Notes |
|---|:---:|---|---|
| `Get-NetIPAddress` | ✅ | `ip -json addr show` | IPAddress, InterfaceAlias, InterfaceIndex, AddressFamily, PrefixLength, ValidLifetime, PreferredLifetime; `-IPAddress`, `-InterfaceAlias`, `-InterfaceIndex`, `-AddressFamily` filters |
| `Get-NetIPConfiguration` | ✅ | `ip -json addr` + `ip -json route` | Per-interface summary: IPv4Address, IPv4DefaultGateway, IPv6Address; loopback excluded by default (`-All` to include) |
| `Get-NetRoute` | ✅ | `ip -json route show` (IPv4 + IPv6) | DestinationPrefix, NextHop, InterfaceAlias, AddressFamily, RouteMetric, TypeOfNextHop; `default` mapped to `0.0.0.0/0` / `::/0` |
| `Get-NetTCPConnection` | ✅ | `ss -tnap` | LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess; ss state names mapped to Windows names; `-State`, `-LocalPort`, `-RemotePort`, `-OwningProcess` filters |
| `Find-NetRoute` | ⚠️ | Stub | |
| `Get-NetCompartment` | ⚠️ | Stub | |
| `Get-NetIPInterface` | ⚠️ | Stub | Future: `ip link` |
| `Get-NetIPv4Protocol` | ⚠️ | Stub | |
| `Get-NetIPv6Protocol` | ⚠️ | Stub | |
| `Get-NetNeighbor` | ⚠️ | Stub | Future: `ip neigh` |
| `Get-NetOffloadGlobalSetting` | ⚠️ | Stub | |
| `Get-NetPrefixPolicy` | ⚠️ | Stub | |
| `Get-NetTCPSetting` | ⚠️ | Stub | |
| `Get-NetTransportFilter` | ⚠️ | Stub | |
| `Get-NetUDPEndpoint` | ⚠️ | Stub | Future: `ss -unap` |
| `Get-NetUDPSetting` | ⚠️ | Stub | |
| `New-NetIPAddress` | ⚠️ | Stub | Future: `ip addr add` |
| `New-NetNeighbor` | ⚠️ | Stub | Future: `ip neigh add` |
| `New-NetRoute` | ⚠️ | Stub | Future: `ip route add` |
| `New-NetTransportFilter` | ⚠️ | Stub | |
| `Remove-NetIPAddress` | ⚠️ | Stub | Future: `ip addr del` |
| `Remove-NetNeighbor` | ⚠️ | Stub | Future: `ip neigh del` |
| `Remove-NetRoute` | ⚠️ | Stub | Future: `ip route del` |
| `Remove-NetTransportFilter` | ⚠️ | Stub | |
| `Set-NetIPAddress` | ⚠️ | Stub | |
| `Set-NetIPInterface` | ⚠️ | Stub | |
| `Set-NetIPv4Protocol` | ⚠️ | Stub | |
| `Set-NetIPv6Protocol` | ⚠️ | Stub | |
| `Set-NetNeighbor` | ⚠️ | Stub | |
| `Set-NetOffloadGlobalSetting` | ⚠️ | Stub | |
| `Set-NetRoute` | ⚠️ | Stub | |
| `Set-NetTCPSetting` | ⚠️ | Stub | |
| `Set-NetUDPSetting` | ⚠️ | Stub | |
| `Test-NetConnection` | ⚠️ | Stub | Future: `ping` / `nc` |

---

## Implementation notes

- `ip -json addr show` and `ip -json route show` are used for structured output — no text parsing required.
- `Get-NetRoute` calls `ip -json route show` for IPv4 and `ip -6 -json route show` for IPv6; both sets are merged into a single result stream.
- `Get-NetTCPConnection` parses `ss -tnap` text output (ss does not support `--json` in all versions). State names are mapped from ss convention (e.g. `ESTAB` → `Established`, `TIME-WAIT` → `TimeWait`).
- `Get-NetIPConfiguration` excludes the loopback interface by default; pass `-All` to include it.

---

## Version history

| Version | Notes |
|---|---|
| 0.1.0 | Initial release. `Get-NetIPAddress`, `Get-NetIPConfiguration`, `Get-NetRoute`, `Get-NetTCPConnection` implemented. 30 stubs for remaining cmdlets. |

---

## License

GPL-3.0 — see [LICENSE](LICENSE).
