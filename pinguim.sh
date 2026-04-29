#!/data/data/com.termux/files/usr/bin/bash

# ===== SOM =====
beep(){ printf "\a"; }

# ===== CORES =====
P='\033[1;35m'
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
C='\033[1;36m'
W='\033[1;37m'
D='\033[2m'
N='\033[0m'

clear

# ===== SPLASH =====
echo -e "${P}"
echo ""
echo "        ██████╗ ██╗███╗   ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗"
echo "        ██╔══██╗██║████╗  ██║██╔════╝ ██║   ██║██║████╗ ████║"
echo "        ██████╔╝██║██╔██╗ ██║██║  ███╗██║   ██║██║██╔████╔██║"
echo "        ██╔═══╝ ██║██║╚██╗██║██║   ██║██║   ██║██║██║╚██╔╝██║"
echo "        ██║     ██║██║ ╚████║╚██████╔╝╚██████╔╝██║██║ ╚═╝ ██║"
echo "        ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝     ╚═╝"
echo -e "${N}"

echo "Iniciando..."
bar=""
for i in $(seq 1 30); do
bar="${bar}█"
printf "\r[%-30s]" "$bar"
sleep 0.02
done
sleep 0.3

# ===== CONFIG =====
TOTAL=0
PKG=""
GAME=""

# ===== HEADER =====
header(){
clear
echo -e "${P}"
echo "╔════════════════════════════════╗"
echo "║                                ║"
echo "║          P I N G U I M          ║"
echo "║            S C A N             ║"
echo "║                                ║"
echo "╚════════════════════════════════╝"
echo -e "${N}"
}

# ===== LOADING =====
loading(){
msg=$1
for i in $(seq 1 20); do
printf "\r${C}▶ $msg... ${i}%%${N}"
sleep 0.015
done
echo ""
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== JOGO =====
select_game(){
header
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
read -p "Escolha: " op

case "$op" in
1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
*) select_game ;;
esac
}

# ===== ADB WIFI =====
adb_connect(){
header
echo "DEPURAÇÃO WIFI"
echo ""

read -p "IP: " ip
read -p "PORTA: " port

loading "Conectando"

adb connect ${ip}:${port} >/dev/null 2>&1

if [ $? -eq 0 ]; then
beep
echo -e "${G}✔ CONECTADO${N}"
else
echo -e "${R}✖ FALHA${N}"
fi

read -p "ENTER..."
}

# ===== SCAN =====
scan_all(){
TOTAL=0

loading "ROOT"
command -v su >/dev/null && add 2

loading "APPS"
pm list packages | grep -Ei "mod|hack|cheat" >/dev/null && add 2

loading "ARQUIVOS"
find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -1 | grep . >/dev/null && add 1

loading "PROCESSOS"
ps | grep -Ei "frida|inject" >/dev/null && add 2

beep
}

# ===== RESULTADO =====
result(){
header

echo "🎮 $GAME"
echo ""

echo "SCORE: $TOTAL"
echo ""

if [ "$TOTAL" -ge 1 ]; then
echo -e "${R}⚠ DETECÇÃO ENCONTRADA${N}"
echo -e "${Y}APLIQUE O WO OU PROCURE O SS PINGUIM NA ORG FALCON${N}"
else
echo -e "${G}✔ LIMPO${N}"
fi

echo ""
echo -e "${D}Créditos: PINGUIM SS${N}"

read -p "ENTER..."
}

# ===== MENU NUMÉRICO =====
while true; do
header

echo -e "${W}Jogo:${N} ${C}${GAME:-Nenhum}${N}"
echo ""

echo "1 - INICIAR SCAN"
echo "2 - TROCAR JOGO"
echo "3 - DEPURAÇÃO WIFI"
echo "4 - SAIR"

read -p "Escolha: " op

case "$op" in
1) [ -z "$PKG" ] && select_game; scan_all; result ;;
2) select_game ;;
3) adb_connect ;;
4) exit ;;
*) echo "Opção inválida"; sleep 1 ;;
esac

done
