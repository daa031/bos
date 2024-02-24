# Лабораторная работа "Настройка сети"

## Утилита `ip`

```bash 
  ip [опции] объект команда [параметры]
```

**Опции:**  - необязательные глобальные настройки, которые сказываются на работе всей утилиты независимо от других аргументов. Некоторые опции:
- `-v`, -version — только вывод информации об утилите и ее версии
- `-h`, -human — выводить данные в удобном для человека виде
- `-s`, -stats — включает вывод статистической информации
- `-d`, -details — показывать ещё больше подробностей
- `-f`, -family — позволяет указать протокол, с которым нужно работать, если протокол не указан, то берется на основе параметров команды. Опция должна принимать одно из значений: bridge, dnet, inet, inet6, ipx или link. По умолчанию используется inet. link означает отсутствие протокола
- `-o`, -oneline — выводить каждую запись с новой строки
- `-r`, -resolve — определять имена хостов с помощью DNS
- `-a`, -all — применить команду ко всем объектам
- `-c`, -color — позволяет настроить цветной, доступные значения: auto, always и never
- `-br`, -brief — выводить только базовую информацию для удобства чтения
- `-4` — короткая запись для -f inet
- `-6` — короткая запись для -f inet -f inet6
- `-B` — короткая запись для -f inet -f bridge
- `-0` — короткая запись для -f inet -f link

**Объект** — тип данных, с которым надо будет работать, например: адреса, устройства, таблица arp, таблица маршрутизации и так далее. Важные объекты:

- `address` или `a` - сетевые адреса
- `link` или `l` - физическое сетевое устройство
- `neighbour` или `neigh` - просмотр и управление ARP
- `route` или `r` - управление маршрутизацией
- `rule` или `ru` - правила маршрутизации
- `tunnel` или `t` - настройка туннелирования

**Команда** - какое-либо действие с объектом. Если команда не задана, по умолчанию используется show (показать). Важные команды:

- `add`
- `change`
- `del` или `delete`
- `flush`
- `get`
- `list` или `show`
- `monitor`
- `replace`
- `restore`
- `save`
- `set`
- `update`

**параметры** - параметры для комманд, если они требуются


## Пакет `OpenSSH`
[ссылка на норм материал по ssh](https://hackware.ru/?p=10033#63)
OpenSSH состоит из десяти утилит:

**Удалённый доступ:**
- `ssh`
- `scp`
- `sftp`
**Управление ключами:**
- `ssh-add`
- `ssh-keysign`
- `ssh-keyscan`
- `ssh-keygen`
**Управление службой:**
- `sshd`
- `sftp-server`
- `ssh-agent`


## Задния IP

1. Для просмотра IP-адресов, связанных с сетевыми интерфейсами, выполните `ip address show` 

```bash
[root@192 ~]# ip address show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.6/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 84550sec preferred_lft 84550sec
    inet6 fe80::a00:27ff:fe32:952b/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:e9:75:9f brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.10/24 brd 192.168.56.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fee9:759f/64 scope link 
       valid_lft forever preferred_lft forever
[root@192 ~]# 
```

Интерфейс **lo** (loopback) - это стандартный интерфейс loopback. **enp0s3** и **enp0s8** - это физический сетевой интерфейс (обычно Ethernet).

**enp0s3**: link/ether 08:00:27:32:95:2b: Физический (MAC) адрес интерфейса.
inet 192.168.1.6/24: Динамический IP-адрес интерфейса, который присвоен через DHCP с маской подсети /24.
inet6 fe80::a00:27ff:fe32:952b/64: IPv6-адрес, основанный на физическом адресе, с маской /64.

- Для вывода краткой информации опция `br`

```sh
ip -br address show
```

- Для просмотра адресов определённого сетевого интерфейса (в примепе ниже — enp0s3) выполните

```bash
ip address show dev enp0s3
```

`dev` означает device. 
Для просмотра статических адресов добавьте параметр `permanent`:
```bash
ip address show dev enp0s3 permanent
```
Для просмотра динамических адресов добавьте параметр `dynamic`:
```bash
ip address show dev enp0s3 dynamic
```

```sh
[root@192 ~]# ip address show dev enp0s3
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.6/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 82560sec preferred_lft 82560sec
    inet6 fe80::a00:27ff:fe32:952b/64 scope link 
       valid_lft forever preferred_lft forever

[root@192 ~]# ip address show dev enp0s3 dynamic
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.6/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 82446sec preferred_lft 82446sec

[root@192 ~]# ip address show dev enp0s3 permanent
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a00:27ff:fe32:952b/64 scope link 
       valid_lft forever preferred_lft forever
[root@192 ~]# 

```

2. Для добавления(удаления `delete`) нового IP-адреса выполните
```sh
ip address add 172.16.132.136/24 dev enp0s3
```

```sh
[root@192 ~]# ip address add 172.16.132.136/24 dev enp0s3
[root@192 ~]# ^C
[root@192 ~]# ip address show dev enp0s3
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.6/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 82039sec preferred_lft 82039sec
    inet 172.16.132.136/24 scope global enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe32:952b/64 scope link 
       valid_lft forever preferred_lft forever
[root@192 ~]# ip address delete 172.16.132.136/24 dev enp0s3
[root@192 ~]# ip address show dev enp0s3
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.6/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 82019sec preferred_lft 82019sec
    inet6 fe80::a00:27ff:fe32:952b/64 scope link 
       valid_lft forever preferred_lft forever
```

3. Для просмотра списка интерфейсов выполните

```sh
ip link show
```

```sh
[root@192 ~]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:e9:75:9f brd ff:ff:ff:ff:ff:ff
[root@192 ~]# 
```

4. Для изменения параметров используется команда `set`. Соответственно, для включения и выключения интерфейсов используются команды `ip link set dev <имя_интерфейса> up` и `ip link set dev <имя_интерфейса> down`:

```sh
ip link set dev enp0s3 down
```
Если выполнить эту команду по SSH, ожидаемо оборвётся соединение.


***MTU*** (Maximum Transmission Unit) - это максимальный размер пакета данных, который может быть передан по сети без фрагментации. Он измеряется в байтах и определяет максимальный размер данных, который может быть включен в один сетевой пакет.

Для изменения MTU (maximum transmission unit) — максимального размера передаваемых пакетов — выполните следующую команду:
```sh
ip link set mtu 4000 dev enp0s3
```
Для просмотра текущего значения:
```sh 
ip link show enp0s3
```
Пример
```sh
[root@192 ~]# ip link show enp0s3
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
[root@192 ~]# ip link set mtu 4000 dev enp0s3
[root@192 ~]# ip link show enp0s3
2: enp0s3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 4000 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether 08:00:27:32:95:2b brd ff:ff:ff:ff:ff:ff
```
Для изменения MAC-адреса необходимо выключить интерфейс, выполнить

```bash
ip link set dev ens160 address AA:BB:CC:DD:EE:FF
```
и после этого включить интерфейс.

5. Для просмотра кэшированной ARP-таблицы выполните

```sh
ip neigh show
```

**ARP** (Address Resolution Protocol) - это протокол, используемый в компьютерных сетях для связи между устройствами на уровне канала передачи данных (Data Link Layer) модели OSI. Основная задача ARP - связать IP-адрес устройства с его физическим (MAC) адресом.

ARP-таблица (или ARP-кэш) представляет собой таблицу соответствия IP-адресов и MAC-адресов устройств в локальной сети. Она хранится на устройствах, таких как компьютеры и маршрутизаторы, и используется для быстрого определения MAC-адреса, соответствующего определенному IP-адресу.



```sh
[root@192 ~]# ip neigh show
192.168.1.1 dev enp0s3 lladdr 28:de:a8:6e:7a:76 STALE 
192.168.56.1 dev enp0s8 lladdr 0a:00:27:00:00:00 DELAY 
192.168.1.10 dev enp0s3 lladdr e8:6f:38:71:c4:cd STALE 
[root@192 ~]# 
```
Для ручного добавления записи в эту таблицу выполните

```sh
ip neigh add 172.16.132.2 lladdr 23:f6:72:44:2a:c1 dev enp0s3
```

```sh
[root@192 ~]# ip neigh show
192.168.1.1 dev enp0s3 lladdr 28:de:a8:6e:7a:76 STALE 
192.168.56.1 dev enp0s8 lladdr 0a:00:27:00:00:00 DELAY 
192.168.1.10 dev enp0s3 lladdr e8:6f:38:71:c4:cd STALE 
[root@192 ~]# ip neigh add 172.16.132.2 lladdr 23:f6:72:44:2a:c1 dev enp0s3
[root@192 ~]# ip neigh show
172.16.132.2 dev enp0s3 lladdr 23:f6:72:44:2a:c1 PERMANENT 
192.168.1.1 dev enp0s3 lladdr 28:de:a8:6e:7a:76 STALE 
192.168.56.1 dev enp0s8 lladdr 0a:00:27:00:00:00 REACHABLE 
192.168.1.10 dev enp0s3 lladdr e8:6f:38:71:c4:cd STALE 
```

Для просмотра таблицы маршрутизации хоста выполните

```sh
ip route show
```

```sh
[root@192 ~]# ip route show
default via 192.168.1.1 dev enp0s3 proto dhcp src 192.168.1.6 metric 102 
192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.6 metric 102 
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.10 metric 103 
```
    Таблица маршрутизации хоста представляет собой базу данных, в которой хост (компьютер или другое устройство в сети) хранит информацию о том, как маршрутизировать сетевой трафик. Эта таблица содержит записи о доступных маршрутах к различным сетям, и хост использует ее для принятия решений о том, как доставить пакеты данных до их конечного назначения.

- **Объяснение default**
   - `default`: эта строка представляет собой маршрут по умолчанию, используемый, когда нет конкретного маршрута для назначения.
   - `via 192.168.1.1`: Трафик, не соответствующий какому-либо конкретному маршруту, направляется через шлюз с IP-адресом 192.168.1.1.
   - `dev enp0s3`: Исходный сетевой интерфейс для маршрута по умолчанию — enp0s3.
   - `proto dhcp`: Протокол, используемый для определения маршрута по умолчанию — DHCP.
   - `src 192.168.1.6`: Используемый исходный IP-адрес для маршрута по умолчанию — 192.168.1.6.
   - `metric 102`: Метрика, измеряющая стоимость маршрута. Низкие значения метрики предпочтительны

- **Объяснение 192.168.1.0/24**
   - `192.168.1.0/24`: Эта строка представляет собой конкретный маршрут для диапазона IP-адресов от 192.168.1.0 до 192.168.1.255.
   - `proto kernel`: Маршрут был добавлен ядром.
   - `scope link`: Маршрут напрямую доступен по ссылке.
   - `src 192.168.1.6`: Исходный IP-адрес для этого маршрута — 192.168.1.6.

Выведите таблицу маршрутизации **local**.

```sh
[root@localhost ~]# ip route show table local
```  
```sh
[root@localhost ~]# ip route show table local
local 127.0.0.0/8 dev lo proto kernel scope host src 127.0.0.1 
local 127.0.0.1 dev lo proto kernel scope host src 127.0.0.1 
broadcast 127.255.255.255 dev lo proto kernel scope link src 127.0.0.1 
local 192.168.3.40 dev enp0s3 proto kernel scope host src 192.168.3.40 
broadcast 192.168.3.255 dev enp0s3 proto kernel scope link src 192.168.3.40 
local 192.168.56.10 dev enp0s8 proto kernel scope host src 192.168.56.10 
broadcast 192.168.56.255 dev enp0s8 proto kernel scope link src 192.168.56.10 
```

7. Для добавления маршрута выполните `ip route add <подсеть>/<маска> via <шлюз>` или `ip route add <подсеть>/<маска> dev <интерфейс>`:
```sh 
sudo ip route add 169.255.0.0 dev enp0s3
```
Соответственно, удаление маршрута:
```sh
sudo ip route del 169.255.0.0 dev enp0s3
```

```sh
[root@localhost ~]# ip route show
default via 192.168.3.1 dev enp0s3 proto dhcp src 192.168.3.40 metric 100 
192.168.3.0/24 dev enp0s3 proto kernel scope link src 192.168.3.40 metric 100 
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.10 metric 101 
[root@localhost ~]# sudo ip route add 169.255.0.0 dev enp0s3
[root@localhost ~]# ip route show
default via 192.168.3.1 dev enp0s3 proto dhcp src 192.168.3.40 metric 100 
169.255.0.0 dev enp0s3 scope link 
192.168.3.0/24 dev enp0s3 proto kernel scope link src 192.168.3.40 metric 100 
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.10 metric 101 
[root@localhost ~]# sudo ip route del 169.255.0.0 dev enp0s3
[root@localhost ~]# ip route show
default via 192.168.3.1 dev enp0s3 proto dhcp src 192.168.3.40 metric 100 
192.168.3.0/24 dev enp0s3 proto kernel scope link src 192.168.3.40 metric 100 
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.10 metric 101 
```

## Задния SSH
1. Установите SSH-сервер:
```sh
dnf install openssh-server
```

Чтобы зайти на сервер используйте команду

```sh
ssh username@server
```

2. Для изменения настроек sshd конфигурационный файл `/etc/ssh/sshd_config`.
 - `Port` - изменить стандартный порт.
 - `PasswordAuthentication` - запретить вход по паролю
 - `PermitRootLogin` - убрать возможность входа от лица суперпользователя 
 - `AllowUsers` - разрешить вход только определённым пользователям 
 - `AllowGroups` - разрешить вход только определённымпользователям определённых групп
 
Изменим порт SSH на 2222. После изменения порта необходимо добавить его в SELinux (об этом позже в курсе). Для этого необхдимо выполнить

```sh
semanage port -a -t ssh_port_t -p tcp 2222
```
добавляет новый порт с номером 2222, устанавливая для него тип контекста безопасности ssh_port_t и указывая, что он использует протокол TCP. Это может быть полезным, например, если вы хотите использовать нестандартный порт для SSH и при этом сохранить настройки SELinux.

Также необходимо настроить правило межсетевого экрана:

```sh
firewall-cmd --zone public --add-port 2222/tcp --permanent && firewall-cmd --reload
```

Перезапустить службу sshd:

```sh
systemctl restart sshd
```

Теперь доступ к SSH будет производиться по порту `2222`. Для этого при подключении необходимо явно указывать порт: `ssh -p 2222 ...`.

3. Для создания ключа SSH используется команда ssh-keygen:

```sh
ssh-keygen -t ed25519 -C comment -f ~/.ssh/rocky4
```
```sh
daa031@fedora:~$ ssh-keygen -t ed25519 -C comment -f ~/.ssh/rocky4
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/daa031/.ssh/rocky4
Your public key has been saved in /home/daa031/.ssh/rocky4.pub
The key fingerprint is:
SHA256:7DM2uqQG0U5Z/IlaGsSIefnI9veRHdB4xR8Q7Mkw0FQ comment
The key's randomart image is:
+--[ED25519 256]--+
| o + .  .*.=Eo   |
|o + o o o * o .  |
| o = o o + = o . |
|  = * o.o . + .  |
| . = =  So .     |
|  . = ..o .      |
|   . ...*.       |
|    .o o.+       |
|   .. o.         |
+----[SHA256]-----+
daa031@fedora:~$ 
```








## Допуск
- Какие адреса идентифицируют устройство в сети?
   - **MAC-адрес** (Media Access Control): Это уникальный идентификатор сетевого адаптера на уровне канала передачи данных в сети. MAC-адрес присваивается производителем сетевого оборудования.

   - **IP-адрес** (Internet Protocol): Это логический адрес, который используется для идентификации устройства в сети на уровне интернет-протокола. IP-адреса могут быть присвоены устройствам статически или динамически с использованием протокола DHCP.

   - **DNS-имя** (Domain Name System): Это символьное имя, которое преобразуется в IP-адрес при обращении к сетевому устройству. DNS-имена используются для более удобного обращения к устройствам, чем использование IP-адресов.

   - **URL** (Uniform Resource Locator): Это адрес, который указывает на конкретный ресурс в Интернете. URL включает в себя протокол (например, http:// или https://) и DNS-имя или IP-адрес.

   - **Port Number** (номер порта): Вместе с IP-адресом идентифицирует конкретный процесс или службу на устройстве. В комбинации с IP-адресом, это обеспечивает уникальную адресацию конкретной службы.


- На каком уровне модели OSI работает ARP?\

   Протокол **ARP** (Address Resolution Protocol) работает на **втором** уровне модели OSI, который известен как уровень канала (Data Link Layer). Протокол ARP предназначен для поиска соответствия между логическими (IP-адресами) и физическими (MAC-адресами) адресами в локальной сети. Он используется для определения MAC-адреса устройства, имея его IP-адрес, и наоборот. ARP сообщения отправляются в пределах локальной сети и не маршрутизируются через маршрутизаторы.

- Что такое таблица маршрутизации?

   Таблица маршрутизации (Routing Table) — это база данных, которая используется в компьютерных сетях и маршрутизаторах для определения того, каким образом должны быть направлены сетевые пакеты данных. Она содержит информацию о том, через какие сетевые интерфейсы и маршруты должны быть направлены данные к конкретным сетевым узлам или подсетям.

   Эта таблица включает в себя записи о сетевых адресах и ассоциированных с ними маршрутах. Когда устройство в сети отправляет данные на удаленный адрес, оно консультирует таблицу маршрутизации, чтобы определить, через какой интерфейс и маршрут следует отправить пакет.

   Записи в таблице маршрутизации могут быть статическими (вручную настроенными администратором) или динамическими (автоматически обновляемыми протоколами динамической маршрутизации). Протоколы динамической маршрутизации, такие как OSPF (Open Shortest Path First) или RIP (Routing Information Protocol), могут автоматически обмениваться информацией о маршрутах между маршрутизаторами, обновляя таблицы маршрутизации для оптимального маршрута в сети.

- Какие методы аутентификации присутствуют в SSH?

   - **Парольная аутентификация** (Password Authentication): Это самый простой метод, при котором пользователь вводит свой пароль для подтверждения подлинности. Однако, этот метод может быть уязвим к атакам подбора паролей, поэтому часто рекомендуется использовать другие более безопасные методы.

   - **Аутентификация на основе открытого ключа** (Public Key Authentication): Этот метод использует пару открытого и закрытого ключей. Пользователь создает пару ключей, где закрытый ключ остается на клиентской стороне, а открытый ключ добавляется в файл authorized_keys на сервере. При попытке подключения клиент предоставляет свой открытый ключ, и сервер проверяет его с помощью соответствующего закрытого ключа.

   - **Аутентификация по сертификату** (Certificate-Based Authentication): Этот метод представляет собой расширение аутентификации на основе открытого ключа и использует сертификаты для управления ключами и подписями. Сертификаты предоставляют дополнительные уровни безопасности и управления ключами.

