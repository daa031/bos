#!/bin/bash

if [$# -ne 1]; then
	echo "передан не один аргумент"
	exit 1
fi

name="$1"

test() {
  local args=("$@")
  echo "Запуск сценария $name с аргументами: ${args[*]}"
  ./"$name" "${args[@]}"
  echo "===================================="
}

test 1 2 3

random_nums=("$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM")
test "${random_nums[@]}"

test "foo" "bar" "foobar" "foo bar"

test "foo" "--foo" "--help" "-l"

