#!/data/data/com.termux/files/usr/bin/bash

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
N='\033[0m'

clear_screen(){ printf "\033c"; }

# ===== HEADER =====
header(){
clear_screen
echo -e "${P}"
echo "╔══════════════════════════════════╗"
echo "║        PINGUIM SCANNER APP       ║"
echo "╚══════════════════════════════════╝"
echo -e "${N}"
}

# ===== BOTÃO GRANDE =====
big_button(){
echo ""
echo -e "${G}        ┌──────────────────────┐"
echo -e "        │   INICIAR SCANNER   │"
echo -e "        └──────────────────────┘${N}"
echo ""
echo -e "${C}Pressione ENTER para iniciar${N}"
}

# ===== LOADING =====
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

# ===== SELEÇÃO DE JOGO =====
select_game(){
header
echo "Selecione o jogo:"
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
echo ""

read -p "Escolha: " op

case "$op" in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
*) select_game ;;
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
loading "ARQUIVOS"
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

# ===== RESULTADO =====
section(){
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

section "ROOT" "$FOUND_ROOT"
section "APPS" "$FOUND_APPS"
section "ARQUIVOS" "$FOUND_FILES"
section "PROCESSOS" "$FOUND_PROC"

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
select_game
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

# ===== APP HOME =====
home(){
while true; do
header

echo -e "${W}Jogo selecionado:${N} ${C}${GAME:-Nenhum}${N}"

big_button

echo "1 - Trocar jogo"
echo "2 - Sair"
echo ""

read -p "Escolha ou ENTER: " op

case "$op" in
"") run_scan ;;
1) select_game ;;
2) exit ;;
*) ;;
esac
done
}

# ===== START =====
home
