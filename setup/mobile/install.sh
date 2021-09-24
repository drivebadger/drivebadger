#!/bin/sh

apt-get install jmtpfs gphoto2 ntfs-3g cryptsetup


dirs="
/media/fallback
/media/targets
/etc/drivebadger/drives
`/opt/drivebadger/internal/mobile/get-keys-directory.sh`
`/opt/drivebadger/internal/mobile/get-metadata-directory.sh`
"

for MD in $dirs; do
	mkdir -p $MD
done

touch /etc/drivebadger/drives/ignore.list /etc/drivebadger/drives/target.list


echo "copying Mobile Badger templates"

cp -af /opt/drivebadger/setup/systemd/storagebadger@.service /etc/systemd/system
cp -af /opt/drivebadger/setup/systemd/ptpbadger@.service /etc/systemd/system
cp -af /opt/drivebadger/setup/systemd/mtpbadger@.service /etc/systemd/system

cp -af /opt/drivebadger/setup/systemd/storagebadger.rules /etc/udev/rules.d
cp -af /opt/drivebadger/setup/systemd/ptpbadger.rules /etc/udev/rules.d
cp -af /opt/drivebadger/setup/systemd/mtpbadger.rules /etc/udev/rules.d

ln -sf /opt/drivebadger/internal/mobile/events/shutdown.sh /etc/network/if-down.d/shutdown-badger
systemctl daemon-reload
/etc/init.d/udev reload


if ! grep -q /opt/drivebadger/internal/mobile/events/boot.sh /etc/rc.local; then
	echo "setting up rc.local entry"
	echo "\n\n# Move this line above \"exit 0\"" >>/etc/rc.local
	echo "/opt/drivebadger/internal/mobile/events/boot.sh" >>/etc/rc.local
	mcedit /etc/rc.local
fi

/opt/drivebadger/internal/mobile/events/boot.sh

if [ -d /opt/drivebadger/external/ext-mobile-drivers ]; then
	/opt/drivebadger/external/ext-mobile-drivers/install.sh
fi
