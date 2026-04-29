#!/data/data/com.termux/files/usr/bin/bash

# ===== CONFIG =====
TOTAL=0
PKG=""
GAME=""
SOURCE=""

# ===== CORES =====
P1='\033[1;35m'
P2='\033[0;35m'
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
N='\033[0m'

# ===== HEADER (SEM FLICKER) =====
header(){
echo -e "\033c"
echo -e "${P1}"
echo "╔══════════════════════════════╗"
echo "║   SCAN SS PINGUIM PRO UI     ║"
echo "║     STABLE MODE FIXED ⚡     ║"
echo "╚══════════════════════════════╝"
echo -e "${N}"
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== BARRA ESTÁVEL =====
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

pause(){
echo ""
read -p "ENTER para continuar..."
}

# ===== GAME =====
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

# ===== SCANS =====

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

# ===== RELATÓRIO =====
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

pause
}

# ===== SCAN =====
run_scan(){
header

if [ -z "$PKG" ]; then
echo "❌ Selecione o jogo primeiro"
pause
return
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

# ===== MENU ESTÁVEL (SEM TREMER) =====
menu(){
while true; do
header
echo "1 - Selecionar jogo"
echo "2 - Executar Scan"
echo "3 - Sair"
echo ""
read -p "Escolha: " op

case $op in
1) select_game ;;
2) run_scan ;;
3) exit ;;
*) echo "Opção inválida"; sleep 1 ;;
esac
done
}

# ===== START =====
menu
