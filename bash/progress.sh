source2 wav/bash/util.sh

progress() {
  local proc=$1;
  local -i progress=${2%.*}
  local -i total=$3
  local -i percent=$((200*$progress/$total % 2 + 100*$progress/$total))
  local -i width=$(($percent/4))
  local title=$4
  local bar="$proc: \\033[38;5;27m[`repeat $width "#"`\\033[38;5;39m`repeat $((25-$width)) "*"`\\033[38;5;27m]\\033[0m $percent% $title"
  echo -ne "$bar\033[0K\r"
  #printf "\r%s" "$bar" # doesn't support colors. Puts cursor at end.
  set-title "$title ($percent%)"
}

progress::fakeload() {
  local -i i=0
  for i in {0..25}; do
    progress fakeload $i 25 "Doing lots of things..."
    sleep 0.05
  done
  set-title fakeload complete
  printf "\rLOADED`repeat 100 " "`"
  echo
}