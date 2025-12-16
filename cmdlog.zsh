# cmdlog.zsh (zsh-only)
# Source this file, then use:
#   cmdlog cmds00         # start logging to ./cmds00
#   cmdlog                # stop logging
#   cmdlog final/cmds00   # stop + move log to ./final/cmds00

autoload -Uz add-zsh-hook

typeset -g CMDLOG_FILE=""
typeset -g CMDLOG_PREEXEC_FN="cmdlog__preexec"
typeset -g CMDLOG_EXIT_FN="cmdlog__on_exit"

cmdlog__ts() {
  # macOS-compatible timestamp
  date "+%Y-%m-%dT%H:%M:%S%z"
}

cmdlog__abspath() {
  local out="$1"
  [[ "$out" != /* ]] && out="$PWD/$out"
  print -r -- "$out"
}

cmdlog__ensure_dir() {
  local out="$1"
  mkdir -p -- "$(dirname -- "$out")" || return 1
}

cmdlog__preexec() {
  [[ -n "$CMDLOG_FILE" ]] || return 0
  # avoid logging the toggle command itself
  [[ "$1" == cmdlog* ]] && return 0
  print -r -- "$1" >> "$CMDLOG_FILE"
}

cmdlog__on_exit() {
  [[ -n "$CMDLOG_FILE" ]] || return 0
  cmdlog_stop
}

cmdlog_start() {
  local target="$1"
  [[ -n "$target" ]] || { echo "usage: cmdlog <output-file> (or cmdlog to stop)"; return 2; }

  local out; out="$(cmdlog__abspath "$target")" || return 1
  mkdir -p -- "$(dirname -- "$out")" || return 1
  : >> "$out" || return 1

  # if switching files, close the old one first
  if [[ -n "$CMDLOG_FILE" && "$CMDLOG_FILE" != "$out" ]]; then
    print -r -- "# stopped: $(cmdlog__ts)" >> "$CMDLOG_FILE"
  fi

  CMDLOG_FILE="$out"
  print -r -- "# started: $(cmdlog__ts)" >> "$CMDLOG_FILE"

  add-zsh-hook -d preexec cmdlog__preexec 2>/dev/null
  add-zsh-hook -d zshexit cmdlog__on_exit 2>/dev/null
  add-zsh-hook preexec cmdlog__preexec
  add-zsh-hook zshexit cmdlog__on_exit
}

cmdlog_stop() {
  [[ -n "$CMDLOG_FILE" ]] || return 0
  print -r -- "# stopped: $(cmdlog__ts)" >> "$CMDLOG_FILE"
  CMDLOG_FILE=""
}

cmdlog() {
  if [[ -n "${1:-}" ]]; then
    cmdlog_start "$1" # start or switch
  else
    cmdlog_stop # write log
  fi
}
