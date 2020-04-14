ADD progs:
- light 
- xorg-xev
- firefox
- rofi
- htop
- pulseaudio/-alsa
- pulsemixer

REMOVE progs:  
- xorg-xbacklight
- brave
- maybe fonts

check for invalid temps from sensor, so liquidprompt doesn't show them all the time  
add udev rule for backlight  
add user to video group  
rename pulse output devices  
script to add null sink and combined sink for streaming  
zgen needs to be added after dotfiles repository loads


delete testing folder
