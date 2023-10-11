# Лабораторная работа "Дискреционное управление доступом"
## Общие сведения
### Биты доступа

| Бит доступа	 | Файл | Директория |
|-------------|-------------|-------------|
| `r` (чтение)	  | Читать из файла	  | Выводить содержимое директории (только имена файлов)  |
| `w` (запись)  | Писать в файл	  | Создавать, удалять, перемещать и переименовывать файлы в директории (также требуется x)  |
| `x` (исполнение/поиск)  | Запускать файл на исполнение (файл является программой или сценарием)  | Читать метаданные файлов в директории (содержимое инодов). Использовать директорию в пути к файлу, переходить в директорию (cd), выводить содержимое директории в длинном формате (ls -l)  |
| `u+s` (set-user-ID, SUID)  | Устанавливает эффективный идентификатор пользователя EUID процесса при исполнении файла равным иденти фикатору UID владельца файла  | Не используется  |
| `g+s` (set-group-ID, SGID)  | Устанавливает эффек тивный идентификатор группы EGID процесса при исполнении файла равным идентификатору GID группы файла  | Устанавливает идентифика тор группы GID для файлов, создаваемых в директории, равным идентификатору группы директории GID (при создании файла, GID наследуется от директории, в которой создается файл)  |
| `o+t` (sticky)  | Не используется  | Удалять или переименовывать файлы в директории может только владелец директории, или владелец файла, или процесс с привилегией CAP_FOWNER (также требуется w)  |

- Чтобы запустить двоичный файл, достаточно только права на исполнение, а для запуска сценария необходимо наличие двух прав: на чтение и на исполнение.



### Системные вызовы
- Некоторые системные вызовы требуют указания или возвращают права доступа к файлу или тип файла.

#### Тип файла
Для описания типа файла используются следующие флаги, определённые в заголовочном файле sys/stat.h:
```h
#define S_IFLNK  0120000
#define S_IFREG  0100000
#define S_IFBLK  0060000
#define S_IFDIR  0040000
#define S_IFCHR  0020000
#define S_IFIFO  0010000
```

#### Права доступа
Для описания прав доступа к файлу используются следующие флаги, определённые в заголовочном файле sys/stat.h:
```h
#define S_ISUID  0004000
#define S_ISGID  0002000
#define S_ISVTX  0001000

#define S_IRWXU    00700
#define S_IRUSR    00400
#define S_IWUSR    00200
#define S_IXUSR    00100

#define S_IRWXG    00070
#define S_IRGRP    00040
#define S_IWGRP    00020
#define S_IXGRP    00010

#define S_IRWXO    00007
#define S_IROTH    00004
#define S_IWOTH    00002
#define S_IXOTH    00001
```

Флаги можно комбинировать между собой с помощью операции побитового ИЛИ |. Например, для создания файла может использоваться системный вызов open с перечислением указанных выше флагов для задания прав доступа к нему:

```c
open("some_file", O_CREAT, S_IRWXU | S_IRGRP);
```


#### Обработка ошибок
Системные вызовы могут завершиться неудачей. Например, файл, к которому запрашивается доступ, не существует или для его открытия недостаточно прав. Для предотвращения непредсказуемого поведения программы в этих случаях необходимо исследовать результат выполнения системного вызова (вообще, любой функции). Чтобы понять, как обрабатывать результат системного вызова, необходимо прочитать его документацию в man(2).

Например, рассмотрим системный вызов access. В man(2) написано:

```
...

RETURN VALUE

       On success (all requested permissions granted, or mode is F_OK
       and the file exists), zero is returned.  On error (at least one
       bit in mode asked for a permission that is denied, or mode is
       F_OK and the file does not exist, or some other error occurred),
       -1 is returned, and errno is set to indicate the error.

...
```


Таким образом, выполнять системный вызов access следует, например, так:
```c
if (-1 == access("some_file", F_OK))
{
    perror("access");
    exit(EXIT_FAILURE);
}
```
Конечно, действия при ошибке зависят от программы. В данном примере пользователю просто сообщается об ошибке, и выполнение порграммы прерывается с соответствующим кодом ошибки.

## Задания
### Биты доступа
#### Просмотр битов доступа и принадлежности файла

Права доступа и принадлежность файла можно просмотреть с помощью команд `ls -l`, `stat`. Например:
```bash
ls -l /etc/passwd
# Вывод:
# -rw-r--r--. 1 root root 1047 Oct  3 17:53 /etc/passwd

stat /etc/passwd
# Вывод:
#   File: /etc/passwd
#   Size: 1047            Blocks: 8          IO Block: 4096   regular file
# Device: fd00h/64768d    Inode: 33965265    Links: 1
# Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
# Context: system_u:object_r:passwd_file_t:s0
# Access: 2023-10-03 17:53:54.820289385 +0300
# Modify: 2023-10-03 17:53:54.675292727 +0300
# Change: 2023-10-03 17:53:54.688292428 +0300
#  Birth: 2023-10-03 17:53:54.675292727 +0300
```

`-rw-r--r--` : 
- `-` - типа файла - тут обычный файл
- `rw-` - владелец может читать, записывать, но не исполнять
- `r--` - права доступа для группы, которой принадлежит файл (но не является владельцем)
- `r--` - права доступа для всех остальных пользователей (не владельцев и не входящих в группу)
это эквивалентно `0644`

### ПРАВА
R = 4

w = 2

x = 1

#### Изменение прав доступа к файлам

Для изменения прав доступа к файлу используется системный вызов chmod. Этот вызов возможно выполнять как в Bash, так и напрямую в C. Рассмотрим оба варианта.

В командах ниже предполагается, что в системе существуют два пользователя: ivan (включен в /etc/sudoers) и polina (не включена в /etc/sudoers). Команды выполняются от лица пользователя ivan.

Создадим файл с секретом и сделаем его доступным на чтение только владельцу:

```bash
touch file
echo "This is a secret!" > file
chmod 600 file
```
Попробуем вывести содержимое файла сначала от лица пользователя ivan, а затем — от лица пользователя polina:

```bash
cat file
# Вывод:
# This is a secret!

sudo -u polina cat file
# Вывод:
# cat: file: Permission denied
```
Теперь сделайте так, чтобы polina смогла прочитать содержимое файла file.

#### решение
```bash
[root@localhost ivan]# cd 2lab/
[root@localhost 2lab]# ls
file
[root@localhost 2lab]# groupadd file_2lab_readers
[root@localhost 2lab]# usermod -aG file_2lab_readers polina
[root@localhost 2lab]# chown :file_2lab_readers file
[root@localhost 2lab]# chmod g+r file
[root@localhost 2lab]# ls -l
```

- `usermod`  - `-a` добавить к `-G` группе  
- `chown` - change owner" (изменить владельца) - `user:group` `file_name`
- `chmod` - change mode" (изменить режим) и используется для изменения прав доступа к файлу. - `g+r` -дать группе влалельца права на чтение


Создадим директорию с файлом в ней:

```bash
mkdir dir
touch dir/file
echo "File content." > dir/file
```
Сделайте так, чтобы файл dir/file мог прочитать только тот, кто знает о его существовании.


#### Решение
```bash
[root@localhost 2lab]# chmod 600 dir/file 
[root@localhost 2lab]# mv dir .dir
[root@localhost 2lab]# ls
file
[root@localhost 2lab]# ls -al
total 4
drwxr-xr-x. 3 ivan ivan               30 Oct  9 21:55 .
drwx------. 5 ivan ivan              121 Oct  9 20:41 ..
drwxr-xr-x. 2 root root               18 Oct  9 21:54 .dir
-rw-r-----. 1 ivan file_2lab_readers   7 Oct  9 20:18 file
```



### Задачи
Решите следующие задачи от имени обычного пользователя (не root).


```bash
[dima@localhost test]$ ls
file
[dima@localhost test]$ ls -l
total 0
-rw-r--r--. 1 dima dima 0 Oct 11 12:29 file
[dima@localhost test]$ chmod 000 file
[dima@localhost test]$ ls -l
total 0
----------. 1 dima dima 0 Oct 11 12:29 file
[dima@localhost test]$ echo "test" > file
-bash: file: Permission denied
[dima@localhost test]$ chmod 200 file
[dima@localhost test]$ echo "test" > file
[dima@localhost test]$ ls -l
total 4
--w-------. 1 dima dima 5 Oct 11 12:32 file
[dima@localhost test]$ cat file 
cat: file: Permission denied
[dima@localhost test]$ chmod 240 file
[dima@localhost test]$ ls -l
total 4
--w-r-----. 1 dima dima 5 Oct 11 12:32 file
[dima@localhost test]$ cat file 
cat: file: Permission denied
[dima@localhost test]$ chmod 640 file
[dima@localhost test]$ ls -l
total 4
-rw-r-----. 1 dima dima 5 Oct 11 12:32 file
[dima@localhost test]$ cat file 
test
[dima@localhost test]$ mkdir dir 
[dima@localhost test]$ cd dir/
[dima@localhost dir]$ echo "file2" > new_file
[dima@localhost dir]$ ls
new_file
[dima@localhost dir]$ cd ..
[dima@localhost test]$ ls
dir  file
[dima@localhost test]$ ls -l
total 4
drwxr-xr-x. 2 dima dima 22 Oct 11 12:35 dir
-rw-r-----. 1 dima dima  5 Oct 11 12:32 file
[dima@localhost test]$ chmod 644 dir/
[dima@localhost test]$ ls -l
total 4
drw-r--r--. 2 dima dima 22 Oct 11 12:35 dir
-rw-r-----. 1 dima dima  5 Oct 11 12:32 file
[dima@localhost test]$ cat /dir/new_file
cat: /dir/new_file: No such file or directory
[dima@localhost test]$ cd dir/
-bash: cd: dir/: Permission denied
[dima@localhost test]$ rm dir/new_file 
rm: cannot remove 'dir/new_file': Permission denied
[dima@localhost test]$ chown root:root dir/
chown: changing ownership of 'dir/': Operation not permitted
[dima@localhost test]$ umask
0022
[dima@localhost test]$ umask 066
[dima@localhost test]$ umask
0066
[dima@localhost test]$ touch file1
[dima@localhost test]$ ls -l file1 
-rw-------. 1 dima dima 0 Oct 11 13:25 file1
[dima@localhost test]$ umask 000
[dima@localhost test]$ touch file2
[dima@localhost test]$ ls -l file2
-rw-rw-rw-. 1 dima dima 0 Oct 11 13:27 file2
[root@localhost ~]# cd /home/dima/
[root@localhost dima]# ls
desktop  project1  test
[root@localhost dima]# cd test/
[root@localhost test]# ls
dir  file  file1  file2
[root@localhost test]# tree
.
├── dir
│   └── new_file
├── file
├── file1
└── file2

1 directory, 4 files
[root@localhost test]# chown root file
[root@localhost test]# ls -l file
-rw-r-----. 1 root dima 5 Oct 11 12:32 file
[root@localhost test]# chmod 600 file
[root@localhost test]# ls -l file
-rw-------. 1 root dima 5 Oct 11 12:32 file
[root@localhost test]# 

-rw-rw-rw-. 1 dima dima 0 Oct 11 13:27 file2
[dima@localhost test]$ cd ..
[dima@localhost ~]$ cd 
.bash_history  .bash_profile  desktop/       test/
.bash_logout   .bashrc        project1/      
[dima@localhost ~]$ cd test/
[dima@localhost test]$ ls
dir  file  file1  file2
[dima@localhost test]$ cat file
cat: file: Permission denied



[root@localhost test]# chmod 640 file
[dima@localhost test]$ cat file
test


```



### Программа
Реализуйте программу chmod на языке C с использованием системных вызовов. Вызов программы должен происходить следующим образом:

chmod <number> <file>
Например,

chmod 0644 some_file
Проверьте пользовательский ввод, обработайте ошибки и выведите их в случае возникновения.

Подсказка
Для конвертации строки в число можно воспользоваться функцией strtoul (string to unsigned long).





