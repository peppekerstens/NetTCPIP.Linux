# NetTCPIP.Linux

[![Pester Tests](https://github.com/peppekerstens/NetTCPIP.Linux/actions/workflows/pester.yml/badge.svg)](https://github.com/peppekerstens/NetTCPIP.Linux/actions/workflows/pester.yml)

PowerShell 7.x module providing cmdlet parity with the Windows `NetTCPIP` module on Linux. Wraps native Linux networking tools (`ip`, `ss`) to deliver a familiar PowerShell experience for IP address, routing, and TCP connection management.

For DNS cmdlets (`Resolve-DnsName`, `Clear-DnsClientCache`, etc.), see the companion module **[DnsClient.Linux](https://github.com/peppekerstens/DnsClient.Linux)**.

Part of the **Linux PowerShell Cmdlet Parity** project — inspired by Evgenij Smirnov's [2025 European PowerShell Summit session](https://www.youtube.com/watch?v=RlzinWYIjBY) and documented in the blog series at [peppekerstens.github.io](https://peppekerstens.github.io/linux-command-wrapping-part-1/).

---

## What it does

On **Linux**, wraps `ip`, `ss`, `ping`, and `nc` to provide PowerShell cmdlets matching the Windows `NetTCPIP` module API as closely as possible. All 34 cmdlets that the Windows module exports are present — 10 are fully implemented, the remaining 24 are stubs that emit a warning on Linux.

On **Windows**, the module refuses to load — use the built-in `NetTCPIP` module.

---

## Requirements

- PowerShell 7.2+
- **Linux only** — the module refuses to load on Windows (throws a descriptive error)
- Linux with `iproute2` (`ip`, `ss`), `iputils-ping` (`ping`), and `netcat` (`nc`) — installed by default on most distros

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
| `Find-NetRoute` | ✅ | `ip route get` | DestinationPrefix, NextHop, InterfaceAlias; wraps `ip route get <dst>` |
| `Get-NetCompartment` | ⚠️ | Stub | |
| `Get-NetIPInterface` | ✅ | `ip -json link show` | InterfaceAlias, InterfaceIndex, NlMtu, AdminState, OperationalStatus |
| `Get-NetIPv4Protocol` | ✅ | `sysctl net.ipv4.*` | Forwarding, DefaultTTL, NeighborCacheLimitEntries |
| `Get-NetIPv6Protocol` | ✅ | `sysctl net.ipv6.*` | Forwarding, DefaultHopLimit |
| `Get-NetNeighbor` | ✅ | `ip neigh show` | IPAddress, InterfaceAlias, LinkLayerAddress, State |
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
| `Test-NetConnection` | ✅ | `ping` + `nc` | ComputerName, PingSucceeded, TcpTestSucceeded; `-Port`, `-InformationLevel Quiet/Detailed` |

---

## Implementation notes

- `ip -json addr show` and `ip -json route show` are used for structured output — no text parsing required.
- `Get-NetRoute` calls `Get-IpRoute` for IPv4 and `Get-IpRoute -IPv6` for IPv6; both sets are merged into a single result stream. A `Get-IpLink` call builds a one-shot interface index lookup map, eliminating the previous per-route `ip link show` call that ran once per route entry.
- `Get-NetTCPConnection` parses `ss -tnap` text output (ss does not support `--json` in all versions). State names are mapped from ss convention (e.g. `ESTAB` → `Established`, `TIME-WAIT` → `TimeWait`).
- `Get-NetIPConfiguration` excludes the loopback interface by default; pass `-All` to include it.

### Implementation Approach (Stage 2 — Crescendo audit)

**Decision: Migrate `ip` calls to a private Crescendo-backed wrapper module.**

`ip` supports `--json` / `-json` for `addr show`, `route show`, and `link show`. All three subcommands were previously called inline in individual cmdlets with duplicated invocation and JSON parsing. A private module at `Crescendo/ip.psm1` (backed by `Crescendo/ip.crescendo.json`) now centralises all three:

| Helper | Wraps | Used by |
|---|---|---|
| `Get-IpAddr` | `ip -json addr show` | `Get-NetIPAddress`, `Get-NetIPConfiguration` |
| `Get-IpRoute` | `ip [-6] -json route show` | `Get-NetRoute`, `Get-NetIPConfiguration` |
| `Get-IpLink` | `ip [-s] -json link show` | `Get-NetRoute` (index map) |

The `ss` command (`Get-NetTCPConnection`) has no JSON mode — it remains custom text parsing.

`Crescendo/ip.psm1` is loaded as a nested module in `NetTCPIP.Linux.psm1` and is **not** exported.

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

## CI / Testing

Tested across 5 Linux distributions in containers (**141 pass, 0 fail, 0 skip** on last full run):

| Distro | Image |
|---|---|
| Ubuntu 24.04 | `ghcr.io/peppekerstens/testinfra:ubuntu-24.04` |
| Debian 12 | `ghcr.io/peppekerstens/testinfra:debian-12` |
| Fedora 40 | `ghcr.io/peppekerstens/testinfra:fedora-40` |
| openSUSE Tumbleweed | `ghcr.io/peppekerstens/testinfra:opensuse-tumbleweed` |
| Arch Linux | `ghcr.io/peppekerstens/testinfra:arch-latest` |

Run locally with:

```powershell
# From the repo root
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

GitHub Actions runs the same matrix on every push — see `.github/workflows/pester.yml`.
---

## Version history

| Version | Notes |
|---|---|
| 0.5.0 | Stage 3: `Find-NetRoute`, `Get-NetIPInterface`, `Get-NetIPv4Protocol`, `Get-NetIPv6Protocol`, `Get-NetNeighbor`, `Test-NetConnection` implemented. 10 implemented, 24 stubs. Multi-distro GHA + docker-compose. |
| 0.4.0 | DnsClient cmdlets extracted to separate [DnsClient.Linux](https://github.com/peppekerstens/DnsClient.Linux) module. NetTCPIP.Linux reverts to NetTCPIP-only surface: 4 implemented, 30 stubs. |
| 0.3.0 | DnsClient cmdlets temporarily merged in (now reverted to DnsClient.Linux). |
| 0.2.0 | Linux-only guard. `#Requires -Version 7.2`. Pester 5.2+ test rewrite. |
| 0.1.0 | Initial release. `Get-NetIPAddress`, `Get-NetIPConfiguration`, `Get-NetRoute`, `Get-NetTCPConnection` implemented. 30 stubs. |

---

## License

GPL-3.0 — see [LICENSE](LICENSE).
