# openwrt-r4a — Project Context

Sibling project to `openwrt-c50v6`, separate repo per decision. Hardware:
Xiaomi Mi Router 4A Gigabit Edition, model **R4A**, MT7621A dual-core 880MHz,
128MB RAM, 16MB NOR flash, target `ramips/mt7621`.

Everything in this repo (scripts, packages.txt structure, zapret setup,
QoS, sysctl, dnsmasq/whitelist/banned.conf, .gitattributes/.gitignore) was
**ported directly from the real `openwrt-c50v6` repo**, not reconstructed
from memory — only what genuinely differs by hardware was changed.

## What's identical to C50v6 (by request — same RAM-conscious philosophy)
- `profiles/packages.txt`: same package set (`tc-tiny` not `tc-full`/cake,
  `opkg`/`libopkg` stripped, ipv6/tunnel/USB/thermal kmods stripped) even
  though R4A has 2x the RAM — deliberately not "upgraded" to full variants.
- `scripts/prepare.sh`, `patch-kernel.sh`, `optimize.sh`, `build.sh`: same
  logic, only target path changed (`mt76x8` → `mt7621`, profile filename).
- `.github/workflows/build.yml`: same CI structure (same OpenWrt release
  v25.12.5, same cache/verify-packages/checksum steps), paths retargeted.
- zapret: `/opt/zapret/` (nfqws static MIPS binary + fake TLS/QUIC/STUN/
  Discord files + ipset lists), `/etc/init.d/zapret`, `/etc/zapret-bypass-ips.txt`
  — copied byte-for-byte. The nfqws binary is a statically linked MIPS-I
  binary; C50v6 (mt76x8) and R4A (mt7621) are both mipsel/o32 — should run,
  but **verify it actually starts on real hardware**, wasn't recompiled or
  tested for mt7621 specifically.
- `/etc/dnsmasq.d/banned.conf` (the real curated USOM/telemetry list, not a
  placeholder), `/etc/dnsmasq.d/whitelist.conf`, `/usr/bin/banned-guncelle`,
  `/usr/bin/siteekle`, `/etc/crontabs/root` (weekly reboot, 3-day zapret
  fake-file refresh, monthly banned.conf/USOM refresh) — all copied verbatim.
- `/etc/config/{firewall,dhcp,dropbear,luci,rpcd,uhttpd,attendedsysupgrade,
  zram-swap}`, `/etc/dnsmasq.conf`, `/etc/sysctl.conf`, `/etc/sysupgrade.conf`
  — all device-agnostic, copied verbatim (AdGuard DNS 94.140.14.14/.15.15,
  IPv6 disabled, uhttpd IPv6 listeners already commented out upstream).
- `rc.local` HTB QoS structure (root HTB + VIP class 1:10 + bulk class 1:11,
  CS2/Steam/Discord/mobile-game UDP port filters) — same values/ports.

## What's different from C50v6
- **Adblock mechanism replaced entirely.** C50v6's `hagezi_init` +
  `hagezi-guncelle` + `/tmp` symlink hack is gone. Replaced with
  **luci-app-adblock-fast** (official package). Configure the Hagezi Light
  URL via LuCI (Services > AdBlock-Fast) after first boot — deliberately
  **not** shipping a static `/etc/config/adblock-fast`: the package's UCI
  schema had a major rewrite recently (shell → ucode core) and a
  hand-written config risks a `uci: Parse error` that blocks LuCI from
  loading it (seen on the OpenWrt forum with this exact package). `banned.conf`
  itself is unrelated to this mechanism either way — it's always lived
  directly in `/etc/dnsmasq.d/`, loaded by dnsmasq's `conf-dir`, independent
  of whatever handles Hagezi.
- `rc.local`'s old "HaGeZi Guncelleme" background block (wait-for-internet
  loop + call `hagezi-guncelle`) removed — adblock-fast's own core handles
  its update schedule now, don't reintroduce a manual wget loop for it.
- `WAN_IF` in `rc.local` and `/etc/init.d/zapret`: placeholder `eth1`
  (was `eth0.2` on C50v6's switch-VLAN setup). **Verify via `ip a` after
  first boot** — R4A has separate physical WAN/LAN ports, not a VLAN split.
- `RATE`/`VIP_RATE` in `rc.local`: placeholder based on a 300Mbps line
  (`270000kbit`, ~10% headroom) vs C50v6's 8Mbps line (`7200kbit`). Confirm
  against the actual measured line speed once connected.
- Image size warning threshold in CI bumped for 16MB flash (~14.5MB warn
  point) vs C50v6's 8MB flash (~7.6MB) — **not verified against R4A's real
  partition layout**, just a rough proportional estimate.

## Open TODOs before "production stable"
1. Flash via OpenWRTInvasion first — stock MIWIFI bootloader is locked down
   (see prior chat notes for the `uart_en`/`boot_wait` steps).
2. Verify real WAN interface name (`ip a`) and update both `rc.local` and
   `/etc/init.d/zapret`.
3. Set real line speed in `rc.local`'s `RATE`/`VIP_RATE`.
4. Confirm nfqws binary actually runs on mt7621 (static MIPS binary from
   C50v6, not recompiled/tested for this target).
5. Set Hagezi Light URL in LuCI's AdBlock-Fast page after first boot.
6. Confirm `net.netfilter.nfnetlink_queue_maxlen` proc entry behaves the
   same on mt7621's kernel as it did on C50v6's mt76x8 kernel (was fine
   there, not re-verified here).

## Build pipeline order
clone → feeds update/install → patch-kernel.sh → prepare.sh (+ `make
defconfig`) → copy files/ → optimize.sh (+ `make defconfig` again) → verify
critical packages → make download → make → verify images exist → check
image size → checksum → upload.
