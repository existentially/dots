. ~/.cache/wal/colors.sh

print_with_icon() {
    local background1=$1
    local foreground1=$2 
    local background2=$3
    local foreground2=$4
    local icon=$5
    local text2=$6
    printf "^b$background1^^c$foreground1^ $icon "
    printf "^b$background2^^c$foreground2^ $text2 ^d^"
}

# get a hex color and return a darkened version of it
darken() {
    local hex="$1"
    local amount="$2"
    local r=$(echo "$hex" | cut -c 2-3)
    local g=$(echo "$hex" | cut -c 4-5)
    local b=$(echo "$hex" | cut -c 6-7)
    r=$(printf "%x" "$((0x$r - $amount))")
    g=$(printf "%x" "$((0x$g - $amount))")
    b=$(printf "%x" "$((0x$b - $amount))")
    echo "#$r$g$b"
}

color1='#e0efda'
color2='#efc7e5'
color3='#b3c2f2'
color4='#cc5a71'
color5='#f2c078'
color6='#83bcff'
darken_amount=20
darker_color1=$(darken $color1 $darken_amount)
darker_color2=$(darken $color2 $darken_amount)
darker_color3=$(darken $color3 $darken_amount)
darker_color4=$(darken $color4 $darken_amount)
darker_color5=$(darken $color5 $darken_amount)
darker_color6=$(darken $color6 $darken_amount)

datetime() {
    local date=`date +"%a, %d %b"`
    print_with_icon "$color1" "$background" "$darker_color1" "$background" "" "$date"
}

clock() {
    local date=`date +"%H:%M"`
    print_with_icon "$color2" "$background" "$darker_color2" "$background" "" "$date"
}

battery() {
    local battery=`acpi -b | grep -Eo '[0-9]+%' | sed 's/%//'`
    local status=`acpi -b | grep -Eo 'Charging|Discharging'`
    local icon="Error"
    if [ -z "$battery" ]; then 
        echo ""
        return
    fi
    if [ "$status" = "Charging" ]; then
        icon=""
    elif [ "$battery" -gt 75 ]; then
        icon=""
    elif [ "$battery" -gt 50 ]; then
        icon=""
    elif [ "$battery" -gt 25 ]; then
        icon=""
    else
        icon=""
    fi
    print_with_icon "$color3" "$background" "$darker_color3" "$background" "$icon" "$battery%%"
    printf " "
}

volume() {
    local volume=`pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'`
    local icon=""
    if [ -z "$volume" ]; then
        echo ""
        return
    fi
    if [ "$volume" -gt 75 ]; then
        icon=""
    elif [ "$volume" -gt 25 ]; then
        icon=""
    fi
    print_with_icon "$color4" "$background" "$darker_color4" "$background" "$icon" "$volume%%"
    printf " "
}

ram() {
    local ram=`free -m | grep Mem: | awk '{print $3}'`
    print_with_icon "$color5" "$background" "$darker_color5" "$background" "" "${ram}MiB"
}

connection() {
    local icon="睊"
    local message="Disconnected"
    if : >/dev/tcp/8.8.8.8/53; then
        icon="直"
        message="Connected"
    fi
    print_with_icon "$color6" "$background" "$darker_color6" "$background" "$icon" "$message"
}

while true; do
    xsetroot -name "$(connection) $(ram) $(volume)$(battery)$(datetime) $(clock)"
    sleep 3
done
