#!/bin/sh
# gamcatch v2: dnsmasq sorgu logundan kumar domain'i yakalar
# v2: slot/kumar keyword'leri cikti (false-positive), restart deterministik, 3 dk'da bir kosar
CONF=/etc/dnsmasq.d/zz-auto-gambling.conf
STAMP=/tmp/.gamcatch.stamp
KW="bahis|casino|iddaa|rulet|tombala|poker|jackpot|bets10|betsat|sahabet|matbet|casibom|holiganbet|meritbet|meritking|1xbet|cratos|restbet|tipobet|sekabet|betpas|mariobet|jokerbet|superbetin|grandbetting|lunabet|superbahis|tempobet|mobilbahis|hepsibahis|youwin|casinomaxi|casinometropol|discountcasino|anadolucasino|grandpashabet|mostbet|betist|betboo|jetbahis|jojobet|piabet|marsbahis|betvole|betcup|asgardbet|dumanbet|bingoplus|madridbet|hga030"
WL="alphabet|corbett"
touch "$CONF"
logread -e 'query\[' | grep -ei "$KW" | grep -viE "$WL" |
  sed -n 's/.*query\[[A-Z0-9]*\] \([^ ]*\).*/\1/p' |
  sort -u | while read -r d; do
    grep -qx "address=/$d/0.0.0.0" "$CONF" || echo "address=/$d/0.0.0.0" >> "$CONF"
  done
if [ ! -f "$STAMP" ] || [ "$CONF" -nt "$STAMP" ]; then
  touch "$STAMP"
  /etc/init.d/dnsmasq restart >/dev/null 2>&1
fi
