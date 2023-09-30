#!/bin/bush

echo "Вызов с объединённым списком аргументов:"
/home/daa031/Desktop/study/bos/1lab/test_finding/3/bin/3.1.sh "$@"

echo "Вызов с аргументами по отдельности:"
for arg in "$@"; do
  /home/daa031/Desktop/study/bos/1lab/test_finding/3/bin/3.1.sh "$arg"
done
