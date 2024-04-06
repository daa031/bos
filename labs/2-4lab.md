# 4 Лабораторная работа "Управление системными и сетевыми сервисами"

## Процессы и контрольные группы

- `ps xaf` - писок процессов в древовидной структуре, где каждый процесс имеет своего родителя
- `ps xawf -eo pid,user,cgroup,args` - 
    - cgroup - тображает информацию о контрольных группах 
    - args - столбец содержит командную строку, с помощью которой был запущен процесс.
- `systemd-cgls` - команда используется для вывода иерархии управляющих групп (cgroups) systemd

## Расположение юнитов в файловой системе

- `/usr/lib/systemd/system/` - файлы юнитов для системных служб, управляемых systemd
- `/run/systemd/system/` - хранятся временные юниты, созданные динамически во время работы системы или пользовательскими процессами.
- `/etc/systemd/system/` - хранятся пользовательские юниты, которые администраторы системы могут создавать для настройки служб, таймеров, сокетов и других объектов, управляемых systemd

## Изучение команды systemctl

1. `systemctl -t help` - информацию о доступных типах юнитов:

2. `systemctl status` - информацию о состоянии всех юнитов

3. `systemctl --type=service` - информацию о состоянии всех юнитов

4. `systemctl status имя.тип` - информацию о состоянии сервиса с помощью (тип пр auditd.service )

5. `systemctl is-active auditd.service`- информацию о состоянии сервиса

6. информацию о зависимостях сервисов друг от друга.
    - `systemctl list-dependencies --before auditd.service` - cписок всех служб, которые должны быть запущены ПЕРЕД auditd.service.
    -  `systemctl list-dependencies --after auditd.service ` - писок всех служб, которые должны быть запущены ПОСЛЕ auditd.service

7. `systemctl list-units --type=service`- вывода списка всех текущих системных служб, которые управляются systemd. Эта команда позволяет просмотреть состояние всех загруженных служб, включая их статус, PID процесса, описание и т. д.

8. вывод всех (активных и не активных) служб/сокетов
    - `systemctl list-units --type=service --all`
    - `systemctl list-units --type=socket --all`

9. `systemctl list-unit-files --type=service` - информацию о файлах юнитов 
    - `disabled`: Служба отключена и не будет запущена при загрузке системы.
    - `enabled`: Служба разрешена и будет запущена при загрузке системы.
    - `static`: Служба является статической и не поддерживает непосредственное управление с помощью systemctl.

10. `systemctl --failed --type=service` - информацию о сервисах с ошибками

## Управление сервисами
1. Запуск, остановка, перезагрузку, web-сервера Apache.
```sh

 # systemctl status httpd.service
 ● httpd.service - The Apache HTTP Server
    Active: inactive (dead)
 # systemctl start httpd.service
 # systemctl status httpd.service
 ● httpd.service - The Apache HTTP Server
    Active: active (running) since Sun 2016-10-23 00:50:54 MSK;
  Main PID: 16547 (httpd)
 # systemctl restart httpd.service
 # systemctl status httpd.service
 ● httpd.service - The Apache HTTP Server
    Active: active (running) since Sun 2016-10-23 00:51:06 MSK;
  Main PID: 16566 (httpd)
 # systemctl stop httpd.service
```
2. Настройте запуск web-сервера Apache во время загрузки системы.


```sh
# systemctl enable httpd.service
 Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.
 # systemctl status httpd.service 
 ● httpd.service - The Apache HTTP Server
    Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
    Active: inactive (dead)
      Docs: man:httpd(8)
            man:apachectl(8)
 ...
 # systemctl start httpd.service 
 # systemctl status httpd.service 
 ● httpd.service - The Apache HTTP Server
    Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
    Active: active (running) since Сб 2019-03-30 23:21:25 MSK; 1s ago
      Docs: man:httpd(8)
            man:apachectl(8)
  Main PID: 22529 (httpd)
    Status: "Processing requests..."
     Tasks: 7
    CGroup: /system.slice/httpd.service
            ├─22529 /usr/sbin/httpd -DFOREGROUND
            ├─22533 /usr/sbin/httpd -DFOREGROUND
            ├─22534 /usr/sbin/httpd -DFOREGROUND
            ├─22535 /usr/sbin/httpd -DFOREGROUND
            ├─22536 /usr/sbin/httpd -DFOREGROUND
            ├─22537 /usr/sbin/httpd -DFOREGROUND
            └─22538 /usr/sbin/httpd -DFOREGROUND
 ...
 # systemctl disable httpd.service
 Removed symlink /etc/systemd/system/multi-user.target.wants/httpd.service.

```
3. Запретите запуск web-сервера Apache как во время загрузки системы, так и в ручную.

    - `systemctl mask httpd.service` для "маскировки" службы, что означает полное отключение службы и предотвращение её запуска.
    - `systemctl status httpd.service`  показывает состояние службы.В выводе указано, что служба маскирована и ссылается на `/dev/null`.
    - `systemctl start httpd.service`  -  При попытке запустить маскированную службу с помощью `systemctl start`, выдаётся ошибка.
    - `systemctl unmask httpd.service`  используется для снятия маскировки с службы.


## Управление таргетами

1. Выведите информацию о загруженных активных target-юнитах:
```sh
systemctl list-units --type=target
```
2. Выведите информацию обо всех target-юнитах:
```sh
systemctl list-units --type=target --all
```
3. Выведите target-юнит по умолчанию.
```sh
stemctl get-default 
```
4. Выведите ссылку на target-юнит по умолчанию. Например:
```sh
ls -l /etc/systemd/system/default.target
```
5. Измените (установите другой) target-юнит по умолчанию. Например:
```sh
systemctl set-default multi-user.target
```
6. Измените target-юнит в рамках текущей сессии. 
```sh
systemctl isolate multi-user.target
```
7. Переведите систему в rescue-режим (аналог однопользовательского режима в init) (systemctl isolate rescue.target). Убедитесь в том, что смонтированы локальные файловые системы, но сетевые средства не подняты. Например:
```sh
 systemctl --no-wall rescue
```
8. Переведите систему в emergency-режим (systemctl isolate emergency.target). Убедитесь в том, что смонтирована только корневая файловая система в режиме "только для чтения" и сетевые средства не подняты. Например:
```sh
systemctl --no-wall emergency
```


## Управление работой системы и питанием компьютера

1. Выгрузите систему и отключите питание компьютера:
```sh
systemctl poweroff
```
2. Выгрузите систему без отключения питания компьютера:
```sh
systemctl halt
```
3. Повторите действия без рассылки пользователям предупреждения. 
```sh
systemctl --no-wall poweroff
```
4. Выгрузите систему и отключите питание компьютера в определенное время с помощью shutdown --poweroff чч:мм, где чч:мм - время в 24-часовом формате. Убедитесь в том, что за 5 минут до выгрузки системы будет создан файл /run/nologin для предотвращения новых входов пользователей в систему.
```sh
[root@10 daa]# cat s.sh 
time_str="23:05"
echo "sudo touch /run/nologin" | at $time_str - 5 minutes
sudo shutdown --poweroff $time_str
[root@10 daa]# ./s.sh 
warning: commands will be executed using /bin/sh
job 3 at Fri Apr  5 23:00:00 2024
Shutdown scheduled for Fri 2024-04-05 23:05:00 MSK, use 'shutdown -c' to cancel.
[root@10 daa]# date
```
5. Выгрузите систему без отключения питания компьютера через определенный промежуток времени с помощью shutdown --halt +минут. Вместо +0 можно написать now. Запущенную выгрузку можно отменить с помощью shutdown -c.
```sh
[root@10 daa]#shutdown --halt +N
```
6. Перезагрузите систему с помощью systemctl --no-wall reboot.
```sh
systemctl --no-wall reboot
```
7. Приостановите работу системы с помощью systemctl suspend. Все текущие процессы и состояние системы будут сохранены в оперативной памяти (RAM), и компьютер перейдет в режим ожидания, потребляя минимальное количество энергии.
```sh
systemctl suspend
```
8. Остановите систему с помощью systemctl hibernate. (гибернация)
```sh
systemctl hibernate
```
9. Изучите другие утилиты systemd.
  - `hostnamectl` - управления и просмотра параметров имени хоста (hostname) системы. Можно изменить имя хоста 
  - `timedatectl` - позволяет управлять и просматривать текущую дату, время и часовой пояс на вашей системе.
  - `localectl` - предоставляет возможность управления и просмотра настроек локали (языковых и региональных настроек) на системе.
  - `loginctl` - это инструмент управления сеансами пользователей и отображения информации о сеансах и пользовательских учетных записях. (loginctl list-sessions)
  - `loginctl session-status 2` - Эта команда используется для получения информации о статусе сеанса с заданным идентификатором.
  - `loginctl show-user user1` - Команда loginctl show-user user1 отображает информацию о пользователе с указанным именем пользователя (user1).


## Создание собственных юнитов

```sh
# cat mephi.service 
[Unit]
Decription=MEPhI hello service
After=sshd.service
[Service]
ExecStart=/usr/bin/printf "Hello, MEPhI!"
[Install]
WantedBy=multi-user.target

# ls -lZ mephi.service 

# journalctl -b
...
May 16 00:57:40 localhost.localdomain setroubleshoot[3979]: SELinux is preventing systemd from read access on the file mephi.service. For complete SELinux messages run: sea>
May 16 00:57:40 localhost.localdomain python3[3979]: SELinux is preventing systemd from read access on the file mephi.service.
                                                     
                                                     *****  Plugin catchall (100. confidence) suggests   **************************
                                                     
                                                     If you believe that systemd should be allowed read access on the mephi.service file by default.
                                                     Then you should report this as a bug.
                                                     You can generate a local policy module to allow this access.
                                                     Do
                                                     allow this access for now by executing:
                                                     # ausearch -c 'systemd' --raw | audit2allow -M my-systemd
                                                     # semodule -X 300 -i my-systemd.pp
                                                     
May 16 00:57:50 localhost.localdomain systemd[1]: dbus-:1.7-org.fedoraproject.Setroubleshootd@3.service: Succeeded.
May 16 00:57:50 localhost.localdomain audit[1]: SERVICE_STOP pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=dbus-:1.7-org.fedoraproje>
May 16 00:57:50 localhost.localdomain systemd[1]: dbus-:1.7-org.fedoraproject.Setroubleshootd@3.service: Consumed 2.020s CPU time.

# ausearch -m avc -ts recent
----
time->Sat May 16 00:57:08 2020
type=AVC msg=audit(1589579828.032:1963): avc:  denied  { read } for  pid=1 comm="systemd" name="mephi.service" dev="sda2" ino=411971 scontext=system_u:system_r:init_t:s0 tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=0

[root@localhost system]# restorecon -v mephi.service 
Relabeled /usr/lib/systemd/system/mephi.service from unconfined_u:object_r:user_home_t:s0 to unconfined_u:object_r:systemd_unit_file_t:s0

# systemctl start mephi.service 
# journalctl -u mephi.service 
-- Logs begin at Thu 2019-10-10 15:56:01 MSK, end at Sat 2020-05-16 01:11:06 MSK. --
May 16 01:11:04 localhost.localdomain systemd[1]: Started MEPhI hello service.
May 16 01:11:04 localhost.localdomain printf[4417]: Hello, MEPhI!
May 16 01:11:04 localhost.localdomain systemd[1]: mephi.service: Succeeded.

# cat mephi.path
[Unit]
Description="Check for MEPhI file in /tmp"
After=sshd.service
[Path]
PathExists=/tmp/mephi.file
Unit=mephi.service
[Install]
WantedBy=multi-user.target

# systemctl enable mephi.path 
Created symlink /etc/systemd/system/multi-user.target.wants/mephi.path → /usr/lib/systemd/system/mephi.path.
# systemctl start mephi.path 
# touch /tmp/mephi.file
```


```sh
# journalctl -f -u mephi
-- Logs begin at Thu 2019-10-10 15:56:01 MSK. --
May 16 01:11:04 localhost.localdomain systemd[1]: Started MEPhI hello service.
May 16 01:11:04 localhost.localdomain printf[4417]: Hello, MEPhI!
May 16 01:11:04 localhost.localdomain systemd[1]: mephi.service: Succeeded.
May 16 01:30:24 localhost.localdomain systemd[1]: Started MEPhI hello service.
May 16 01:30:24 localhost.localdomain printf[4894]: Hello, MEPhI!
May 16 01:30:24 localhost.localdomain systemd[1]: mephi.service: Succeeded.
```