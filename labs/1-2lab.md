# Лабораторная работа "Управление пользователями"

# Изучаемые команды и файлы

Команды управления пользователями: useradd, userdel, usermod, chage
Команды управления группами: groupadd, groupdel, groupmod
Команды для повышения привилегий: sudo, su
Конфигурационные файлы: /etc/passwd, /etc/shadow, /etc/group, /etc/default/useradd, /etc/login.defs, /etc/sudoers


# Файлы

## /etc/passwd
В текстовом файле /etc/passwd содержится список пользователей. Каждая строка этого файла описывает одного пользователя и представляет собой запись, состоящую из семи полей, разделенных двоеточием.

```bash
daa031:x:1000:1000:daa031:/home/daa031:/bin/bash
```
1. имя  пользователя
2. зашиврованный пароль(x-означает что хэш сумма пароля хранится в /etc/shadow)
3. идентификатор пользователя(UID)
4. идентификатор основной группы пользователя(GID)
5. комментарий(GECOS)
6. путь к домашней директории
7. путь к программе которая будет запущена после входа

## /etc/shadow

Текстовый файл /etc/shadow для управления паролями пользователей. Он принадлежит пользователю root и не доступен на чтение и запись обычным пользователям. Каждая строка этого файла соответствует одному пользователю системы и представляет собой запись, состоящую из девяти полей, разделенных двоеточием. Основная функция файла /etc/shadow – хранить хэш-суммы паролей пользователей системы. Для вычисления хэш-суммы пароля должна использоваться криптографическая хэш-функция.

```bash
daa031:$y$j9T$eSmDL7Us8LB47dmdLgbZC1$XN0VFNn9ohyfjjCzaUElPSiWbdOO6HYmDB/ga6PLd76:19494:0:99999:7:::
```
1. имя  пользователя
2. $ идентификатор алгоритма хэширования $ соль $ хэш сумма
3. Дата последнего изменения пароля
4. минимальный срок действия пароля
5. максимальный срок действия пароля
6. период предупреждения
7. период бездействия пароля
8. срок действия учетной записи

## /etc/group
Пользователи объединяются в группы для более гибкого управления доступом к файлам. Пользователь должен входить как минимум в одну группу — такую группу называют основной (primary). Также пользователь может входить в несколько дополнительных (supplementary) групп. Список групп хранится в текстовом файле /etc/group. Каждая строка этого файла описывает одну группу и представляет собой запись, состоящую из четырех полей, разделенных двоеточием.

```bash
mephi:x:1003:name1,name2
```

1. Имя группы
2. Зашифрованный пароль группы
3. Идентификатор группы (GID)
4. Список имен пользователей, входящих в группу

## /etc/login.defs
содержит настройки и параметры, связанные с процессом аутентификации и управлением учетными записями пользователей в системе Linux. Эти настройки позволяют администраторам настраивать различные аспекты входа в систему и безопасности пользовательских учетных записей. '

## /etc/sudoers
Файл /etc/sudoers содержит настройки и правила, связанные с использованием команды sudo.айл /etc/sudoers содержит список правил, каждое из которых определяет, какие пользователи или группы пользователей могут выполнять определенные команды с привилегиями суперпользователя


# Командный интерфейс


## useradd
Для создания пользователя предназначена команда ``useradd``. С помощью опций команды можно явно задать каждую характеристику пользователя. Если опции не заданы, берутся значения по умолчанию из файлов ``/etc/default/useradd ``и ``/etc/login.defs``. После создания домашней директории пользователя в нее копируется содержимое директории ``/etc/skel``, в которую системный администратор может поместить файлы, которые по умолчанию должны присутствовать у каждого пользователя.  

- ``/etc/default/useradd``- ранения настроек по умолчанию, которые применяются при создании новых пользователей с помощью команды useradd. GROUP - группу по умолчанию, к которой будет добавлен новый пользователь. HOME - задает домашний каталог(GROUP=100 в файле /etc/default/useradd обычно указывает на числовой идентификатор (GID) группы, которой по умолчанию будет принадлежать новый пользователь при создании. В данном случае, 100 - это GID группы.). INACTIVE - Указывает, сколько дней новый пользователь может оставаться неактивным (не входить в систему) до того, как его учетная запись будет заблокирована. Значение по умолчанию обычно равно -1. EXPIRE -  Позволяет задать дату окончания действия учетной записи нового пользователя. Учетная запись будет блокирована после этой даты. SHELL - Задает оболочку по умолчанию для новых пользователей. SKEL - Определяет каталог с шаблонами файлов и каталогов, который будет использоваться для инициализации домашнего каталога нового пользователя. CREATE_MAIL_SPOOL - Если установлено в yes, создается почтовый ящик (spool) для пользователя по умолчанию. Если установлено в no, то почтовый ящик не создается.

- ``/etc/login.defs``  -является конфигурационным файлом, который содержит различные параметры и настройки для управления поведением учетных записей.  UID_MIN и UID_MAX: Определяют минимальный и максимальный UID (User Identifier) для пользовательских учетных записей. GID_MIN и GID_MAX: Аналогично UID_MIN и UID_MAX, но для групповых идентификаторов (GID).PASS_MAX_DAYS и PASS_MIN_DAYS: Устанавливают максимальное и минимальное количество дней, которое пользователь может держать пароль, прежде чем ему потребуется его изменить.PASS_WARN_AGE: Определяет количество дней, за которое пользователь будет предупрежден о необходимости сменить пароль до истечения срока действия текущего пароля.PASS_MIN_LEN: Устанавливает минимальную длину пароля для пользователей.LOGIN_RETRIES: Задает количество попыток входа в систему с неправильным паролем перед блокировкой учетной записи. UMASK: Устанавливает маску доступа по умолчанию для создаваемых файлов и директорий пользователей.USERGROUPS_ENAB: Управляет созданием групп с именами, совпадающими с именами пользователей, по умолчанию. Если установлено в yes, то для каждого пользователя будет создана группа с тем же именем. MAIL_DIR: Устанавливает директорию для почтовых ящиков пользователей.ENV_PATH: Определяет путь по умолчанию, который будет установлен для переменной окружения PATH при входе пользователя.ENV_ROOTPATH: Устанавливает путь по умолчанию для пользователя root.ENCRYPT_METHOD: Определяет метод, используемый для хэширования паролей. Обычно устанавливается в SHA512.SHA_CRYPT_MIN_ROUNDS и SHA_CRYPT_MAX_ROUNDS: Определяют количество раундов, используемых при хэшировании паролей в методе SHA-512. Эти параметры повышают безопасность паролей.


- ``/etc/skel`` - используется в Linux для создания домашних каталогов новых пользователей при их первом входе в систему или при создании новой учетной записи. Директория /etc/skel содержит набор файлов и каталогов, которые будут скопированы в домашние каталоги новых пользователей как начальная конфигурация. .bashrc и .bash_profile: Начальные настройки оболочки Bash для новых пользователей.
.profile: Начальные настройки оболочки Bourne-compatible для новых пользователей (если используется оболочка, совместимая с Bourne shell).
.bash_logout: Команды, выполняемые при выходе пользователя из системы.
.ssh: Каталог для SSH-ключей и настроек, если SSH используется на системе.
public_html: Каталог для веб-страниц, если используется Apache или другой веб-сервер.



Команда ``useradd`` по умолчанию создает записи для нового пользователя в трех основных файлах. Для пользователя создана новая индивидуальная группа, в которую входит только данный пользователь. Пароль пользователю по умолчанию не устанавливается, поэтому его нужно установить явно командой ``passwd``.

Для модификации пользователя используется команда ``usermod``. Ее опции в основном повторяют опции команды useradd.

Иногда пользователю требуется возможность аутентификации по паролю, но не требуется работать в командной оболочке. Например, на почтовом сервере пользователи должны иметь учетные записи, чтобы подключаться из почтовых клиентов. Тогда в качестве входной оболочки можно установить программу ``/sbin/nologin``.


## userdel 
Для удаления пользователя используется команда userdel. По умолчанию команда userdel только удаляет учетную запись пользователя, но не затрагивает его файлы. (с флагом -r чтобы кикнуть все)(-f (--force) -  чтобы отключает запросы на подтверждение и выполняет операцию удаления без дополнительных вопросов.)

## passwd

- ``passwd -e`` / ``chage -d 0`` - заставить пользователя сменить пароль при следующем входе в систему. В результате, в поле даты последнего изменения пароля будет записан 0.

- ``usermod -L(-U)`` / ``passwd -l(-u)`` - заблокировать(разблокировать) вход пользователя в систему по паролю.

После создания учетной записи пользователя в поле, где хранится хэш-сумма пароля, записан восклицательный знак, что не позволяет пользователю войти в систему без пароля. При блокировке пользователя хэш-сумма пароля не изменяется, но в начало записывается восклицательный знак. При разблокировании пользователя восклицательный знак просто удаляется. 
```bash
sudo usermod -L kikmepls
cat /etc/shadow
>kikmepls:!$6$LjBXWCaDSu
sudo usermod -U kikmepls
cat /etc/shadow
>kikmepls:$6$LjBXWCaDSu
```

## groupadd

используется для создания новой группы пользователей. Группы представляют собой организационные единицы, которые могут содержать одного или нескольких пользователей и обеспечивать управление правами доступа к файлам и ресурсам.(sudo groupadd -r -g 1000 sysgroup Создание системной группы с именем "sysgroup" и числовым идентификатором GID 1000:)

# Суперпользователь

Для повышения своих привилегий используются такие программы, как sudo, su или Polkit. Команда ``su - <username> ``позволяет войти под пользователем ``<username>``. Если имя пользователя не указано, подразумевается ``root``:
`` su -``

Команда ``sudo`` позволяет выполнить другую команду от лица суперпользователя или другого пользователя в зависимости от настроек в конфигурационном файле ``/etc/sudoers``. В отличие от su, sudo требует ввода пароля текущего пользователя, а не пользователя, от лица которого запрашивается доступ:
```bash
sudo cat /etc/shadow
# [sudo] password for <username>:
```
- Все действия с использованием sudo по умолчанию записываются в файл /var/log/secure.


# Задания

## Повышение привилегий

### su
Войдите в систему от лица обычного пользователя. Изучите своё окружение, выполнив следующие команды:

```bash
id
pwd
echo $HOME
echo $PATH
```
-  ``su - daa`` перейти на пользоваетля daa

результат:
```bash
[user2@localhost ~]$ id
uid=1002(user2) gid=1002(user2) groups=1002(user2) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
[user2@localhost ~]$ pwd
/home/user2
[user2@localhost ~]$ echo $HOME
/home/user2
[user2@localhost ~]$ echo $PATH
/home/user2/.local/bin:/home/user2/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
```
Повысьте свои привилегии, сменив пользователя на root. Снова изучите своё окружение.

```bash
[user2@localhost ~]$ su
Password: 
[root@localhost user2]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
[root@localhost user2]# pwd
/home/user2
[root@localhost user2]# 
[root@localhost user2]# echo $home

[root@localhost user2]# echo $HOME
/root
[root@localhost user2]# echo $PATH
/root/.local/bin:/root/bin:/home/user2/.local/bin:/home/user2/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
[root@localhost user2]# exit
exit
[user2@localhost ~]$ 
```

### sudo
Войдите в систему от лица обычного пользователя. Попробуйте вывести последние 5 строк файла /var/log/messages. Воспользуйтесь sudo, чтобы решить задачу.

```bash
[user2@localhost ~]$ tail -n 5 /var/log/messages
tail: cannot open '/var/log/messages' for reading: Permission denied
[user2@localhost ~]$ sudo tail -n 5 /var/log/messages

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for user2: 
user2 is not in the sudoers file.  This incident will be reported.
[user2@localhost ~]$ sudo tail -n 5 /var/log/messages
[sudo] password for user2: 
Sorry, try again.
[sudo] password for user2: 
user2 is not in the sudoers file.  This incident will be reported.
[user2@localhost ~]$ su
Password: 
[root@localhost user2]# tail -n 5 /var/log/messages
Oct  5 22:08:19 localhost systemd[1]: Started Hostname Service.
Oct  5 22:08:49 localhost systemd[1]: systemd-hostnamed.service: Deactivated successfully.
Oct  5 22:11:03 localhost su[1658]: FAILED SU (to root) user2 on pts/0
Oct  5 22:11:07 localhost su[1661]: (to root) user2 on pts/0
Oct  5 22:17:18 localhost su[1695]: (to root) user2 on pts/0
```


Сделайте резервную копию файла /etc/motd, назовите её /etc/motdOLD. Попробуйте выполнить
(Файл /etc/motd (Message Of The Day) содержит текстовое сообщение, которое отображается при входе в систему через командную строку или терминал.)
```bash
[user2@localhost etc]$ sudo echo "Welcome to Linux!" >> /etc/motd
-bash: /etc/motd: Permission denied
[user2@localhost etc]$ sudo echo "Welcome to Linux!" >> /etc/motd
-bash: /etc/motd: Permission denied
[user2@localhost etc]$ su
Password: 
[root@localhost etc]# sudo echo "Welcome to Linux!" >> /etc/motd
[root@localhost etc]# cat motd
Welcome to Linux!
[root@localhost etc]# reboot
[root@localhost etc]# Connection to 192.168.3.35 closed by remote host.
Connection to 192.168.3.35 closed.
[daa031@fedora .ssh]$ ssh rocky 
Welcome to Linux!
Last login: Thu Oct  5 20:59:38 2023 from 192.168.3.4
[daa@localhost ~]$ 
```
- объяснение почему. sudo применяется к команде echo, но не к самому оператору >> , который выполняет перенаправление вывода в файл /etc/motd (решение ``echo "Welcome to Linux!" | sudo tee -a /etc/motd
``) (tee позволяет выполнить операцию записи с правами суперпользователя, а флаг -a используется для добавления текста в конец файла без перезаписи его содержимого.)

# Изучение конфигурационных файлов

## /etc/passwd

В качестве примера работы с файлом /etc/passwd рассмотрим shell-скрипт, который выводит на экран информацию о пользователях, у которых в качестве оболочки установлен Bash. Для разбиения записей на отдельные поля используется тот факт, что поля разделяются символом :. Поэтому если переопределить переменную IFS (Internal Field Separator), Bash будет читать отдельные поля, как отдельные слова, разделенные символом-разделителем:

```bash
grep 'bash$' /etc/passwd |
while IFS=: read user passwd uid gid name homedir shell
do
    printf "%16s: %s\n" \
        User "$user" \
        Password "$passwd" \
        "User ID" "$uid" \
        "Group ID" "$gid" \
        Name "$name" \
        "Home directory" "$homedir" \
        Shell "$shell"
    echo
done
```

## /etc/shadow
Предположим, что сегодня 31 января, и в системе создан пользователь, который будет работать над проектом в течение шести месяцев (180 дней). Команда date позволяет вычислить дату, которая наступит через определенное количество дней после текущего дня. Срок действия учетной записи для нового пользователя можно ограничить 180 днями. Пароль требуется менять не реже, чем каждые три месяца (90 дней). Минимальный срок действия пароля не установлен. За пять дней до обязательной смены пароля пользователю начнут выдаваться предупреждения. Если пользователь не поменяет свой пароль, то в течение 10 дней он сможет войти в систему со старым паролем и установить новый пароль. Команда chage -l выводит текущие настройки пароля пользователя.

```bash
date
# Вывод: Mon 31 Jan 2022 02:50:12 PM MSK

date -d +180days +%Y-%m-%d
# Вывод: 2022-07-30

sudo chage -E $(date -d +180days +%Y-%m-%d) ivan
# Нет вывода

sudo chage -m 0 -M 90 -W 5 -I 10 ivan
# Нет вывода

sudo chage -l ivan
# Вывод:
# Last password change                              : Jan 31, 2022
# Password expires                                  : May 01, 2022
# Password inactive                                 : May 11, 2022
# Account expires                                   : Jul 30, 2022
# Minimum number of days between password change    : 0
# Maximum number of days between password change    : 90
# Number of days of warning before password expires : 5

sudo grep ivan /etc/shadow
# Вывод: ivan:$6$ZjdXqIs4BlbjqkBs$7oRI476rdxWEr-iysR0UYScdvaLrHO2uq9msYpVxnxeO0zuaeDTvpmfedb8oLC8kDBz9FPrrzRLn70y9//f06x.:19023:0:90:5:10:19203:
```

# Создание пользователя

## Вручную
Так как информация о пользователе хранится в простых текстовых файлах, управлять учетными записями можно и вручную. Для этого необходимо выполнить следующие действия:

1. Выбрать отличительные характеристики пользователя: логическое имя, идентификатор пользователя UID, идентификатор группы пользователя GID.
2. Создать запись в /etc/passwd.
3. Создать запись в /etc/group.
4. Создать домашнюю директорию пользователя по шаблону /home/<username>
5. Скопировать в домашнюю директорию файлы, которые должны присутствовать у пользователя и, в том числе, выполняться при входе пользователя в систему.
6. Изменить владельца и группу домашней директории со всем ее содержимым на вновь созданного пользователя и его группу. При необходимости изменить права к домашней директории.
7. Создать запись в /etc/shadow в соответствии с политикой безопасности организации по управлению паролями (например, как часто надо пользователю менять свой пароль).
8. Установить пользователю пароль.
Проделайте эти шаги и создайте пользователя вручную.

Подсказка
Для создания записи в /etc/shadow можно воспользоваться командой openssl passwd.


### Решение
1. 
2. ``nano /etc/passwd`` - добавим сюда новую строку ``user_lab:x:1003:1003::/home/user_lab:/bin/bash``
3. ``nano /etc/group`` - добавим сюда новую строку ``user_lab:x:1003:``
4. ``/home/user_lab`` - Создать домашнюю директорию пользователя
5. немного изменил ``/etc/skel``; ``cp -r /etc/skel/* /home/user_lab`` - скопировал скелет;
6. ``sudo chown -R user_lab:1003 /home/user_lab`` ; ``sudo chmod 700 /home/user_lab``- изменить владельца и группу домашней директории на вновь созданного пользователя и его группу.  ``ls -l`` - вывод: ``drwxr-xr-x. 2 user_lab user_lab  6 Oct  6 00:36 desktop`` -  Это описание типа и прав доступа к директории desktop, где d - директория,  rwx - права доступа для владельца (чтение (r), запись (w) и выполнение (x)); r-x - права для группы и r-x - права для остальных пользователей. ``chmod 700 /home/user_lab/`` дать права :7 означает права доступа для владельца (user), которые включают в себя rwx (чтение, запись и выполнение). 0 означает отсутствие прав доступа для группы и остальных пользователей (ничего не разрешено).
7.  ``openssl passwd -6 1`` - выдасть сторку
8. эту строку прокинуть в /etc/shadow и записать туда же дату :``current_date=$(date +%s) days_since_epoch=$((current_date / 86400)) echo $days_since_epoch `` выведет ``19636`` Эта команда вернет текущую дату и время в секундах с начала эпохи Unix. Чтобы получить количество дней, вы можете разделить это значение на 86400 (поскольку в одном дне 86400 секунд): 
9. тестим. Надо выйти из рута залогиниться под дргим пользователм и потом уже из него выполнить вход с паролем на новосозданного юзер_лаб
10. ``visudo`` -  сюда вписать <user_name> ALL=(ALL) ALL чтобы дать права супер пользователя 

## С использованием командного интерфейса
```bash
[root@localhost ~]# useradd user_lab2
[root@localhost ~]# passwd user_lab2
Changing password for user user_lab2.
New password: 
BAD PASSWORD: The password is a palindrome
Retype new password: 
passwd: all authentication tokens updated successfully.
[root@localhost ~]# cd /home/
[root@localhost home]# ls
daa  kikmepls  user2  user_lab  user_lab2
[root@localhost home]# cd user_lab2
[root@localhost user_lab2]# ls
desktop  project1
[root@localhost user_lab2]# 
```

### сравнение
```bash
[root@localhost user_lab2]# grep user_lab /etc/shadow
user_lab:$6$GoFwPT6/n9quXBvi$9NvugaDZxRpYanCoiZ2jX0mPz/pF96Jj/2drRU2uM6kaDGjzQghO9oRUg.MsArBk2OQ5Pls8i5qACAkHsLXpI0:19636:0:99999:7:::
user_lab2:$6$UFICcYiTysPZ0vAD$jakjcjLA5RVPEOJ.IeUKmRv/CvNqQFc7Rc1EC7hTEtNl0G4E6TTvbWgUJ7aquKnsjKYK.fHgrlQy6QUcrswjr0:19636:0:99999:7:::
[root@localhost user_lab2]# grep user_lab /etc/passwd
user_lab:x:1003:1003::/home/user_lab:/bin/bash
user_lab2:x:1004:1004::/home/user_lab2:/bin/bash
[root@localhost user_lab2]# grep user_lab /etc/group
user_lab:x:1003:
user_lab2:x:1004:
[root@localhost user_lab2]# 
```

## Удаление пользователя
Рассмотрим пример, когда удаляется только учетная запись пользователя, но после создания нового пользователя последний получает доступ к файлам пользователя, который был удален.
```bash
sudo useradd old
id old
# Вывод: uid=1003(old) gid=1004(old) groups=1004(old)

ls -l /home/
# Часть вывода: drwx------. 2 old     old      62 Sep 26 20:52 old

sudo userdel old
ls -l /home
# Часть вывода: drwx------. 2    1003    1004  62 Sep 26 20:52 old

sudo useradd new
id new
# Вывод:  uid=1003(new) gid=1004(new) groups=1004(new)

ls -l /home
# Часть вывода:
# drwx------. 2 new     new      62 Sep 26 20:54 new
# drwx------. 2 new     new      62 Sep 26 20:52 old
```
Чтобы предотвратить подобные ситуации, рекомендуется не удалять пользователя, а блокировать его учетную запись. Дополнительно можно придерживаться правил, следующих ниже.

- При создании нового пользователя явно указывать его UID:
```bash
sudo useradd -u 1002 user2
```

- При удалении пользователя перемещать все его файлы в специально выделенную директорию, а его домашнюю директорию удалять:
```bash
find / -user user1 -exec mv {} /new/location; 2>/dev/null
sudo userdel -r user1
```

- Чтобы найти файлы, которые не принадлежат никакому пользователю, можно выполнить следующую команду:
```bash
find / -nouser -o -nogroup 2>/dev/null
```

```
Команда find / -nouser -o -nogroup 2>/dev/null используется для поиска файлов и директорий в корневой директории (/) системы, которые не имеют назначенных пользователей (владельцев) или групп. Давайте разберем эту команду по частям:

find: Это утилита поиска файлов и директорий в файловой системе.

/: Это начальный путь, с которого начинается поиск. В данном случае, поиск выполняется в корневой директории, то есть по всей файловой системе.

-nouser: Этот параметр find фильтрует файлы и директории, которые не имеют назначенного пользователя (владельца).

-o: Этот параметр find означает "или". Он позволяет выполнять операции "или" между разными критериями поиска. В данной команде он используется для того, чтобы найти файлы или директории, которые не имеют назначенного пользователя ИЛИ не имеют назначенной группы.

-nogroup: Этот параметр find фильтрует файлы и директории, которые не имеют назначенной группы.

2>/dev/null: Эта часть команды направляет стандартный поток ошибок (stderr) в /dev/null, что означает, что ошибки (например, отсутствие разрешений на доступ к определенным директориям) будут игнорироваться, и вы не увидите их на экране.

Таким образом, команда find / -nouser -o -nogroup 2>/dev/null выполняет поиск файлов и директорий в корневой директории, которые либо не имеют назначенного пользователя (владельца), либо не имеют назначенной группы. Результаты поиска будут выведены на экран, если они найдены, но ошибки будут подавлены и не отображены.

```

## Прикладная задача
Пусть вам необходимо

1. Создать группу consultants с GID 40000, создать в ней пользователей для Ивана, Полины и Дмитрия. Основная группа должна быть группой с именем пользователя
2. Задать каждому пользователю пароль default
3. Потребовать смены пароля пользователей каждые 30 дней, за исключением Полины — ей 15 дней
4. Аккаунты должны истечь через 90 дней
5. После первого входа пользователи должны сменить свой пароль


### решение:
<details>
<summary>ОТВЕТ</summary>

1. Создать группу consultants с GID 40000, создать в ней пользователей для Ивана, Полины и Дмитрия. Основная группа должна быть группой с именем пользователя

- `groupadd -g` : -g устанавливает числовой индификатор (GID)
- ``useradd -g <> -G <> -m <>`` : -g  указывает основную группу пользователя ; -G указывает дополнительные группы; -m казывает создать домашний каталог для пользователя


Создать группу consultants с GID 40000
```bash
groupadd -g 40000 users_lab
``` 
создать группы с именем пользователя
```bash
groupadd -g 40001 ivan
groupadd -g 40002 polina
groupadd -g 40003 dima
 ```

добивть пользователя в именную группу как в основную и в общую
```bash
useradd -g ivan -G users_lab -m ivan
useradd -g polina -G users_lab -m polina
useradd -g dima -G users_lab -m dima
 ```

результат
```bash
cat /etc/group
users_lab:x:40000:ivan,polina,dima
ivan:x:40001:
polina:x:40002:
dima:x:40003:

cat /etc/passwd 
ivan:x:1006:40001::/home/ivan:/bin/bash
polina:x:1007:40002::/home/polina:/bin/bash
dima:x:1008:40003::/home/dima:/bin/bash
```

2. Задать каждому пользователю пароль default

```bash
[root@localhost home]# passwd ivan
Changing password for user ivan.
New password: 
BAD PASSWORD: The password is shorter than 8 characters
Retype new password: 
passwd: all authentication tokens updated successfully.
```

3. Потребовать смены пароля пользователей каждые 30 дней, за исключением Полины — ей 15 дней

chage:
- -m минимальное количество дней, которое должно пройти между сменой паролей
- -M количество дней, через которое пароль пользователя должен быть изменен
- -W редупреждение (warning) в днях до истечения срока действия пароля

```bash
chage -m 0 -M 30 -W 7 ivan
chage -m 0 -M 30 -W 7 dima
chage -m 0 -M 15 -w 7 polina
```

4. Аккаунты должны истечь через 90 дней
- E: Этот параметр -E используется для указания даты окончания срока действия учетной записи.`$(date -d "+90 days" +%Y-%m-%d):` Внутри круглых скобок выполняется команда date, которая вычисляет текущую дату и добавляет к ней 90 дней. Формат %Y-%m-%d указывает на формат даты (год-месяц-день), в который нужно преобразовать результат выполнения команды date. Таким образом, эта часть команды определяет дату, через которую истечет срок действия учетной записи.

```bash
chage -E $(date -d "+90 days" +%Y-%m-%d) ivan
chage -E $(date -d "+90 days" +%Y-%m-%d) dima
chage -E $(date -d "+90 days" +%Y-%m-%d) polina
```

5. После первого входа пользователи должны сменить свой пароль
- ``passwd -e polina`` - Эта команда установит флаг "пароль истек" для пользователя "Иван". После этого, когда пользователь "Иван" попытается войти в систему, ему будетпредложено сменить свой пароль.

```bash
[root@localhost ~]# passwd -e ivan
Expiring password for user ivan.
passwd: Success
[root@localhost ~]# passwd -e dima
Expiring password for user dima.
passwd: Success
[root@localhost ~]# passwd -e polina
Expiring password for user polina.
passwd: Success
```
</details>






## Допуск
- Назовите основные команды получения справки по программам.
<details>
<summary>ОТВЕТ</summary>
man, -h (help), info

</details>

- Назовите основные команды навигации по системе, вывода на экран произвольного текста, содержимого файлов и директорий.
<details>
<summary>ОТВЕТ</summary>

`ls -l`,`pwd`, `cd`; `echo`; `cat`; `less` ; `head -n 5 filename `

</details>

- Назовите основные команды создания, перемещения, удаления файлов и директорий.
<details>
<summary>ОТВЕТ</summary>
touch, mkdir; cd, pwd;  mv, cp; rm (-r, -i)
</details>

- Назовите команду для поиска файлов в файловой системе.
<details>
<summary>ОТВЕТ</summary>
find <где> -name <имя фала> -o -name <*.cpp> -type f(d) -mtime -7 -size +10M -user username

или 

find /path/to/search -type f \( -name "file1.txt" -o -name "file2.txt" \)

</details>

- Что делают операторы >, >>, |?
<details>
<summary>ОТВЕТ</summary>

- `>` - используется для перенаправления вывода команды в файл. Если файл не существует, он будет создан; если файл существует, он будет перезаписан. 
- `>>` - используется для перенаправления вывода команды в файл, но в отличие от >, он добавляет вывод в конец файла, не перезаписывая его. 
- `|` - используется для передачи вывода одной команды в качестве ввода в другую команду. Это позволяет создавать цепочки команд (конвейеры) для обработки данных. Пример:
</details>

- В каком файле хранятся данные о пользователях?
<details>
<summary>ОТВЕТ</summary>

``/etc/passwd``

</details>

- Назовите команды для создания/удаления/изменения пользователя/группы.
<details>
<summary>ОТВЕТ</summary>

- Создание пользователя/группы ``sudo useradd`` / ``sudo groupadd``
- удаления пользователя/группы ``sudo userdel`` / ``sudo groupdel ``
- изменения пользователя/группы  ``sudo usermod -l newusername oldusername ``/ ``sudo groupmod -n newgroupname oldgroupname ``

</details>

- Как повысить свои привилегии?
<details>
<summary>ОТВЕТ</summary>

``sudo, su -, visudo - сюда вписать <user_name> ALL=(ALL) ALL чтобы дать права супер пользователя``
</details>

- Какой командой изменять пароль?
<details>
<summary>ОТВЕТ</summary>

``passwd usename``
</details>


- чем отличаются команды `su -` и `su` ?
<details>
<summary>ОТВЕТ</summary>

`su - user_name` - Эта команда переключает пользователя и включает его окружение, как если бы он входил в систему с начала. Она выполняет вход в систему от имени указанного пользователя, запуская его оболочку и загружая его окружение (переменные среды, рабочий каталог и т. д.).
`su user_name` - Эта команда также переключает пользователя, но не загружает его окружение. Она позволяет войти в систему под другим пользователем, но сохраняет текущее окружение, включая ваш рабочий каталог и переменные среды.

</details>