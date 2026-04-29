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

add(){ TOTAL=$((TOTAL+$1)); }

# ===== MENU =====
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
*) echo "Inválido"; sleep 1 ;;
esac
done
}

# ===== GAME =====
select_game(){
header
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
read -p "Escolha: " op

case "$op" in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
esac
}

# ===== SCANS =====

scan_root(){
loading "ROOT"
if command -v su >/dev/null; then
  FOUND_ROOT="Root detectado"
  add 2
else
  FOUND_ROOT="OK"
fi
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

# ===== RESULTADO BONITO =====
show_section(){
title="$1"
data="$2"

echo -e "${C}▶ $title${N}"

if [ -n "$data" ]; then
  echo -e "${Y}$data${N}"
else
  echo -e "${G}✔ Nada encontrado${N}"
fi
echo ""
}

result(){
header

echo "🎮 JOGO: $GAME"
echo "📦 ORIGEM: $SOURCE"
echo ""

show_section "ROOT" "$FOUND_ROOT"
show_section "APPS SUSPEITOS" "$FOUND_APPS"
show_section "ARQUIVOS" "$FOUND_FILES"
show_section "PROCESSOS" "$FOUND_PROC"

echo "=============================="
echo "⚠ SCORE: $TOTAL"
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

# ===== EXEC =====
run_scan(){

if [ -z "$PKG" ]; then
echo "Selecione o jogo primeiro"
sleep 1
return
fi

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

# ===== START =====
menu
