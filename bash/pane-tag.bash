# Tag tmux pane with a name and color
# Usage: tp <name> [color]
# Colors: red, green, blue, yellow, magenta, cyan, orange, pink
# Example: tp "my-api" blue
tp() {
    [ -z "$TMUX" ] && echo "Not in tmux" && return 1
    [ -z "$1" ] && echo "Usage: tp <name> [color]" && return 1
    local name="$1"
    local color="${2:-default}"
    local bg=""
    case "$color" in
        red)     bg="colour52"  ;;
        green)   bg="colour22"  ;;
        blue)    bg="colour17"  ;;
        yellow)  bg="colour58"  ;;
        magenta) bg="colour53"  ;;
        cyan)    bg="colour23"  ;;
        orange)  bg="colour130" ;;
        pink)    bg="colour125" ;;
        default) bg=""          ;;
        *)       bg="$color"    ;; # pass raw tmux colour
    esac
    tmux select-pane -T "$name"
    [ -n "$bg" ] && tmux select-pane -P "bg=$bg"
}
