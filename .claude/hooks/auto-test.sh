#!/usr/bin/env bash
# Finds and runs the matching test file after Claude edits a source file.
# PostToolUse hook for Edit|Write. Always exits 0.
# Silent on success — only emits output when tests fail, so passing tests
# contribute zero tokens. Skips test files, config, docs, non-code extensions.
#
# Eugen's path is pytest (Hades/Hermes/TrueSpend suites); unittest is the
# fallback. Non-code edits (his .md vault notes) are skipped by extension, so
# this is inert in the vault.

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
EXTENSION="${BASENAME##*.}"
NAME="${BASENAME%.*}"
DIR=$(dirname "$FILE_PATH")

# Skip if the edited file IS a test file.
case "$BASENAME" in
  *.test.*|*.spec.*|*_test.*|*_spec.*|test_*|spec_*) exit 0 ;;
esac

# Skip config, style, and non-code files.
case "$EXTENSION" in
  json|yaml|yml|toml|ini|cfg|env|md|txt|css|scss|less|svg|png|jpg|ico|html) exit 0 ;;
esac

# Skip files in non-testable directories.
case "$FILE_PATH" in
  */.claude/*|*/public/*|*/static/*|*/assets/*|*/__mocks__/*) exit 0 ;;
esac

find_project_root() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/package.json" ] || [ -f "$dir/pyproject.toml" ] || [ -f "$dir/Cargo.toml" ] || [ -f "$dir/go.mod" ] || [ -d "$dir/.git" ]; then
      echo "$dir"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo "$PWD"
}

ROOT=$(find_project_root)
STEM="$NAME"

find_test_file() {
  local stem="$1"
  local ext="$2"

  local patterns=(
    "${stem}.test.${ext}"
    "${stem}.spec.${ext}"
    "${stem}_test.${ext}"
    "${stem}_spec.${ext}"
    "test_${stem}.${ext}"
  )

  for pattern in "${patterns[@]}"; do
    [ -f "${DIR}/${pattern}" ] && { echo "${DIR}/${pattern}"; return; }
  done

  for pattern in "${patterns[@]}"; do
    [ -f "${DIR}/__tests__/${pattern}" ] && { echo "${DIR}/__tests__/${pattern}"; return; }
  done

  local rel_dir="${DIR#$ROOT/}"
  local test_rel_dir
  for test_root in "tests" "test" "__tests__" "spec"; do
    test_rel_dir=$(echo "$rel_dir" | sed "s|^src/|${test_root}/|;s|^lib/|${test_root}/|")
    for pattern in "${patterns[@]}"; do
      [ -f "${ROOT}/${test_rel_dir}/${pattern}" ] && { echo "${ROOT}/${test_rel_dir}/${pattern}"; return; }
    done
  done

  local found
  for pattern in "${patterns[@]}"; do
    found=$(find "$ROOT" -maxdepth 5 -name "$pattern" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.venv/*" -print -quit 2>/dev/null)
    [ -n "$found" ] && { echo "$found"; return; }
  done
}

TEST_FILE=$(find_test_file "$STEM" "$EXTENSION")

if [ -z "$TEST_FILE" ]; then
  exit 0
fi

REL_TEST="${TEST_FILE#$ROOT/}"

OUTPUT=""
EXIT=0
case "$EXTENSION" in
  js|jsx|ts|tsx|mjs|cjs)
    if [ -f "$ROOT/node_modules/.bin/vitest" ]; then
      OUTPUT=$(cd "$ROOT" && npx vitest run "$REL_TEST" 2>&1); EXIT=$?
    elif [ -f "$ROOT/node_modules/.bin/jest" ]; then
      OUTPUT=$(cd "$ROOT" && npx jest "$REL_TEST" 2>&1); EXIT=$?
    elif [ -f "$ROOT/node_modules/.bin/mocha" ]; then
      OUTPUT=$(cd "$ROOT" && npx mocha "$REL_TEST" 2>&1); EXIT=$?
    else
      OUTPUT=$(cd "$ROOT" && npm test -- "$REL_TEST" 2>&1); EXIT=$?
    fi
    ;;
  py)
    if command -v pytest >/dev/null 2>&1; then
      OUTPUT=$(cd "$ROOT" && pytest "$REL_TEST" 2>&1); EXIT=$?
    elif command -v python >/dev/null 2>&1; then
      OUTPUT=$(cd "$ROOT" && python -m unittest "$REL_TEST" 2>&1); EXIT=$?
    elif command -v python3 >/dev/null 2>&1; then
      OUTPUT=$(cd "$ROOT" && python3 -m unittest "$REL_TEST" 2>&1); EXIT=$?
    fi
    ;;
  go)
    OUTPUT=$(cd "$DIR" && go test ./... 2>&1); EXIT=$?
    ;;
  rs)
    OUTPUT=$(cd "$ROOT" && cargo test 2>&1); EXIT=$?
    ;;
  *)
    exit 0
    ;;
esac

if [ "$EXIT" -ne 0 ]; then
  echo "auto-test: failures in $REL_TEST"
  echo "$OUTPUT"
fi

exit 0
