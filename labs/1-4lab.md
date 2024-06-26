# Лабораторная работа "Системные вызовы для работы с файлами"

## что-то умное про файловый дескриптор

## Системные вызовы

- `open`- Системный вызов open() либо открывает существующий файл, либо создает и открывает новый файл. int open(const char *pathname, int flags, mode_t mode); Аргумент pathname задает путь к файлу. Если в этом аргументе находится символьная ссылка, она преобразуется в новый путь к файлу. В случае успеха open() возвращает номер дескриптора открытого файла, который используется для работы с файлом в последующих системных вызовах. В случае ошибки open() возвращает – 1, а для errno устанавливается код ошибки. Аргумент flags является битовой строкой, указывающей режимдоступа к файлу с использованием одной из констант, перечисленных в табл. 2.10

| Флаг      | Описание                                       |
|-----------|-----------------------------------------------|
| Флаги режима доступа к файлу                     |                                                |
| O_RDONLY   | Открытие файла только для чтения              |
| O_WRONLY   | Открытие файла только для записи              |
| O_RDWR     | Открытие файла как для чтения, так и для записи |
| Флаги создания файла                           |                                                |
| O_CLOEXEC  | Установка флага закрытия при выполнении (close-on-exec) |
| O_CREAT    | Создание файла, если он еще не существует      |
| O_DIRECTORY| Аргумент `pathname` должен указывать на директорию, иначе ошибка |
| O_EXCL     | С флагом `O_CREAT`: исключительное создание файла |
| Флаги ввода/вывода                             |                                                |
| O_NOCTTY   | `pathname` запрещено становиться управляющим терминалом данного процесса |
| O_NOFOLLOW | Запрет на разыменование символьных ссылок      |
| O_TMPFILE  | Создание временного файла без имени. Аргумент `pathname` должен указывать на директорию, в которой будет создан файл. Все, что будет записано в файл, будет утеряно после закрытия последнего дескриптора файла |
| O_TRUNC    | Усечение существующего файла до нулевой длины   |
| O_APPEND   | Записи добавляются исключительно в конец файла |
| O_ASYNC    | Генерация сигнала, когда возможен ввод/вывод    |
| O_DIRECT   | Операции ввода/вывода осуществляются без использования кэша |
| O_DSYNC    | Синхронизированный ввод/вывод с обеспечением целостности данных |
| O_NOATIME  | Запрет на обновление времени последнего доступа к файлу при чтении с помощью системного вызова `read()` |
| O_NONBLOCK | Открытие в неблокируемом режиме                |
| O_SYNC     | Ведение записи в файл в синхронном режиме      |

 
- `read`- Системный вызов read() позволяет считывать данные из открытого файла, на который ссылается дескриптор fd.
```c
#include <unistd.h>
ssize_t read(int fd, void *buf, size_t count);
``` 
Аргумент count определяет количество считываемых байтов, которые нужно сохранить в буфере памяти по адресу из аргумента buf. Буфер buf должен иметь длину в байтах не менее той, что задана в аргументе count. Обратите внимание, что память под буфер нужно  выделить заранее и в системный вызов нужно передать именно указатель на буфер.  74 В случае успеха возвращается количество прочитанных байт или 0, если встретился символ конца файла. В случае ошибки возвращается -1. Поэтому для возвращаемого значения используется тип данных ssize_t, который является целочисленным типом со знаком. Чтение из терминала выполняется до первого встреченного символа новой строки (‘\n’).  
Указатель чтения (и записи) хранится внутри файлового дескриптора. Каждый файловый дескриптор, связанный с открытым файлом, содержит информацию о текущей позиции указателя чтения в этом файле. Этот указатель изменяется при операциях чтения и записи, что позволяет работать с файлом порциями данных и двигаться по нему.

- `write`- Системный вызов write() записывает данные в открытый файл:
```c
#include <unistd.h>
ssize_t write(int fd, const void *buf, size_t count);
```
Аргумент buf представляет собой адрес записываемых данных, count является количеством записываемых из буфера данных, а fd содержит дескриптор файла, который ссылается на тот файл, куда будут записываться данные. В случае успеха вызов write() возвращает количество фактически записанных данных, которое может быть меньше значения аргумента count.

`STDOUT_FILENO` - это макрос в языке C, предоставляемый стандартной библиотекой, который представляет файловый дескриптор стандартного вывода (stdout). 



###  задача1 cat
Программа должна выводить сконкатенированное символом переноса строки (\n) содержимое файлов, имена которых переданы ей на вход в качестве аргументов командной строки.

Количество аргументов произвольно.
Некоторые файлы могут не существовать: порядок действий в этом случае определите сами.
Файлы текстовые, могут быть пустыми.
Пример ожидаемой работы программы:
```bash 
echo "file1 content." > file1

echo "file2 content." > file2

./cat file1 file2
# Вывод:
# file1 content.
# file2 content.
```
#### решение 
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Использование: %s <имена файлов>\n", argv[0]);
        exit(1);
    }

    for (int i = 1; i < argc; i++) {
        int fd = open(argv[i], O_RDONLY);

        if (fd == -1) {
            fprintf(stderr, "Ошибка при открытии файла %s\n", argv[i]);
            continue; // Продолжаем с другими файлами
        }

        char buffer[4096];
        ssize_t n;

        while ((n = read(fd, buffer, sizeof(buffer))) > 0) {
            if (write(STDOUT_FILENO, buffer, n) != n) {
                fprintf(stderr, "Ошибка при записи данных в стандартный вывод\n");
                close(fd);
                exit(1);
            }
        }

        close(fd);

        if (n == -1) {
            fprintf(stderr, "Ошибка при чтении файла %s\n", argv[i]);
            continue; // Продолжаем с другими файлами
        }

        putchar('\n'); // Добавляем символ новой строки между файлами, кроме последнего
    }

    putchar('\n'); // Добавляем символ новой строки в конце

    return 0;
}

```






- ``-

- ``-

- ``-


###  задача2 cp


```c

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "ошибка аргументов");
        exit(1);
    }

    const char *source = argv[1];
    const char *target = argv[2];

    int source_fd = open(source, O_RDONLY);
    int target_fd = open(target, O_CREAT | O_WRONLY | O_TRUNC, 0666);

    if ((source_fd == -1) || (target_fd == -1)) {
        fprintf(stderr,"ошибка открытия исходного/целевого файла");
        exit(1);
    }

    char buffer[4096];
    ssize_t n;

    while ((n = read(source_fd, buffer, sizeof(buffer))) > 0) {
        if (write(target_fd, buffer, n) != n) {
            fprintf(stderr, "Ошибка при записи данных в целевой файл");
            close(source_fd);
            close(target_fd);
            exit(1);
        }
    }

    close(source_fd);
    close(target_fd);

    return 0;
}
```


###  задача3 ls

- `_GNU_SOURCE` В примере программы ls, #define _GNU_SOURCE используется, чтобы активировать доступ к системному вызову syscall с константой SYS_getdents, который не является частью стандарта C, но может быть доступен на системах, использующих glibc

- `struct linux_dirent` - Директории обладают внутренней структурой, поэтому для их
чтения предназначен отдельный системный вызов getdents().
int getdents(unsigned int fd, struct linux_dirent
*dirp,
 unsigned int count);
int getdents64(unsigned int fd, struct linux_dirent64
*dirp,
 unsigned int count);
Системный вызов getdents() читает несколько структур
linux_dirent из директории, на которую ссылается дескриптор открытого файла fd, в буфер dirp размером count. Структура
linux_dirent объявлена следующим образом:
```c
struct linux_dirent {
 unsigned long d_ino; /* Номер инода */
 unsigned long d_off; /* Смещение от начала директории до начала следующей linux_dirent */
 unsigned short d_reclen; /* Размер этой linux_dirent */
 char d_name[]; /* Имя файла, заканчивающееся null */
/* Длина вычисляется как (d_reclen - 2 - offsetof(struct linux_dirent, d_name)) */
/*
 char pad; // Дополняющий байт
 char d_type; // Тип файла. Смещение
(d_reclen - 1)
*/
}
```


```c
#define _GNU_SOURCE
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <sys/types.h>

struct linux_dirent {
    unsigned long  d_ino;
    off_t          d_off;
    unsigned short d_reclen;
    char           d_name[];
};

int main(int argc, char *argv[]) {
    const char *dir = "."; // По умолчанию текущая директория

    if (argc > 1) {
        dir = argv[1];
    }

    int fd = open(dir, O_RDONLY);
    if (fd == -1) {
        fprintf(stderr,"ошибка открытия директории");
        exit(1);
    }

    char buffer[4096];
    int nread;
    int bpos = 0;

    while (1) {
        nread = syscall(SYS_getdents, fd, (struct linux_dirent *)buffer, sizeof(buffer));
        if (nread == -1) {
            fprintf(stderr,"ошибка при вызове getdents");
            exit(1);
        }
        if (nread == 0) {
            break;
        }

        while (bpos < nread) {
            struct linux_dirent *d = (struct linux_dirent *)(buffer + bpos);
            printf("%s\n", d->d_name);
            bpos += d->d_reclen;
        }
    }

    close(fd);
    return 0;
}

```


## Допуск
- Какие основные системные вызовы используются для создания/открытия/чтения/записи/закрытия файла?
    1.  `open` c аргументами : `O_RDONLY, O_CREAT, O_WRONLY, O_TRUNC ` и `close()`
    2. `read(fd, buffer, sizeof(buffer)) write`
    3.  `close()`

- Что такое файловый дескриптор?
    В операционных системах Unix и подобных им, включая Linux, файловый дескриптор представляет собой индекс в таблице файловых дескрипторов (File Descriptor Table). {см фотку}

- Где хранятся файловые дескрипторы?
    Файловые дескрипторы хранятся в таблице файловых дескрипторов (File Descriptor Table), 

- Что такое системный вызов?
    Системный вызов (System Call, syscall) - это интерфейс, предоставляемый операционной системой для взаимодействия между пользовательскими приложениями и ядром операционной системы. Системные вызовы позволяют приложениям выполнять привилегированные операции, такие как создание или открытие файлов, управление процессами, ввод-вывод данных и другие операции, которые требуют доступа к аппаратному обеспечению и ресурсам компьютера.

    Системные вызовы предоставляют абстракцию для доступа к функциональности операционной системы, скрывая детали реализации и обеспечивая безопасный и управляемый способ взаимодействия с ядром. Они позволяют приложениям запрашивать операционную систему выполнить определенные задачи, которые они сами не могут выполнять из-за ограничений безопасности и изоляции.
    Примеры типичных системных вызовов включают:

    open(): Для открытия файлов и устройств.

    read(): Для чтения данных из файлов и сокетов.

    write(): Для записи данных в файлы и сокеты.

    fork(): Для создания нового процесса.

    exec(): Для выполнения другой программы в контексте текущего процесса.

    exit(): Для завершения текущего процесса.

    kill(): Для отправки сигнала процессу.

- Какие средства обработки ошибок системных вызовов существуют?

```c
int result = some_system_call();
if (result == -1) {
    perror("Ошибка в системном вызове");
}
fprintf(stderr, "Нет разрешения на выполнение операции\n");
if (-1 == access("some_file", F_OK))
{
    perror("access");
    exit(EXIT_FAILURE);
}
```