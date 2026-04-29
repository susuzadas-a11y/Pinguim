#!/data/data/com.termux/files/usr/bin/bash

# ===== CONFIG =====
TOTAL=0
PKG=""
GAME=""
SOURCE="Desconhecido"

# ===== CORES =====
P='\033[1;35m'
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
C='\033[1;36m'
N='\033[0m'

# ===== LIMPAR TELA =====
clear_screen(){
  printf "\033c"
}

# ===== TELA INICIAL (APP STYLE) =====
splash(){
clear_screen
echo -e "${P}"
echo "██████╗ ██╗███╗   ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗"
echo "██╔══██╗██║████╗  ██║██╔════╝ ██║   ██║██║████╗ ████║"
echo "██████╔╝██║██╔██╗ ██║██║  ███╗██║   ██║██║██╔████╔██║"
echo "██╔═══╝ ██║██║╚██╗██║██║   ██║██║   ██║██║██║╚██╔╝██║"
echo "██║     ██║██║ ╚████║╚██████╔╝╚██████╔╝██║██║ ╚═╝ ██║"
echo "╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝     ╚═╝"
echo -e "${N}"
echo ""
echo -e "${C}Iniciando sistema...${N}"
sleep 1
}

# ===== HEADER =====
header(){
clear_screen
echo -e "${P}╔══════════════════════════════╗"
echo "║        PINGUIM APP UI        ║"
echo "╚══════════════════════════════╝${N}"
}

# ===== LOADING SUAVE =====
loading(){
name="$1"
bar=""
for i in $(seq 1 20); do
  bar="${bar}█"
  printf "\r[%-20s] %s" "$bar" "$name"
  sleep 0.03
done
echo ""
}

# ===== MENU (SEM TREMER) =====
menu(){
while true; do
header
echo "🎮 1 - Iniciar Scan"
echo "🎯 2 - Selecionar Jogo"
echo "❌ 3 - Sair"
echo ""
read -p "Escolha: " op

case "$op" in
1) run_scan ;;
2) select_game ;;
3) exit ;;
*) echo "Opção inválida"; sleep 1 ;;
esac
done
}

# ===== SELECT GAME =====
select_game(){
header
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
echo ""
read -p "Escolha: " op

case "$op" in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
*) ;;
esac
}

# ===== SCANS =====
add(){ TOTAL=$((TOTAL+$1)); }

scan_root(){ loading "ROOT"; command -v su >/dev/null && add 2; }

scan_adb(){
loading "ADB"
[ "$(settings get global adb_enabled 2>/dev/null)" = "1" ] && add 1
}

scan_apps(){
loading "APPS"
pm list packages | grep -Ei "mod|hack" >/dev/null && add 2
}

scan_files(){
loading "FILES"
find /sdcard -iname "*mod*" 2>/dev/null | head -1 | grep -q . && add 1
}

scan_install(){
loading "SOURCE"
inst=$(dumpsys package "$PKG" 2>/dev/null | grep installerPackageName)

if echo "$inst" | grep -qi "vending"; then
SOURCE="Play Store"
elif [ -n "$inst" ]; then
SOURCE="APK externo"
fi
}

# ===== RESULT =====
result(){
header
echo "🎮 JOGO: $GAME"
echo "📦 ORIGEM: $SOURCE"
echo "⚠ RISCO: $TOTAL"
echo ""

if [ "$TOTAL" -ge 5 ]; then
echo -e "${R}ALTO RISCO${N}"
elif [ "$TOTAL" -ge 2 ]; then
echo -e "${Y}SUSPEITO${N}"
else
echo -e "${G}LIMPO${N}"
fi

echo ""
read -p "ENTER para voltar..."
}

# ===== RUN =====
run_scan(){

if [ -z "$PKG" ]; then
echo "Selecione o jogo primeiro"
sleep 1
return
fi

TOTAL=0

scan_root
scan_adb
scan_apps
scan_files
scan_install

result
}

# ===== START =====
splash
menu
