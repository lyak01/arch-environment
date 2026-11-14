#!/usr/bin/env bash
# suites.sh - Parseo de suites.yaml y menús de selección interactiva

parse_suites() {
  local yaml="$REPO_DIR/suites.yaml"
  if [[ ! -f "$yaml" ]]; then
    log "ERROR" "No se encontró $yaml"
    return 1
  fi
  SUITE_ORDER=()
  unset SUITE_DESC SUITE_CORE SUITE_REC SUITE_OPT
  declare -gA SUITE_DESC SUITE_CORE SUITE_REC SUITE_OPT
  local suite="" variant="" listkey="" line indent trim key val item
  while IFS= read -r line; do
    if [[ -z "$line" || "$line" == \#* ]]; then
      continue
    fi
    indent=0
    while [[ "${line:$indent:1}" == " " ]]; do
      indent=$((indent+1))
    done
    trim="${line#"${line%%[![:space:]]*}"}"
    case "$trim" in
      "suites:")
        continue
        ;;
      -*)
        item="${trim#- }"
        item="${item%\"}"
        item="${item#\"}"
        if [[ -n "$suite" ]]; then
          key="$suite"
          if [[ -n "$variant" && "$variant" != "__variants__" ]]; then
            key="$suite|$variant"
          fi
          case "$listkey" in
            core)
              SUITE_CORE[$key]+="$item "
              ;;
            recommended)
              SUITE_REC[$key]+="$item "
              ;;
            optional)
              SUITE_OPT[$key]+="$item "
              ;;
          esac
        fi
        ;;
      *:*)
        key="${trim%%:*}"
        val="${trim#*:}"
        val="${val#\"}"
        val="${val%\"}"
        if [[ $indent -eq 2 ]]; then
          suite="$key"
          variant=""
          listkey=""
          SUITE_ORDER+=("$suite")
          SUITE_DESC[$suite]="$val"
          SUITE_CORE[$suite]=""
          SUITE_REC[$suite]=""
          SUITE_OPT[$suite]=""
        elif [[ $indent -eq 4 ]]; then
          case "$key" in
            description)
              SUITE_DESC[$suite]="$val"
              ;;
            core)
              listkey="core"
              ;;
            recommended)
              listkey="recommended"
              ;;
            optional)
              listkey="optional"
              ;;
            variants)
              variant="__variants__"
              listkey=""
              ;;
          esac
        elif [[ $indent -eq 6 ]]; then
          if [[ "$suite" == "desktop" ]]; then
            case "$key" in
              description|core|recommended|optional)
                ;;
              *)
                variant="$key"
                listkey=""
                ;;
            esac
          fi
        elif [[ $indent -eq 8 ]]; then
          case "$key" in
            description)
              SUITE_DESC["$suite|$variant"]="$val"
              ;;
            core)
              listkey="core"
              ;;
            recommended)
              listkey="recommended"
              ;;
            optional)
              listkey="optional"
              ;;
          esac
        fi
        ;;
    esac
  done < "$yaml"
  if [[ ${#SUITE_ORDER[@]} -eq 0 ]]; then
    log "ERROR" "No se pudieron leer suites de $yaml"
    return 1
  fi
  log "INFO" "Suites cargadas: ${SUITE_ORDER[*]}"
}

ask_single_select() {
  local title="$1"
  shift
  local -a opts=("$@")
  SELECTED=""
  if [[ ${#opts[@]} -eq 0 ]]; then
    return 0
  fi
  local i=1
  echo "$title"
  local o
  for o in "${opts[@]}"; do
    echo "  $i) $o"
    i=$((i+1))
  done
  local r
  read -rp "Selecciona una opción (número): " r
  if [[ "$r" =~ ^[0-9]+$ ]] && (( r>=1 && r<=${#opts[@]} )); then
    SELECTED="${opts[$((r-1))]}"
  fi
}

ask_multiselect() {
  local title="$1"
  shift
  local -a opts=("$@")
  SELECTED=()
  if [[ ${#opts[@]} -eq 0 ]]; then
    return 0
  fi
  local i=1
  echo "$title"
  local o
  for o in "${opts[@]}"; do
    echo "  $i) $o"
    i=$((i+1))
  done
  local r
  read -rp "Selecciona números (separados por espacio/coma), 'a'=todos, 'n'=ninguno: " r
  if [[ "$r" == "a" || "$r" == "A" ]]; then
    SELECTED=("${opts[@]}")
    return 0
  fi
  if [[ -z "$r" || "$r" == "n" || "$r" == "N" ]]; then
    return 0
  fi
  local num
  for num in ${r//,/ }; do
    if [[ "$num" =~ ^[0-9]+$ ]] && (( num>=1 && num<=${#opts[@]} )); then
      SELECTED+=("${opts[$((num-1))]}")
    fi
  done
}

select_suites() {
  local i=1
  echo "=== SUITES DISPONIBLES ==="
  local s
  for s in "${SUITE_ORDER[@]}"; do
    echo "  $i) $s — ${SUITE_DESC[$s]}"
    i=$((i+1))
  done
  local r
  read -rp "Selecciona suites (números separados por espacio/coma), 'a'=todas, 'n'=ninguna: " r
  SELECTED_SUITES=()
  if [[ "$r" == "a" || "$r" == "A" ]]; then
    SELECTED_SUITES=("${SUITE_ORDER[@]}")
  elif [[ -n "$r" && "$r" != "n" && "$r" != "N" ]]; then
    local num
    for num in ${r//,/ }; do
      if [[ "$num" =~ ^[0-9]+$ ]] && (( num>=1 && num<=${#SUITE_ORDER[@]} )); then
        SELECTED_SUITES+=("${SUITE_ORDER[$((num-1))]}")
      fi
    done
  fi
  local has_desktop=0
  for s in "${SELECTED_SUITES[@]}"; do
    if [[ "$s" == "desktop" ]]; then
      has_desktop=1
    fi
  done
  if [[ $has_desktop -eq 1 ]]; then
    ask_single_select "Selecciona variante de desktop:" xfce kde gnome hyprland i3 none
    DESKTOP_VARIANT="$SELECTED"
    if [[ -z "$DESKTOP_VARIANT" ]]; then
      log "WARN" "No se seleccionó variante de desktop. Se omitirá la suite desktop."
      local -a tmp=()
      for s in "${SELECTED_SUITES[@]}"; do
        if [[ "$s" != "desktop" ]]; then
          tmp+=("$s")
        fi
      done
      SELECTED_SUITES=("${tmp[@]}")
    fi
  fi
  log "INFO" "Suites seleccionadas: ${SELECTED_SUITES[*]:-ninguna}"
}

collect_packages() {
  SELECTED_PACKAGES=()
  local s key core rec opt
  for s in "${SELECTED_SUITES[@]}"; do
    key="$s"
    if [[ "$s" == "desktop" ]]; then
      key="desktop|$DESKTOP_VARIANT"
    fi
    core="${SUITE_CORE[$key]:-}"
    rec="${SUITE_REC[$key]:-}"
    opt="${SUITE_OPT[$key]:-}"
    if [[ -n "${core// }" ]]; then
      echo "=== $s: paquetes core ==="
      local -a core_arr=()
      read -ra core_arr <<< "$core"
      local p
      for p in "${core_arr[@]}"; do
        echo " - $p"
      done
      if ask_yes_no "¿Incluir paquetes core de $s?"; then
        SELECTED_PACKAGES+=("${core_arr[@]}")
      fi
    fi
    if [[ -n "${rec// }" ]]; then
      local -a rec_arr=()
      read -ra rec_arr <<< "$rec"
      ask_multiselect "Recomendados de $s (opcional):" "${rec_arr[@]}"
      if [[ ${#SELECTED[@]} -gt 0 ]]; then
        SELECTED_PACKAGES+=("${SELECTED[@]}")
      fi
    fi
    if [[ -n "${opt// }" ]]; then
      local -a opt_arr=()
      read -ra opt_arr <<< "$opt"
      ask_multiselect "Opcionales de $s (opcional):" "${opt_arr[@]}"
      if [[ ${#SELECTED[@]} -gt 0 ]]; then
        SELECTED_PACKAGES+=("${SELECTED[@]}")
      fi
    fi
  done
  local -A seen=()
  local -a uniq=()
  local p
  for p in "${SELECTED_PACKAGES[@]}"; do
    if [[ -z "${seen[$p]:-}" ]]; then
      seen[$p]=1
      uniq+=("$p")
    fi
  done
  SELECTED_PACKAGES=("${uniq[@]}")
  log "INFO" "Paquetes seleccionados: ${SELECTED_PACKAGES[*]:-ninguno}"
}
