dunstify="@dunst@/bin/dunstify"
brightnessctl="@brightnessctl@/bin/brightnessctl"

# Unique notification ID for dunst
msgId="42002"
appName="brightness"

# echo a progress bar
progress_bar() {
    local -r percent=$1
    local -r max_percent=${2:-100}
    local -r width=${3:-20}
    local -r progress=$(((percent > max_percent ? max_percent : percent) * width / max_percent))
    local -r rest=$((width-progress))

    printf -v fill "%*s" $progress ""
    printf -v empty "%*s" $rest ""
    printf -v pct "%*s" 4 $percent
    echo -n "${fill// /█}$empty$pct"
}

brightness="$(brightnessctl --exponent=2 set $1 | sed -n 's_^\s\+Current.*(\([0-9]\+\)%)$_\1_p')"
body="💡 $(progress_bar "$brightness")"
${dunstify} -a "$appName" -u low -r "$msgId" "$body" ""
