#!/data/data/com.termux/files/usr/bin/bash

# ========= CONFIG =========
OWNER_PIN="7865"
BLOCK_FILE="$HOME/.pinguim_block"
USED_PINS="$HOME/.pinguim_used_pins"
HISTORY_FILE="$HOME/.pinguim_history.log"

VALID_PINS=(
"01" "2002" "9321" "3469" "9397" "2773" "83872"
"02773" "2937" "15838" "205273" "2862" "7262" "62835"
)

# ========= CORES =========
P1='\033[1;35m'; P2='\033[0;35m'; W='\033[1;37m'
G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'

# ========= UI =========
line() { echo -e "${P2}══════════════════════════════════════${N}"; }
box() {
  line
  printf "${P1} %-38s ${N}\n" "$1"
  line
}

banner() {
  clear
  echo -e "${P1}"
  echo "╔══════════════════════════════════════╗"
  echo "║        SCAN SS PINGUIM ANT XIT       ║"
  echo "╠══════════════════════════════════════╣"
  echo "║             PRO+ EDITION             ║"
  echo "╚══════════════════════════════════════╝"
  echo -e "${N}"
}

# ========= LOADING =========
loading_ultra() {
  for ((i=0;i<=100;i++)); do
    d=$((i/2)); l=$((50-d))
    bd=$(printf "%0.s#" $(seq 1 $d))
    bl=$(printf "%0.s " $(seq 1 $l))
    (( i % 2 == 0 )) && c="$P1" || c="$P2"

    if   [ $i -lt 30 ]; then m="Iniciando..."
    elif [ $i -lt 60 ]; then m="Carregando módulos..."
    elif [ $i -lt 90 ]; then m="Processando..."
    else                     m="Finalizando..."
    fi

    printf "\r${c}[%s%s] %d%% | %s${N}" "$bd" "$bl" "$i" "$m"
    sleep 0.02
  done
  echo ""
}

# ========= ID =========
get_id() {
  id=$(getprop ro.serialno 2>/dev/null)
  [ -z "$id" ] && id=$(settings get secure android_id 2>/dev/null)
  [ -z "$id" ] && id=$(uname -n)
  echo "$id"
}
DEVICE_ID=$(get_id)

# ========= BLOQUEIO =========
if [ -f "$BLOCK_FILE" ]; then
  [ "$(cat "$BLOCK_FILE")" = "$DEVICE_ID" ] && exit 1
fi

# ========= LOGIN =========
login() {
  tentativas=3
  while [ $tentativas -gt 0 ]; do
    banner
    box "LOGIN"
    echo -e "${W}Digite o código:${N}"
    read pin

    [ "$pin" = "$OWNER_PIN" ] && return

    for p in "${VALID_PINS[@]}"; do
      if [ "$pin" = "$p" ]; then
        if [ -f "$USED_PINS" ] && grep -q "^$pin:" "$USED_PINS"; then
          echo -e "${R}PIN já utilizado${N}"; sleep 1; exit 1
        fi
        NOW=$(date +%s)
        echo "$pin:$DEVICE_ID:$NOW" >> "$USED_PINS"
        return
      fi
    done

    tentativas=$((tentativas-1))
    echo -e "${Y}Código inválido (${tentativas} restantes)${N}"
    sleep 1
  done

  echo "$DEVICE_ID" > "$BLOCK_FILE"
  exit 1
}

# ========= EXPIRAÇÃO =========
check_expiration() {
  [ ! -f "$USED_PINS" ] && return
  NOW=$(date +%s)
  while IFS=: read -r pin id data; do
    if [ "$id" = "$DEVICE_ID" ]; then
      dias=$(( (NOW - data)/86400 ))
      [ "$dias" -ge 15 ] && echo -e "${R}Licença expirada${N}" && exit 1
    fi
  done < "$USED_PINS"
}

# ========= MENU GAME =========
select_game() {
  banner
  box "SELECIONE O JOGO"
  echo -e "${P2}1 - Free Fire${N}"
  echo -e "${P2}2 - Free Fire MAX${N}"
  echo -e "${P2}0 - Sair${N}"
  read -p "> " op
  case $op in
    1) PKG="com.dts.freefireth"; GAME="Free Fire" ;;
    2) PKG="com.dts.freefiremax"; GAME="Free Fire MAX" ;;
    0) exit ;;
    *) select_game ;;
  esac
}

# ========= SCANS =========
TOTAL=0
add(){ TOTAL=$((TOTAL+$1)); }

scan_root() {
  box "ROOT"
  if command -v su >/dev/null 2>&1; then
    echo -e "${Y}⚠ Root detectado${N}"; add 2
  else
    echo -e "${G}✔ OK${N}"
  fi
}

scan_adb() {
  box "ADB"
  adb1=$(settings get global adb_enabled 2>/dev/null)
  adb2=$(settings get global adb_wifi_enabled 2>/dev/null)

  [ "$adb1" = "1" ] && echo -e "${Y}⚠ USB Debug ativo${N}" && add 1 || echo -e "${G}✔ USB off${N}"
  [ "$adb2" = "1" ] && echo -e "${Y}⚠ ADB Wi-Fi ativo${N}" && add 1
}

scan_tmp() {
  box "TMP"
  c=$(ls /data/local/tmp 2>/dev/null | wc -l)
  [ "$c" -gt 0 ] && echo -e "${Y}⚠ Arquivos suspeitos${N}" && add 1 || echo -e "${G}✔ Limpo${N}"
}

scan_logs() {
  box "LOGS"
  l=$(logcat -d 2>/dev/null | wc -l)
  [ "$l" -lt 50 ] && echo -e "${Y}⚠ Poucos logs${N}" && add 1 || echo -e "${G}✔ OK${N}"
}

scan_app() {
  box "APP"
  pm list packages | grep -q "$PKG" \
    && echo -e "${G}✔ $GAME instalado${N}" \
    || { echo -e "${R}✖ Não encontrado${N}"; add 1; }
}

scan_replay() {
  box "REPLAYS"
  SRC="/sdcard/Android/data/com.dts.freefiremax/files/MReplays"
  DST="/sdcard/Android/data/com.dts.freefireth/files/MReplays"

  [ ! -d "$SRC" ] && echo "Origem não encontrada" && return
  [ ! -d "$DST" ] && echo "Destino não encontrado" && return

  S=$(ls -t "$SRC"/*.json 2>/dev/null | head -1)
  D=$(ls -t "$DST"/*.json 2>/dev/null | head -1)

  [ -z "$S" ] || [ -z "$D" ] && echo "Sem dados" && return

  h1=$(md5sum "$S" 2>/dev/null | cut -d ' ' -f1)
  h2=$(md5sum "$D" 2>/dev/null | cut -d ' ' -f1)

  if [ "$h1" = "$h2" ]; then
    echo -e "${R}❗ Replay idêntico (hash)${N}"; add 3
  fi

  t1=$(stat -c %Y "$S" 2>/dev/null)
  t2=$(stat -c %Y "$D" 2>/dev/null)
  diff=$((t2 - t1))

  if [ "$diff" -ge 0 ] && [ "$diff" -le 60 ]; then
    echo -e "${Y}⚠ Transferência recente${N}"; add 1
  fi
}

# ========= RELATÓRIO =========
report() {
  line
  echo -e "${P1}TOTAL DE DETECÇÕES: ${W}$TOTAL${N}"
  if [ "$TOTAL" -ge 5 ]; then
    echo -e "${R}ALTO INDÍCIO${N}"
  elif [ "$TOTAL" -ge 2 ]; then
    echo -e "${Y}SUSPEITO${N}"
  else
    echo -e "${G}LIMPO${N}"
  fi
  line

  echo "$(date) | $GAME | DET=$TOTAL" >> "$HISTORY_FILE"
}

# ========= RUN =========
login
check_expiration
select_game

banner
box "INICIANDO SCAN DE $GAME"
loading_ultra

scan_root
scan_adb
scan_tmp
scan_logs
scan_app
scan_replay

report

echo -e "${P2}SCAN FINALIZADO${N}"