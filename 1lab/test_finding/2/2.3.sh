#!/bin/bash

input_file="bash.txt"

zeros_file="zeros"
nozeros_file="nozeros"

grep "000000" "$input_file" > "$zeros_file"

grep -v "000000" "$input_file" > "$nozeros_file"

echo "Первые 10 строк из $zeros_file:"
head -n 10 "$zeros_file"
echo "Последние 10 строк из $zeros_file:"
tail -n 10 "$zeros_file"

echo "Первые 10 строк из $nozeros_file:"
head -n 10 "$nozeros_file"
echo "Последние 10 строк из $nozeros_file:"
tail -n 10 "$nozeros_file"
