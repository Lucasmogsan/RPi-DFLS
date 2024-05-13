# RPi DFLS repository content
- Dockerized host computer ROS2 humble intended to be used for communicating, visualizing etc. from RPi
- Description on setup of RPi

# TODO:
- [x] Get password
- [x] Set up RPi to connect to PC and internet
- [ ] Save new image
- [ ] Get RTC to work (why do we use?)
- [ ] Add Rviz (using multiple machines on same network instead)
- [ ] Install [Oculus](https://github.com/ENSTABretagneRobotics/oculus_ros2)
- [ ] Make clean dockerized ROS2 humble image

# Raspberry Pi Setup
Image: The image contains the following
- Ubuntu RPi ROS, Blueview

## Make image from SD card:
Follow [this guide](https://pimylifeup.com/backup-raspberry-pi/)

```bash
sudo dd if=/dev/mmcblk0 of=~/$DATE-rpi-backup.img # Uncompressed
sudo dd if=/dev/mmcblk0 bs=4M | xz -z > ~/$DATE-rpi-backup.img.xz   # Compressed... VERY slow
```

## Flash image to SD-card (Linux guide)
1. Delete all partitions SD card from Disks app
1. Check device name (can be seen from Disks app or cmd `sudo blkid` or `lsblk` - try before and after inserting to make sure)
1. `umount` device
1. Flash image to SD-card (NB: change file location `~/Downloads/20231123T150900_spc_backup.img.xz` and device location `/dev/mmcblk0`)
    1. `xzcat ~/Downloads/20231123T150900_spc_backup.img.xz | sudo dd bs=4M of=/dev/mmcblk0` (took approx 30 min)
        1. `sudo watch kill -USR1 $(pgrep ^dd)` (in another terminal to follow progress)
        1. the `xzcat` decrompresses the image (as it is compressed to .xz) while the `dd` writes our backup image to the SD Card (remmeber to change the device location)
    1. `sudo bmaptool copy ~/Downloads/20231123T150900_spc_backup.img.xz /dev/mmcblk0` (faster, not tested)


## Connect to internet (to update packes, install new ones etc.)
You can connect to the RPi in two ways
1. `eth0` (ethernet port): Fixed ip `192.168.53.253`
    1. Connect directly to PC
1. `eth1` (USB using USB-ETH converter): `DHCP` (given ip from server)
    1. Connect to ethernet router and access internet this way

nmap -sP 10.59.9.0/24


## If using RTC
- Using [DS3231 Real Time Clock for Raspberry Pi](https://www.adafruit.com/product/4282)
- Battery CR1220
- Follow [This guide](https://pimylifeup.com/raspberry-pi-rtc/) for RPi setup


## Forgotten password:
Change the shadow file (`sudo nano /etc/shadow`):
- Hash for password: `$y$j9T$dVtVCcXe/VyMKB1DS5GgA1$Rhd4xLQr1VbLOGerqqe8y0lXA7I71h7sJ2gqWC4TA.5`


# ROS2 setup

## Running ROS on multiple machines (RPi and computer)
- Stream topics
- Visualize outputs
[This](https://roboticsbackend.com/ros2-multiple-machines-including-raspberry-pi/)


Make sure all hosts (RPi and computer) have IP addresses on the same network with `hostname -I`. Check by `ping`ing eachother.


## Oculus ROS
[This](https://github.com/ENSTABretagneRobotics/oculus_ros2)