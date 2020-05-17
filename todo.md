ADD progs:
- light 
- xorg-xev
- firefox or chrome-like
- rofi
- htop
- pulseaudio/-alsa
- pulsemixer
- ripgrep
- reflector
- vlc
- steam
- steam-fonts
- xf86-video, mesa, etc. (with lib32)
- deluge

REMOVE progs:  
- xorg-xbacklight
- brave
- ncmpcpp
- fonts (maybe)

check for invalid temps from sensor, so liquidprompt doesn't show them all the time  
add udev rule for backlight  
add user to video group  
rename pulse output devices  
script to add null sink and combined sink for streaming  
zgen needs to be added after dotfiles repository loads  
reflector automation  
tearing fix (if intel)   
clock synch  
random image generator for setbg  
enable multilib  
default tags for programs  
startup script for work related progs

delete testing folder
