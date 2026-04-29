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
P='\033[1;35m'  # roxo
G='\033[1;32m'  # verde
Y='\033[1;33m'  # amarelo
R='\033[1;31m'  # vermelho
C='\033[1;36m'  # ciano
W='\033[1;37m'  # branco
D='\033[2m'     # dim
N='\033[0m'     # reset

# ===== TERMINAL HELPERS =====
clear_screen(){ printf "\033c"; }
hide_cursor(){ tput civis 2>/dev/null; }
show_cursor(){ tput cnorm 2>/dev/null; }
cleanup(){ show_cursor; stty echo icanon 2>/dev/null; }
trap cleanup EXIT

# ler tecla (↑ ↓ Enter)
read_key(){
  stty -echo -icanon time 0 min 1 2>/dev/null
  key=$(dd bs=1 count=1 2>/dev/null)
  if [[ "$key" == $'\x1b' ]]; then
    key+=$(dd bs=1 count=2 2>/dev/null)
  fi
  echo "$key"
}

# ===== HEADER =====
header(){
  clear_screen
  echo -e "${P}"
  echo "╔══════════════════════════════════════╗"
  echo "║        PINGUIM SCANNER APP PRO       ║"
  echo "╚══════════════════════════════════════╝"
  echo -e "${N}"
}

# ===== BOTÃO GRANDE (COM FOCO) =====
draw_big_button(){
  focused="$1" # 1=focus, 0=normal
  if [ "$focused" -eq 1 ]; then
    echo -e "${G}"
    echo "        ┌──────────────────────────┐"
    echo "        │    ▶ INICIAR SCANNER     │"
    echo "        └──────────────────────────┘"
    echo -e "${N}"
  else
    echo -e "${D}"
    echo "        ┌──────────────────────────┐"
    echo "        │      INICIAR SCANNER     │"
    echo "        └──────────────────────────┘"
    echo -e "${N}"
  fi
}

draw_small(){
  label="$1"
  focused="$2"
  if [ "$focused" -eq 1 ]; then
    echo -e "${C}   ▶ $label${N}"
  else
    echo -e "     $label"
  fi
}

# ===== LOADING =====
loading(){
  name="$1"
  bar=""
  for i in $(seq 1 30); do
    bar="${bar}█"
    printf "\r[%-30s] %s" "$bar" "$name"
    sleep 0.02
  done
  echo ""
}

add(){ TOTAL=$((TOTAL+$1)); }

# ===== SELEÇÃO DE JOGO =====
select_game_ui(){
  options=("Free Fire" "Free Fire MAX" "Voltar")
  idx=0
  while true; do
    header
    echo "Selecione o jogo:"
    echo ""
    for i in "${!options[@]}"; do
      if [ "$i" -eq "$idx" ]; then
        echo -e "${C} ▶ ${options[$i]}${N}"
      else
        echo "   ${options[$i]}"
      fi
    done

    key=$(read_key)
    case "$key" in
      $'\x1b[A') ((idx--)); [ $idx -lt 0 ] && idx=$((${#options[@]}-1));; # up
      $'\x1b[B') ((idx++)); [ $idx -ge ${#options[@]} ] && idx=0;;        # down
      "") # Enter
        case "$idx" in
          0) PKG="com.dts.freefireth"; GAME="Free Fire"; return ;;
          1) PKG="com.dts.freefiremax"; GAME="Free Fire MAX"; return ;;
          2) return ;;
        esac
      ;;
    esac
  done
}

# ===== SCANS =====
scan_root(){
  loading "ROOT"
  if command -v su >/dev/null 2>&1; then
    FOUND_ROOT="Root detectado"
    add 2
  else
    FOUND_ROOT="OK"
  fi
}

scan_apps(){
  loading "APPS"
  FOUND_APPS=$(pm list packages 2>/dev/null | grep -Ei "mod|hack|cheat" | head -5)
  [ -n "$FOUND_APPS" ] && add 2
}

scan_files(){
  loading "ARQUIVOS"
  FOUND_FILES=$(find /sdcard -iname "*mod*" -o -iname "*hack*" 2>/dev/null | head -5)
  [ -n "$FOUND_FILES" ] && add 1
}

scan_proc(){
  loading "PROCESSOS"
  FOUND_PROC=$(ps 2>/dev/null | grep -Ei "frida|inject" | head -3)
  [ -n "$FOUND_PROC" ] && add 2
}

scan_install(){
  loading "INSTALAÇÃO"
  inst=$(dumpsys package "$PKG" 2>/dev/null | grep -i installerPackageName)
  if echo "$inst" | grep -qi "vending"; then
    SOURCE="Play Store"
  elif [ -n "$inst" ]; then
    SOURCE="APK externo"
  else
    SOURCE="Desconhecido"
  fi
}

# ===== RESULTADO =====
section(){
  title="$1"; data="$2"
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
  echo -e "${D}Pressione ENTER para voltar${N}"
  read
}

# ===== EXEC =====
run_scan(){
  if [ -z "$PKG" ]; then
    select_game_ui
  fi

  TOTAL=0
  FOUND_ROOT=""; FOUND_APPS=""; FOUND_FILES=""; FOUND_PROC=""

  scan_root
  scan_apps
  scan_files
  scan_proc
  scan_install

  result
}

# ===== HOME UI (SETAS + BOTÃO GRANDE) =====
home_ui(){
  hide_cursor
  options=("INICIAR" "TROCAR JOGO" "SAIR")
  idx=0

  while true; do
    header
    echo -e "${W}Jogo:${N} ${C}${GAME:-Nenhum}${N}"
    echo ""

    # botão grande (primeiro item)
    if [ "$idx" -eq 0 ]; then
      draw_big_button 1
    else
      draw_big_button 0
    fi
    echo ""

    # itens menores
    draw_small "Trocar jogo" $([ "$idx" -eq 1 ] && echo 1 || echo 0)
    draw_small "Sair"        $([ "$idx" -eq 2 ] && echo 1 || echo 0)

    key=$(read_key)
    case "$key" in
      $'\x1b[A') ((idx--)); [ $idx -lt 0 ] && idx=2;;
      $'\x1b[B') ((idx++)); [ $idx -gt 2 ] && idx=0;;
      "") # Enter
        case "$idx" in
          0) run_scan ;;
          1) select_game_ui ;;
          2) cleanup; exit ;;
        esac
      ;;
    esac
  done
}

# ===== START =====
home_ui
