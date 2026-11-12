#!/usr/bin/env bash
# Run every egglog program in the repository and compare what it prints
# with the output recorded next to it.
#
#   ./check.sh            compare
#   ./check.sh --update   record the current output as expected
#
# A program that needs options says so on its first line: "; flags: --proofs".
# facts.egg holds data only and is included by the others, so it is skipped.

set -u
cd "$(dirname "$0")"

if ! command -v egglog >/dev/null 2>&1; then
  echo "egglog not found. Install it with: cargo install egglog --locked --version 3.0.0" >&2
  exit 2
fi

update=0
[ "${1:-}" = "--update" ] && update=1

# Warnings span several indented lines and name internal variables that
# change between versions. They are dropped so the recorded output is stable.
strip_warnings() {
  awk '
    /^\[WARN \]/ { skipping = 1; next }
    skipping && /^[[:space:]]/ { next }
    skipping && /^$/ { next }
    { skipping = 0; print }
  '
}

status=0
for program in cases/*/*.egg frictions/*.egg; do
  dir=$(dirname "$program")
  name=$(basename "$program" .egg)
  [ "$name" = "facts" ] && continue

  flags=$(sed -n '1s/^; flags: //p' "$program")
  expected="$dir/expected/$name.txt"

  # egglog resolves (include ...) from the working directory.
  actual=$(
    cd "$dir" || exit
    # shellcheck disable=SC2086
    egglog $flags "$name.egg" 2>&1 | strip_warnings
    echo "exit=${PIPESTATUS[0]}"
  )

  if [ "$update" = 1 ]; then
    mkdir -p "$dir/expected"
    printf '%s\n' "$actual" > "$expected"
    echo "recorded  $program"
  elif [ ! -f "$expected" ]; then
    echo "MISSING   $expected"
    status=1
  elif [ "$actual" = "$(cat "$expected")" ]; then
    echo "ok        $program"
  else
    echo "DIFFERS   $program"
    diff <(printf '%s\n' "$actual") "$expected" | sed 's/^/    /'
    status=1
  fi
done

exit $status
