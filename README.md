# Overview

Drive Badger is a framework for secure, automated, huge scale, time-effective data exfiltration from computers running any version of Windows (including Windows Server and Windows Embedded) or Linux.

It runs on any size of hardware, from mini-pcs, through laptops, desktop computers, up to big servers (see [hardware compatibility list](https://github.com/drivebadger/drivebadger/wiki/Hardware-compatibility-list)). Basically on anything, that can run [Kali Linux](https://github.com/drivebadger/drivebadger/wiki/Kali-Linux), and have at least 1 working USB port.

It is able to exfiltrate data off encrypted hard drives (currently only with [Bitlocker](https://github.com/drivebadger/drivebadger/wiki/Bitlocker-support), support for other encryption types is planned).

Drive Badger runs below the operating system level - so it doesn't need any passwords (eg. Active Directory) to exfiltrated computers. Instead, it is able to discover several types of passwords on its own,
and use them to automatically expand the attack surface:

- on Windows computers, decode FTP passwords saved by Total Commander and use them to exfiltrate data off FTP servers using exfiltrated computer's IP
- on Linux computers, exfiltrate `smb` and `nfs` shares defined statically in `/etc/fstab`

This is a core repository for Drive Badger product. You can visit its homepage for more details: https://drivebadger.com/


# Installing

Detailed manual can be found [here](https://github.com/drivebadger/drivebadger/wiki/Installing).

TL;DR:

- prepare USB device with Kali Linux (see [recommended hardware](https://github.com/drivebadger/drivebadger/wiki/Recommended-hardware)
- configure persistent partition (preferably with [LUKS encryption](https://github.com/drivebadger/drivebadger/wiki/LUKS-performance))
- install Drive Badger by just git-cloning this repository and a few others


# Legal information

This software was written and is meant to be **used only by eligible entities**, eg:

- police officers
- special agents
- intelligence officers
- military forces
- private detectives
- corporate red teams
- diplomats or other people with personal immunity

Its usage is always a subject to local legislation, and the user is solely responsible for all potential law infringements
and/or misfeasances of duties.

Intention of this product, is not an incitement for a crime. Rather, Drive Badger is mainly intended to be used in countries, where
using such tools is legal, or at most, can be a subject to possible disciplinary action between the end user and his/her employer.
