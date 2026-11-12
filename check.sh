#!/usr/bin/env bash
# Run every program in the repository, in both engines, and compare what
# it prints with the output recorded next to it. Then compare the engines
# with each other.
#
#   ./check.sh            compare
#   ./check.sh --update   record the current output as expected
#
# An egglog program that needs options says so on its first line:
# "; flags: --proofs". facts.egg holds data only: it is included by the
# egglog programs and read by the Prolog ones, so it is not run.

set -u
cd "$(dirname "$0")"

if ! command -v egglog >/dev/null 2>&1; then
  echo "egglog not found. Install it with: cargo install egglog --locked --version 3.0.0" >&2
  exit 2
fi
if ! command -v swipl >/dev/null 2>&1; then
  echo "swipl not found. Install SWI-Prolog 9: apt install swi-prolog-nox, or brew install swi-prolog" >&2
  exit 2
fi

update=0
[ "${1:-}" = "--update" ] && update=1

# egglog's warnings span several indented lines and name internal
# variables that change between versions. They are dropped so the
# recorded output is stable.
strip_warnings() {
  awk '
    /^\[WARN \]/ { skipping = 1; next }
    skipping && /^[[:space:]]/ { next }
    skipping && /^$/ { next }
    { skipping = 0; print }
  '
}

status=0

compare() {  # program, expected file, actual output
  if [ "$update" = 1 ]; then
    mkdir -p "$(dirname "$2")"
    printf '%s\n' "$3" > "$2"
    echo "recorded  $1"
  elif [ ! -f "$2" ]; then
    echo "MISSING   $2"
    status=1
  elif [ "$3" = "$(cat "$2")" ]; then
    echo "ok        $1"
  else
    echo "DIFFERS   $1"
    diff <(printf '%s\n' "$3") "$2" | sed 's/^/    /'
    status=1
  fi
}

for program in cases/*/*.egg frictions/*.egg; do
  dir=$(dirname "$program")
  name=$(basename "$program" .egg)
  [ "$name" = "facts" ] && continue

  flags=$(sed -n '1s/^; flags: //p' "$program")

  # egglog resolves (include ...) from the working directory.
  actual=$(
    cd "$dir" || exit
    # shellcheck disable=SC2086
    egglog $flags "$name.egg" 2>&1 | strip_warnings
    echo "exit=${PIPESTATUS[0]}"
  )
  compare "$program" "$dir/expected/$name.txt" "$actual"
done

for program in cases/*/*.pl frictions/*.pl; do
  dir=$(dirname "$program")
  name=$(basename "$program" .pl)

  actual=$(
    cd "$dir" || exit
    swipl "$name.pl" 2>&1
    echo "exit=$?"
  )
  compare "$program" "$dir/expected/$name.pl.txt" "$actual"
done

# The two engines. Where a program exists in both, every block made of a
# quoted label followed by numbers must be the same block in both outputs:
# same hypotheses, in the same order, with the same counts.
numbers() {
  awk '
    /^"/        { label = $0; next }
    /^[0-9]+$/  { if (label != "") { print label; label = "" } print; next }
                { label = "" }
  ' "$1"
}

for prolog in cases/*/expected/*.pl.txt; do
  egglog="${prolog%.pl.txt}.txt"
  [ -f "$egglog" ] || continue
  wanted=$(numbers "$egglog")
  [ -n "$wanted" ] || continue
  blocks=$(printf '%s\n' "$wanted" | grep -c '^"')
  if [ "$wanted" = "$(numbers "$prolog")" ]; then
    echo "agree     $egglog and $(basename "$prolog") (blocks: $blocks)"
  else
    echo "DISAGREE  $egglog and $(basename "$prolog")"
    diff <(printf '%s\n' "$wanted") <(numbers "$prolog") | sed 's/^/    /'
    status=1
  fi
done

exit $status
