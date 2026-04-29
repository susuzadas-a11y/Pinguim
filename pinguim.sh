#!/data/data/com.termux/files/usr/bin/bash

# ===== AUTO START (SPLASH) =====
if [ -z "$PINGUIM_STARTED" ]; then
export PINGUIM_STARTED=1

printf "\033c"
echo "██████╗ ██╗███╗   ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗"
echo "██╔══██╗██║████╗  ██║██╔════╝ ██║   ██║██║████╗ ████║"
echo "██████╔╝██║██╔██╗ ██║██║  ███╗██║   ██║██║██╔████╔██║"
echo "██╔═══╝ ██║██║╚██╗██║██║   ██║██║   ██║██║██║╚██╔╝██║"
echo "██║     ██║██║ ╚████║╚██████╔╝╚██████╔╝██║██║ ╚═╝ ██║"
echo "╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝     ╚═╝"

echo ""
echo "Iniciando..."
bar=""
for i in $(seq 1 25); do
bar="${bar}█"
printf "\r[%-25s]" "$bar"
sleep 0.03
done
sleep 0.2
fi

# ===== CONFIG =====
TOTAL=0
PKG=""
GAME=""
SOURCE="Desconhecido"

FOUND_ROOT=""
FOUND_APPS=""
FOUND_FILES=""
FOUND_PROC=""

# ===== CORES =====
P='\033[1;35m'
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
C='\033[1;36m'
W='\033[1;37m'
D='\033[2m'
N='\033[0m'

# ===== TERMINAL =====
clear_screen(){ printf "\033c"; }
hide_cursor(){ tput civis 2>/dev/null; }
show_cursor(){ tput cnorm 2>/dev/null; }

enable_input(){ stty echo icanon 2>/dev/null; }
disable_input(){ stty -echo -icanon 2>/dev/null; }

cleanup(){
show_cursor
enable_input
}
trap cleanup EXIT

# ===== TECLAS =====
read_key(){
key=$(dd bs=1 count=1 2>/dev/null)
if [[ "$key" == $'\x1b' ]]; then
key+=$(dd bs=1 count=2 2>/dev/null)
fi
echo "$key"
}

# ===== UI =====
header(){
clear_screen
echo -e "${P}"
echo "╔══════════════════════════════════════╗"
echo "║        PINGUIM SCANNER APP PRO       ║"
echo "╚══════════════════════════════════════╝"
echo -e "${N}"
}

big_button(){
if [ "$1" -eq 1 ]; then
echo -e "${G}        ┌──────────────────────────┐"
echo "        │    ▶ INICIAR SCANNER     │"
echo "        └──────────────────────────┘${N}"
else
echo -e "${D}        ┌──────────────────────────┐"
echo "        │      INICIAR SCANNER     │"
echo "        └──────────────────────────┘${N}"
fi
}

menu_item(){
if [ "$2" -eq 1 ]; then
echo -e "${C} ▶ $1${N}"
else
echo "   $1"
fi
}

loading(){
bar=""
for i in $(seq 1 25); do
bar="${bar}█"
printf "\r[%-25s] %s" "$bar" "$1"
sleep 0.02
done
echo ""
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== GAME =====
select_game(){
enable_input
header
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
read -p "Escolha: " op
disable_input

case "$op" in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
esac
}

# ===== SCANS =====
scan_root(){
loading "ROOT"
command -v su >/dev/null && FOUND_ROOT="Root detectado" && add 2 || FOUND_ROOT="OK"
}

scan_apps(){
loading "APPS"
FOUND_APPS=$(pm list packages | grep -Ei "mod|hack|cheat" | head -5)
[ -n "$FOUND_APPS" ] && add 2
}

scan_files(){
loading "FILES"
FOUND_FILES=$(find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -5)
[ -n "$FOUND_FILES" ] && add 1
}

scan_proc(){
loading "PROCESSOS"
FOUND_PROC=$(ps | grep -Ei "frida|inject" | head -3)
[ -n "$FOUND_PROC" ] && add 2
}

scan_install(){
loading "INSTALAÇÃO"
inst=$(dumpsys package "$PKG" 2>/dev/null | grep installerPackageName)

if echo "$inst" | grep -qi "vending"; then
SOURCE="Play Store"
elif [ -n "$inst" ]; then
SOURCE="APK externo"
fi
}

# ===== RESULT =====
section(){
echo -e "${C}▶ $1${N}"
[ -n "$2" ] && echo -e "${Y}$2${N}" || echo -e "${G}✔ Nada encontrado${N}"
echo ""
}

result(){
enable_input
header

echo "🎮 JOGO: $GAME"
echo "📦 ORIGEM: $SOURCE"
echo ""

section "ROOT" "$FOUND_ROOT"
section "APPS" "$FOUND_APPS"
section "FILES" "$FOUND_FILES"
section "PROCESSOS" "$FOUND_PROC"

echo "=============================="
echo "⚠ SCORE: $TOTAL"
echo ""

[ "$TOTAL" -ge 5 ] && echo -e "${R}ALTO RISCO${N}" || \
[ "$TOTAL" -ge 2 ] && echo -e "${Y}SUSPEITO${N}" || \
echo -e "${G}LIMPO${N}"

read -p "ENTER para voltar..."
disable_input
}

run_scan(){
[ -z "$PKG" ] && select_game

TOTAL=0
FOUND_ROOT=""
FOUND_APPS=""
FOUND_FILES=""
FOUND_PROC=""

scan_root
scan_apps
scan_files
scan_proc
scan_install

result
}

# ===== HOME =====
home(){
hide_cursor
disable_input
idx=0

while true; do
header
echo -e "${W}Jogo:${N} ${C}${GAME:-Nenhum}${N}"
echo ""

big_button $([ "$idx" -eq 0 ] && echo 1 || echo 0)
echo ""

menu_item "Trocar jogo" $([ "$idx" -eq 1 ] && echo 1 || echo 0)
menu_item "Sair" $([ "$idx" -eq 2 ] && echo 1 || echo 0)

key=$(read_key)

case "$key" in
$'\x1b[A') ((idx--)); [ $idx -lt 0 ] && idx=2 ;;
$'\x1b[B') ((idx++)); [ $idx -gt 2 ] && idx=0 ;;
"")
case "$idx" in
0) run_scan ;;
1) select_game ;;
2) cleanup; exit ;;
esac
;;
esac
done
}

home
