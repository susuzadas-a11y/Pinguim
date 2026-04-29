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
D='\033[2m'
N='\033[0m'

beep(){ printf "\a"; }

header(){
clear
echo -e "${P}"
echo "╔════════════════════════════════╗"
echo "║          P I N G U I M          ║"
echo "║            S C A N             ║"
echo "╚════════════════════════════════╝"
echo -e "${N}"
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== ADB AUTO (INÍCIO) =====
adb_auto(){
header
echo "CONECTAR DEPURAÇÃO WIFI"
echo ""

read -p "IP: " ip
read -p "PORTA: " port

echo ""
echo "Conectando..."

adb connect ${ip}:${port} >/dev/null 2>&1

if [ $? -eq 0 ]; then
echo -e "${G}✔ CONECTADO${N}"
else
echo -e "${R}✖ FALHA (pode continuar mesmo assim)${N}"
fi

sleep 1
}

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

# ===== ROOT DETALHADO =====
scan_root(){
FOUND_ROOT=""

if command -v su >/dev/null 2>&1; then
if su -c "id" >/dev/null 2>&1; then
FOUND_ROOT="ROOT REAL (su funcional)"
add 3
else
FOUND_ROOT="POSSÍVEL ROOT (su bloqueado)"
add 1
fi
else
FOUND_ROOT="Sem root"
fi
}

# ===== SCAN =====
scan_all(){
TOTAL=0
FOUND_APPS=""
FOUND_FILES=""
FOUND_PROC=""

# ROOT
scan_root

# APPS
FOUND_APPS=$(pm list packages | grep -Ei "mod|hack|cheat|inject" | sed 's/package://g' | head -10)
[ -n "$FOUND_APPS" ] && add 2

# FILES
FILES=$(find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -5)
if [ -n "$FILES" ]; then
for f in $FILES; do
DATA=$(stat -c %y "$f" 2>/dev/null | cut -d'.' -f1)
FOUND_FILES+="$f | $DATA\n"
done
add 2
fi

# PROCESSOS
FOUND_PROC=$(ps | grep -Ei "frida|inject" | grep -v grep | head -5)
[ -n "$FOUND_PROC" ] && add 3

# ORIGEM
inst=$(dumpsys package "$PKG" 2>/dev/null | grep installerPackageName)
echo "$inst" | grep -qi "vending" && SOURCE="Play Store" || SOURCE="APK Externo"

beep
}

# ===== RESULT =====
section(){
echo -e "${C}▶ $1${N}"
[ -n "$2" ] && echo -e "${Y}$2${N}" || echo -e "${G}✔ Nada encontrado${N}"
echo ""
}

result(){
header

echo "🎮 $GAME"
echo "📦 Origem: $SOURCE"
echo ""

section "ROOT" "$FOUND_ROOT"
section "APPS SUSPEITOS" "$FOUND_APPS"
section "ARQUIVOS SUSPEITOS" "$FOUND_FILES"
section "PROCESSOS SUSPEITOS" "$FOUND_PROC"

echo "=============================="
echo "⚠ SCORE: $TOTAL"
echo ""

if [ "$TOTAL" -ge 5 ]; then
echo -e "${R}🚨 ALTO RISCO${N}"
echo -e "${Y}APLIQUE O WO IMEDIATAMENTE${N}"
elif [ "$TOTAL" -ge 1 ]; then
echo -e "${Y}⚠ SUSPEITO${N}"
echo -e "${Y}PROCURE O SS PINGUIM${N}"
else
echo -e "${G}✔ LIMPO${N}"
fi

echo ""
echo -e "${D}Créditos: PINGUIM SCAN${N}"

read -p "ENTER..."
}

# ===== MENU =====
menu(){
while true; do
header

echo -e "${W}Jogo:${N} ${C}${GAME:-Nenhum}${N}"
echo ""

echo "1 - INICIAR SCAN"
echo "2 - TROCAR JOGO"
echo "3 - SAIR"

read -p "Escolha: " op

case "$op" in
1) [ -z "$PKG" ] && select_game; scan_all; result ;;
2) select_game ;;
3) exit ;;
*) echo "Opção inválida"; sleep 1 ;;
esac

done
}

# ===== START =====
adb_auto
menu
