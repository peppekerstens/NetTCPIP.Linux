# NetTCPIP.Linux

PowerShell 7.x module providing cmdlet parity with the Windows `NetTCPIP` module on Linux. Wraps native Linux networking tools (`ip`, `ss`) to deliver a familiar PowerShell experience for IP address, routing, and TCP connection management.

For DNS cmdlets (`Resolve-DnsName`, `Clear-DnsClientCache`, etc.), see the companion module **[DnsClient.Linux](https://github.com/peppekerstens/DnsClient.Linux)**.

Part of the **Linux PowerShell Cmdlet Parity** project — inspired by Evgenij Smirnov's [2025 European PowerShell Summit session](https://www.youtube.com/watch?v=RlzinWYIjBY) and documented in the blog series at [peppekerstens.github.io](https://peppekerstens.github.io/linux-command-wrapping-part-1/).

---

## What it does

On **Linux**, wraps `ip` and `ss` to provide PowerShell cmdlets matching the Windows `NetTCPIP` module API as closely as possible. All 34 cmdlets that the Windows module exports are present — 4 are fully implemented, the remaining 30 are stubs that emit a warning on Linux.

On **Windows**, the module refuses to load — use the built-in `NetTCPIP` module.

---

## Requirements

- PowerShell 7.2+
- **Linux only** — the module refuses to load on Windows (throws a descriptive error)
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
| `Get-NetIPAddress` | ✅ | `ip -json addr show` | IPAddress, InterfaceAlias, InterfaceIndex, AddressFamily, PrefixLength; `-IPAddress`, `-InterfaceAlias`, `-InterfaceIndex`, `-AddressFamily` filters |
| `Get-NetIPConfiguration` | ✅ | `ip -json addr` + `ip -json route` | Per-interface summary: IPv4Address, IPv4DefaultGateway, IPv6Address; loopback excluded by default (`-All` to include) |
| `Get-NetRoute` | ✅ | `ip -json route show` (IPv4 + IPv6) | DestinationPrefix, NextHop, InterfaceAlias, AddressFamily, RouteMetric; `default` mapped to `0.0.0.0/0` / `::/0` |
| `Get-NetTCPConnection` | ✅ | `ss -tnap` | LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess; ss state names mapped to Windows names; `-State`, `-LocalPort`, `-RemotePort`, `-OwningProcess` filters |
| `Find-NetRoute` | ⚠️ | Stub | Future: `ip route get` |
| `Get-NetCompartment` | ⚠️ | Stub | |
| `Get-NetIPInterface` | ⚠️ | Stub | Future: `ip link` |
| `Get-NetIPv4Protocol` | ⚠️ | Stub | Future: `sysctl` |
| `Get-NetIPv6Protocol` | ⚠️ | Stub | Future: `sysctl` |
| `Get-NetNeighbor` | ⚠️ | Stub | Future: `ip neigh` |
| `Get-NetOffloadGlobalSetting` | ⚠️ | Stub | |
| `Get-NetPrefixPolicy` | ⚠️ | Stub | |
| `Get-NetTCPSetting` | ⚠️ | Stub | Future: `sysctl net.ipv4.tcp_*` |
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

## How we built this

### Why this module exists

The Windows `NetTCPIP` module is the go-to for IP address inspection, routing, and TCP connection enumeration in PowerShell scripts. None of it works on Linux. `ip` and `ss` exist, but their output is raw text (or JSON in newer iproute2 versions) that you have to parse manually every time. The goal was to make `Get-NetIPAddress` and friends Just Work on Linux so cross-platform scripts don't need platform branches.

### Tool choices

**`ip -json`** was the obvious choice for address and routing data. The `-json` flag has been in iproute2 since version 4.12 (2017). It gives clean structured output — no text parsing, no regex. `Get-NetIPAddress`, `Get-NetRoute`, and `Get-NetIPConfiguration` all use this.

**`ss`** is the modern replacement for `netstat`. `ss --json` isn't universally available across distributions, so `Get-NetTCPConnection` parses `ss -tnap` text output, which is consistently available.

### Key gotchas

**LISTEN sockets have a wildcard remote address.** When `ss` reports a listening socket, the remote address column is `0.0.0.0:*` or `[::]:*`. The `*` is not a valid port number. Detect the wildcard pattern and return `0` for the port.

**Loop variable shadowing.** A pipeline loop used `$localPort` as the loop variable — same as the `-LocalPort` parameter. Renamed to `$_localPort` / `$_remotePort`. Classic PowerShell footgun.

**State name mapping.** `ss` uses `ESTAB`, `TIME-WAIT`, etc. Windows uses `Established`, `TimeWait`. A lookup table maps between them.

**`Get-NetRoute` needs two calls.** `ip -json route show` returns IPv4 only. IPv6 requires `ip -6 -json route show`. The `default` route maps to `0.0.0.0/0` / `::/0`.

---

## Version history

| Version | Notes |
|---|---|
| 0.4.0 | DnsClient cmdlets extracted to separate [DnsClient.Linux](https://github.com/peppekerstens/DnsClient.Linux) module. NetTCPIP.Linux reverts to NetTCPIP-only surface: 4 implemented, 30 stubs. |
| 0.3.0 | DnsClient cmdlets temporarily merged in (now reverted to DnsClient.Linux). |
| 0.2.0 | Linux-only guard. `#Requires -Version 7.2`. Pester 5.2+ test rewrite. |
| 0.1.0 | Initial release. `Get-NetIPAddress`, `Get-NetIPConfiguration`, `Get-NetRoute`, `Get-NetTCPConnection` implemented. 30 stubs. |

---

## License

GPL-3.0 — see [LICENSE](LICENSE).
