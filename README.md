# NetTCPIP.Linux

PowerShell 7.x module providing cmdlet parity with the Windows `NetTCPIP` and `DnsClient` modules on Linux. Wraps native Linux networking tools (`ip`, `ss`, `dig`, `resolvectl`) to deliver a familiar PowerShell experience for IP address, routing, TCP connection management, and DNS resolution.

Part of the **Linux PowerShell Cmdlet Parity** project — inspired by Evgenij Smirnov's [2025 European PowerShell Summit session](https://www.youtube.com/watch?v=RlzinWYIjBY) and documented in the blog series at [peppekerstens.github.io](https://peppekerstens.github.io/linux-command-wrapping-part-1/).

---

## What it does

On **Linux**, wraps `ip`, `ss`, `dig`, and `resolvectl` to provide PowerShell cmdlets matching the Windows `NetTCPIP` and `DnsClient` module APIs as closely as possible. All 55 cmdlets that the two Windows modules export are present — 8 are fully implemented, the remaining 47 are stubs that emit a warning on Linux.

On **Windows**, every function delegates transparently to the built-in cmdlets — no behavioral change.

---

## Requirements

- PowerShell 7.2+
- **Linux only** — the module refuses to load on Windows (throws a descriptive error)
- Linux with `iproute2` (`ip`, `ss`) — installed by default on Ubuntu 24.04
- `dig` (package: `dnsutils` / `bind9-dnsutils`) for `Resolve-DnsName`
- `resolvectl` (systemd-resolved) or `nscd` for `Clear-DnsClientCache`

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

# Resolve a hostname (A records)
Resolve-DnsName -Name 'dns.google' -Type A

# Show configured DNS servers per interface
Get-DnsClientServerAddress

# Show DNS search suffix list
Get-DnsClientGlobalSetting

# Flush the DNS cache
Clear-DnsClientCache
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

### DnsClient cmdlets

| Cmdlet | Status | Linux tool | Notes |
|---|:---:|---|---|
| `Resolve-DnsName` | ✅ | `dig` | A, AAAA, CNAME, MX, NS, TXT, SOA, PTR; `-Name`, `-Type`, `-Server` parameters; skips gracefully if `dig` missing |
| `Clear-DnsClientCache` | ✅ | `resolvectl flush-caches` | Falls back to `nscd --invalidate=hosts`; supports `-WhatIf` / `-Confirm` |
| `Get-DnsClientServerAddress` | ✅ | `/etc/resolv.conf` + `resolvectl status` | Returns per-interface DNS server list with InterfaceAlias, AddressFamily, ServerAddresses |
| `Get-DnsClientGlobalSetting` | ✅ | `/etc/resolv.conf` + `resolvectl status` | Returns SuffixSearchList from search/domain lines |
| `Add-DnsClientDohServerAddress` | ⚠️ | Stub | |
| `Add-DnsClientNrptRule` | ⚠️ | Stub | |
| `Get-DnsClient` | ⚠️ | Stub | |
| `Get-DnsClientCache` | ⚠️ | Stub | |
| `Get-DnsClientDohServerAddress` | ⚠️ | Stub | |
| `Get-DnsClientNrptGlobal` | ⚠️ | Stub | |
| `Get-DnsClientNrptPolicy` | ⚠️ | Stub | |
| `Get-DnsClientNrptRule` | ⚠️ | Stub | |
| `Register-DnsClient` | ⚠️ | Stub | |
| `Remove-DnsClientDohServerAddress` | ⚠️ | Stub | |
| `Remove-DnsClientNrptRule` | ⚠️ | Stub | |
| `Set-DnsClient` | ⚠️ | Stub | |
| `Set-DnsClientDohServerAddress` | ⚠️ | Stub | |
| `Set-DnsClientGlobalSetting` | ⚠️ | Stub | |
| `Set-DnsClientNrptGlobal` | ⚠️ | Stub | |
| `Set-DnsClientNrptRule` | ⚠️ | Stub | |
| `Set-DnsClientServerAddress` | ⚠️ | Stub | |

---

## Implementation notes

- `ip -json addr show` and `ip -json route show` are used for structured output — no text parsing required.
- `Get-NetRoute` calls `ip -json route show` for IPv4 and `ip -6 -json route show` for IPv6; both sets are merged into a single result stream.
- `Get-NetTCPConnection` parses `ss -tnap` text output (ss does not support `--json` in all versions). State names are mapped from ss convention (e.g. `ESTAB` → `Established`, `TIME-WAIT` → `TimeWait`).
- `Get-NetIPConfiguration` excludes the loopback interface by default; pass `-All` to include it.

### DNS tools

- `Resolve-DnsName` runs `dig +noall +answer +authority +additional +ttlid +comments` and parses the section output into typed objects. If `dig` is not available it emits a warning and returns nothing (does not throw).
- `Clear-DnsClientCache` tries `resolvectl flush-caches` first, then falls back to `nscd --invalidate=hosts`. Fully `ShouldProcess`-aware.
- `Get-DnsClientServerAddress` reads `nameserver` lines from `/etc/resolv.conf` as the global fallback and also queries `resolvectl status` to capture per-interface DNS server assignments.
- `Get-DnsClientGlobalSetting` reads `search`/`domain` lines from `/etc/resolv.conf` and merges with `resolvectl status` global DNS Domain output.

---

## Version history

| Version | Notes |
|---|---|
| 0.3.0 | DnsClient cmdlets merged in: `Resolve-DnsName`, `Clear-DnsClientCache`, `Get-DnsClientServerAddress`, `Get-DnsClientGlobalSetting` implemented; 17 DnsClient stubs added. Total: 55 cmdlets (8 implemented, 47 stubs). |
| 0.2.0 | Linux-only guard added (throws on Windows). `#Requires -Version 7.2` added to `.psm1`. Tests rewritten for Pester 5.2+: `BeforeDiscovery`, conditional import, all Describe blocks skipped on non-Linux — 138/138 pass on WSL2, 138 skipped on Windows. |
| 0.1.0 | Initial release. `Get-NetIPAddress`, `Get-NetIPConfiguration`, `Get-NetRoute`, `Get-NetTCPConnection` implemented. 30 stubs for remaining cmdlets. |

---

## How we built this

### Why this module exists

The Windows `NetTCPIP` module is the go-to for IP address inspection, routing, and TCP connection enumeration in PowerShell scripts. None of it works on Linux. `ip` and `ss` exist, but their output is raw text (or JSON in newer iproute2 versions) that you have to parse manually every time. The goal here was to make `Get-NetIPAddress` and friends Just Work on Linux so cross-platform scripts don't need platform branches.

### Tool choices

**`ip -json`** was the obvious choice for address and routing data. The `-json` flag has been in iproute2 since version 4.12 (2017), so it's safe to rely on for any modern Linux. It gives clean structured output — no text parsing, no regex. `Get-NetIPAddress`, `Get-NetRoute`, and `Get-NetIPConfiguration` all use this.

**`ss`** is the modern replacement for `netstat`. The problem is that `ss --json` isn't universally available across distributions — some older Ubuntu LTS versions ship an `ss` that doesn't support it. So `Get-NetTCPConnection` parses `ss -tnap` text output instead, which is consistently available. The column layout is stable enough to parse safely.

### Key gotchas

**LISTEN sockets have a wildcard remote address.** When `ss` reports a listening socket, the remote address column is `0.0.0.0:*` or `[::]:*`. The `*` is not a valid port number, so any code that tries to extract a port via a "digits only" regex on that column will silently fail or crash. The fix is to detect the wildcard pattern and return `0` for the port rather than trying to parse it.

**Loop variable shadowing.** During development of `Get-NetTCPConnection`, a pipeline loop used `$localPort` as the loop variable name — same as the `-LocalPort` parameter. Inside the loop, `$localPort` resolves to the current iteration value, silently overwriting the parameter. The filter then always matched (or never matched). Renamed the loop variables to `$_localPort` / `$_remotePort` to keep them distinct. Classic PowerShell footgun.

**State name mapping.** `ss` uses its own state names: `ESTAB`, `TIME-WAIT`, `CLOSE-WAIT`, `SYN-SENT`, etc. Windows uses `Established`, `TimeWait`, `CloseWait`, `SynSent`. A lookup table maps between them. Without this, `-State Established` would never match anything.

**`Get-NetRoute` needs two calls.** `ip -json route show` only returns IPv4 routes. IPv6 routes require `ip -6 -json route show`. Both are called and the results merged. The `default` route entry has no destination prefix — it's mapped to `0.0.0.0/0` for IPv4 and `::/0` for IPv6 to match Windows behavior.

**`-Filter -Exclude` trap.** Early drafts of the module used `-Filter` on `Where-Object` inside the `.psm1`. This silently does nothing on Linux (filter provider semantics differ). Replaced with explicit `Where-Object { ... }` pipeline filtering throughout.

### Naming and stub strategy

The Windows `NetTCPIP` module exports 34 cmdlets. We implement 4 — the ones that cover 90%+ of real-world usage. The remaining 30 are stubs: they export the correct function name, emit a `Write-Warning` saying "not yet implemented on Linux", and return nothing. This keeps the module's exported surface consistent with Windows so `Get-Command -Module NetTCPIP` returns the expected list without errors.

All 4 implemented cmdlets keep the original Windows names (no renaming needed — `NetTCPIP` is already platform-neutral in naming). The stubs carry comments marking which Linux tool would be the natural implementation path (`ip link` for `Get-NetIPInterface`, `ip neigh` for `Get-NetNeighbor`, etc.).

### Test approach

Tests live in `Tests\NetTCPIP.Linux.Tests.ps1` and use Pester 5.2+. The test file includes `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }` and a `BeforeDiscovery` block that detects whether the current platform is Linux. On Windows, all `Describe` blocks get `-Skip` applied — 138 tests skip cleanly rather than error.

On WSL2 the full 138 tests pass. Tests cover parameter filtering (AddressFamily, InterfaceAlias, State, LocalPort, RemotePort, OwningProcess), state name mapping, and the wildcard remote address edge case for LISTEN sockets.

---

## License

GPL-3.0 — see [LICENSE](LICENSE).
