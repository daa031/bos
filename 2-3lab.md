# 3  Лабораторная работа "Изучение SELinux"


### Использование SELinux

- lld для вывода динамических зависимостей
- тут видно что есть либа libselinux.so.1

```sh
[daa@localhost ~]$ ldd /bin/ls | grep selinux
	libselinux.so.1 => /lib64/libselinux.so.1 (0x00007f8cb2fc3000)
```

### Расположение в файловой системе

```sh
[daa@localhost ~]$ ls -l /etc/selinux/
[daa@localhost ~]$ ls -l /etc/selinux/targeted/
```ё
Выведут: 
- `/etc/selinux/` - тут лежат файлы конфигурации  selinux
    - `config` - 
        - `SELinux = enforcing / permissive / disabled` - режим работы
        - `SELINUXTYPE = targeted / minimum / mls` - тип политики
    - `semanage.conf` - Файл конфигурации для утилиты semanage (управлениие  настройками политики, такими как контекст безопасности и типы файлов)
    -  `targeted` - тут лежат доп файлы конфигурации
        - `booleans.subs_dist` -  определения для булевых переменных SELinux
        - `contexts` -  Этот каталог содержит файлы, определяющие контексты безопасности SELinux для различных объектов, таких как файлы, процессы и сетевые порты. Контексты безопасности определяют, как объекты в системе могут взаимодействовать друг с другом.
        - `logins` - файлы, связанные с контекстами безопасности для пользовательских учетных записей 
        - `policy` - файлы, определяющие правила и параметры политики SELinux для типа "целевой".
        - `setrans.conf` - тот файл содержит конфигурацию для инструмента setrans, который используется для управления переводами контекстов SELinux в метки безопасности
        - `seusers` - Этот файл определяет пользовательские имена, связанные с контекстами безопасности SELinux

## Контексты безопасности (КБ)

### пользователя
- `id -Z` отображает контекст безопасности текущего юзера
```sh
[daa@localhost targeted]$ id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```
- `unconfined_u` - пользователь не ограничен в своих действиях политикой SELinux
- `unconfined_r` - "неограниченная" роль.
- `unconfined_t` - "неограниченный" тип, что свидетельствует о том, что процессы, связанные с этим пользователем, ролью и контекстом, могут выполняться в обычном (неограниченном) режиме.
- `s0-s0` - уровень безопасности, где s0 означает базовый уровень 
- `c0.c1023` - указывает на контекст безопасности. c0 означает классификацию, а c1023 представляет собой уровень доступа.

### некоторых файлов
```sh
 $ ls -Z /etc/passwd /etc/group /etc/shadow
 system_u:object_r:passwd_file_t:s0 /etc/group
 system_u:object_r:passwd_file_t:s0 /etc/passwd
 system_u:object_r:shadow_t:s0 /etc/shadow

 $ ls -Z /etc/login.defs /etc/sudoers
 system_u:object_r:etc_t:s0 /etc/login.defs
 system_u:object_r:etc_t:s0 /etc/sudoers

 $ ls -Z /usr/bin/passwd 
 system_u:object_r:passwd_exec_t:s0 /usr/bin/passwd

 $ ls -Z /usr/sbin/useradd 
 system_u:object_r:useradd_exec_t:s0 /usr/sbin/useradd
```

### КБ файлов

Контексты безопасности файлов хранятся в расширенных атрибутах (extended attributes);файловой системы ext4 в пространстве security.selinux:

```c
        struct ext4_xattr_entry {
        __u8	e_name_len;	/* length of name */
        __u8	e_name_index;	/* attribute name index */
        __le16	e_value_offs;	/* offset in disk block of value */
        __le32	e_value_inum;	/* inode in which the value is stored */
        __le32	e_value_size;	/* size of attribute value */
        __le32	e_hash;		/* hash value of name and value */
        char	e_name[0];	/* attribute name */
        };
```

- `getfattr` - вывод атрибута с именем `-n security.selinux` у файла `/etc/passwd` 

```sh
[daa@localhost ~]$ getfattr -n security.selinux /etc/passwd
getfattr: Removing leading '/' from absolute path names
# file: etc/passwd
security.selinux="system_u:object_r:passwd_file_t:s0"
```

### КБ некоторых системных процессов:

```sh
ps Zaux
 LABEL                           USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
 ...
 system_u:system_r:init_t:s0     root         1  0.0  0.1 194328  5300 ?        Ss   апр19   0:06 /usr/lib/systemd/systemd --switched-root --sys
 ...
 system_u:system_r:auditd_t:s0   root      4566  0.0  0.0  55520   536 ?        S<sl апр19   0:00 /sbin/auditd
 ...
 system_u:system_r:systemd_logind_t:s0 root 4640 0.0  0.0  26452  1700 ?        Ss   апр19   0:01 /usr/lib/systemd/systemd-logind
 ...
 ```


- информацию, которую предоставляет файловая система /proc:
    - `current` - текущий контекст безопасности SELinux для процесса.
    - `exec` - раниться контекст, связанный с последним исполняемым файлом.
    - `fscreate` - безопасности, связанный с последним файлом, созданным процессом.
    - `keycreate` - процесс создавал ключи, то здесь может храниться контекст безопасности, связанный с последним созданным ключом.
    - `prev` - хранится предыдущий контекст безопасности SELinux, который был установлен для процесса.
    - `sockcreate` -  Если процесс создавал сокеты (сетевые соединения), здесь может храниться контекст безопасности, связанный с последним созданным сокетом.

```sh
[daa@localhost ~]$ ls /proc/$$/attr
current  exec  fscreate  keycreate  prev  sockcreate
```

### КБ процесса смены пароля пользователя

- `pgrep` - тулза поиска процессов по их именам
- `ps` - отображение инфы о текущих процессах системы 

```sh
[daa@localhost attr]$ ps Z $(pgrep passwd)
LABEL                               PID TTY      STAT   TIME COMMAND
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 11484 pts/0 Ss   0:00 -bash
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 11549 pts/0 R+   0:00 ps Z
```

### КБ некоторых сетевых портов:

```sh
[daa@localhost attr]$ netstat -tnlpZ
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name     Security Context                                 
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -                    -                                                 
tcp6       0      0 :::22                   :::*                    LISTEN      -                    -            
```

## Состояние системы

## sestatus / getenforce / /sys/fs/selinux/enforce
- `sestatus`
    - "enforcing" означает, что SELinux активно применяет свои политики.
- `getenforce`
- `/sys/fs/selinux/enforce`

```sh
[daa@localhost attr]$ sestatus 
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33

[daa@localhost attr]$ getenforce
Enforcing

[daa@localhost attr]$ cat /sys/fs/selinux/enforce 
1
```


### режимы работы SELinux: disabled, permissive, enforcing. 

```sh 
[daa@localhost attr]$ sestatus 
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33


# изменил на disabled (это видно из поля Mode from config file)
[daa@localhost attr]$ sudo nano /etc/selinux/config 
[daa@localhost attr]$ sestatus 
SELinux status:                 enabled
...
Current mode:                   enforcing
Mode from config file:          disabled
Policy MLS status:              enabled
...

#видно что SELinux отключен после перезагрузки
[daa@localhost attr]$ sudo reboot
[daa@localhost ~]$ sestatus 
SELinux status:                 disabled

#менем режим на Permissive
[daa@localhost ~]$ sudo nano /etc/selinux/config 
[daa@localhost ~]$ sudo reboot
[daa@localhost ~]$ sestatus 
SELinux status:                 enabled
...
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
...
```


### способы изменения режима работы SELinux: setenforce 1, echo 1 > /sys/fs/selinux/enforce.

- `setenforce  [0|1|permissive|enforcing]` - изменения, внесенные с помощью setenforce, не сохраняются после перезагрузки системы.

```sh
[daa@localhost ~]$ getenforce
Enforcing

#меняем режим работы на permissive
[daa@localhost ~]$ sudo setenforce 0
[daa@localhost ~]$ getenforce
Permissive
[daa@localhost ~]$ sestatus
...
Current mode:                   permissive
...

#видно что после перезагрузки настройки не сохранились
[daa@localhost ~]$ sudo reboot
[daa@localhost ~]$ getenforce 
Enforcing
[daa@localhost ~]$ sestatus 
...
Current mode:                   enforcing
...
```

- `echo 1 > /sys/fs/selinux/enforce` -  внесенные непосредственно с помощью команды echo 1 > /sys/fs/selinux/enforce, не сохранятся после перезагрузки системы. Этот метод изменяет значение параметра enforce в файловой системе ядра на текущей сессии работы системы, но не сохраняет его между перезагрузками.


### параметры сборки ядра

- `CONFIG_SECURITY_SELINUX_DEVELOP` - Этот параметр определяет, включена ли поддержка SELinux для разработчиков. Когда он включен (=y), в ядре включаются дополнительные функции и отладочная информация, которые могут быть полезны при разработке или отладке SELinux.
- `CONFIG_SECURITY_SELINUX_BOOTPARAM` - тот параметр определяет, поддерживаются ли параметры загрузки ядра, связанные с SELinux. Когда он включен (=y), ядро будет учитывать определенные параметры загрузки, позволяя пользователю задавать параметры SELinux при загрузке ядра.


## Переключатели (booleans)

### переключатели web-сервера:

информацию о различных переключателях SELinux, связанных с веб-сервером Apache (httpd)

```sh
getsebool -a | grep httpd

```
- `httpd_enable_homedirs` - веб-серверу Apache не разрешено обслуживать содержимое из домашних каталогов пользователей.

- `httpd_read_user_content - `веб-сервер Apache не разрешено читать содержимое из домашних каталогов пользователей.
```sh
httpd_anon_write --> off:

Запись анонимных пользователей в контент веб-сервера выключена.
httpd_builtin_scripting --> on:

Использование встроенных средств сценариев веб-сервера включено.
httpd_enable_cgi --> on:

Возможность использования сценариев CGI включена.
httpd_enable_ftp_server --> off:

Интеграция FTP-сервера в веб-сервер выключена.
```
для изменения:
```sh
sudo setsebool -P httpd_anon_write on
```

## Изучение политики безопасности

```sudo dnf install setools-console``` 

```sh
[daa@localhost ~]$ seinfo
Statistics for policy file: /sys/fs/selinux/policy
Policy Version:             33 (MLS enabled)
Target Policy:              selinux
Handle unknown classes:     allow
  Classes:             135    Permissions:         457
  Sensitivities:         1    Categories:         1024
  Types:              5091    Attributes:          253
  Users:                 8    Roles:                14
  Booleans:            349    Cond. Expr.:         379
  Allow:             63261    Neverallow:            0
  Auditallow:          165    Dontaudit:          8435
  Type_trans:       252097    Type_change:          87
  Type_member:          35    Range_trans:        6161
  Role allow:           37    Role_trans:          418
  Constraints:          70    Validatetrans:         0
  MLS Constrain:        72    MLS Val. Tran:         0
  Permissives:           2    Polcap:                6
  Defaults:              7    Typebounds:            0
  Allowxperm:            0    Neverallowxperm:       0
  Auditallowxperm:       0    Dontauditxperm:        0
  Ibendportcon:          0    Ibpkeycon:             0
  Initial SIDs:         27    Fs_use:               35
  Genfscon:            109    Portcon:             665
  Netifcon:              0    Nodecon:               0
[daa@localhost ~]$ 
```

- `seinfo --class` - вывод информации о классе объектов SELinux
- class это категория, определяющая типы ресурсов или объектов в системе, к которым может быть применена политика безопасности SELinux. Каждый класс объектов объединяет различные типы файлов или ресурсов по их функциональности или общим характеристикам.

```sh
[root@localhost daa]# seinfo --class | grep file
   blk_file
   chr_file
   fifo_file
   file
   filesystem
   lnk_file
   sock_file
```

- `seinfo --class file -x`  - вывести подробную (-х) инфу о claas`е file

```sh
[root@localhost daa]# seinfo --class file -x

Classes: 1
   class file
inherits file
{
	entrypoint
	execute_no_trans
}
```

- `seinfo --common file -x` - `--common` - ключ, указывающий seinfo вывести общие (common) разрешения и атрибуты для указанного класса объектов. покажет общие разрешения и атрибуты, применяемые к классу объектов SELinux file

```sh
[root@localhost daa]# seinfo --common file -x

Commons: 1
   common file
{
	append
	audit_access
	create
	execmod
	execute
	getattr
	ioctl
	link
	lock
	map
    ...
	rename
	setattr
    ...
}
```

- виды доступа для других классов: dir, blk_file, chr_file, lnk_file, fifo_file, sock_file, filesystem.

```sh
seinfo --class  < dir/blk_file/filesystem > -x
```



- Сравните виды доступа классов file и dir
Общие (common) разрешения для file:

Commons: 
- `swapon`: Разрешение для операции swapon.
- `relabelto`: Разрешение для операции relabelto.
- `map`: Разрешение для операции map.
- `quotaon`: Разрешение для операции quotaon.
- `execmod`: Разрешение для выполнения модуля ядра.
- `lock`: Разрешение для операции lock.
- `append`: Разрешение на дописывание данных.
- `audit_access`: Разрешение для операции audit_access.
- `setattr`: Разрешение для установки атрибутов.
- `ioctl`: Разрешение для операции ioctl.
- `mounton`: Разрешение для операции mounton.
- `link`: Разрешение для операции link.
- `execute`: Разрешение на выполнение файла.
- `rename`: Разрешение для операции rename.
- `relabelfrom`: Разрешение для операции relabelfrom.
- `read`: Разрешение на чтение файла.
- `create`: Разрешение для создания файла.
- `write`: Разрешение на запись в файл.
- `unlink`: Разрешение для операции unlink.
- `getattr`: Разрешение для получения атрибутов.
- `open`: Разрешение для операции open.


```sh
$ seinfo | grep 'Policy Version'
Policy Version:             32 (MLS enabled)
$ seinfo -c file -x

Classes: 1
   class file
inherits file
{
	entrypoint
	execute_no_trans
}
$ seinfo -c dir -x

Classes: 1
   class dir
inherits file
{
	add_name
	search
	remove_name
	reparent
	rmdir
}
$ seinfo --common file -x

Commons: 1
   common file
{
	swapon
	relabelto
	map
	quotaon
	execmod
	lock
	append
	audit_access
	setattr
	ioctl
	mounton
	link
	execute
	rename
	relabelfrom
	read
	create
	write
	unlink
	getattr
	open
}
```

## Управление контекстами безопасности файлов

1. Определение контекстов с помощью регулярных выражений. Файлы /etc/selinux/targeted/contexts/files/file_contexts.*. Изучите список регулярных выражений, задающих контесты безопасности файлов.

```sh
grep 'httpd_.*_t' /etc/selinux/targeted/contexts/files/file_context
```

2. Выведите список регулярных выражений:


```sudo dnf install policycoreutils-python-utils```

```sh
 # semanage fcontext -l
 Контекст файла SELinux                     тип                Контекст
 
 /.*                                        all files          system_u:object_r:default_t:s0 
 /[^/]+                                     regular file       system_u:object_r:etc_runtime_t:s0 
 /a?quota\.(user|group)                     regular file       system_u:object_r:quota_db_t:s0 
 /mnt(/[^/]*)?                              symbolic link      system_u:object_r:mnt_t:s0 
 /mnt(/[^/]*)?                              directory          system_u:object_r:mnt_t:s0 
 ...
```


3. Изучите назначение контекста файлам. Наследование по умолчанию. Создайте новый файл. Определите его контекст. Определите контекст каталога, в котором был создан файл

```sh
[daa@localhost 2l]$ ls -Zl file.txt 
-rw-r--r--. 1 daa daa unconfined_u:object_r:user_home_t:s0 7 Mar  8 14:32 file.txt
[daa@localhost 2l]$ ls -Zd .
unconfined_u:object_r:user_home_t:s0 .
[daa@localhost 2l]$ 
```



4. - 

5. Контекст файловой системы. Назначение контекста при монтировании файловой системы. Опции команды mount: context и defcontext.

6. 
###  Команда chcon.
Команда `chcon` в Linux используется для изменения контекста безопасности файлов и каталогов в системе, включая их тип, роль и пользователя SELinux. Эта команда позволяет вам явным образом устанавливать или изменять контексты безопасности, в отличие от автоматического присвоения, осуществляемого SELinux.

Синтаксис команды `chcon` выглядит следующим образом:

```bash
chcon [опции] новый_контекст файл(ы)
```

Некоторые основные опции:

- **`-t, --type=ТИП`**: Устанавливает тип (type) в новом контексте.
- **`-u, --user=ПОЛЬЗОВАТЕЛЬ`**: Устанавливает пользователя (user) в новом контексте.
- **`-r, --role=РОЛЬ`**: Устанавливает роль (role) в новом контексте.
- **`-l, --range=ДИАПАЗОН`**: Устанавливает диапазон (range) в новом контексте.

Примеры использования:

1. **Установка типа контекста:**
   ```bash
   chcon -t httpd_sys_content_t /var/www/html/index.html
   ```
   Этот пример устанавливает тип контекста файла `index.html` в `httpd_sys_content_t`.

2. **Установка пользователя и роли:**
   ```bash
   chcon -u system_u -r object_r /path/to/file
   ```
   Этот пример устанавливает пользователя и роль в новом контексте для файла.

3. **Сброс контекста:**
   ```bash
   chcon --reference=/etc/passwd /path/to/other/file
   ```
   Этот пример устанавливает контекст файла таким же, как у файла `/etc/passwd`. Это может быть полезно для восстановления контекста после некоторых изменений.

Важно отметить, что изменения, внесенные с помощью `chcon`, не сохраняются после перезагрузки системы. Если вы хотите сохранить изменения, лучше использовать `semanage` для добавления новых контекстов в правилах политики SELinux.

7. 
### Резервные копии. Сохранение и восстановление расширенных атрибутов.
Резервные копии (бэкапы) играют важную роль в обеспечении безопасности данных, позволяя восстановить информацию в случае её потери, повреждения или случайного удаления. При создании резервных копий необходимо учесть не только основные содержимое файлов, но и расширенные атрибуты, такие как атрибуты безопасности SELinux.

В Linux, команды `cp`, `rsync` или другие инструменты копирования файлов по умолчанию не всегда сохраняют расширенные атрибуты. Для выполнения резервного копирования с сохранением этих атрибутов можно использовать инструменты, поддерживающие их передачу.

Примеры:

1. **С помощью `rsync`:**
   ```bash
   rsync -aAX /source/directory/ /destination/directory/
   ```
   - `-a` - режим архива, включающий рекурсию и сохранение многих атрибутов файлов.
   - `-A` - сохранение расширенных атрибутов.
   - `-X` - сохранение атрибутов безопасности SELinux.

2. **С помощью `tar`:**
   ```bash
   tar --selinux --xattrs -cvf backup.tar /source/directory/
   ```
   - `--selinux` - сохранение атрибутов безопасности SELinux.
   - `--xattrs` - сохранение расширенных атрибутов.

3. **С помощью `cpio`:**
   ```bash
   find /source/directory/ | cpio -pdmu --quiet --preserve-context --atime-preserve=system
   ```
   - `--preserve-context` - сохранение атрибутов безопасности SELinux.

При восстановлении резервной копии также важно убедиться, что инструменты, используемые для восстановления, поддерживают передачу и восстановление этих атрибутов. В противном случае, можно потерять информацию о безопасности, которая была сохранена в расширенных атрибутах.


8. 
### Изменение контекста файла (постоянное). Команда semanage fcontext.


Команда `semanage fcontext` в SELinux используется для изменения (и добавления) правил контекста файлов. Эта команда позволяет вам настраивать, какие контексты безопасности будут автоматически присвоены файлам и каталогам при их создании в определенных местах файловой системы.

Синтаксис команды выглядит следующим образом:

```bash
semanage fcontext [опции] -a -t ТИП_КОНТЕКСТА ПАТТЕРН
```

Некоторые основные опции:

- **`-a`**: Добавить новое правило.
- **`-d`**: Удалить правило.
- **`-t ТИП_КОНТЕКСТА`**: Указать тип контекста, который вы хотите присвоить.
- **`-s СТАНДАРТ`**: Указать стандарт (например, `s0`) для установки уровня безопасности.
- **`-r РОЛЬ`**: Указать роль в контексте безопасности.
- **`-l`**: Вывести список текущих правил.

Примеры использования:

1. **Добавление правила:**
   ```bash
   semanage fcontext -a -t httpd_sys_content_t "/srv/web(/.*)?"
   ```
   Этот пример добавляет правило, что все файлы и подкаталоги в `/srv/web` должны иметь контекст безопасности `httpd_sys_content_t`.

2. **Удаление правила:**
   ```bash
   semanage fcontext -d "/srv/web(/.*)?"
   ```
   Этот пример удаляет ранее добавленное правило для `/srv/web`.

3. **Просмотр текущих правил:**
   ```bash
   semanage fcontext -l
   ```
   Этот пример выводит список текущих правил.

Изменения, внесенные с помощью `semanage fcontext`, остаются после перезагрузки системы и используются SELinux для автоматического присвоения контекстов безопасности файлам и каталогам в соответствии с вашими настройками.









## Ограничение web-сервера Apache с помощью политики безопасности SELinux

1. Для доступа к серверу из сети нужно узнать IP-адрес с помощью команды ip addr. Также дополнительно мнастроить файервол следующим образом:

```sh
[root@10 daa]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:44:7c:b2 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 85702sec preferred_lft 85702sec
    inet6 fe80::a00:27ff:fe44:7cb2/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:af:95:eb brd ff:ff:ff:ff:ff:ff
    inet 192.168.59.10/24 brd 192.168.59.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feaf:95eb/64 scope link 
       valid_lft forever preferred_lft forever
[root@10 daa]# firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
success
success
success
[root@10 daa]# 
```


2. Содержимое сайта располагается в директории /var/www/html/. Создайте файл index.html. Изучите типы созданного файла и директории.

```sh
[root@10 html]# ls -dZ /var/www/html/
system_u:object_r:httpd_sys_content_t:s0 /var/www/html/
[root@10 html]# ls -Z /var/www/html/index.html
unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html
[root@10 html]# 
```

### Изменение корневой директории сайта

```sh
[root@10 html]# curl 127.0.0.1/
Здравствуй, МИФИ!
[root@10 html]# nano /etc/httpd/conf/httpd.conf
[root@10 html]# nano /etc/httpd/conf/httpd.conf
[root@10 html]# nano /etc/httpd/conf/httpd.conf
[root@10 html]# mkdir /www
[root@10 html]# echo 'Новый сайт' > /www/index.html 
[root@10 html]# ls -dZ /www
unconfined_u:object_r:default_t:s0 /www
[root@10 html]# ls -Z /www/index.html
unconfined_u:object_r:default_t:s0 /www/index.html
[root@10 html]# ls
index.html
```
- `default_t` -  тип контекста безопасности по умолчанию - Правила не определен для каталога /www/ и его содержимого. 
- `unconfined_u` -  процесс, который создал каталог и файл, работает в режиме безопасности SELinux, "unconfined" (неограниченный). 

Перезапустите web-сервер Apache.

```sh
systemctl restart httpd.service
```



### Поиск причины
Права доступа субъектов к объектам кодируются в виде т.н. векторов доступа, которые для повышения производительности кэшируются. Поэтому сообщения системы аудита, которые генерятся системой SELinux имеют тип AVC (Access Vector Cache).

Проверьте работоспособность web-сервера Apache. Так как новая страница не появилась, выполните поиск недавних событий аудита с типом AVC

```sh
# ausearch -m avc -ts recent -i
----
type=PROCTITLE msg=audit(03/15/2024 00:40:22.084:98407) : proctitle=/usr/sbin/httpd -DFOREGROUND 
type=PATH msg=audit(03/15/2024 00:40:22.084:98407) : item=0 name=/www/index.html inode=393218 dev=103:03 mode=file,644 ouid=root ogid=root rdev=00:00 obj=unconfined_u:object_r:default_t:s0 nametype=NORMAL cap_fp=none cap_fi=none cap_fe=0 cap_fver=0 cap_frootid=0 
type=CWD msg=audit(03/15/2024 00:40:22.084:98407) : cwd=/ 
type=SYSCALL msg=audit(03/15/2024 00:40:22.084:98407) : arch=x86_64 syscall=stat success=no exit=EACCES(Permission denied) a0=0x7f21f000a408 a1=0x7f21f7ffe800 a2=0x7f21f7ffe800 a3=0x2 items=1 ppid=116731 pid=116734 auid=unset uid=apache gid=apache euid=apache suid=apache fsuid=apache egid=apache sgid=apache fsgid=apache tty=(none) ses=unset comm=httpd exe=/usr/sbin/httpd subj=system_u:system_r:httpd_t:s0 key=(null) 
type=AVC msg=audit(03/15/2024 00:40:22.084:98407) : avc:  denied  { getattr } for  pid=116734 comm=httpd path=/www/index.html dev="nvme0n1p3" ino=393218 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0 
```

Воспользуйтесь системой помощи SELinux - утилитой audit2why.

```sh
ausearch -m avc -ts recent | audit2why
```

```sh
[root@10 www]# ausearch -m avc -ts recent | audit2why
type=AVC msg=audit(1710576988.332:265): avc:  denied  { getattr } for  pid=2979 comm="httpd" path="/www/index.html" dev="dm-0" ino=50607204 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1710576988.332:266): avc:  denied  { getattr } for  pid=2979 comm="httpd" path="/www/index.html" dev="dm-0" ino=50607204 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:default_t:s0 tclass=file permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

[root@10 www]# ausearch -m avc -ts recent | audit2allow


#============= httpd_t ==============
allow httpd_t default_t:file getattr;
[root@10 www]# 

```


ответ

Результат audit2why и audit2allow указывает на то, что SELinux запрещает процессу с доменом httpd_t получать атрибуты файла с контекстом безопасности default_t.

Причиной этого запрета может быть то, что файл, к которому процесс с доменом httpd_t пытается получить доступ, находится в каталоге или имеет контекст безопасности, который не соответствует ожидаемым правилам безопасности SELinux для процесса httpd_t.


### Восстановление работы web-сервера Apache

``` sh
[root@10 www]# semanage fcontext -a -t httpd_sys_content_t "/www(/.*)?"
[root@10 www]# semanage fcontext -l | grep '^/www'
/www(/.*)?                                         all files          system_u:object_r:httpd_sys_content_t:s0 
[root@10 www]# restorecon -Rv /www/
Relabeled /www from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /www/index.html from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
[root@10 www]# ls -Z /www/index.html
unconfined_u:object_r:httpd_sys_content_t:s0 /www/index.html
[root@10 www]# curl 127.0.0.1/
Новый сайт
[root@10 www]# 
```


1. `semanage fcontext -a -t httpd_sys_content_t "/www(/.*)?"`: Эта команда добавляет новое правило контекста безопасности SELinux для всех файлов и подкаталогов в каталоге `/www`. Это правило говорит SELinux, что все файлы и подкаталоги в `/www` должны иметь контекст безопасности `httpd_sys_content_t`.

2. `semanage fcontext -l | grep '^/www'`: Эта команда отображает все текущие правила контекста безопасности SELinux для каталога `/www`. Результат показывает, что все файлы и подкаталоги в `/www` должны иметь контекст безопасности `httpd_sys_content_t`.

3. `restorecon -Rv /www/`: Эта команда восстанавливает контекст безопасности для всех файлов и подкаталогов в каталоге `/www` в соответствии с правилами, определенными в SELinux. Она изменяет контекст безопасности файлов и каталогов из предыдущего контекста (`default_t`) в новый контекст (`httpd_sys_content_t`).

4. `ls -Z /www/index.html`: Эта команда выводит контекст безопасности файла `/www/index.html`. Результат показывает, что контекст безопасности файла теперь `httpd_sys_content_t`.







## Переходы

### Переход типа 
- Переход типа - изменение типа контекста безопасности файла или процесса в процессе выполнения. 


- `sesearch -T -s httpd_t -t var_log_t ` - поиск и анализ политики безопасности SELinux.
    - `-T` - вывести информацию о типе политики SELinux. Он говорит о том, что вы ищете правила перехода типа (Type Transition).
    - `-s httpd_t` - Указывает начальный тип контекста безопасности (httpd_t). 
    - `-t var_log_t` -  Указывает конечный тип контекста безопасности (var_log_t).
    - ищет правила перехода типа, которые позволяют веб-серверу (httpd_t) выполнять операции над лог-файлами (var_log_t).


```sh
type_transition httpd_t tmp_t : file httpd_tmp_t;

```
Это правило говорит, что процессы с контекстом безопасности httpd_t (например, веб-сервер) при взаимодействии с файлами, к которым применяется тип контекста tmp_t (например, временный каталог), временно изменят свой контекст безопасности на httpd_tmp_t в процессе выполнения операции над этими файлами.


```sh
 $ sesearch -T -s httpd_t -t tmp_t
 Found 4 semantic te rules:
    type_transition httpd_t tmp_t : file httpd_tmp_t; 
    type_transition httpd_t tmp_t : dir httpd_tmp_t; 
    type_transition httpd_t tmp_t : lnk_file httpd_tmp_t; 
    type_transition httpd_t tmp_t : sock_file httpd_tmp_t; 
```


### Переход домена

- Разрешение процессу в домене passwd_t изменить файл с типом shadow_t

```sh
    $ sesearch --allow --source passwd_t --target shadow_t --class file
    allow passwd_t shadow_t:file { append create getattr ioctl link lock map open read relabelfrom relabelto rename setattr unlink write };
```

#### Условия для выполнения перехода домена

1. Новый домен процесса имеет право entrypoint к типу исполняемого файла (запускаемой программы). Пример:
```sh
 # sesearch -A -s passwd_t -t passwd_exec_t -c file
    allow passwd_t passwd_exec_t:file { entrypoint execute getattr ioctl lock map open read };
```

2. Текущий домен процесса имеет право execute к типу файла, который является точкой входа (entry point). Пример:
```sh
 # sesearch -A -s unconfined_t -t passwd_exec_t -c file
    allow unconfined_t passwd_exec_t:file { execute execute_no_trans getattr ioctl map open read };
```

3. Текущий домен процесса имеет право transition к новому домену. Пример:
```sh
 # sesearch -A -s unconfined_t -t passwd_t -c process
    allow unconfined_t passwd_t:process transition;
```
#### Инициирование перехода домена по умолчанию
```sh
    $ sesearch --type_trans -s unconfined_t -t passwd_exec_t
    type_transition unconfined_t passwd_exec_t:process passwd_t;
```



## Аудит

```sh
[root@10 www]# seinfo | grep -E '(dontaudit|allow)'.
  Allow:             63261    Neverallow:            0
  Auditallow:          165    Dontaudit:          8435
  Role allow:           37    Role_trans:          418
  Allowxperm:            0    Neverallowxperm:       0
  Auditallowxperm:       0    Dontauditxperm:        0
[root@10 www]# 

```

```sh
ausearch -m avc,user_avc,selinux_err -ts recent
```