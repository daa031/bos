#!/bin/bash

# Получаем имя текущего пользователя и его домашний каталог
user_name=$(whoami)
home_dir=$(eval echo ~$user_name)

# Вычисляем количество символов в имени пользователя и домашнем каталоге
user_name_length=${#user_name}
home_dir_length=${#home_dir}

# Выводим информацию в одну строку
echo "$user_name $home_dir $((user_name_length + home_dir_length))"
