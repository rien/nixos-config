
import="@imagemagick@/bin/import"
xclip="@xclip@/bin/xclip"
dunstify="@dunst@/bin/dunstify"

appName="screenshot"
msgId="42003"

screenshot_file="$(mktemp -p /tmp XXXX.png)"
$import "$screenshot_file"
$dunstify --appname="$appName" --replace="$msgId" "📸 $screenshot_file"

# -loop -1 causes it to wait until the clipboard is replaced
$xclip -loop -1 -selection clipboard -target image/png "$screenshot_file"

rm "$screenshot_file"
