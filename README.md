# RPi DFLS repository content
- ()Dockerized host computer ROS2 humble intended to be used for communicating, visualizing etc. from RPi
- Use [Foxglove](https://docs.foxglove.dev/docs/introduction) instead
- Description on setup of RPi

# TODO:
- [x] Get password
- [x] Set up RPi to connect to PC and internet
- [x] Save new image
- [x] Get RTC to work
- [x] Add Rviz (using multiple machines on same network instead)
- [x] Make clean dockerized ROS2 humble image
- [x] Install [Oculus](https://github.com/ENSTABretagneRobotics/oculus_ros2)
- [x] Script to update RTC time from NTP server, when connected.
- [ ] Reset power script (is it already in the image? cannot find it)

# Hardware
- Raspberry Pi 4 Model B, 8GB RAM (D9ZCL)
- Dual Sonar Payload


# Run on Otter

# Run independently

Automatically:

Manually: Connected to computer

1. Flash default Ubuntu Desktop 22.04 LTS 64-bit to SD card
1. Use screen and keyboard for setup!
    1. MicroHDMI to screen and USB for keyboard (+ mouse)
1. First time set up the configurations on the screen (timezone, language, etc.)
1. Enable ssh [from this guide](https://www.xda-developers.com/how-to-enable-ssh-on-ubuntu/)
    ```bash
    sudo apt install openssh-server -y
    ```
    1. (not sure if needed) Make an empty file `ssh` in the `system-boot` folder.
1. Setup network configs using `nmtui` (see chapter on which networks to set up)
1. Download and install whatever needed
    - [ROS Humble](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html) Desktop (full with GUI) or Base (base packages)
    - [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
    - [Colcon](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Colcon-Tutorial.html) (is already if ROS desktop is installed)
    - [Rosdep](https://docs.ros.org/en/humble/Tutorials/Intermediate/Rosdep.html)
1. Clone ROS repos and build
    - [Oculus nodes](https://github.com/ENSTABretagneRobotics/oculus_ros2)
    - [Oculus driver](https://github.com/ENSTABretagneRobotics/oculus_driver)
    - [SPC-HW - powerbank](https://gitlab.gbar.dtu.dk/dtu-aqua-observation-technology/sonar/spc_hw/-/tree/main/)
1. Other setup
    - pip, python package installer `sudo apt install python3-pip`
    - I2C tool for RTC `sudo apt install python3-smbus i2c-tools`
    - Deacitvate firewall for sensors: Either by IP () or for all (temp: `sudo ufw disable`, permanent: `sudo systemctl disable ufw`)

1. Modify Configuration Files for ethernet connection to computer
    1. Wifi configured manually in file `01-network-manager-all.yaml` in the `/etc/netplan` folder.

    ```bash
    sudo nano /media/lucas/writable/etc/netplan/01-network-manager-all.yaml
    ```
    ```bash
    network:
        version: 2

        ethernets:
            eth0:
            dhcp4: false
            optional: true
            addresses:
                - 192.168.53.252/24
    ```
1. Insert SD card to RPi, start up and give it a few min to start up (if using mobile hotspot you can see when it is connected)
1. Use wireshark to identify RPi ip-adress
    1. `sudo wireshark` - choose wlp0s20f3 - start recording
    1. (optional) add filter - examples: `ip.src == 172.20.0.0/16` (shows ip sources with ip 172.20.X.X)
1. Replace so network manager (nmtui) takes care of network stuff
```bash
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
```




# Raspberry Pi Setup
Image: The image contains the following
- [x] Raspberry Pi OS (Raspbian)
- [x] ROS 2 Humble
- [x] Blueview ROS packages, driver, and dependencies
- [ ] Oculus ROS packages (and driver)

## Write image from SD card to file (to make backup):
Follow [this guide](https://pimylifeup.com/backup-raspberry-pi/)

```bash
sudo dd if=/dev/mmcblk0 of=~/$DATE-rpi-backup.img # Uncompressed (>40Gb)
sudo dd if=/dev/mmcblk0 bs=4M | xz -z > ~/$DATE-rpi-backup.img.xz   # Compressed (~5gB), VERY slow (~2h)
```

## Flash image from file to SD-card (Linux guide)
1. Delete all partitions SD card from Disks app
1. Check device name (can be seen from Disks app or cmd `sudo blkid` or `lsblk` - try before and after inserting to make sure)
1. `umount` device (e.g. `umount /dev/mmcblk0`)
1. Flash image to SD-card (NB: change file location `~/Downloads/20231123T150900_spc_backup.img.xz` and device location `/dev/mmcblk0`)
    1. `xzcat ~/Downloads/20231123T150900_spc_backup.img.xz | sudo dd bs=4M of=/dev/mmcblk0` (approx. 63GB = 30 min)
        1. `sudo watch kill -USR1 $(pgrep ^dd)` (in another terminal to follow progress)
        1. the `xzcat` decrompresses the image (as it is compressed to .xz) while the `dd` writes our backup image to the SD Card (remmeber to change the device location)
    1. `sudo bmaptool copy --nobmap ~/Downloads/20231123T150900_spc_backup.img.xz /dev/mmcblk0` (faster, not tested)

## Multiple subnets
249: RPi Sonar Oculus
252: RPi Lidar
253: RPi Sonar Blueview

The RPi has the following adresses (configured using `sudo nmtui` for profile `SPC_otter`) on `eth0` (ethernet port connected to ethernet switch to communicate with sensors and computer):
- 10.42.0.253/24 (???)
- 192.168.53.253/24 (Otter NTP on 2 / Ouster on 4 / Otter camera stream on 5 / computer)
- 192.168.1.253/24 (Blueview on 45)
- 192.168.2.253/24 (Oculus on 4)



## Internet: Connect RPi to internet (to update packes, install new ones etc.)
Run `nmtui` to configure ethernet and wifi:

1. `eth0` (ethernet port, NOT for internet): Has multiple fixed ips with one of them being `192.168.53.253` connected to computer
1. `wlan0` (wifi): can be chose in `nmtui to connect to wifi (e.g. personal hotspot)`
1. `eth1` (USB using USB-ETH converter): `DHCP` (given ip from server)
    1. Connect to ethernet router and access internet this way (check with `ping google.com`)

Run `ìp route` to check which connections are set up and which are default (the `default via metric` tells the priority with lower is higher priority)

```bash
nmcli connection show
```

NOTE: 2024-06-06 Lucas removed `default via 10.42.0.1 dev eth0 proto static metric 100` by `sudo ip route del default via 10.42.0.1 dev eth0` as the metric was lower (higher priority) than others when connecting to wifi or other ethenet.

nmap -sP 10.59.9.0/24


## Forgotten password:
If the password is somehow forgotten this method was used to unlock the spc-admin user:
- Change the shadow file (`sudo nano /etc/shadow`) with the hash for password: `$y$j9T$dVtVCcXe/VyMKB1DS5GgA1$Rhd4xLQr1VbLOGerqqe8y0lXA7I71h7sJ2gqWC4TA.5`


## Adding RTC
- Using [DS3231 Real Time Clock for Raspberry Pi](https://www.adafruit.com/product/4282)
- Battery CR1220
- Follow [This guide](https://pimylifeup.com/raspberry-pi-rtc/) for RPi setup
    - OBS: For Ubuntu use `/boot/firmware/config.txt` instead of `/boot/config.txt` otherwise similar procedure

Use UTC time!! RTC and RPi should be configured to UTC.
- On Ubuntu `sudo dpkg-reconfigure tzdata`, choose `None of the above` and choose `UTC`


Update RTC time:
1. Update RPi system time from NTP server (RPi must be connected to wifi or ethernet) - TODO: maybe RTC needs to be disonnected???
1. Update RTC time with RPi system time

Read RPi system time:
```bash
timedatectl
```

Read RTC time
```bash
sudo hwclock -r
```

Write RTC time
```bash
sudo hwclock -w
```



# ROS 2
The ROS 2 setup is as follows (see [ROS 2 humble on RPI](https://docs.ros.org/en/humble/How-To-Guides/Installing-on-Raspberry-Pi.html) and [this guide](https://roboticsbackend.com/install-ros2-on-raspberry-pi/)):
- **Underlay**: [ROS 2 ***humble base*** installation](https://www.ros.org/reps/rep-2001.html#humble-hawksbill-may-2022-may-2027) is as always located on `/opt/ros/<distro>`
- **Overlay**: ROS 2 workspace is located on `/home/spc-admin/ros2_humble` and `/home/spc-admin/XX_ws` (if another ws is needed)
    - All packages should be installed to the workspaces' `src` folders.


## Build

Must use sudo
```bash
sudo colcon build
```

## Running ROS on multiple machines (RPi and computer)
- Stream topics
- Visualize outputs
[This](https://roboticsbackend.com/ros2-multiple-machines-including-raspberry-pi/)


Connect to RPi from computer
```bash
ssh spc-admin@192.168.53.253
aqua-admin.2920
```

Make sure all hosts (RPi and computer) have IP addresses on the same network with `hostname -I`. Check by `ping`ing eachother.
```bash
ping 192.168.2.4 (Oculus)
ping 192.168.1.45 (Blueview)
```


## Oculus
Using [this](https://github.com/ENSTABretagneRobotics/oculus_ros2) Github repo.

Features:
- IP = 192.168.2.4

1. Source environment
```bash
source /opt/ros/humble/setup.bash
source /home/spc-admin/ros2_humble/install/setup.bash
```

1. Clone the [oculus_ros2](https://github.com/ENSTABretagneRobotics/oculus_ros2) package... If it won't build do also clone the [oculus_driver](https://github.com/ENSTABretagneRobotics/oculus_driver) package.
```bash
source /opt/ros/humble/setup.bash
cd home/spc-admin/ros2_humble/src
git clone >>https-packages<<
cd /home/spc-admin/ros2_humble/
sudo colcon build --packages-select oculus_ros2 oculus_driver
source /home/spc-admin/ros2_humble/install/setup.bash
```

1. Run default oculus node
```bash
ros2 launch oculus_ros2 default.launch.py
```


## BlueView
Using [This](https://gitlab.gbar.dtu.dk/dtu-aqua-observation-technology/sonar/blooview_interface) GitLab repo.

Features:
- IP = 192.168.1.45

1. Start node:
    ```bash
    ros2 run blooview_interface blooview_interface
    TODO: how to start the node?
    ```
1. Select transducer head (this determines the FOV, 0 is 130deg)
    ```bash
    ros2 service call /get_set_active_head blooview_msgs/srv/GetSetInt64 '{flag: 0, value: 0}'
    ```
1. (optional) configure (start_range, stop_range, gain_adjustment, tvg_slope, sound_speed)
    ```bash
    # Example to set range to 0.2 - 10m
    ros2 service call /get_set_start_range blooview_msgs/srv/GetSetFloat64 '{flag: 0, value: 0.2}'
    ros2 service call /get_set_stop_range blooview_msgs/srv/GetSetFloat64 '{flag: 0, value: 10.0}'
    ```
1. Start pinging and recording (NB: Sonar should be submerged in water to avoid overheating)
    ```bash
    ros2 service call /start_pinging std_srvs/srv/Trigger
    ros2 service call /start_recording std_srvs/srv/Trigger
    ```
    e.g. check the feed (do before start recording)

    ```bash
    ros2 service call /start_streaming std_srvs/srv/Trigger
    ```
1. Stop recording and pinging
    ```bash
    ros2 service call /stop_recording std_srvs/srv/Trigger
    ros2 service call /stop_pinging std_srvs/srv/Trigger
    ```

## Power distributor
Using [This](https://gitlab.gbar.dtu.dk/dtu-aqua-observation-technology/sonar/spc_hw) GitLab repo.

## Foxglove

See [this](https://docs.ros.org/en/humble/How-To-Guides/Visualizing-ROS-2-Data-With-Foxglove-Studio.html)


# Services (running at startup)

Multiple services are set up in order to
located at `/etc/systemd/system`