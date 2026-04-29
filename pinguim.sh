#!/data/data/com.termux/files/usr/bin/bash

# ===== CONFIG =====
TOTAL=0
PKG=""
GAME=""

# ===== CORES =====
P1='\033[1;35m'
P2='\033[0;35m'
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
N='\033[0m'

# ===== UI =====
clear_screen(){ clear; }

header(){
clear_screen
echo -e "${P1}"
echo "╔══════════════════════════════╗"
echo "║   SCAN SS PINGUIM PRO UI     ║"
echo "║     LOADING SCAN MODE ⚡      ║"
echo "╚══════════════════════════════╝"
echo -e "${N}"
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== BARRA DE LOADING =====
loading(){
name="$1"
for i in $(seq 1 20); do
  bar=$(printf "%0.s█" $(seq 1 $i))
  space=$(printf "%0.s " $(seq 1 $((20-i))))
  printf "\r${P2}[%s%s] %s${N}" "$bar" "$space" "$name"
  sleep 0.03
done
echo ""
}

pause(){
echo ""
read -p "ENTER para continuar..."
}

# ===== GAME SELECT =====
select_game(){
header
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
echo ""
read -p "Escolha: " op

case $op in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
*) select_game ;;
esac
}

# ===== SCANS COM LOADING =====

scan_root(){
loading "ROOT"
su -c id >/dev/null 2>&1 && add 2
}

scan_adb(){
loading "ADB"
a=$(settings get global adb_enabled 2>/dev/null)
b=$(settings get global adb_wifi_enabled 2>/dev/null)
[ "$a" = "1" ] && add 1
[ "$b" = "1" ] && add 1
}

scan_apps(){
loading "APPS"
pm list packages | grep -Ei "mod|hack|cheat" >/dev/null && add 2
}

scan_proc(){
loading "PROCESSOS"
ps | grep -Ei "frida|inject" >/dev/null && add 2
}

scan_files(){
loading "ARQUIVOS"
find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -1 >/dev/null && add 1
}

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
echo "ORIGEM: ${SOURCE:-Não verificado}"
echo "RISCO TOTAL: $TOTAL"
echo ""

if [ "$TOTAL" -ge 5 ]; then
echo -e "${R}⚠ ALTO RISCO${N}"
elif [ "$TOTAL" -ge 2 ]; then
echo -e "${Y}⚠ SUSPEITO${N}"
else
echo -e "${G}✔ LIMPO${N}"
fi

pause
menu
}

# ===== MENU =====
menu(){
header
echo "1 - Selecionar jogo"
echo "2 - Executar Scan"
echo "3 - Sair"
echo ""
read -p "Escolha: " op

case $op in
1) select_game; menu ;;
2) run_scan ;;
3) exit ;;
*) menu ;;
esac
}

# ===== SCAN TOTAL =====
run_scan(){
header

if [ -z "$PKG" ]; then
echo "❌ Selecione o jogo primeiro"
pause
menu
fi

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

# ===== START =====
menu
