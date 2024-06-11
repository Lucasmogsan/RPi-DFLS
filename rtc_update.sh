#!/bin/bash

# Check for internet connection
ping -c 2 192.168.53.2 > /dev/null

if [ $? -eq 0 ]; then
    echo "Online. Updating system time from NTP server..."
    echo "System time is currently: $(date)"
    # Set NTP server
    sudo timedatectl set-ntp no
    sudo timedatectl set-ntpserver 192.168.53.2
    sudo timedatectl set-ntp yes

    # Wait for system time to update
    sleep 5

    # Update RTC from system time
    echo "Updating RTC from system time..."
    sudo hwclock -w
    echo "RTC time is currently: $(sudo hwclock -r)"
else
    echo "Offline. Not updating RTC."
    echo "RTC time is currently: $(sudo hwclock -r)"
fi