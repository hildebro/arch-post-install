#!/bin/sh

error() {
	printf "ERROR:\\n%s\\n" "$1"
	exit
        }

# todo opption doesn't work
[[ $1 == 'dekstop' ]] || [[ $1 == 'laptop' ]] || error "Please specify target machine."

machine=$1
dotfilesrepo="https://github.com/hildebro/dotfiles.git"
dotfilebranch="master"
aurhelper="paru"
name="hillburn"
repodir="/home/$name/.local/src"; mkdir -p "$repodir"; chown -R "$name":wheel $(dirname "$repodir")

newperms() { # Set sudoers settings
	sed -i "/#paisfiopad/d" /etc/sudoers
	echo "$* #paisfiopad" >> /etc/sudoers
        }

manualinstall() { # Installs $1 manually if not installed. Used only for AUR helper here.
	[ -f "/usr/bin/$1" ] || (
	cd /tmp || exit
	rm -rf /tmp/"$1"*
	curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz &&
	sudo -u "$name" tar -xvf "$1".tar.gz &&
	cd "$1" &&
	sudo -u "$name" makepkg --noconfirm -si
	cd /tmp || return) ;
        }

installpkg(){ pacman --noconfirm --needed -S "$1";}

gitmakeinstall() {
	progname="$(basename "$1")"
	dir="$repodir/$progname"
	sudo -u "$name" git clone --depth 1 "$1" "$dir" || { cd "$dir" || return ; sudo -u "$name" git pull --force origin master;}
	cd "$dir" || exit
	make
	make install
	cd /tmp || return ;}

aurinstall() { \
	sudo -u "$name" $aurhelper -S --noconfirm "$1"
	}

pipinstall() { \
	command -v pip || installpkg python-pip
	yes | pip install "$1"
	}

installationloop() { \
	cp progs.csv /tmp/progs.csv
        cd /tmp
	total=$(wc -l < progs.csv)
	while IFS=, read -r tag program; do
		n=$((n+1))
		case "$tag" in
			"A") aurinstall "$program" ;;
			"G") gitmakeinstall "$program" ;;
			"P") pipinstall "$program" ;;
			*) installpkg "$program"  ;;
		esac
	done < progs.csv ;}

# Refresh keyring
pacman --noconfirm -Sy archlinux-keyring

# Some base packages
installpkg curl
installpkg base-devel
installpkg git
installpkg ntp

# Sync system time manually once before installation, just in case
ntp 0.us.pool.ntp.org

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.
newperms "%wheel ALL=(ALL) NOPASSWD: ALL"

# Make pacman colorful and adds eye candy on the progress bar
grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color$/Color/" /etc/pacman.conf
grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

# Install aur helper
manualinstall $aurhelper || error "Failed to install AUR helper."

# Enable multilib
sed -i '/^#\[multilib\]/{N;s/#//g}' /etc/pacman.conf
sudo pacman -Sy

# Device specific options
if [ $machine == 'laptop' ]; then
    # Graphics
    installpkg mesa
    installpkg lib32-mesa
    installpkg vulkan-intel
    installpkg intel-ucode
    # Fix tearing
    cp system-files/20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf
    # Ignore unreadable sensor on thinkpads (mainly to prevent an error with liquidprompt)
    cp system-files/thinkpad /etc/sensors.d/thinkpad
    # Enable backlight control for video group
    cp system-files/backlight.rules /etc/udev/rules.d/backlight.rules
    # Add user to video group
    usermod -a -G video $name
else
    # Graphics
    installpkg nvidia
    installpkg nvidia-settings
    installpkg nvidia-utils
    installpkg lib32-nvidia-utils
    installpkg amd-ucode
fi

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

# Emoji rendering fix for suckless software
yes | sudo -u "$name" $aurhelper -S libxft-bgra

# Install dotfiles in the user's home directory
[ ! -d "/home/$name" ] && mkdir -p "/home/$name"
chown -R "$name":wheel "/home/$name"
sudo -u "$name" git clone -b "$branch" --depth 1 "$dotfilesrepo" /tmp/dotfiles
sudo -u "$name" cp -rfT /tmp/dotfiles "/home/$name"
# Setup dotfiles git config to work via "dg" alias (see dotfiles)
mv "/home/$name/.git" "/home/$name/.dotfiles"

# Clone zgen into zsh config directory
sudo -u "$name" git clone https://github.com/tarjoilija/zgen.git /home/$name/.config/zsh/.zgen

# Weekly timer to refresh mirrorlist
# todo go back into paisfiopad folder or use absolute path
cp system-files/reflector.service /etc/systemd/system/reflector.service
cp system-files/reflector.timer /etc/systemd/system/reflector.timer
systemctl enable reflector.timer

# Daily service to sync time
systemctl enable ntpdate.service

# Get rid of system beep
rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf ;

# Make zsh the default shell for the user
sed -i "s/^$name:\(.*\):\/bin\/.*/$name:\1:\/bin\/zsh/" /etc/passwd

# dbus UUID must be generated for Artix runit
dbus-uuidgen > /var/lib/dbus/machine-id

# This line, overwriting the `newperms` command above will allow the user to run
# serveral important commands, `shutdown`, `reboot`, updating, etc. without a password.
newperms "%wheel ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/systemctl restart NetworkManager,/usr/bin/loadkeys,/usr/bin/paru"

