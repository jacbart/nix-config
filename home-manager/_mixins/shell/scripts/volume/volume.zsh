#!/usr/bin/env zsh

set +e  # Disable errexit
set +u  # Disable nounset
set +o pipefail  # Disable pipefail

volUP="wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
volDown="wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
volTog="wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

vol=$(wpctl get-volume @DEFAULT_SINK@ | cut -d " " -f 2)

alias notif="dunstify -h string:x-canonical-private-synchronous:audio"

case $1 in
up)
	if (( $(echo "$vol >= 2" | bc) )); then
		notif -h int:value:100 "Volume"
	else
		eval "$volUP"
		currVol=$(echo "$vol * 50 + 5" | bc)
		notif -h int:value:"$currVol" "Volume"
	fi
	;;
down)
	if (( $(echo "$vol <= 0" | bc) )); then
		notif -h int:value:0 "Volume"
	else
		eval "$volDown"
		currVol=$(echo "$vol * 50 - 5" | bc)
		notif -h int:value:"$currVol" "Volume"
	fi
	;;
toggle)
	eval "$volTog"
	notif "Toggled Mute"
	;;
*)
	notif "Error in volume"
	;;
esac
