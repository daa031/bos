#!/bin/bash

# Путь к домашнему каталогу пользователя
home_directory="."

# Создаем временный файл для хранения списка файлов
temp_file=$(mktemp txt_files.XXXXXX)

# Используем find для поиска файлов с расширением ".txt" в домашнем каталоге
find "$home_directory" -type f -name "*.txt" > "$temp_file"

# Выводим список найденных файлов
echo "Список файлов с расширением .txt:"
cat "$temp_file"

# Используем wc длqя подсчета строк в найденных файлах
total_lines=$(cat "$temp_file" | xargs wc -l | awk '{total += $1} END {print total}')

# Используем du для подсчета суммарного размера в байтах
total_size=$(cat "$temp_file" | xargs du -cb | tail -n 1 | cut -f1)

# Выводим суммарный размер и количество строк
echo "Суммарный размер файлов (в байтах): $total_size"
echo "Суммарное количество строк: $total_lines"

# Удаляем временный файл
rm "$temp_file"
