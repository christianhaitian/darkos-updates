#!/bin/bash
clear
UPDATE_DATE="12312025"
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

	touch "$UPDATE_DONE"

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

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187

fi