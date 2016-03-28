# usage `cat file | indent n`
indent() {
  local -i width=$(($1*2));
  local prefix=`repeat $width`
  local line=;
  while read -es line; do
    echo -e "$prefix$line";
  done
}

repeat() {
  [[ $1 -gt 1 ]] && seq  -f "$2" -s '' $1
}

# http://unix.stackexchange.com/questions/124407/what-color-codes-can-i-use-in-my-ps1-prompt
colors() {
  color=16;
  while [ $color -lt 245 ]; do
        echo -e "$color: \\033[38;5;${color}m${color}\\033[48;5;${color}mworld\\033[0m"
        ((color++));
  done 
}

pid() {
  ps -A -o "pid command" | grep -E "^\s+[0-9]+\s+/.*$1" | \
    while read -s pid command rest; do [[ `basename $command` == "$1" ]] && echo $pid; done
}

set-title() {
  echo -n -e "\033]0;$@\007"
}

is_git() {
  git rev-parse 2> /dev/null
}