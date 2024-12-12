# mediamtx-installer

Інсталяційний скрипт для `mediamtx`, який налаштовує автозапуск сервісу та 
попередні налаштування.

Зробіть копію скрипта та виконайте його
``` zsh
sudo ./mediaMtxInstallerSELinux.sh
```

Якщо не вдається то додайте втребут виконуваний

```zsh
sudo chmod +x mediaMtxInstaller.sh
```
Та виконайте скрипт

```zsh
sudo bash mediaMtxInstaller.sh`
```

__Сценарій автоматично визначить CPU/OS і завантажить останню версію збірки
`mediamtx`, а також налаштує службу `systemd`, щоб вона автоматично запускалася 
під час перезавантаження.__

*За потреби змініть `mediamtx.yml`.*

__Subscribe server to an existing stream (ex: ip camera)__

Відредагуйте `/usr/local/etc/mediamtx.yml` у кінці файлу:

```yml
paths:
  # example:
  # my_camera:
  #   source: rtsp://my_camera
  amcrest:
    source: rtsp://admin:password@192.168.10.113
```

Цей приклад зробить потік доступним за адресою [rtsp://&lt;your-media-mtx-server-ips&gt;:8554/amcrest](rtsp://&lt;your-media-mtx-server-ips&gt;:8554/amcrest) , який можна перевірити за допомогою програвача VLC і спробувати відкрити "мережевий потік" за цією URL-адресою.
