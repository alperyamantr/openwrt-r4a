# OpenWrt R4A Gigabit — Özel Üretim Firmware

Xiaomi Mi Router 4A Gigabit Edition (Model: R4A) için yüksek performanslı, düşük gecikmeli (ultra-low latency), oyun odaklı ve DPI korumalı özel OpenWrt firmware projesi.

## Donanım Özellikleri
- **SoC:** MediaTek MT7621A (Dual-Core 880MHz, 4 Donanımsal VPE Thread)
- **RAM:** 128MB DDR3
- **Flash:** 16MB SPI NOR
- **Target:** amips/mt7621 (OpenWrt v25.12 Snapshot)
- **Ağ Arayüzü:** 1x Gigabit WAN (DSA wan), 2x Gigabit LAN (lan1, lan2)
- **Kablosuz Ağ:** Dual-Band Wi-Fi (2.4GHz b/g/n + 5GHz a/n/ac)

## Temel Yetenekler & Optimizasyonlar
1. **DPI Bypass (Zapret nfqws):**
   - MediaTek MT7621A çift çekirdeğine özel multi-worker ve fanout (QNUM 80 & 81) yük dengeleme.
   - QUIC (UDP 443) engellemesi ile tarayıcıları temiz ve kesintisiz TCP 443 bağlantısına yönlendirme.
   - İlk 6 paketten sonra Software Flow Offload ile doğrudan çekirdek seviyesinde paket aktarımı (sıfır CPU darboğazı).
   - Ağ ve firewall yeniden yüklemelerinde kesinti yaşamayan hotplug koruması (/etc/hotplug.d/firewall/99-zapret).
2. **QoS & Gaming VIP Önceliklendirme:**
   - HTB + fq_codel + cake tabanlı bufferbloat engelleme mimarisi.
   - CS2, Steam SDR, Discord ve mobil oyun portları için garantili 1:10 VIP kanalı.
3. **Reklam, Telemetri & Tehdit Koruması:**
   - Entegre dblock-fast ve HaGeZi Pro filtreleme motoru.
   - Xiaomi, Oppo, Huawei/Honor cihaz telemetrisi engelleme listeleri.
   - gamcatch ile gerçek zamanlı kumar/bahis domain yakalama ve engelleme betiği.
   - USOM tehdit filtreleme altyapısı (anned.conf).
4. **Çekirdek & Sistem:**
   - TCP Westwood tıkanıklık kontrol algoritması.
   - Packet Steering (RPS/RFS) ile ağ kesmelerinin 4 iş parçacığına dengeli dağıtımı.
   - ZRAM Swap (LZO sıkıştırma) ile kararlı bellek yönetimi.

## Derleme (Build)
GitHub Actions üzerinden Build OpenWrt Firmware iş akışı tetiklenerek doğrudan kuruluma hazır .bin imajı üretilir.
