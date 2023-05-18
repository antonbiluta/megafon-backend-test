#!/bin/bash

FILESERVERS=servers.txt
FILENAME=file.txt

declare -a SERVERS
SERVERS=('cat "$FILESERVERS"')

ERRORFILE=error.log

# отчистить файл ошибок, перед началом, 
# чтобы на почту не прилетали отчеты с прошлого использования
> $ERRORFILE

for server in ${SERVERS[@]}
do
    # с помощью rsync отправляем файл на сервер под определенным юзером в определенную папку. 
    # Если произошла ошибка, то записываем её в логи
    rsync -avz $FILENAME user@$server:/path/ || echo $server >> $ERRORFILE
done

# Если в логах есть записи
if [ -s $ERRORFILE ]
then
    # Тема сообщения "ошибка копирования..", прикрепляем к отправке файл логов со списком серверов
    mail -s "Ошибка копирования файла" mailbox@server.ru -A $ERRORFILE
fi