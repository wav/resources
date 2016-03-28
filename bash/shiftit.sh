source2 wav/bash/util.sh

# usage `shiftit l | osascript`
shiftit() {
  local -i code
  case "$1" in
    1) code=18;;
    2) code=19;;
    3) code=20;;
    4) code=21;;
    l) code=123;;
    r) code=124;;
    u) code=126;;
    d) code=125;;
    *) return 1;;
  esac
  cat <<EOF
tell application "System Events"
  key code $code using {command down, option down, control down}
end tell
EOF
}

# usage `terminal w:1 cd $pwd` # opens a new window in the top left corner in the current directory
#       `terminal t cd $pwd`   # opens a new tab in the current directory
terminal() {
  local type=$1; shift
  local script=
  [[ "$type" =~ w: ]] && script=`shiftit ${type#*:} | indent 2`

  osascript<<EOF
tell application "Terminal"  
  do script "$@"
  activate
$script
end tell
EOF
}

alias _r='terminal w:r'
alias _l='terminal w:l'
alias _1='terminal w:1'
alias _2='terminal w:2'
alias _3='terminal w:3'
alias _4='terminal w:4'