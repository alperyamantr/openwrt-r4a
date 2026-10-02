# openwrt-r4a

Custom OpenWrt build for Xiaomi Mi Router 4A Gigabit Edition (model R4A),
target `ramips/mt7621`. Ported directly from the real `openwrt-c50v6` repo —
see `docs/PROJECT_CONTEXT.md` for exactly what carried over unchanged, what's
different, and the open TODOs before first flash.

## Quick start
1. Push this repo to GitHub, run the `Build OpenWrt Firmware` workflow
   (workflow_dispatch or push to `main`/`master`).
2. Grab the `openwrt-r4a-<run>` artifact from the run.
3. Flash via OpenWRTInvasion first (stock MIWIFI bootloader is locked down).
4. Work through `docs/PROJECT_CONTEXT.md`'s TODO list on real hardware (WAN
   interface name, line rate, adblock-fast's Hagezi URL, nfqws binary check).

Or build locally with `scripts/build.sh` (clone `openwrt` next to this
repo's `scripts/`/`files/`/`profiles/` first).
