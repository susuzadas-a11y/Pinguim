#!/data/data/com.termux/files/usr/bin/bash

#═══════════════════════════════════════
#        P I N G U I M  P A N E L
#                 V2
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
GAME="FREE FIRE"
PKG="com.dts.freefireth"

ROOT_RESULT=""
APP_RESULT=""
FILE_RESULT=""
PROC_RESULT=""
NET_RESULT=""
FRAME_RESULT=""
APK_RESULT=""

LOG_DIR="/sdcard/PinguimLogs"

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
echo "║               V2                 ║"
echo "║                                  ║"
echo "╚══════════════════════════════════╝"
echo -e "${N}"
}

# ===== SCORE =====
add(){
TOTAL=$((TOTAL+$1))
}

# ===== LOADING =====
loading(){

echo ""

for i in 10 20 30 40 50 60 70 80 90 100
do
echo -ne "\r${C}SCANEANDO... ${i}%${N}"
sleep 0.15
done

echo ""
echo ""
}

# ===== ROOT =====
scan_root(){

if command -v su >/dev/null 2>&1; then

if su -c "id" >/dev/null 2>&1; then

ROOT_RESULT="ROOT REAL DETECTADO"
add 5

else

ROOT_RESULT="SU ENCONTRADO"
add 2

fi

else

ROOT_RESULT="SEM ROOT"

fi
}

# ===== FRAMEWORK =====
scan_frameworks(){

FRAME=$(pm list packages | grep -Ei \
"magisk|zygisk|lsposed|xposed")

if [ -n "$FRAME" ]; then

FRAME_RESULT=$(echo "$FRAME" | \
sed 's/package://g')

add 5

fi
}

# ===== APPS =====
scan_apps(){

APPS=$(pm list packages | grep -Ei \
"mod|hack|cheat|inject|script|menu|vip")

if [ -n "$APPS" ]; then

APP_RESULT=$(echo "$APPS" | \
sed 's/package://g' | head -20)

add 3

fi
}

# ===== FILES =====
scan_files(){

FILES=$(find /sdcard \
/sdcard/Download \
/sdcard/Documents \
-maxdepth 3 \
\( -iname "*mod*" \
-o -iname "*hack*" \
-o -iname "*cheat*" \
-o -iname "*inject*" \
-o -iname "*.lua" \
-o -iname "*.js" \
-o -iname "*.dex" \
-o -iname "*.so" \) \
2>/dev/null | head -20)

if [ -n "$FILES" ]; then

while IFS= read -r f
do

DATE=$(stat -c %y "$f" 2>/dev/null | cut -d'.' -f1)

FILE_RESULT="${FILE_RESULT}${f} | ${DATE}\n"

done <<< "$FILES"

add 2

fi
}

# ===== PROCESS =====
scan_process(){

PROC=$(ps -A 2>/dev/null || ps)

PROC=$(echo "$PROC" | \
grep -Ei \
"frida|gdb|inject|speed|hack|xposed" | \
grep -v grep)

if [ -n "$PROC" ]; then

PROC_RESULT=$(echo "$PROC" | head -15)

add 6

fi
}

# ===== NETWORK =====
scan_network(){

PORT=$(ss -an 2>/dev/null | \
grep -E "27042|27043|4444|8080")

if [ -n "$PORT" ]; then

NET_RESULT="$PORT"

add 5

fi
}

# ===== APK =====
scan_apk(){

APK=$(pm path "$PKG" 2>/dev/null | \
head -1 | cut -d':' -f2)

if [ -n "$APK" ]; then

HASH=$(sha256sum "$APK" 2>/dev/null | awk '{print $1}')

APK_RESULT="$HASH"

fi
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

# ===== SAVE LOG =====
save_log(){

mkdir -p "$LOG_DIR"

LOG="$LOG_DIR/scan_$(date +%d%m%Y_%H%M%S).txt"

{
echo "PINGUIM PANEL V2"
echo ""
echo "DATA: $(date)"
echo ""
echo "GAME: $GAME"
echo "PACKAGE: $PKG"
echo "SCORE: $TOTAL"
echo ""

echo "[ROOT]"
echo "$ROOT_RESULT"
echo ""

echo "[FRAMEWORK]"
echo "$FRAME_RESULT"
echo ""

echo "[APPS]"
echo "$APP_RESULT"
echo ""

echo "[FILES]"
echo -e "$FILE_RESULT"
echo ""

echo "[PROCESS]"
echo "$PROC_RESULT"
echo ""

echo "[NETWORK]"
echo "$NET_RESULT"
echo ""

echo "[APK HASH]"
echo "$APK_RESULT"
echo ""

} > "$LOG"
}

# ===== RESULT =====
result(){

header

echo -e "${W}GAME:${N} ${C}$GAME${N}"
echo -e "${W}PACKAGE:${N} ${Y}$PKG${N}"

echo ""
echo "════════════════════════════"
echo ""

section "ROOT" "$ROOT_RESULT"
section "FRAMEWORKS" "$FRAME_RESULT"
section "APPS SUSPEITOS" "$APP_RESULT"
section "ARQUIVOS SUSPEITOS" "$FILE_RESULT"
section "PROCESSOS SUSPEITOS" "$PROC_RESULT"
section "PORTAS SUSPEITAS" "$NET_RESULT"
section "SHA256 APK" "$APK_RESULT"

echo "════════════════════════════"
echo ""

if [ "$TOTAL" -ge 12 ]; then

STATUS="${R}🚨 ALTO RISCO${N}"

elif [ "$TOTAL" -ge 5 ]; then

STATUS="${Y}⚠ SUSPEITO${N}"

else

STATUS="${G}✔ LIMPO${N}"

fi

echo -e "${W}SCORE:${N} ${R}$TOTAL${N}"
echo ""
echo -e "$STATUS"

echo ""
echo -e "${D}LOG SALVO EM:${N}"
echo -e "${C}$LOG_DIR${N}"

echo ""
}

# ===== START SCAN =====
start_scan(){

TOTAL=0

ROOT_RESULT=""
APP_RESULT=""
FILE_RESULT=""
PROC_RESULT=""
NET_RESULT=""
FRAME_RESULT=""
APK_RESULT=""

loading

scan_root
scan_frameworks
scan_apps
scan_files
scan_process
scan_network
scan_apk

save_log

beep
}

# ===== MENU =====
menu(){

while true
do

header

echo -e "${W}JOGO:${N} ${C}$GAME${N}"

echo ""
echo "1 - INICIAR SCAN"
echo "2 - FREE FIRE MAX"
echo "3 - FREE FIRE"
echo "4 - SAIR"
echo ""

read -p "ESCOLHA: " op

case "$op" in

1)

start_scan
result

read -p "ENTER..."

;;

2)

GAME="FREE FIRE MAX"
PKG="com.dts.freefiremax"

;;

3)

GAME="FREE FIRE"
PKG="com.dts.freefireth"

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

# ===== AUTO START =====

header
echo ""
echo -e "${C}INICIANDO SCAN AUTOMÁTICO...${N}"
sleep 1

start_scan
result

read -p "ENTER PARA MENU..."

menu
