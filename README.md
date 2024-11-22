# mediamtx-installer

Install script to make `mediamtx` auto run on boot/restart and general setup info.

Copy script to target, make it executable:

``` zsh
sudo ./mediaMtxInstallerSELinux.sh
```

If you cannot set the executable attribute:

```zsh
sudo chmod +x mediaMtxInstaller.sh
```

Then run it:

```zsh
sudo bash mediaMtxInstaller.sh
```

__Script will automatically detect cpu/os and download latest release build of mediamtx, and configure systemd service so it auto-starts on reboots.__

*Modify `mediamtx.yml` as necessary.*

__Subscribe server to an existing stream (ex: ip camera)__

Edit `/usr/local/etc/mediamtx.yml` at the end of the file:

```yml
paths:
  # example:
  # my_camera:
  #   source: rtsp://my_camera
  amcrest:
    source: rtsp://admin:password@192.168.10.113
```

This example will make a stream available at [rtsp://&lt;your-media-mtx-server-ips&gt;:8554/amcrest](rtsp://&lt;your-media-mtx-server-ips&gt;:8554/amcrest) which you can test by using VLC player and trying to open a "network stream" with this URL.
