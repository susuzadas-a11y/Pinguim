#!/data/data/com.termux/files/usr/bin/bash

# ===== CONFIG =====
TOTAL=0
PKG=""
GAME=""
SOURCE=""

# ===== CORES =====
P1='\033[1;35m'
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
N='\033[0m'

# ===== UI =====
header(){
echo -e "\033c"
echo -e "${P1}"
echo "╔══════════════════════════════╗"
echo "║   SCAN SS PINGUIM PRO UI     ║"
echo "║        AUTO START ⚡         ║"
echo "╚══════════════════════════════╝"
echo -e "${N}"
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== LOADING =====
loading(){
name="$1"
bar=""
i=0
while [ $i -lt 20 ]; do
  bar="${bar}█"
  i=$((i+1))
  echo -ne "[${bar}--------------------] $name\r"
  sleep 0.04
done
echo ""
}

# ===== JOGO =====
select_game(){
header
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
read -p "Escolha: " op

case $op in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
*) select_game ;;
esac
}

# ===== SCANS =====

scan_root(){ loading "ROOT"; su -c id >/dev/null 2>&1 && add 2; }

scan_adb(){
loading "ADB"
[ "$(settings get global adb_enabled 2>/dev/null)" = "1" ] && add 1
[ "$(settings get global adb_wifi_enabled 2>/dev/null)" = "1" ] && add 1
}

scan_apps(){ loading "APPS"; pm list packages | grep -Ei "mod|hack|cheat" >/dev/null && add 2; }

scan_proc(){ loading "PROCESSOS"; ps | grep -Ei "frida|inject" >/dev/null && add 2; }

scan_files(){ loading "ARQUIVOS"; find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -1 >/dev/null && add 1; }

scan_replay(){
loading "REPLAY"
S=$(ls -t /sdcard/Android/data/$PKG/files/MReplays/*.json 2>/dev/null | head -1)
[ -n "$S" ] && add 1
}

scan_install_source(){
loading "INSTALAÇÃO"

inst=$(dumpsys package "$PKG" 2>/dev/null | grep -i installerPackageName)

if echo "$inst" | grep -qi "com.android.vending"; then
    SOURCE="Play Store"
elif [ -n "$inst" ]; then
    SOURCE="APK externo"
else
    SOURCE="Desconhecido"
fi
}

# ===== RESULTADO =====
report(){
header

echo "JOGO: $GAME"
echo "ORIGEM: $SOURCE"
echo "RISCO TOTAL: $TOTAL"
echo ""

if [ "$TOTAL" -ge 5 ]; then
echo -e "${R}⚠ ALTO RISCO${N}"
elif [ "$TOTAL" -ge 2 ]; then
echo -e "${Y}⚠ SUSPEITO${N}"
else
echo -e "${G}✔ LIMPO${N}"
fi
}

# ===== EXEC =====
run(){
select_game
TOTAL=0
scan_root
scan_adb
scan_apps
scan_proc
scan_files
scan_replay
scan_install_source
report
}

run
