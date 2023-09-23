#!/bin/sh

sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S 1password adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts alacritty ansible arandr avahi bat bc blueman bluez bluez-utils btop cups deemix deluge-gtk dnsmasq docker docker-compose dosfstools dunst eza feh firefox fzf git gnome-keyring gnumeric greetd greetd-tuigreet htop i3blocks intellij-idea-ultimate-edition maim man-db miniserve mumble neovim pamixer pirewire-alsa pipewire-pulse pulsemixer python-spotdl python-virtualenv reflector ripgrep rofi rsync rustup signal-desktop slock starship steam sxiv telegram-desktop thunderbird ttf-joypixels ttf-liberation unclutter unrar unzip xcompmgr yt-dlp zip zoxide zsh

git clone "https://github.com/hildebro/dotfiles" /tmp/dotfiles
cp -rfT /tmp/dotfiles /home/hillburn
mv /home/hillburn/.git /home/hillburn/.dotfiles

chsh -s $(which zsh)

rm ~/.bash*

# cleanup vim and zsh configs

# init gpg

# maybe reflector stuff
# maybe system beep (if not needed for desktop, still keept for laptop just in case)
# maybe some commands that dont need sudo pw (via /etc/sudoers.d)
# remove nvidia from .config
# remove zgen
# fix .dotfiles/config having broken fetch (maybe checkout master first, then switch branch. or just omit --depth
# freesync
# run display config on startup

# start docker socket
# add user to docker group


# avahi hostname resolution for printing
