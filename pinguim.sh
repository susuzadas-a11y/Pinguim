#!/data/data/com.termux/files/usr/bin/bash

#═══════════════════════════════════════
#           P I N G U I M
#             P A N E L
#═══════════════════════════════════════

# ===== CORES =====
P='\033[1;35m'
G='\033[1;32m'
R='\033[1;31m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[1;37m'
D='\033[2m'
N='\033[0m'

# ===== VARS =====
TOTAL=0
GAME=""
PKG=""
SOURCE="Desconhecido"

ROOT_RESULT=""
APP_RESULT=""
FILE_RESULT=""
PROC_RESULT=""
NET_RESULT=""

# ===== SOM =====
beep(){
printf "\a"
}

# ===== HEADER =====
header(){
clear
echo -e "${P}"
echo "╔══════════════════════════════════╗"
echo "║                                  ║"
echo "║         P I N G U I M            ║"
echo "║            P A N E L             ║"
echo "║                                  ║"
echo "╚══════════════════════════════════╝"
echo -e "${N}"
}

# ===== ADD SCORE =====
add(){
TOTAL=$((TOTAL+$1))
}

# ===== LOADING =====
loading(){
echo ""
echo -ne "${C}INICIANDO"
for i in 1 2 3 4 5; do
echo -ne "."
sleep 0.2
done
echo -e "${N}"
echo ""
}

# ===== ADB =====
adb_connect(){
header

echo -e "${C}DEPURAÇÃO WIFI${N}"
echo ""

read -p "IP: " ip
read -p "PORTA: " port

echo ""
echo -e "${Y}CONECTANDO...${N}"

adb connect ${ip}:${port} >/dev/null 2>&1

if [ $? -eq 0 ]; then
echo -e "${G}✔ CONECTADO${N}"
else
echo -e "${R}✖ FALHA NA CONEXÃO${N}"
fi

sleep 2
}

# ===== SELECT GAME =====
select_game(){
header

echo -e "${W}SELECIONE O JOGO${N}"
echo ""
echo "1 - Free Fire"
echo "2 - Free Fire MAX"
echo ""

read -p "ESCOLHA: " op

case "$op" in

1)
PKG="com.dts.freefireth"
GAME="FREE FIRE"
;;

2)
PKG="com.dts.freefiremax"
GAME="FREE FIRE MAX"
;;

*)
select_game
;;

esac
}

# ===== ROOT =====
scan_root(){

if command -v su >/dev/null 2>&1; then

if su -c "id" >/dev/null 2>&1; then

ROOT_RESULT="ROOT REAL DETECTADO"
add 4

else

ROOT_RESULT="SU ENCONTRADO"
add 2

fi

else

ROOT_RESULT="SEM ROOT"

fi
}

# ===== APPS =====
scan_apps(){

APPS=$(pm list packages | grep -Ei \
"mod|hack|cheat|inject|script|menu|vip")

if [ -n "$APPS" ]; then

APP_RESULT=$(echo "$APPS" | \
sed 's/package://g' | head -10)

add 2

else

APP_RESULT=""

fi
}

# ===== FILES =====
scan_files(){

FILES=$(find /sdcard -maxdepth 3 \
\( -iname "*mod*" \
-o -iname "*hack*" \
-o -iname "*cheat*" \
-o -iname "*inject*" \) \
2>/dev/null | head -10)

if [ -n "$FILES" ]; then

while read f; do

DATE=$(stat -c %y "$f" 2>/dev/null | cut -d'.' -f1)

FILE_RESULT="${FILE_RESULT}${f} | ${DATE}\n"

done <<< "$FILES"

add 2

fi
}

# ===== PROCESS =====
scan_process(){

PROC=$(ps -A | grep -Ei \
"frida|inject|speed|hack" | grep -v grep)

if [ -n "$PROC" ]; then

PROC_RESULT=$(echo "$PROC" | head -10)

add 5

fi
}

# ===== NETWORK =====
scan_network(){

PORT=$(netstat -an 2>/dev/null | grep 27042)

if [ -n "$PORT" ]; then

NET_RESULT="PORTA FRIDA 27042 DETECTADA"

add 5

fi
}

# ===== SOURCE =====
scan_source(){

inst=$(dumpsys package "$PKG" 2>/dev/null | \
grep installerPackageName)

echo "$inst" | grep -qi "vending"

if [ $? -eq 0 ]; then

SOURCE="PLAY STORE"

else

SOURCE="APK EXTERNO"
add 1

fi
}

# ===== SCAN =====
start_scan(){

TOTAL=0

ROOT_RESULT=""
APP_RESULT=""
FILE_RESULT=""
PROC_RESULT=""
NET_RESULT=""

loading

scan_root
scan_apps
scan_files
scan_process
scan_network
scan_source

beep
}

# ===== SECTION =====
section(){

echo -e "${C}▶ $1${N}"

if [ -n "$2" ]; then

echo -e "${Y}$2${N}"

else

echo -e "${G}✔ NADA ENCONTRADO${N}"

fi

echo ""
}

# ===== RESULT =====
result(){

header

echo -e "${W}JOGO:${N} ${C}$GAME${N}"
echo -e "${W}ORIGEM:${N} ${Y}$SOURCE${N}"

echo ""
echo "════════════════════════════"
echo ""

section "ROOT" "$ROOT_RESULT"
section "APPS SUSPEITOS" "$APP_RESULT"
section "ARQUIVOS SUSPEITOS" "$FILE_RESULT"
section "PROCESSOS SUSPEITOS" "$PROC_RESULT"
section "REDE SUSPEITA" "$NET_RESULT"

echo "════════════════════════════"
echo ""

echo -e "${W}SCORE:${N} ${R}$TOTAL${N}"
echo ""

if [ "$TOTAL" -ge 8 ]; then

echo -e "${R}🚨 ALTO RISCO${N}"

elif [ "$TOTAL" -ge 3 ]; then

echo -e "${Y}⚠ SUSPEITO${N}"

else

echo -e "${G}✔ LIMPO${N}"

fi

echo ""
echo -e "${D}PINGUIM PANEL${N}"

echo ""
read -p "ENTER..."
}

# ===== LOG =====
save_log(){

mkdir -p /sdcard/PinguimLogs

LOG="/sdcard/PinguimLogs/scan_$(date +%H%M%S).txt"

echo "PINGUIM PANEL" > "$LOG"
echo "" >> "$LOG"

echo "GAME: $GAME" >> "$LOG"
echo "SOURCE: $SOURCE" >> "$LOG"
echo "SCORE: $TOTAL" >> "$LOG"

echo "" >> "$LOG"

echo "$ROOT_RESULT" >> "$LOG"
echo "$APP_RESULT" >> "$LOG"
echo -e "$FILE_RESULT" >> "$LOG"
echo "$PROC_RESULT" >> "$LOG"
echo "$NET_RESULT" >> "$LOG"
}

# ===== MENU =====
menu(){

while true; do

header

echo -e "${W}JOGO:${N} ${C}${GAME:-NENHUM}${N}"

echo ""
echo "1 - INICIAR SCAN"
echo "2 - TROCAR JOGO"
echo "3 - CONECTAR ADB"
echo "4 - SAIR"
echo ""

read -p "ESCOLHA: " op

case "$op" in

1)

[ -z "$PKG" ] && select_game

start_scan
save_log
result

;;

2)

select_game

;;

3)

adb_connect

;;

4)

exit

;;

*)

echo ""
echo -e "${R}OPÇÃO INVÁLIDA${N}"
sleep 1

;;

esac

done
}

# ===== START =====
menu
