#!/usr/bin/env zsh

set +e  # Disable errexit
set +u  # Disable nounset
set +o pipefail  # Disable pipefail

brightnessUP="brightnessctl s +5%"
brightnessDown="brightnessctl s 5%-"

brightness=$(brightnessctl get)

notif() {
	dunstify -h string:x-canonical-private-synchronous:brightness "$@"
}

max=$(brightnessctl max)

case $1 in
up)
	if (( $(echo "$brightness >= $max" | bc) )); then
		notif -h int:value:100 "Backlight"
	else
		eval "$brightnessUP"
		currBrightness=$(echo "$brightness * 100 / $max" | bc)
		notif -h int:value:"$currBrightness" "Backlight"
	fi
	;;
down)
	if (( $(echo "$brightness <= 0" | bc) )); then
		notif -h int:value:0 "Backlight"
	else
		eval "$brightnessDown"
		currBrightness=$(echo "$brightness * 100 / $max" | bc)
		notif -h int:value:"$currBrightness" "Backlight"
	fi
	;;
*)
	notif "Error in brightness"
	;;
esac
