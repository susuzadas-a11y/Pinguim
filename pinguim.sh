#!/data/data/com.termux/files/usr/bin/bash

# ===== CONFIG =====
LOG="$HOME/pinguim_log.txt"
TMP_HASH="$HOME/.pinguim_hash"

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

log(){
echo "[$(date)] $1" >> "$LOG"
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
read -p "IP: " ip
read -p "PORTA: " port

echo "Conectando..."
adb connect ${ip}:${port} >/dev/null 2>&1

[ $? -eq 0 ] && echo -e "${G}✔ CONECTADO${N}" || echo -e "${R}✖ FALHA${N}"

read -p "ENTER..."
}

# ===== REPLAY HASH =====
check_replay(){
REPLAY=$(ls -t /sdcard/Android/data/$PKG/files/MReplays/*.json 2>/dev/null | head -1)

[ -z "$REPLAY" ] && return

HASH=$(md5sum "$REPLAY" | cut -d ' ' -f1)

if [ -f "$TMP_HASH" ]; then
OLD=$(cat "$TMP_HASH")
if [ "$HASH" != "$OLD" ]; then
echo -e "${R}Replay MODIFICADO${N}"
log "Replay alterado: $REPLAY"
add 3
fi
fi

echo "$HASH" > "$TMP_HASH"
}

# ===== SCAN =====
scan_all(){
TOTAL=0
FOUND_ROOT=""
FOUND_APPS=""
FOUND_FILES=""
FOUND_PROC=""

# ROOT
if command -v su >/dev/null; then
FOUND_ROOT="Root detectado"
log "$FOUND_ROOT"
add 2
fi

# APPS
FOUND_APPS=$(pm list packages | grep -Ei "mod|hack|cheat" | sed 's/package://g' | head -10)
[ -n "$FOUND_APPS" ] && log "$FOUND_APPS" && add 2

# FILES
FILES=$(find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -5)
if [ -n "$FILES" ]; then
for f in $FILES; do
DATA=$(stat -c %y "$f" 2>/dev/null | cut -d'.' -f1)
FOUND_FILES+="$f | $DATA\n"
done
log "$FOUND_FILES"
add 2
fi

# PROCESSOS
FOUND_PROC=$(ps | grep -Ei "frida|inject" | grep -v grep | head -5)
[ -n "$FOUND_PROC" ] && log "$FOUND_PROC" && add 3

# ORIGEM
inst=$(dumpsys package "$PKG" 2>/dev/null | grep installerPackageName)
echo "$inst" | grep -qi "vending" && SOURCE="Play Store" || SOURCE="APK Externo"

# REPLAY
check_replay
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
echo "📦 $SOURCE"
echo ""

section "ROOT" "$FOUND_ROOT"
section "APPS" "$FOUND_APPS"
section "ARQUIVOS" "$FOUND_FILES"
section "PROCESSOS" "$FOUND_PROC"

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

# ===== MONITOR =====
monitor(){
header
echo "MONITORAMENTO EM TEMPO REAL (CTRL+C para sair)"
echo ""

while true; do
scan_all

if [ "$TOTAL" -ge 3 ]; then
echo -e "${R}⚠ ALERTA${N}"
beep
fi

sleep 5
done
}

# ===== MENU =====
while true; do
header

echo -e "${W}Jogo:${N} ${C}${GAME:-Nenhum}${N}"
echo ""

echo "1 - SCAN"
echo "2 - MONITOR TEMPO REAL"
echo "3 - TROCAR JOGO"
echo "4 - DEPURAÇÃO WIFI"
echo "5 - VER LOG"
echo "6 - SAIR"

read -p "Escolha: " op

case "$op" in
1) [ -z "$PKG" ] && select_game; scan_all; result ;;
2) [ -z "$PKG" ] && select_game; monitor ;;
3) select_game ;;
4) adb_connect ;;
5) cat "$LOG"; read -p "ENTER..." ;;
6) exit ;;
*) echo "Erro"; sleep 1 ;;
esac

done
