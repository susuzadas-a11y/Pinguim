#!/data/data/com.termux/files/usr/bin/bash

# ===== AUTO PRIMEIRA EXECUÇÃO =====
FIRST_RUN="$HOME/.pinguim_first"
if [ ! -f "$FIRST_RUN" ]; then
  touch "$FIRST_RUN"
else
  echo "Sistema já inicializado"
fi

# ===== CONFIG =====
OWNER_PIN="7865"
BLOCK_FILE="$HOME/.pinguim_block"
USED_PINS="$HOME/.pinguim_used_pins"
HISTORY="$HOME/.pinguim_history.log"

touch "$USED_PINS"

VALID_PINS=("01" "2002" "9321" "3469" "9397" "2773" "83872" "02773" "2937" "15838" "205273" "2862" "7262" "62835")

# ===== CORES =====
P1='\033[1;35m'; P2='\033[0;35m'
W='\033[1;37m'; G='\033[1;32m'
Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'

# ===== UI =====
line(){ echo -e "${P2}══════════════════════════════════════${N}"; }
box(){ line; printf "${P1} %-38s ${N}\n" "$1"; line; }

banner(){
clear
echo -e "${P1}"
echo "╔══════════════════════════════════════╗"
echo "║        SCAN SS PINGUIM ANT XIT       ║"
echo "╠══════════════════════════════════════╣"
echo "║              PRO+ FINAL              ║"
echo "╚══════════════════════════════════════╝"
echo -e "${N}"
}

# ===== LOADING =====
loading(){
for((i=0;i<=100;i++));do
d=$((i/2)); l=$((50-d))
bd=$(printf "%0.s#" $(seq 1 $d))
bl=$(printf "%0.s " $(seq 1 $l))
((i%2==0)) && c="$P1" || c="$P2"
printf "\r${c}[%s%s] %d%%${N}" "$bd" "$bl" "$i"
sleep 0.01
done; echo ""
}

# ===== ID =====
get_id(){
id=$(getprop ro.serialno 2>/dev/null)
[ -z "$id" ] && id=$(settings get secure android_id 2>/dev/null)
[ -z "$id" ] && id="unknown"
echo "$id"
}
ID=$(get_id)

# ===== BLOCK =====
[ -f "$BLOCK_FILE" ] && [ "$(cat "$BLOCK_FILE")" = "$ID" ] && exit 1

# ===== LOGIN =====
login(){
t=3
while [ $t -gt 0 ]; do
banner; box "LOGIN"
read -p "PIN: " pin

[ "$pin" = "$OWNER_PIN" ] && return

for p in "${VALID_PINS[@]}"; do
if [ "$pin" = "$p" ]; then
grep -q "^$pin:" "$USED_PINS" 2>/dev/null && exit 1
echo "$pin:$ID:$(date +%s)" >> "$USED_PINS"
return
fi
done

t=$((t-1))
done

echo "$ID" > "$BLOCK_FILE"
exit 1
}

# ===== GAME =====
select_game(){
banner; box "SELECIONE"
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
read op
case $op in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
*) select_game ;;
esac
}

TOTAL=0
add(){ TOTAL=$((TOTAL+$1)); }

# ===== SCANS =====
scan_root(){
box "ROOT"
su -c id >/dev/null 2>&1 && echo "ROOT detectado" && add 2 || echo "OK"
}

scan_adb(){
box "ADB"
a=$(settings get global adb_enabled 2>/dev/null)
b=$(settings get global adb_wifi_enabled 2>/dev/null)
[ "$a" = "1" ] && echo "USB ativo" && add 1
[ "$b" = "1" ] && echo "WiFi ativo" && add 1
}

scan_tmp(){
box "TMP"
l=$(ls /data/local/tmp 2>/dev/null)
[ -n "$l" ] && echo "$l" && add 1 || echo "OK"
}

scan_logs(){
box "LOGS"
c=$(logcat -d 2>/dev/null | wc -l)
[ "$c" -lt 50 ] && echo "Poucos logs" && add 1 || echo "OK"
}

scan_apps(){
box "APPS"
p=$(pm list packages | grep -Ei "mod|cheat|hack")
[ -n "$p" ] && echo "$p" && add 2 || echo "OK"
}

scan_proc(){
box "PROCESSOS"
ps | grep -Ei "frida|inject" && add 2 || echo "OK"
}

scan_files(){
box "ARQUIVOS"
f=$(find /sdcard -iname "*mod*" -o -iname "*cheat*" 2>/dev/null | head -5)
[ -n "$f" ] && echo "$f" && add 1 || echo "OK"
}

scan_replay(){
box "REPLAY"

S=$(ls -t /sdcard/Android/data/com.dts.freefiremax/files/MReplays/*.json 2>/dev/null | head -1)
D=$(ls -t /sdcard/Android/data/com.dts.freefireth/files/MReplays/*.json 2>/dev/null | head -1)

if [ -z "$S" ] || [ -z "$D" ]; then
  echo "Sem dados"
  return
fi

h1=$(md5sum "$S" 2>/dev/null | cut -d ' ' -f1)
h2=$(md5sum "$D" 2>/dev/null | cut -d ' ' -f1)

[ "$h1" = "$h2" ] && echo "Replay igual" && add 3

t1=$(date -r "$S" +%s 2>/dev/null)
t2=$(date -r "$D" +%s 2>/dev/null)

[ -n "$t1" ] && [ -n "$t2" ] && {
d=$((t2-t1))
[ "$d" -lt 60 ] && echo "Transferência recente" && add 1
}
}

# ===== RELATÓRIO =====
report(){
line
echo "TOTAL: $TOTAL"

[ "$TOTAL" -ge 5 ] && echo "ALTO RISCO" || \
[ "$TOTAL" -ge 2 ] && echo "SUSPEITO" || \
echo "LIMPO"

echo "$(date) | $GAME | $TOTAL" >> "$HISTORY"
line
}

# ===== RUN =====
login
select_game
banner
loading

scan_root
scan_adb
scan_tmp
scan_logs
scan_apps
scan_proc
scan_files
scan_replay

report

echo "FINALIZADO"
