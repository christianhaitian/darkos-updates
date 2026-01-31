#!/bin/bash

clear
UPDATE_DATE="01302026"
LOG_FILE="/home/ark/update$UPDATE_DATE.log"
UPDATE_DONE="/home/ark/.config/.update$UPDATE_DATE"

if [ -f "$UPDATE_DONE" ] || [ -z "$UPDATE_DONE" ]; then
	msgbox "No more updates available.  Check back later."
	rm -- "$0"
	exit 187
fi

if [ -f "$LOG_FILE" ]; then
	sudo rm "$LOG_FILE"
fi

LOCATION="https://raw.githubusercontent.com/christianhaitian/darkos-updates/master"

sudo msgbox "ONCE YOU PROCEED WITH THIS UPDATE SCRIPT, DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT IN A STATE OF UNUSABILITY.  Make sure you've created a backup of this sd card as a precaution in case something goes very wrong with this process.  You've been warned!  Type OK in the next screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

if [ "$my_var" != "OK" ] && [ "$my_var" != "ok" ]; then
  sudo msgbox "You didn't type OK.  This script will exit now and no changes have been made from this process."
  printf "You didn't type OK.  This script will exit now and no changes have been made from this process." | tee -a "$LOG_FILE"
  rm -- "$0"
  exit 187
fi

c_brightness="$(cat /sys/class/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/class/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update12242025" ]; then

	printf "\nAdd missing files for Drastic\nUpdate drastic.sh script\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12242025/darkosupdate12242025.zip -O /dev/shm/darkosupdate12242025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/darkosupdate12242025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/darkosupdate12242025.zip" ]; then
	  sudo unzip -X -o /dev/shm/darkosupdate12242025.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate12242025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate12242025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nUpdate boot text to reflect current version of dArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=dArkOS ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update12242025"

fi

if [ ! -f "/home/ark/.config/.update12312025" ]; then

	printf "\nUpdate Emulationstation for chinese language based fixes and timezone updating\nFix Playstation not working with 32bit pcsx_rearmed cores\nFix controls for duckstation standalone emulator\nRevert osk.py\nFix checknswitchforusbdac\nFix no audio on boot for rgb10\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12312025/darkosupdate12312025.zip -O /dev/shm/darkosupdate12312025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/darkosupdate12312025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/darkosupdate12312025.zip" ]; then
	  sudo unzip -X -o /dev/shm/darkosupdate12312025.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate12312025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate12312025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct pcsx_rearmed 32bit core depending on chipset\n" | tee -a "$LOG_FILE"
	if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  rm -f /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.rk3326
	  rm -f /home/ark/.config/retroarch32/cores/pcsx_rearmed_rumble_libretro.so.rk3326
	else
	  cp -f /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.rk3326 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so
	  cp -f /home/ark/.config/retroarch32/cores/pcsx_rearmed_rumble_libretro.so.rk3326 /home/ark/.config/retroarch32/cores/pcsx_rearmed_rumble_libretro.so
	  rm -f /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.rk3326
	  rm -f /home/ark/.config/retroarch32/cores/pcsx_rearmed_rumble_libretro.so.rk3326
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-g350-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
      sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	else
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ]; then
	  printf "\nUpdate ogage\n" | tee -a "$LOG_FILE"
	  sudo mv -fv /home/ark/ogage /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo chmod 777 /usr/local/bin/ogage
	else
	  printf "\nNo need to update ogage\n" | tee -a "$LOG_FILE"
	  rm -fv /home/ark/ogage | tee -a "$LOG_FILE"
	fi

	printf "\nAdd BigPEmu to emulationstaton as the Atari Jagauar emulator.  Forget about the retroarch core.\n" | tee -a "$LOG_FILE"
	cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12312025.bak
	sed -i 's|/usr/local/bin/retroarch -L /home/ark/.config/retroarch/cores/virtualjaguar_libretro\.so|/usr/local/bin/bigpemu.sh|g' /etc/emulationstation/es_systems.cfg
	mkdir -p /roms/atarijaguar
	if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
	  mkdir -p /roms2/atarijaguar
	fi

	printf "\nAdd mediatek firmware files, ntfs support, and vlc\n" | tee -a "$LOG_FILE"
	sudo apt update -y  | tee -a "$LOG_FILE"
	sudo apt -y install firmware-mediatek ntfs-3g vlc-data vlc-plugin-base | tee -a "$LOG_FILE"

	printf "\nInstall libavcodec58 for portmaster\n" | tee -a "$LOG_FILE"
	wget -t 3 -T 60 --no-check-certificate http://security.debian.org/debian-security/pool/updates/main/f/ffmpeg/libavcodec58_4.3.9-0+deb11u1_arm64.deb | tee -a "$LOG_FILE"
	dpkg --fsys-tarfile libavcodec58_4.3.9-0+deb11u1_arm64.deb | tar -xO ./usr/lib/aarch64-linux-gnu/libavcodec.so.58.91.100 > libavcodec.so.58
	sudo mv -f libavcodec.so.58 /usr/lib/aarch64-linux-gnu/
	sudo chown root:root /usr/lib/aarch64-linux-gnu/libavcodec.so.58
	rm -f libavcodec58_4.3.9-0+deb11u1_arm64.deb
    wget -t 3 -T 60 --no-check-certificate http://security.debian.org/debian-security/pool/updates/main/f/ffmpeg/libavcodec58_4.3.9-0+deb11u1_armhf.deb | tee -a "$LOG_FILE"
	dpkg --fsys-tarfile libavcodec58_4.3.9-0+deb11u1_armhf.deb | tar -xO ./usr/lib/arm-linux-gnueabihf/libavcodec.so.58.91.100 > libavcodec.so.58
	sudo mv -f libavcodec.so.58 /usr/lib/arm-linux-gnueabihf/
	sudo chown root:root /usr/lib/arm-linux-gnueabihf/libavcodec.so.58
	rm -f libavcodec58_4.3.9-0+deb11u1_armhf.deb

	printf "\nUpdate boot text to reflect current version of dArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=dArkOS ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update12312025"

fi

if [ ! -f "/home/ark/.config/.update01082026" ]; then

	printf "\nUpdate Emulationstation to fix swap ab when in options and crashing while scrolling with few games loaded\nUpdate emulationstation translations\nFix drastic in game saves and default restore for rg351mp\nAdd Vietnamese ES translation\nAdd Sharp Shimmerless Shader\nFix Chinese text rendering\nAdd liblcf library for easyrpg\nAdd missing easyrpg.sh script\nChange default j2me emulator to freej2me-plus\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01082026/darkosupdate01082026.zip -O /dev/shm/darkosupdate01082026.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/darkosupdate01082026.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/darkosupdate01082026.zip" ]; then
	  sudo unzip -X -o /dev/shm/darkosupdate01082026.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate01082026.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate01082026.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-g350-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
      sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	else
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation settings depending on chipset\n" | tee -a "$LOG_FILE"
	cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01082026.bak
	if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  cp -f /etc/emulationstation/es_systems.cfg.rk3566 /etc/emulationstation/es_systems.cfg
	  rm -f /etc/emulationstation/es_systems.cfg.rk*
	else
	  cp -f /etc/emulationstation/es_systems.cfg.rk3326 /etc/emulationstation/es_systems.cfg
	  rm -f /etc/emulationstation/es_systems.cfg.rk*
	fi
	if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
 	  printf "\nAccomodate for roms2 with new es_systems.cfg file...\n" | tee -a "$LOG_FILE"
	  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
	fi

	if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ] || [ ! -z "$(grep "RGB20PRO" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  printf "\nUpdate batt_life_warning.py script\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/powkiddy/batt_life_warning.py /usr/local/bin/. | tee -a "$LOG_FILE"
	elif [ ! -z "$(grep "RG351MP" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  printf "\nUpdate batt_life_warning.py scripts\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/rg351mp/batt_life_warning.py* /usr/local/bin/. | tee -a "$LOG_FILE"
	fi
	rm -rfv /home/ark/powkiddy/ | tee -a "$LOG_FILE"
	rm -rfv /home/ark/rg351mp/ | tee -a "$LOG_FILE"

	printf "\nRemove Backup ArkOS and Restore ArkOS settings scripts.  They're now replaced with Backup dArkOS and Restore dArkOS settings scripts\n" | tee -a "$LOG_FILE"
	rm -fv /opt/system/Advanced/Backup\ ArkOS\ Settings.sh | tee -a "$LOG_FILE"
	rm -fv /opt/system/Advanced/Restore\ ArkOS\ Settings.sh | tee -a "$LOG_FILE"

	printf "\nMove bigpemu defaultconfig to defaultconfigs\n"
	mv -v /opt/bigpemu/defaultconfig/ /opt/bigpemu/defaultconfigs/ | tee -a "$LOG_FILE"

	printf "\nMove Scan_for_new_games.alg from scummvm to alg\n"
	mv -v /roms/scummvm/Scan_for_new_games.alg /roms/alg/Scan_for_new_games.alg | tee -a "$LOG_FILE"
	if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
	  mv -v /roms2/scummvm/Scan_for_new_games.alg /roms2/alg/Scan_for_new_games.alg | tee -a "$LOG_FILE"
	fi

	printf "\nAdd netcat for online download of j2me\n" | tee -a "$LOG_FILE"
	sudo apt update -y  | tee -a "$LOG_FILE"
	sudo apt -y install netcat-openbsd | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of dArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=dArkOS ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update01082026"

fi

if [ ! -f "/home/ark/.config/.update01162026" ]; then

	printf "\nFix Quick Mode\nFix OpenBOR\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01162026/darkosupdate01162026.zip -O /dev/shm/darkosupdate01162026.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/darkosupdate01162026.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/darkosupdate01162026.zip" ]; then
	  sudo unzip -X -o /dev/shm/darkosupdate01162026.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate01162026.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate01162026.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if [ -f "/opt/system/Advanced/Enable Quick Mode.sh" ]; then
	  sudo rm -fv /usr/local/bin/quickmode.sh | tee -a "$LOG_FILE"
	fi

	if [ ! -f "/etc/polkit-1/rules.d/10-networkmanager.rules" ]; then
	  printf "\nRemove requirement for sudo to control nmcli\n" | tee -a "$LOG_FILE"
	  cat <<EOF | sudo tee /etc/polkit-1/rules.d/10-networkmanager.rules
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager") == 0 &&
        subject.isInGroup("netdev")) {
        return polkit.Result.YES;
    }
});
EOF
	fi

	if [ ! -z "$(grep "RG353" /home/ark/.config/.DEVICE | tr -d '\0')" ] && [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  printf "\nFix unknown panel version info for RG353V/VS and RG353M V1 and V2 units\n" | tee -a "$LOG_FILE"
	  sudo dd if=/home/ark/resource.img of=/dev/mmcblk1 bs=512 seek=24576 conv=notrunc | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/resource.img | tee -a "$LOG_FILE"
	else
	  sudo rm -fv /home/ark/resource.img | tee -a "$LOG_FILE"
	fi

	printf "\nUpgraded Debian Trixie OS to version 13.3\n" | tee -a "$LOG_FILE"
	sudo apt -y update | tee -a "$LOG_FILE"
	sudo apt -y upgrade | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of dArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=dArkOS ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update01162026"

fi

if [ ! -f "/home/ark/.config/.update01302026" ]; then

	printf "\nAdd gif and vid option to emulationstation\nFix perfmax and perfnorm scripts\nFix hdmi-test script\nUpdate local netplay based scripts and configs\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01302026/darkosupdate01302026.zip -O /dev/shm/darkosupdate01302026.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/darkosupdate01302026.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/darkosupdate01302026.zip" ]; then
	  sudo unzip -X -o /dev/shm/darkosupdate01302026.zip -d / | tee -a "$LOG_FILE"
	  sudo cp -fv /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh /usr/local/bin/. | tee -a "$LOG_FILE"
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
	    sudo rm -fv /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
	  fi
	  if [ ! -z "$(grep "RGB10" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	    sudo rm -fv /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/darkosupdate01302026.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/darkosupdate01302026.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nAdd hostapd and dnsmasq for local netplay\n" | tee -a "$LOG_FILE"
	sudo apt update -y  | tee -a "$LOG_FILE"
	sudo mv -fv /etc/dnsmasq.conf /tmp/. | tee -a "$LOG_FILE"
	sudo mv -fv /etc/hostapd/hostapd.conf /tmp/. | tee -a "$LOG_FILE"
	sudo apt -y install hostapd dnsmasq | tee -a "$LOG_FILE"
	sudo mv -fv /tmp/dnsmasq.conf /etc/dnsmasq.conf | tee -a "$LOG_FILE"
	sudo mv -fv /tmp/hostapd.conf /etc/hostapd/hostapd.conf | tee -a "$LOG_FILE"
	sudo systemctl disable hostapd dnsmasq | tee -a "$LOG_FILE"

	if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" != *"rk3566"* ]]; then
	  sudo rm -fv /usr/local/bin/hdmi-test.sh | tee -a "$LOG_FILE"
	fi

	sudo chown -R ark:ark /opt
	if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  rm -fv /opt/gametank/GameTankEmulator.rk3326 | tee -a "$LOG_FILE"
	else
	  mv -fv /opt/gametank/GameTankEmulator.rk3326 /opt/gametank/GameTankEmulator | tee -a "$LOG_FILE"
	fi

	if [ ! -f "/usr/share/alsa/alsa.conf.mednafen" ]; then
	  printf "\nCreate missing alsa.conf.mednafen\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/share/alsa/alsa.conf /usr/share/alsa/alsa.conf.mednafen | tee -a "$LOG_FILE"
	  sudo sed -i '/\"\~\/.asoundrc\"/s//\"\~\/.asoundrc.mednafen\"/' /usr/share/alsa/alsa.conf.mednafen
	fi

	printf "\nCopy correct emulationstation settings depending on chipset\n" | tee -a "$LOG_FILE"
	cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01302026.bak
	if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  cp -f /etc/emulationstation/es_systems.cfg.rk3566 /etc/emulationstation/es_systems.cfg
	  rm -f /etc/emulationstation/es_systems.cfg.rk*
	else
	  cp -f /etc/emulationstation/es_systems.cfg.rk3326 /etc/emulationstation/es_systems.cfg
	  rm -f /etc/emulationstation/es_systems.cfg.rk*
	fi
	mkdir -p /roms/gametank
	if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
 	  printf "\nAccomodate for roms2 with new es_systems.cfg file...\n" | tee -a "$LOG_FILE"
	  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
	  mkdir -p /roms2/gametank
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-a10mini-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-g350-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
      sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	else
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi

	if [ ! -z "$(grep "A10MINI" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  printf "\nEnabling additional lower scaling frequencies for the A10 Mini power savings..\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/rk3326-a10mini-linux.dtb /boot/. | tee -a "$LOG_FILE"
	elif [ ! -z "$(grep "RG351MP" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  printf "\nEnabling additional lower scaling frequencies for the RG351MP power savings..\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/rk3326-rg351mp-linux.dtb /boot/. | tee -a "$LOG_FILE"
	fi
	sudo rm -fv /home/ark/rk3326-a10mini-linux.dtb /home/ark/rk3326-rg351mp-linux.dtb | tee -a "$LOG_FILE"

	printf "\nDoing some theme updates..\n\n" | tee -a "$LOG_FILE"
	for theme in es-theme-nes-box es-theme-sagabox es-theme-saganx es-theme-switch
	do
	  if [ -d "/roms/themes/$theme" ]; then
		printf "\nUpdating $theme\n" | tee -a "$LOG_FILE"
		cd /roms/themes/$theme
		git fetch origin
		git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
		git pull
		cd /home/ark
	  fi
	done

	if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  printf "\nAdd shutdown tasks for remembering panel settings\n" | tee -a "$LOG_FILE"
	  echo "@reboot /usr/local/bin/panel_set.sh RestoreSettings &" | sudo tee -a /var/spool/cron/crontabs/root
	  sudo systemctl daemon-reload
	  sudo systemctl enable shutdowntasks
	  sudo systemctl restart shutdowntasks
	else
	  sudo rm -fv /etc/systemd/system/shutdowntasks.service | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/panel_set.sh | tee -a "$LOG_FILE"
	fi

	if [ ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')" ] && [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  printf "\nRevert RG353V v2 screen changes from last update..\n" | tee -a "$LOG_FILE"
	  sudo mv -fv /home/ark/rk3566-353v.dtb /boot/. | tee -a "$LOG_FILE"
	  sudo mv -fv /home/ark/rk3566-353v-notimingchange.dtb /boot/. | tee -a "$LOG_FILE"
	elif [ ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')" ] && [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
	  printf "\nAdd additonal notimingchange dtb to boot partition..\n" | tee -a "$LOG_FILE"
	  sudo mv -fv /home/ark/rk3566-353m-notimingchange.dtb /boot/. | tee -a "$LOG_FILE"
	fi
	sudo rm -fv /home/ark/rk3566-353* | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of dArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=dArkOS ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187

fi