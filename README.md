# Overview

Drive Badger is a framework for secure, automated, huge scale, time-effective data exfiltration from computers running any version of:

- Windows (including Windows Server and Windows Embedded)
- Linux
- Mac OS (including support for new APFS filesystem)

It runs on any size of hardware, from mini-pcs, through laptops, desktop computers, up to big servers (see [hardware compatibility list](https://github.com/drivebadger/drivebadger/wiki/Hardware-compatibility-list)). Basically on anything, that can run [Kali Linux](https://github.com/drivebadger/drivebadger/wiki/Kali-Linux), and have at least 1 working USB port.

It is able to exfiltrate data off encrypted hard drives - it currently supports the following encryption schemes:

- [Bitlocker](https://github.com/drivebadger/drivebadger/wiki/Encryption-support-(Bitlocker))
- [FileVault](https://github.com/drivebadger/drivebadger/wiki/Encryption-support-(FileVault))
- [VeraCrypt](https://github.com/drivebadger/drivebadger/wiki/Encryption-support-(VeraCrypt))
- [LUKS](https://github.com/drivebadger/drivebadger/wiki/Encryption-support-(LUKS))

Support for other encryption schemes is also planned (see [project roadmap](https://github.com/drivebadger/project/wiki/Roadmap)).

Drive Badger runs below the operating system level - so it doesn't need any passwords (eg. Active Directory) to exfiltrated computers. Instead, it is able to discover
several types of passwords and other resources on its own, and use them to automatically expand the attack surface:

- on Windows computers, decode FTP passwords saved by Total Commander and use them to exfiltrate data off FTP servers using exfiltrated computer's IP
- on Linux computers, exfiltrate `smb` and `nfs` shares defined statically in `/etc/fstab`
- on VMware servers, mount VMDK virtual drive images and recursively exfiltrate virtual machine contents

This is a core repository for Drive Badger product. You can visit its homepage for more details: https://drivebadger.com/


# Mobile Badger

Drive Badger can be also run in Mobile Badger mode, as standalone solution for Raspberry Pi or similar hardware. Mobile Badger brings data exfiltration support for:

- Android phones, tablets and possibly other devices (Android version from 4.x to latest)
- Apple iOS-based devices (with iOS 14.x)
- Windows Phone 8/10 (Lumia phones)
- all sorts of mobile devices supporting USB data transfer ([details](https://github.com/drivebadger/mobilebadger/wiki))


# Further reading

Is Drive Badger for me?

- [Why ever use Drive Badger? This can be done manually, or by ad-hoc script.](https://github.com/drivebadger/project/wiki/Frequently-Asked-Questions)
- [Legal and risk-related questions: when using Drive Badger is legal?](https://github.com/drivebadger/project/wiki/Legal-questions)
- [Recommended hardware - before you buy anything...](https://github.com/drivebadger/drivebadger/wiki/Recommended-hardware)

Ok, I'm interested, what should I read next?

- [How to start?](https://github.com/drivebadger/drivebadger/wiki/How-to-start%3F)
- [Installation manual](https://github.com/drivebadger/drivebadger/wiki/Installing) and [ready to use install script](https://github.com/drivebadger/drivebadger/wiki/Install-script).
- [Understanding the boot process](https://github.com/drivebadger/drivebadger/wiki/Understanding-the-boot-process)
- [Planning the big attack](https://github.com/drivebadger/fieldmanual/wiki/Planning-the-big-attack)
- [How to configure drive encryption keys before attack?](https://github.com/drivebadger/fieldmanual/wiki/Configuring-encryption-keys)
- [Filesystem injection support](https://github.com/drivebadger/drivebadger/wiki/Filesystem-injection-support)
- [Troubleshooting](https://github.com/drivebadger/drivebadger/wiki/Troubleshooting)

Mobile Badger - standalone version of Drive Badger:

- [Recommended hardware - before you buy anything...](https://github.com/drivebadger/mobilebadger/wiki/Recommended-hardware)
- [Installation manual](https://github.com/drivebadger/mobilebadger/wiki/Installing) and [ready to use install script](https://github.com/drivebadger/mobilebadger/wiki/Install-script).
- [How the data storage is organized](https://github.com/drivebadger/mobilebadger/wiki/Data-storage)
- [Event display: what is actually happening with your device?](https://github.com/drivebadger/mobilebadger/wiki/Events-display)

I want to stay current...

- [News](https://github.com/drivebadger/project/wiki/News)
- [Project roadmap](https://github.com/drivebadger/project/wiki/Roadmap)


# Legal information

This software was written and is meant to be **used only by eligible entities**, eg:

- police officers
- special agents
- intelligence officers
- military forces
- private investigators
- corporate red teams
- diplomats or other people with personal immunity

Its usage is always a subject to local legislation, and the user is solely responsible for all potential law infringements
and/or misfeasances of duties.

Intention of this product, is not an incitement for a crime. Rather, Drive Badger is mainly intended to be used in countries, where
using such tools is legal, or at most, can be a subject to possible disciplinary action between the end user and his/her employer.
