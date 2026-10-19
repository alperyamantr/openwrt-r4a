# OpenWrt R4A Gigabit — Proje Mimarisi & Sistem Dokümanı

## Genel Bilgiler
- **Cihaz:** Xiaomi Mi Router 4A Gigabit Edition (Model: R4A)
- **SoC:** MediaTek MT7621A — Dual-Core 880MHz (MIPS 1004KEc, 4 Donanımsal VPE Thread)
- **RAM:** 128MB DDR3
- **Flash:** 16MB SPI NOR
- **Ağ:** 1x WAN (DSA wan), 2x LAN (lan1, lan2 köprüsü br-lan)
- **Kablosuz Ağ:** MT7603 (2.4GHz) + MT7612 (5GHz AC)
- **OpenWrt Hedefi:** ramips/mt7621 (v25.12.6)

## Çekirdek ve Ağ Mimarisi
1. **Packet Steering (RPS/RFS):**
   Ağ trafiği donanım kesmeleri (softirq) MT7621A'nın 4 sanal çekirdeğine dengeli paylaştırılır. Tek çekirdeğin doyuma ulaşması engellenir (packet_steering=1, concurrency=2).
2. **TCP Westwood & fq_codel:**
   Kernel seviyesinde Westwood algoritması ve fq_codel varsayılan kuyruk yöneticisi olarak aktiftir.

## Zapret (DPI Bypass Motoru)
- **Binary:** /opt/zapret/nfqws (mipsel mimarisi, MT7621 tam uyumlu)
- **Multi-Worker:** İki bağımsız procd worker örneği:
  - Worker 1: --qnum=80
  - Worker 2: --qnum=81
- **Kuyruk Dağıtımı:** nftables queue flags bypass,fanout to 80-81 ile akışlar bağlantı bazında çekirdeklere dağıtılır.
- **QUIC Kuralı:** UDP 443 doğrudan nftables üzerinden reject with icmp port-unreachable ile geri çevrilir; tüm tarayıcılar kesintisiz TCP 443 TLS 1.3 akışına düşer.
- **Flow Offload:** İlk 6 paket nfqws tarafından çözüldükten sonra akış doğrudan flow add @ft üzerinden kernel flowtable'a aktarılır.
- **Kalıcılık:** /etc/hotplug.d/firewall/99-zapret tetikleyicisi ile ağ ve firewall yenilenmelerinde servis kesintisiz çalışır.

## QoS & Trafik Şekillendirme (/etc/rc.local)
- **Arayüz:** DSA wan portu
- **Bant Genişliği:** RATE="7200kbit" (8 Mbps upload hattına göre %90 tavan, bufferbloat engelleme)
- **VIP Sınıfı (1:10):** 300kbit garantili taban bant, fq_codel 5ms hedef gecikme.
  - CS2 & Steam SDR UDP portları (26976-27103)
  - Discord ve STUN portları (3478, 4379-4380)
  - Mobil oyun port aralıkları
- **Genel Trafik (1:11):** cake qdisc ile diffserv ve adil bant paylaşımı.

## DNS, Güvenlik ve Reklam Filtreleme
- **Upstream DNS:** AdGuard DNS (94.140.14.14 / 94.140.15.15) DoH proxy desteğiyle.
- **AdBlock-Fast:** HaGeZi Pro listesi ve üretici telemetri filtreleri (Xiaomi, Oppo, Huawei).
- **Gamcatch:** gamcatch.sh gerçek zamanlı dnsmasq sorgu izleme ile bahis ve kumar domainlerini anlık engelleyen cron betiği.
- **Statik Tehdit Filtresi:** USOM ve bilinen zararlı domainler (banned.conf).

## Sistem Sağlığı ve Doğrulama
- Canlı sistemde bellek kullanımı ~50MB / 128MB seviyesinde stabildir.
- ZRAM Swap 32MB LZO sıkıştırma ile aktiftir.
- Boşta işlemci yükü (Load Average) ~0.15 civarındadır.
