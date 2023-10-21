# Лабораторная работа "Дискреционное управление доступом"
## Общие сведения
### Биты доступа

| Бит доступа	 | Файл | Директория |
|-------------|-------------|-------------|
| `r` `4`(чтение)	  | Читать из файла	  | Выводить содержимое директории (только имена файлов)  |
| `w` `2` (запись)  | Писать в файл	  | Создавать, удалять, перемещать и переименовывать файлы в директории (также требуется x)  |
| `x` `1`(исполнение/поиск)  | Запускать файл на исполнение (файл является программой или сценарием)  | Читать метаданные файлов в директории (содержимое инодов). Использовать директорию в пути к файлу, переходить в директорию (cd), выводить содержимое директории в длинном формате (ls -l)  |
| `u+s` `4` (set-user-ID, SUID)  | Устанавливает эффективный идентификатор пользователя EUID процесса при исполнении файла равным иденти фикатору UID владельца файла  | Не используется  |
| `g+s` `2`(set-group-ID, SGID)  | Устанавливает эффек тивный идентификатор группы EGID процесса при исполнении файла равным идентификатору GID группы файла  | Устанавливает идентифика тор группы GID для файлов, создаваемых в директории, равным идентификатору группы директории GID (при создании файла, GID наследуется от директории, в которой создается файл)  |
| `o+t` `1`(sticky)  | Не используется  | Удалять или переименовывать файлы в директории может только владелец директории, или владелец файла, или процесс с привилегией CAP_FOWNER (также требуется w)  |

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

#### РЕШЕНИЕ 
my_chmod
- `fprintf` - как printf, только выводит в заданный поток
- `stderr` - поток ошибок: (.`/my_program 2> error.log`); (`dmesg, syslog, journalctl` - сообщения об ошибках могут записываться в системные логи.)
- `exit(1)` (`exit(EXIT_FAILURE)`) - завершиаем программу с кодом  1 (посмтреть `echo $?`)
- `perror`  предназначен специально для вывода сообщений об ошибках и автоматически включает описание ошибки, связанное с текущим значением errno. Он удобен для вывода стандартных диагностических сообщений об ошибках.
-
```c
int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "ошибка аргументов\n");
        exit(1);
    }

    const char *mode_str = argv[1];
    const char *file = argv[2];

    unsigned long mode = strtoul(mode_str, NULL, 8);

    if (mode < 0 || mode > 7777) {
        fprintf(stderr,"Неверный формат прав доступа");
        exit(1);
    }

    if (chmod(file, (mode_t)mode) == -1) {
        fprintf(stderr,"ошибка");
        exit(1);
    }
	
    printf("Права доступа к файлу успешно изменены \n");
    return 0;
}
```


### Атрибуты файла
Следующий блок команд выполняется от лица суперпользователя root. Ниже файлу f_append_only устанавливаются атрибуты, позволяющие только дописывать содержимое в конец файла. Подробности в man chattr.

```bash
echo abc > f_append_only

echo 123456 > f_append_only

ls -l f_append_only
# Вывод:
# -rw-r--r--. 1 root root 4 Oct 10 19:00 f_append_only

cat f_append_only
# Вывод:
# 123456

chattr +a f_append_only

lsattr f_append_only
# Вывод:
# -----a-------------- f_append_only
```
Попробуйте изменить/перезаписать файл. Объясните результаты. В каких сценариях это может быть полезно?

Сделайте так, чтобы этот файл нельзя было изменять, переименовывать и удалять, а также чтобы нельзя было создавать на него ссылки и открывать его для записи.

```bash
[root@localhost 3lab]# chmod 444 f_append_only 
[root@localhost 3lab]# ls -l f_append_only 
-r--r--r--. 1 root root 7 Oct 11 15:17 f_append_only
[root@localhost 3lab]# chattr +i f_append_only
[root@localhost 3lab]# chattr +a f_append_only


[root@localhost 3lab]# lsattr f_append_only 
----ia---------------- f_append_only
[root@localhost 3lab]# 

```


- chattr - для добавления расширенных  атрибуто:
+i: Защитить файл или директорию от случайного удаления или изменения. Файл с атрибутом +i не может быть удален, перемещен, переименован, а также к нему нельзя создать жесткую ссылку. Этот атрибут может быть очень полезным для важных системных файлов.

-i: Снять атрибут +i с файла или директории, позволяя изменять и удалять его.

+a: Установить атрибут "append-only". Это предотвращает перезапись файла, позволяя только добавление данных в конец файла.

-a: Снять атрибут "append-only".

+u: Установить атрибут "undeletable". Это предотвращает удаление файла даже для суперпользователей.

-u: Снять атрибут "undeletable".

+S: Установить атрибут "synchronous updates". Это требует синхронной записи данных в файл в режиме реального времени, что может повысить надежность данных, но снизить производительность.

-S: Снять атрибут "synchronous updates".

+j: Установить атрибут "data journalling", что гарантирует, что данные будут сохранены в журнале файловой системы перед их записью на диск.

-j: Снять атрибут "data journalling".

-посмотреть эти атрибуты: lsattr file_name

### Программа
Напишите программу trigatime на языке C, которая добавляет флаг A (у файла не обновляется время последнего доступа, поле atime инода), если в атрибутах файла он не указан, и убирает этот флаг, если он указан. Пример работы программы:

```bash
touch file

lsattr file
# Вывод:
# ---------------------- file

trigatime file

lsattr file
# Вывод:
# -------A-------------- file

trigatime file

lsattr file
# Вывод:
# ---------------------- file
```

#### ОТВЕТ
```c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include </./usr/include/linux/fs.h>
#include <sys/ioctl.h>
#include <unistd.h> 


int main(int argc, char *argv[]) {

    if (argc != 2) {
        fprintf(stderr, "error arg\n");
        exit(1);
    }

    char *file_name = argv[1];
    int file_descriptor = open(file_name, O_RDONLY);

    if (file_descriptor == -1) {
        fprintf(stderr,"cant open file");
        exit(1);
    }

    unsigned int flags;
    if (ioctl(file_descriptor, FS_IOC_GETFLAGS, &flags) == -1) {
        fprintf(stderr, "Ошибка при получении атрибутов файловой системы");
        exit(1);
    }

//вообще можно ксорить
//flags ^= FS_NOATIME_FL;

    if (flags & FS_NOATIME_FL) {
        flags &= ~FS_NOATIME_FL;
        printf("снять атрибут noatime\n");
    } else {
        flags |= FS_NOATIME_FL;
        printf("установить атрибут noatime\n");
    }
    
    if (ioctl(file_descriptor, FS_IOC_SETFLAGS, &flags) == -1) {
        fprintf(stderr,"error\n");
        close(file_descriptor);
        exit(1);
    }
    close(file_descriptor);
    return 0;
}
```

### ACL
ACL - Список управления доступом (Access Control List, ACL)

- `getfacl` - для вывода ACL:

```bash
getfacl /etc/passwd
# Вывод:
# getfacl: Removing leading '/' from absolute path names
# # file: etc/passwd
# # owner: root
# # group: root
# user::rw-
# group::r--
# other::r--
```
- `setfacl` - Для установки ACL :(`-m` : опиция указывает на изменение (modifying) ACL, позволяет добавлять новые правила в ACL файла); (`u:user_name:rwx` - u указывает что правило применятеся к user_name, к которому применяется правила rwx)

```bash
touch file

chmod 600 file

setfacl -m u:polina:r file

ls -l file
# Вывод:
# -rw-r-----+ 1    ivan    ivan 14 Oct  5 18:01 file

getfacl file
# Вывод:
# # file: file
# # owner: ivan
# # group: ivan
# user::rw-
# user:polina:r--
# group::---
# mask::r--
# other::---
```

-m: Это опция команды, которая указывает на изменение (modifying) ACL. Она позволяет добавлять новые правила в ACL файла.

u:polina:r: Это само правило ACL. Оно имеет следующую структуру:

u: Это префикс, который указывает, что это правило применяется к пользователю.
polina: Это имя пользователя (в данном случае, "polina"), для которого устанавливаются правила.
r: Это право доступа, в данном случае, "r" означает право на чтение (read).



Перейдите в директорию /tmp. Создайте папку и сделайте так, чтобы polina по-умолчанию могла изменять содержимое всех создаваемых в ней файлов.


### Допуск

1. Объясните все биты прав доступа в выводе ls -l.
<details>
<summary>ОТВЕТ</summary>
    ЛЕНЬ ПИСАТЬ
</details>

2. Какая команда используется для изменения прав доступа к файлу?
<details>
<summary>ОТВЕТ</summary>

Изменение прав доступа в символьной нотации: `chmod +rwx file.txt` 

Изменение прав доступа в числовой нотации: `chmod 755 file.txt`


</details>

3. Кто может изменять права доступа к файлам?
<details>
<summary>ОТВЕТ</summary>
владелец и root
</details>

4. Для чего нужен ACL?
<details>
<summary>ОТВЕТ</summary>
нужны для более гибкого и точного управления правами доступа к файлам и директориям в операционных системах. (Например можно настроить доступп к файлу для двух пользователей и Наследование прав: ACL поддерживают наследование прав доступа от родительских директорий к дочерним. Это упрощает установку и управление правами для больших структур директорий.)
</details>

5. Как устанавливать атрибуты файла?
<details>
<summary>ОТВЕТ</summary>
chattr +(-)атрибут file_name
</details>

6. Может ли пользователь root игнорировать атрибуты файла при работе с ним?
<details>
<summary>ОТВЕТ</summary>
Вроде может но кроме u или i
</details>


### Допсы:
1. Объяснить почему на shadow нет битов доступа но все равно есть возможность создавать пароль с других юзеров:
```bash
# ls -l /etc/shadow /usr/bin/passwd
---------- 1 root root   798 Jul 21 21:15 /etc/shadow
-rwsr-xr-x 1 root root 26688 Sep 10  2015 /usr/bin/passwd
```
ответ: /etc/shadow и подобные программы либо имеют установленный бит suid (поэтому каждый может запускать их с правами root), либо предназначены только для использования root, поэтому разрешения на, в любом случае, не имеют значения.Биты разрешений обычно не применяются к процессам, запущенным с соответствующими возможностями (например, когда они выполняются с правами root). 

2. 


