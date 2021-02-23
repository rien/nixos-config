dunstify="@dunst@/bin/dunstify"
pactl="@pulseaudio@/bin/pactl"
paplay="@pulseaudio@/bin/paplay"
noot="@noot@"

# Unique notification ID for dunst
msgId="42001"
appName="volumectl"

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

# echo progress bar with the current volume percentage
show_volume() {
    local -r volume="$(${pactl} list sinks | sed -n 's_^\s\+Volume:.* \([0-9]\+\)%.*$_\1_p')"
    local -r muted="$(${pactl} list sinks | sed -n 's_^\s\+Mute: \(.*\)$_\1_p')"
    local symbol="🔉"
    if [ "$muted" = "yes" ]; then
        symbol="🔇"
    fi
    echo -n "$symbol $(progress_bar $volume)"
}

notify() {
    ${dunstify} -a "$appName" -u low -r "$msgId" "$1" ""
}

change_volume() {
    ${pactl} set-sink-volume @DEFAULT_SINK@ $@
    notify "$(show_volume)"
    ${paplay} ${noot}
}

toggle_mute() {
    ${pactl} set-sink-mute @DEFAULT_SINK@ toggle
    notify "$(show_volume)"
}

case "$1" in
    change)
        change_volume "$2"
        ;;
    mute)
        toggle_mute
        ;;
    *)
        echo "Unrecognised command: $@"
        ;;
esac
