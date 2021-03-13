# Overview

This is a core repository for Drive Badger product. You can visit its homepage for more details: https://drivebadger.com/

This software is meant to be used only by police officers, special agents, or other eligible entities. Its usage is always a subject to local legislation, and its user is solely responsible for all potential law infringements and/or misfeasances of duties. Intention of this product, is not an incitement for a crime. Rather, Drive Badger is mainly intended to be used in countries, where using such tools is legal, or at most, can be a subject to possible disciplinary action between the end user and his/her employer.

Drive Badger is meant to be integrated with Kali Linux Live on external USB drive.

How it works:

- user connects USB drive to someone's computer
- user boots Kali Linux from that drive in Persistent mode (preferably with LUKS encryption)
- Kali Linux starts in text mode
- `/etc/rc.drivebadger` script is run in background
- it enumerates computer drives, and makes a copy of (almost) all data from all other recognized drives (including softraid) to user's USB drive
- console with pre-logged `kali` user stays available, allowing user to run anything else, to hide the real reason for running Kali Linux

# Setup

1. Download Kali Linux Live 32-bit image (it is particularly tested with this version: https://cdimage.kali.org/kali-2020.1b/kali-linux-2020.1b-live-i386.iso) - in most cases, 32-bit is better than 64-bit, since it can run anywhere, while 64-bit doesn't give you any additional advantages.

2. Write downloaded image to your chosen USB device (at least 8GB required just for testing, but 240GB-2TB recommended for field usage).

3. Create the third partition on that USB device (optionally with LUKS encryption, and optionally splitting it into 3rd and 4th partitions). See manuals https://www.kali.org/docs/usb/kali-linux-live-usb-persistence/ and https://www.kali.org/docs/usb/dojo-kali-linux-usb-persistence-encryption/ for more details.

If you choose to use LUKS encryption, then instead of command from the manual:

`cryptsetup --verbose --verify-passphrase luksFormat /dev/sdb3`

you can use much stronger encryption/hashing related parameters, to avoid brute forcing your chosen password, eg.:

`cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --debug --verify-passphrase luksFormat /dev/sdb3`

4. Just before unmounting the third partition according to the manual, copy this repository contents as `/run/live/persistence/sdb3/rw/opt/drivebadger`.

5. If you have access to commercial extensions, clone them into `/run/live/persistence/sdb3/rw/opt/drivebadger/config` and `/run/live/persistence/sdb3/rw/opt/drivebadger/hooks` subdirectories.

6. Boot Kali Linux from your prepared USB device and make sure that it runs properly. You will get the graphical mode by default.

7. Open the terminal, execute `sudo su -` to become root, and execute:

`cd /opt/drivebadger/2020.1 && ./install.sh`

This command does 3 things:

- installs `/etc/rc.drivebadger` as systemd service (it will run automatically on each another reboot)
- enables ssh server to also run automatically after each reboot
- disables graphical mode

# Design notes

## Free vs commercial version

This repository contains the complete free version of Drive Badger. Commercial version uses the same code, and just extends it using external repositories cloned into `config` and `hooks` subdirectories. You are welcome to write your own extensions as well.

## Performance of LUKS vs no encryption

LUKS encryption costs more intensive CPU usage - but since the computer is booted into console-only Kali Linux, this is not a problem (unless you try to work in graphical mode, or run other CPU-intensive applications). It shouldn't however affect write speed.

Just to make sure, we performed some real tests:

- Core 2 Duo E8400, 4GB RAM (standard Dell OptiPlex 780)
- copying from Samsung SSD 850 EVO 500GB
- copying to Samsung Portable SSD T5 1TB USB 3.1, connected to USB 2.0 port
- set of files: Windows 10 Home + Visual Studio with many additional tools + Embarcadero RAD Studio, 27GB of data in ~134000 files (after applying rsync exclusions)

1. No encryption - 14m 5s.
2. LUKS encryption - 14m 2s. CPU usage and system load were noticeably bigger.

You can see more interesting benchmarks here: https://www.phoronix.com/scan.php?page=article&item=ubuntu-1804-encrypt&num=2

## Pen drive vs external SSD drive

Yes, there are differences between "pen drives" or "thumb drives", and SSD external drives. The most important differences for you are:

- controller speed - SSD drive has way bigger read/write performance
- storage type, especially for very compact pen drives - many flash chips start to slow down write operation after just 50-100 writes (per cell)

On the other hand, SSD drives are more expensive, and bigger, harder to hide and operate, especially comparing to models like SanDisk Ultra Fit.

## Why not wait for full network configuration

Systemd configuration for `rc-drivebadger` service requires only drives/filesystems related configuration, and running rsyslog.

It doesn't wait for DHCP or full network configuration, which can result in identifying computers only after model name, without IP address - however this behavior is intentional. Instead it sleeps for at least 7 seconds (currently 15) to give time to the network stack, to configure itself and get the IP address from DHCP.

Such behavior prevents waiting very long, possibly indefinitely, not running the solution at all, in case of network problems (eg. Wifi-only - remember that Kali doesn't have your Wifi password).
