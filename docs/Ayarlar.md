# Xiaomi Mi Router 4A Gigabit — OpenWrt Sistem Ayarları

> Xiaomi Mi Router 4A Gigabit Edition (R4A) için yüksek performanslı ağ, dual-core optimizasyonu, DNS filtreleme ve Zapret DPI bypass yapılandırması.

---

## Sistem Bilgisi

| Parametre    | Değer                                       |
| ------------ | -------------------------------------------- |
| Model        | Xiaomi Mi Router 4A Gigabit (R4A)            |
| Target       | ramips/mt7621                                |
| CPU          | MediaTek MT7621A, Dual-Core 880 MHz (4 VPE)  |
| RAM          | 128 MB DDR3                                  |
| Flash        | 16 MB SPI NOR                                |
| WAN Portu    | wan (DSA Gigabit)                            |
| LAN Portları | lan1, lan2 (br-lan köprüsü)                  |
| Wi-Fi        | Dual-Band MT7603 (2.4G) + MT7612 (5G AC)     |

---

## Zapret DPI Bypass (Dual-Core)

Zapret, 
fqws ve nftables NFQUEUE kullanılarak MT7621 çift çekirdekli mimarisine özel multi-worker olarak çalışır.

### Yapılandırma (/etc/init.d/zapret):
`sh
FLOWOFFLOAD="software"
QUIC_MODE="block"
WAN_IF="wan"
LAN_IF="br-lan"
QUEUE_PKTS=6
`

- **Worker 1:** --qnum=80
- **Worker 2:** --qnum=81
- **Yük Dengeleme:** nftables queue flags bypass,fanout to 80-81
- **QUIC Koruması:** UDP 443 nftables seviyesinde reddedilerek tarayıcılar TCP 443 TLS 1.3'e zorlanır.
- **Kalıcılık:** /etc/hotplug.d/firewall/99-zapret tetikleyicisi devrededir.

---

## QoS / Trafik Şekillendirme (/etc/rc.local)

HTB + fq_codel + cake tabanlı önceliklendirme ile rekabetçi oyunlarda bufferbloat engellenir.

- **WAN:** wan
- **Hız Limiti:** RATE="7200kbit" (8 Mbps upload hattına göre optimize)
- **VIP Sınıfı (1:10):** CS2 (26976-27103), Discord (3478, 4379-4380) ve mobil oyunlar için garantili 300kbit taban bant ve 5ms hedef gecikme.
- **Genel Sınıf (1:11):** cake qdisc.

---

## Reklam ve Güvenlik Filtreleme

1. **AdBlock-Fast:** HaGeZi Pro listesi + OEM (Xiaomi, Oppo, Huawei) telemetri filtreleri.
2. **Gamcatch:** /usr/bin/gamcatch.sh ile her 3 dakikada bir dnsmasq sorgularından kumar/bahis sitelerini yakalayıp engelleyen otomatik motor.
3. **Statik Tehdit:** USOM ve bilinen zararlı listesi (/etc/dnsmasq.d/banned.conf).
