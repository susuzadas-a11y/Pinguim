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
echo "╔════════════════════════════════╗"
echo "║   SCAN SS PINGUIM PRO UI      ║"
echo "║        LAUNCHER MODE ⚡        ║"
echo "╚════════════════════════════════╝"
echo -e "${N}"
}

pause(){
echo ""
read -p "ENTER para voltar..."
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== MENU PRINCIPAL =====
menu(){
header
echo "1 - Selecionar jogo"
echo "2 - Executar Scan Rápido"
echo "3 - Ver resultado atual"
echo "4 - Sair"
echo ""
read -p "Escolha: " op

case $op in
1) select_game ;;
2) run_scan ;;
3) show_result ;;
4) exit ;;
*) menu ;;
esac
}

# ===== SELEÇÃO DE JOGO =====
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

echo ""
echo "[✔] Jogo selecionado: $GAME"
pause
menu
}

# ===== SCANS =====
scan_root(){
su -c id >/dev/null 2>&1 && add 2
}

scan_adb(){
a=$(settings get global adb_enabled 2>/dev/null)
b=$(settings get global adb_wifi_enabled 2>/dev/null)
[ "$a" = "1" ] && add 1
[ "$b" = "1" ] && add 1
}

scan_apps(){
pm list packages | grep -Ei "mod|hack|cheat" >/dev/null && add 2
}

scan_proc(){
ps | grep -Ei "frida|inject" >/dev/null && add 2
}

scan_files(){
find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -1 >/dev/null && add 1
}

scan_replay(){
S=$(ls -t /sdcard/Android/data/$PKG/files/MReplays/*.json 2>/dev/null | head -1)
[ -n "$S" ] && add 1
}

scan_install_source(){
inst=$(dumpsys package "$PKG" 2>/dev/null | grep -i installerPackageName)

if echo "$inst" | grep -qi "com.android.vending"; then
    SOURCE="Play Store"
elif [ -n "$inst" ]; then
    SOURCE="APK externo"
else
    SOURCE="Desconhecido"
fi
}

# ===== EXECUÇÃO DO SCAN =====
run_scan(){
header

if [ -z "$PKG" ]; then
echo "❌ Nenhum jogo selecionado"
pause
menu
fi

echo "[+] Iniciando scan..."
echo ""

TOTAL=0

scan_root
scan_adb
scan_apps
scan_proc
scan_files
scan_replay
scan_install_source

echo "[✔] Scan concluído"
pause
menu
}

# ===== RESULTADO =====
show_result(){
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

# ===== START =====
menu
