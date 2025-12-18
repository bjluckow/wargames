#!/bin/zsh
set -euo pipefail

file="${1:?usage: pbpaste | redact <file> <secrets_log>}"
secrets_log="${2:?usage: pbpaste | redact <file> <secrets_log>}"

pw="$(cat)"
pw="${pw%$'\n'}"  # drop trailing newline
[[ -n "$pw" ]] || { echo "empty password on stdin"; exit 2; }

# redact in-place
PW="$pw" perl -i -pe 's/\Q$ENV{PW}\E/<PASSWORD REDACTED>/g' -- "$file"

# record: <filename> <password>\n  (append)
mkdir -p -- "$(dirname -- "$secrets_log")" 2>/dev/null || true
print -r -- "$file $pw" >> "$secrets_log"
