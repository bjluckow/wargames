# usage: source ./utils.sh

begin() {
  lvl="$1"
  [ -n "$lvl" ] || { echo "usage: login <banditN>"; return 2; }

  host="bandit.labs.overthewire.org"
  port=2220
  out="$lvl"

  if [ -e "$out" ]; then
    echo "output file already exists: $out" >&2
    return 1
  fi

  script -q "${out}" ssh "${lvl}@${host}" -p "${port}"
}

redact() {
  file="$1"
  secrets_log="${2:-./secrets.txt}"
  [ -n "${file:-}" ] && [ -n "${secrets_log:-}" ] || {
    echo "usage: pbpaste | redact <file> <secrets_log>"
    return 2
  }

  pw="$(cat)"
  pw="${pw%$'\n'}"
  [ -n "$pw" ] || { echo "empty password on stdin"; return 2; }

  # redact in-place
  PW="$pw" perl -i -pe 's/\Q$ENV{PW}\E/<PASSWORD REDACTED>/g' -- "$file"

  # append "<file> <password>\n" to secrets_log
  mkdir -p "$(dirname "$secrets_log")" 2>/dev/null || true
  printf "%s %s\n" "$file" "$pw" >> "$secrets_log"
}

lastpw() {
  secrets_file="${1:-./secrets.txt}"
  [ -f "$secrets_file" ] || { echo "missing: $secrets_file"; return 2; }

  pw="$(tail -n 1 -- "$secrets_file" | awk '{print $NF}')"
  [ -n "$pw" ] || { echo "no password found"; return 2; }

  printf "%s" "$pw" | pbcopy
  echo "copied last password from $secrets_file"
}
