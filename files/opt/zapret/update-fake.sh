#!/bin/sh
FAKE_DIR="/opt/zapret/files/fake"
LOG_FILE="/tmp/zapret-update.log"

mkdir -p "$FAKE_DIR" 2>/dev/null
cd "$FAKE_DIR" || exit 1

echo "$(date) - Fake update started" >> "$LOG_FILE"

CHANGED=0

fetch_fake() {
    local url="$1"
    local target="$2"
    local tmp="${target}.tmp"
    
    rm -f "$tmp" 2>/dev/null
    
    if command -v uclient-fetch >/dev/null 2>&1; then
        uclient-fetch --no-check-certificate -q "$url" -O "$tmp" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q --no-check-certificate "$url" -O "$tmp" 2>/dev/null
    elif command -v curl >/dev/null 2>&1; then
        curl -skL "$url" -o "$tmp" 2>/dev/null
    fi
    
    # Boyut ve varlik kontrolu (0 byte dosya bozmasini engeller)
    if [ -s "$tmp" ]; then
        if ! cmp -s "$tmp" "$target" 2>/dev/null; then
            mv -f "$tmp" "$target"
            echo "$(date) - Guncellendi: $target ($(wc -c < "$target") bytes)" >> "$LOG_FILE"
            CHANGED=1
        else
            rm -f "$tmp"
            echo "$(date) - Degisiklik yok: $target" >> "$LOG_FILE"
        fi
    else
        rm -f "$tmp"
        echo "$(date) - Indirme basarisiz veya dosya bos: $target (mevcut dosya korundu)" >> "$LOG_FILE"
    fi
}

BASE_URL="https://raw.githubusercontent.com/bol-van/zapret/master/files/fake"

fetch_fake "$BASE_URL/tls_clienthello_www_google_com.bin" "tls_clienthello_www_google_com.bin"
fetch_fake "$BASE_URL/quic_initial_www_google_com.bin" "quic_initial_www_google_com.bin"
fetch_fake "$BASE_URL/discord-ip-discovery-with-port.bin" "discord-ip-discovery-with-port.bin"
fetch_fake "$BASE_URL/stun.bin" "stun.bin"

echo "$(date) - Fake update finished. Changed: $CHANGED" >> "$LOG_FILE"

# Sadece dosya gercekten degistiyse servisi yeniden baslat
if [ "$CHANGED" -eq 1 ]; then
    echo "$(date) - Zapret servisi yeniden baslatiliyor..." >> "$LOG_FILE"
    /etc/init.d/zapret restart >/dev/null 2>&1
fi

exit 0
