#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <name> <command> [args...]" >&2
  exit 64
fi

NAME="$1"
shift
TAIL_LINES="${LOUPE_CI_TAIL_LINES:-120}"
SUMMARY_BYTES="${LOUPE_CI_SUMMARY_BYTES:-1800}"
DIAGNOSTIC_GLOBS="${LOUPE_CI_DIAGNOSTICS:-/tmp/loupe-*}"
OUTPUT_LOG="/tmp/loupe-ci-${NAME//[^[:alnum:]._-]/-}.log"

set +e
"$@" > >(tee "$OUTPUT_LOG") 2>&1
STATUS=$?
set -e
STATUS="${STATUS:-0}"
if [[ "$STATUS" -eq 0 ]]; then
  exit 0
fi

SUMMARY="$(
  tail -n 80 "$OUTPUT_LOG" 2>/dev/null \
    | tail -c "$SUMMARY_BYTES" \
    | tr '\n' ' ' \
    | sed 's/%/%25/g; s/\r/%0D/g' \
    | cut -c 1-"$SUMMARY_BYTES"
)"
if [[ -z "$SUMMARY" ]]; then
  SUMMARY="Command exited with status ${STATUS}"
else
  SUMMARY="Command exited with status ${STATUS}. Last output: ${SUMMARY}"
fi
echo "::error title=${NAME} failed::${SUMMARY}"
echo "::group::Loupe diagnostics"
for pattern in $DIAGNOSTIC_GLOBS; do
  matches=( $pattern )
  if [[ "${matches[0]}" == "$pattern" && ! -e "${matches[0]}" ]]; then
    continue
  fi

  for path in "${matches[@]}"; do
    if [[ -d "$path" ]]; then
      echo "--- $path/ ---"
      find "$path" -maxdepth 2 -type f | sort | head -50
      continue
    fi

    if [[ ! -f "$path" ]]; then
      continue
    fi

    byte_count="$(wc -c <"$path" | tr -d ' ')"
    echo "--- $path (${byte_count} bytes) ---"
    case "$path" in
      *.json|*.log|*.txt)
        tail -n "$TAIL_LINES" "$path" || true
        ;;
      *)
        echo "skipping binary or unsupported diagnostic preview"
        ;;
    esac
  done
done
echo "::endgroup::"

exit "$STATUS"
