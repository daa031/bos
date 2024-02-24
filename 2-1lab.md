# Лабораторная работа "Управление файловыми системами"


## 1. Изучение свойств блочных устройств

### 1.1  `ls -l /dev/sda{,[123]}`
- `ls -l /dev/sda{,[123]}` - 
    - в выводе `b` - означает блочное устройство. 
    -  `/dev/sda` основное блочное устройство, связанное с жестким диском
    - `sda{,[123]}` - разделы 
### 1.2 `lsblk` 
- `lsblk` - используется для отображения информации о блочных устройствах (например, жестких дисках) в виде древовидной структуры. 
    - `RM` - 0-устройство не извелаемое (non-removable);1-извлекаемое. 
    - `MAJ`(Major) - номер обозначает основное блочное устройство. Он связан с драйвером устройства, который управляет этим устройством.
    - `MIN`(Minor) - омер используется для идентификации конкретного раздела или подустройства внутри основного блочного устройства. Каждый раздел имеет свой уникальный MIN номер.
    - `RO` - "Read-Only"

```sh 
[daa@10 ~]$ lsblk --list
NAME       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda          8:0    0   20G  0 disk 
sda1         8:1    0    1G  0 part /boot
sda2         8:2    0   19G  0 part 
sr0         11:0    1 1024M  0 rom  
rl_10-root 253:0    0   17G  0 lvm  /
rl_10-swap 253:1    0    2G  0 lvm  [SWAP]
```

### 1.3 `/proc/diskstats`
- `cat /proc/diskstats `
    - файл `/proc/diskstats ` - предоставляет статистику о вводе-выводе для блочных устройств, содержит информацию о количестве операций чтения и записи, а также времени занятости устройств.

### 1.4 `partprobe -s`
Команда partprobe используется для обновления ядра Linux о текущем состоянии разделов на диске без необходимости перезапуска системы. Она обновляет ядро с информацией о новых или измененных разделах, которые могли появиться после изменений в таблице разделов.

Опция -s в команде partprobe -s добавляет дополнительный вывод для отображения информации о событиях, связанных с разделами. Это может быть полезно для отслеживания изменений, вносимых командой partprobe.

GPT, или GUID Partition Table, представляет собой стандарт для организации таблицы разделов на жестком диске. Эта технология использует уникальные идентификаторы GUID (Globally Unique Identifiers) для идентификации разделов. GPT является более современным и гибким методом управления разделами по сравнению с устаревшей технологией MBR (Master Boot Record).

### 1.5  `df -Th -x tmpfs -x devtmpfs`
- Вывести статистику использования файловых систем.
```sh
$ df -Th -x tmpfs -x devtmpfs
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/nvme0n1p6 ext4   49G   42G  5.4G  89% /
/dev/nvme0n1p5 ext4  974M  291M  616M  33% /boot
/dev/nvme0n1p4 vfat  599M   27M  573M   5% /boot/efi
/dev/nvme0n1p7 ext4  412G  319G   73G  82% /home
```

### 1.6 `cat /proc/devices `
Вывести информацию о зарегистрированных в ядре драйверах блочных устройств. Определить номер драйвера жесткого диска.
```sh
$ cat /proc/devices 
Character devices:
  1 mem
  5 /dev/tty
  5 /dev/console
...
Block devices:
  7 loop
  8 sd
...
259 blkext
```

## 2. Создание и монтирование файловой системы

1. Создать файл размером 100 Мегабайт.
- `truncate` - предназначенная для изменения размера файла до указанного размера.

    - `-s 100M`- указывает новый размер файлa(100мб) 
    - `fs-2024.img` - имя файла, который будет создан или изменен.

- `du`: Это команда для подсчета использования дискового пространства.
    `-s` - показывает только общий (суммарный) размер для указанных файлов или директорий, без детализации для каждого подфайла или поддиректории.

```sh
[daa@10 lab1]$ truncate -s 100M fs-2024.img
[daa@10 lab1]$ ls -lh
total 0
-rw-r--r--. 1 daa daa 100M Feb 23 17:29 fs-2024.img
[daa@10 lab1]$ du -s fs-2024.img
0	fs-2024.img
```

2. Связать созданный файл с блочным устройством loop.

- `losetup --find --show fs-2024.img`-  используется для ассоциирования блочного устройства loop с указанным файлом образа диска (в данном случае, fs-2024.img).


- `losetup`- используется для управления блочными устройствами loop.

- `--find`: Это опция, которая говорит losetup автоматически найти первое доступное блочное устройство loop, упрощает процесс поиска свободного устройства loop, так что вам не нужно вручную указывать /dev/loopX.

- `--show` - требует от losetup вывести имя ассоциированного устройства loop после его настройки.

- `fs-2024.img` - Это имя файла образа диска, который будет использоваться для создания блочного устройства loop.


```sh   
[daa@10 lab1]$ sudo losetup --find --show fs-2024.img
/dev/loop0
[daa@10 lab1]$ losetup --list
NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE                  DIO LOG-SEC
/dev/loop0         0      0         0  0 /home/daa/lab1/fs-2024.img   0     512
```

3. Создать файловую систему, определить: размер блока, количество индексных дескрипторов и блоков данных, номера блоков с резервной копией суперблока:



- `mkfs` - для создания файловой системы.
- `-t ext4`- указывает тип файловой системы. В данном случае, это ext4. `Ext4` - это распространенный тип файловой системы в Linux.
- `/dev/loop0` - блочное устройство, на котором будет создана файловая система. В данном случае, это ваше устройство loop, созданное для файла fs-2024.img.

Команда mkfs будет форматировать указанное блочное устройство, в данном случае /dev/loop0, создавая на нем файловую систему типа ext4. 

```sh
[daa@10 lab1]$ sudo mkfs -t ext4 /dev/loop0
[sudo] password for daa: 
mke2fs 1.46.5 (30-Dec-2021)
Discarding device blocks: done                            
Creating filesystem with 102400 1k blocks and 25584 inodes
Filesystem UUID: c98dd8b7-69a6-4bdd-b6e4-51c2ce0f4b1c
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 
```

4. Определить UUID файловой системы.

UUID (Уникальный Идентификатор Устройства) - это уникальный идентификатор, присвоенный файловой системе на устройстве. Этот идентификатор используется для однозначного идентификации файловой системы, независимо от того, какое устройство она в данный момент использует или находится на.

Когда вы создаете файловую систему (например, при форматировании диска), система присваивает ей UUID. Этот UUID остается постоянным для данной файловой системы даже в том случае, если вы переносите ее на другое устройство или меняете букву устройства (например, из /dev/sda1 в /dev/sdb1).

```sh
[daa@10 lab1]$ sudo blkid /dev/sda1
/dev/sda1: UUID="b7d36520-9e32-4350-b32a-2ce5a24a3c3d" TYPE="xfs" PARTUUID="58904159-01"
[daa@10 lab1]$ sudo blkid /dev/loop0
/dev/loop0: UUID="c98dd8b7-69a6-4bdd-b6e4-51c2ce0f4b1c" TYPE="ext4"
```

5. Выполнить монтирование файловой системы, определить опции монтирования.

- `sudo mount /dev/loop0 /mnt` - монтирует файловую систему, расположенную на блочном устройстве /dev/loop0, в каталог (точку монтирования) /mnt. В данном случае, это действие выполняется с правами суперпользователя (sudo), что может потребовать ввода пароля пользователя.

- `mount | grep /mnt` - Эта команда используется для вывода списка текущих монтированных файловых систем и фильтрации (через grep) только тех, которые связаны с точкой монтирования /mnt.


```sh
[daa@10 lab1]$ sudo mount /dev/loop0 /mnt
[sudo] password for daa: 
[daa@10 lab1]$ mount | grep /mnt
/dev/loop0 on /mnt type ext4 (rw,relatime,seclabel)
```


6. Выполнить мониторинг файловой системы. Вывести информацию о количестве блоков и индексных дескрипторов.

- `df` - это утилита в Unix-подобных системах, которая отображает статистику использования файловых систем.
- `-h` - опция, которая предлагает отображение размеров в более читаемом формате, используя единицы измерения в стиле "human-readable" (например, Килобайты, Мегабайты).
- `/mnt` - это путь к точке монтирования, для которой вы хотите получить информацию.

   В результате выполнения этой команды вы видите информацию о дисковом пространстве для файловой системы, связанной с `/mnt`. Вывод включает общий размер, использованное пространство, доступное пространство и процент использования.
-  `-hi` - эта опция отображает информацию о индексных узлах (inodes) в читаемом формате.



```sh
[daa@10 lab1]$ df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/loop0       89M   14K   82M   1% /mnt
[daa@10 lab1]$ df -hi /mnt
Filesystem     Inodes IUsed IFree IUse% Mounted on
/dev/loop0        25K    11   25K    1% /mnt
```
Индексные узлы (inodes) - это структуры данных в файловых системах, используемые для хранения метаданных о файлах и каталогах. Каждый файл или каталог в файловой системе имеет свой собственный индексный узел, который содержит информацию о нем.


7. Создайте тестовый файл с читаемыми данными.

```sh
echo Hello > /mnt/mephi
```
8. Выполнить размонтирование файловой системы.

```sh
umount /dev/loop0
```

## 2.2 Исследование свойств файловой системы

Содержимое суперблока можно вывести командой `tune2fs -l <блочное_устройство>` или командой d`umpe2fs -h <блочное_устройство>`. В качестве аргумента <блочное_устройство> можно указать имя файла блочного устройства, содержащего файловую систему, (/dev/sda1), или метку файловой системы (LABEL=<метка>), или идентификатор файловой системы (UUID=<идентификатор>).

Определить поддерживаемые возможности (features) и опции монтирования по умолчанию, определить количество свободных блоков данных и индексных дескрипторов, определить количество монтирований и время последнего монтирования.

```sh
dumpe2fs -h /dev/loop0
```
Как связаны следующие величины?
- Block size: 1024
- Inode size: 128
- Inodes per group: 1976
- Inode blocks per group: 247

-   `Block size: 1024` - Это размер блока в файловой системе, измеряемый в байтах. В данном случае, блоки в файловой системе имеют размер 1024 байта.

- `Inode size: 128` - Это размер индексного узла (inode) в файловой системе, измеряемый в байтах. В данном случае, каждый индексный узел имеет размер 128 байт.

- `Inodes per group: 1976` - Это количество индексных узлов, выделенных в каждой группе блоков в файловой системе. В данном случае, в каждой группе блоков имеется 1976 индексных узлов.

- `Inode blocks per group: 247` - Это количество блоков, выделенных под индексные узлы в каждой группе блоков. В данном случае, 247 блоков в каждой группе предназначены для хранения индексных узлов.
Связь между этими значениями заключается в том, что размер индексного узла (Inode size) и количество индексных узлов в группе (Inodes per group) определяют, сколько места будет выделено под индексные узлы в каждой группе блоков. Таким образом, блоки, выделенные под индексные узлы в каждой группе (Inode blocks per group), могут быть рассчитаны как (Inodes per group * Inode size) / Block size.


В данном случае, расчет будет (1976 * 128) / 1024 = 247. Это означает, что в каждой группе блоков предназначено 247 блоков для хранения индексных узлов.

1. Освободить блочное устройство.
```sh
losetup --detach /dev/loop0
losetup --list
```

2. Произведите поиск данных в образе файловой системы.


```sh
[daa@10 lab1]$  grep Hello fs-2024.img 
grep: fs-2024.img: binary file matches
[daa@10 lab1]$ grep mephi fs-2024.img
grep: fs-2024.img: binary file matches
[daa@10 lab1]$ grep -a "mephi" fs-2024.img #- тогда можно найт
```
О чём говорит вывод команды grep? 0  пытаемся найти строку в бинаре

## 2.3 Особенности алгоритма создания файловой системы
Обратите внимание на выбранный размер блока и количество созданных индексных дескрипторов (инодов).

```sh
$ dd if=/dev/zero of=./fs-2024.img bs=1M count=500
500+0 records in
500+0 records out
524288000 bytes (524 MB, 500 MiB) copied, 0.296697 s, 1.8 GB/s
$ sudo losetup --find --show fs-2024.img 
/dev/loop0
$ sudo mkfs -t ext4 /dev/loop0
mke2fs 1.45.5 (07-Jan-2020)
Discarding device blocks: done                            
Creating filesystem with 512000 1k blocks and 128016 inodes
Filesystem UUID: d9979c30-b24c-480b-9187-158569cac725
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729, 204801, 221185, 401409

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done 

$ sudo losetup --detach /dev/loop0 
$ rm fs-2024.img
```

Теперь изучите характеристики файловой системы размером 1 Гбайт.
```sh
$ dd if=/dev/zero of=./fs-2024.img bs=1G count=1
1+0 records in
1+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 1.43769 s, 747 MB/s
$ sudo losetup --find --show fs-2024.img 
/dev/loop0
$ sudo mkfs -t ext4 /dev/loop0
mke2fs 1.45.5 (07-Jan-2020)
Discarding device blocks: done                            
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 1d15f690-c714-442a-96ae-360f5952d478
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

$ sudo losetup --detach /dev/loop0 
$ rm fs-2024.img
```
Какой размер блока выбрал алгоритм создания файловой системы в каждом случае? Какие ещё есть отличия?
Размер блока: Размер блока в первом случае - 1 мегабайт, во втором случае - 1 гигабайт. Это влияет на эффективность работы с файловой системой, особенно при работе с маленькими файлами.

Количество блоков и индексных узлов: В обоих случаях используется mkfs для создания файловой системы типа ext4. Размер блока и количество блоков влияют на общее количество индексных узлов и размер файловой системы.

## 2.4 Изучение сигнатур (magic strings) файловой системы
Выведите магические строки и затем удалите их, создав бэкап. Файл бэкапа будет создан в домашней директории пользователя root.

```sh
wipefs -O DEVICE,OFFSET,TYPE,UUID /dev/loop0
DEVICE OFFSET TYPE UUID
loop0  0x438  ext4 d9979c30-b24c-480b-9187-158569cac725
wipefs --all --backup /dev/loop0
/dev/loop0: 2 bytes were erased at offset 0x00000438 (ext4): 53 ef
```
DEVICE: Устройство, с которого необходимо удалить сигнатуры (например, /dev/loop0).
OFFSET: Смещение в байтах от начала устройства. Этот параметр можно использовать, чтобы начать поиск не с самого начала устройства.
TYPE: Указывает на тип сигнатур или метаданных, которые нужно удалить.
UUID: UUID, который необходимо удалить.

Команда wipefs --all --backup /dev/loop0 в Linux используется для удаления всех сигнатур файловой системы и метаданных с указанного устройства (/dev/loop0). Опция --backup позволяет создать резервную копию таблицы разделов и подписей файловой системы перед их удалением.

Краткое описание опций:

--all: Удаляет все сигнатуры файловой системы и метаданные на устройстве.
--backup: Создает резервную копию таблицы разделов и подписей файловой системы перед их удалением.

- Восстановите магические строки из бэкапа.


```sh
# dd if=/root/wipefs-loop0-0x00000438.bak of=/dev/loop0 seek=$((0x00000438)) bs=1 conv=notrunc
2+0 records in
2+0 records out
2 bytes copied, 0.0129952 s, 0.2 kB/s
# wipefs -O DEVICE,OFFSET,TYPE,UUID /dev/loop0
DEVICE OFFSET TYPE UUID
loop0  0x438  ext4 d9979c30-b24c-480b-9187-158569cac725
```
## 2.5 Изучение механизма автоматического монтирования файловых систем /etc/fstab
Вывести содержимое файла /etc/fstab
```sh
$ cat /etc/fstab

UUID=32d6eee9-ba8d-defa-8bf4-ccefd34bf14e /                       ext4    defaults        1 1
UUID=ac78c18c-5060-defa-8dc0-91145963689e /boot                   ext4    defaults        1 2
UUID=BEEA-630E                            /boot/efi               vfat    umask=0077,shortname=winnt 0 2
UUID=b1d6d09c-f4e6-defa-9b5e-b2bb8eb4d328 /home                   ext4    defaults        1 2
UUID=dfcfb4ba-3fad-defa-b507-ca5ca54c51d8 none                    swap    defaults        0 0
```


# 3. Изучение бита Set-Group-ID для директории
1. Создать файл размером 10 Мегабайт.

```sh
# dd if=/dev/zero of=loop-fs.img bs=1M count=10
10+0 records in
10+0 records out
10485760 bytes (10 MB, 10 MiB) copied, 0.0101878 s, 1.0 GB/s
```

2. Связать созданный файл с первым свободным loop-устройством и вывести информацию о всех loop-устройствах.
```sh
# losetup -fP loop-fs.img 
# losetup -a
/dev/loop1: [66309]:1846788 (/root/loop-fs.img)
# ls -l /dev/loop1
brw-rw----. 1 root disk 7, 1 Feb  6 05:04 /dev/loop1
```

3. Создадим файловую систему в файле-образе и новую точку монтирования.

```sh
# mkfs -t ext4 loop-fs.img 
# mkdir /mnt/loop-fs
```

4. Выполним монтирование файловой системы с опциями по умолчанию (т.е. с опцией -o nogrpid).

```sh
# mount -o loop /dev/loop1 /mnt/loop-fs/
# mount | grep loop-fs
/dev/loop1 on /mnt/loop-fs type ext4 (rw,relatime,seclabel)
```

5. Создадим в новой файловой системе тестовую директорию и файл в ней.
Создадим двух новых пользователей, новую группу, и включим этих пользователей в эту группу. Сделаем владельцем тестовой директории новую группу и дадим для неё все права на директорию.

```sh
# cd /mnt/loop-fs/
# mkdir project-2022
# useradd student1
# useradd student2
# groupadd project-2022
# usermod -aG project-2022 student1
# usermod -aG project-2022 student2
# chown :project-2022 project-2022
# chmod g+w project-2022/
# ls -ld project-2022/
drwxrwxr-x. 2 root project-2022 1024 Feb  6 05:15 project-2022/
```

Теперь с помощью команды su создадим в тестовой директории файлы от имени новых пользователей.

```sh
# su student1
$ touch project-2022/report1
$ exit
# su student2
$ touch project-2022/report2
$ exit
# ls -l project-2022/
total 2
-rw-rw-r--. 1 student1 student1 0 Feb  6 05:24 report1
-rw-rw-r--. 1 student2 student2 0 Feb  6 05:24 report2
```

Видно, что владельцем и группой-владельцем каждого файла назначается UID и GID пользователя, создавшего файл.

Теперь установим для тестовой директории бит set-group-ID и повторно создадим в тестовой директории файлы от имени новых пользователей.

```sh
# chmod g+s project-2022/
# ls -ld project-2022/
drwxrwsr-x. 2 root project-2022 1024 Feb  6 05:24 project-2022/
# su student1
$ touch project-2022/report12
$ exit
# su student2
$ touch project-2022/report22
$ exit
# ls -l project-2022/
total 4
-rw-rw-r--. 1 student1 student1     0 Feb  6 05:24 report1
-rw-rw-r--. 1 student1 project-2022 0 Feb  6 05:25 report12
-rw-rw-r--. 1 student2 student2     0 Feb  6 05:24 report2
-rw-rw-r--. 1 student2 project-2022 0 Feb  6 05:26 report22
```


видно, что, как и в предыдущем случае, владельцем каждого файла назначается UID пользователя, создавшего файл, а вот группа-владельца для обоих файлов наследуется от группы-владельца директории. Таким образом, разные пользователи, входящие в одну общую группу, могут создавать файлы, доступные всем пользователям в общей группе. Это позволяет организовать совместную работу нескольких пользователей над одним проектом.

Теперь сбросим для тестовой директории бит set-group-ID и выполним монтирование файловой системы, указав явно опцию -o grpid.

```sh
# chmod g-s project-2022/
# ls -ld project-2022/
drwxrwxr-x. 2 root project-2022 1024 Feb  6 05:26 project-2022/
# cd
# umount /mnt/loop-fs/
# mount -o grpid,loop /dev/loop1 /mnt/loop-fs/
```


Повторно создадим в тестовой директории файлы от имени новых пользователей.

```sh
# cd /mnt/loop-fs/
# su student1
$ touch project-2022/report1-grpid
$ exit
# su student2
$ touch project-2022/report2-grpid
$ exit
# ls -l project-2022/
total 6
-rw-rw-r--. 1 student1 student1     0 Feb  6 05:24 report1
-rw-rw-r--. 1 student1 project-2022 0 Feb  6 05:25 report12
-rw-rw-r--. 1 student1 project-2022 0 Feb  6 05:31 report1-grpid
-rw-rw-r--. 1 student2 student2     0 Feb  6 05:24 report2
-rw-rw-r--. 1 student2 project-2022 0 Feb  6 05:26 report22
-rw-rw-r--. 1 student2 project-2022 0 Feb  6 05:31 report2-grpid
```
Видно, что, как и в предыдущих двух случаях, владельцем каждого файла назначается UID пользователя, создавшего файл. А группа-владельца для обоих файлов наследуется от группы-владельца директории, не смотря на то, что у директории не установлен бит set-group-ID.

Вернём систему в исходное состояние: удалим директорию монтирования, loop-устройство и файл с образом файловой системы.
```sh
# cd
# umount /mnt/loop-fs/
# rmdir /mnt/loop-fs/
# losetup -d /dev/loop1
# rm loop-fs.img
```



В рассмотренном примере было показано влияние опций монтирования и наличия бита set-group-ID у родительской директории на то, какая группа будет у новых файлов, создаваемых в директории


# 4. Изучение LUKS

LUKS (Linux Unified Key Setup) - это стандарт для устройства дискового шифрования в Linux. Он предоставляет стандартизированный способ управления шифрованием дисков на уровне блоков данных. LUKS обеспечивает надежный и удобный интерфейс для создания, хранения, использования и обмена шифрованными блочными устройствами.



Команда dd в Linux используется для копирования и преобразования файлов или устройств. В данном случае, команда dd используется для создания файла с заданным размером и заполненного случайными данными из устройства /dev/random. 


Команда du в Linux используется для оценки использования дискового пространства файлами и каталогами. В данном случае, команда du -sh fs-LUKS.img предоставляет информацию о размере файла fs-LUKS.img. Разберем аргументы этой команды:

```sh
# dd if=/dev/random of=./fs-LUKS.img bs=1M count=100
100+0 records in
100+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 0.628301 s, 167 MB/s
# ls -l fs-LUKS.img 
-rw-r--r--. 1 root root 104857600 Feb 19 01:06 fs-LUKS.img
# du -sh fs-LUKS.img 
101M	fs-LUKS.img
```

Создать LUKS-контейнер, используя созданный файл в качестве устройства хранения.

ВСЕ ДАННЫЕ НА УСТРОЙСТВЕ ХРАНЕНИЯ БУДУТ УНИЧТОЖЕНЫ!

Для подтверждения операции введите большими буквами YES. Затем введите два раза парольную фразу для доступа к LUKS-контейнеру (опция -y).

```sh
# cryptsetup luksFormat fs-LUKS.img 

WARNING!
========
This will overwrite data on fs-LUKS.img irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for fs-LUKS.img: 
Verify passphrase: 
```

Откройте LUKS-контейнер, используя парольную фразу, и свяжите с новым устройством fs-LUKS (имя можно выбрать другое). Убедитесь, что отображение устройства выполнено.

```sh
# cryptsetup luksOpen fs-LUKS.img fs-LUKS
Enter passphrase for fs-LUKS.img: 
# ls -l /dev/mapper/
total 0
crw-------. 1 root root 10, 236 Feb 19 00:54 control
lrwxrwxrwx. 1 root root       7 Feb 19 01:56 fs-LUKS -> ../dm-0
```

Выведите статус устройства. Какой тип контейнера используется? Обратите внимание, что неявно было выполнено loop-связывание.

```sh
# cryptsetup status fs-LUKS 
/dev/mapper/fs-LUKS is active.
  type:    LUKS2
  cipher:  aes-xts-plain64
  keysize: 512 bits
  key location: keyring
  device:  /dev/loop0
  loop:    /root/fs-LUKS.img
  sector size:  512
  offset:  32768 sectors
  size:    172032 sectors
  mode:    read/write
```
Убедитесь, что в ядро загружен модуль отображения устройств.

```sh
# lsmod | grep dm_crypt
dm_crypt               53248  1
```
Создайте файловую систему и выполните её монтирование. Выведите информацию о блочных устройствах.
```sh
# mkfs.ext4 /dev/mapper/fs-LUKS 
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 86016 1k blocks and 21560 inodes
Filesystem UUID: 3a6081f5-ce3c-4485-b5d3-2a2868952bf5
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

# mount /dev/mapper/fs-LUKS /mnt/
# mount | grep /mnt
/dev/mapper/fs-LUKS on /mnt type ext4 (rw,relatime,seclabel)
# lsblk 
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
loop0         7:0    0   100M  0 loop  
└─fs-LUKS   253:0    0    84M  0 crypt /mnt
...
```


Создайте тестовый файл с читаемыми данными. Выполните размонтирование файловой системы. Закройте LUKS-контейнер.

```sh
# echo Hello > /mnt/mephi
# umount /mnt 
# cryptsetup luksClose fs-LUKS 
```

Произведите поиск данных в образе файловой системы.

```sh
# grep Hello fs-LUKS.img 
# grep mephi fs-LUKS.img 
```

### Добавление ключа
Можно cryptsetup luksDump fs-LUKS.img или cryptsetup luksDump /dev/loop0.

```sh
# cryptsetup luksDump /dev/loop0 
LUKS header information
Version:       	2
Epoch:         	3
Metadata area: 	16384 [bytes]
Keyslots area: 	16744448 [bytes]
UUID:          	7fd7ca5d-5678-4ba8-9a2c-de5cd60d0c0f
Label:         	(no label)
Subsystem:     	(no subsystem)
Flags:       	(no flags)

Data segments:
  0: crypt
	offset: 16777216 [bytes]
	length: (whole device)
	cipher: aes-xts-plain64
	sector: 512 [bytes]

Keyslots:
  0: luks2
	Key:        512 bits
	Priority:   normal
	Cipher:     aes-xts-plain64
	Cipher key: 512 bits
	PBKDF:      argon2i
	Time cost:  6
	Memory:     1048576
	Threads:    4
	Salt:       06 a4 52 70 d4 29 cb 52 13 e4 f2 8b c6 3c 8a bb 
	            94 88 5d ca df df f7 e4 2d d0 21 fa 05 94 83 b8 
	AF stripes: 4000
	AF hash:    sha256
	Area offset:32768 [bytes]
	Area length:258048 [bytes]
	Digest ID:  0
Tokens:
Digests:
  0: pbkdf2
	Hash:       sha256
	Iterations: 129774
	Salt:       2e ce 26 95 e7 16 45 e9 c8 f6 10 30 70 05 a4 53 
	            55 10 62 fe 9d 9e 3a 29 b9 cf ee 3c aa f7 58 07 
	Digest:     2c 57 26 31 84 4a eb a4 23 14 44 dd 5d a7 a3 3f 
	            d1 04 f2 61 39 7b 04 96 04 3e 03 54 b5 0b a3 4e 
                
```

Сколько занято слотов?

Добавить новый ключ в свободный слот. Проверить, что теперь занято два слота.

```sh
# cryptsetup luksAddKey /dev/loop0
# cryptsetup luksDump /dev/loop0
```