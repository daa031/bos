# 6 Лабораторная работа  "Управление пакетами"

## Работа с настроенными rpm-репозиториями

1. Выведите список доступных репозиториев и групп (коллекций) пакетов. Определите количество пакетов в каждом из них.
```bash
yum repolist
yum grouplist
```
Выведите список установленных пакетов и подсчитайте их количество.
```bash

rpm -qa | less
rpm -qa | wc -l
yum list installed | less
```
Определите установлен ли в системе пакет построения графиков функций gnuplot.
```bash
rpm -qa | grep gnuplot
```
Найдите пакет gnuplot в доступных репозиториях.
```bash
yum search gnuplot
```
Выведите информацию о пакете gnuplot.
```bash
yum info gnuplot
```
Установите пакет gnuplot.
```bash
sudo yum install gnuplot
```
Какие еще пакеты были установлены для удовлетворения зависимостей?

Выведите информацию об установленном пакете.
```bash
rpm -qi gnuplot
yum list installed gnuplot
```
Выведите список установленных файлов из пакета gnuplot.

```bash
rpm -ql gnuplot
```
Определите, к какому пакету относится файл /usr/bin/gnuplot-wx.
```bash
rpm -qf /usr/bin/gnuplot-wx
```
Определите зависимости для пакета gnuplot.
```bash
yum deplist gnuplot
```
Попробуйте удалить пакет gnuplot-common с помощью утилиты rpm.
```bash```bash

sudo rpm -e gnuplot-common
```
Удалите пакет gnuplot и его зависимости. Сравните работу утилит rpm и yum.
```bash
sudo yum remove gnuplot-common
```daa031@192:~$ tar -cvzf rpmbuild/ backrpm
tar: backrpm: Функция stat завершилась с ошибкой: Нет такого файла или каталога
tar (child): rpmbuild/: Функция open завершилась с ошибкой: Это каталог
tar (child): Error is not recoverable: exiting now
tar: Child returned status 2
tar: Error is not recoverable: exiting now
daa031@192:~$ 



Убедитесь, что подключенный репозиторий доступен.
```bash
sudo yum clean all
sudo yum repolist yandex
```

## Создание rpm-пакета из сценария на языке Bash


## Создание rpm-пакета из программы на языке C

