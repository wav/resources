HAS_COLOURS=1
LOGGING_SHOW_TIME=1
LOGGING_TIME_FORMAT="+ %H:%M:%S"

log::_color() {
    # TODO: eval http://www.arwin.net/tech/bash.php#s_1
    local c=$1
    shift
    [[ $HAS_COLOURS -eq 1 ]] && echo -e "\033["$c"m"$@"\033[0m" || echo $@
}

log::fail() {
    log::_color "1;49;91" "[Failed`[[ '$LOGGING_TIME_FORMAT' = '1' ]] && date '$LOGGING_TIME_FORMAT'`]" $@ >&2
    exit 1
}

log::error() {
    log::_color "0;49;91" "[Error`[[ '$LOGGING_TIME_FORMAT' = '1' ]] && date '$LOGGING_TIME_FORMAT'`]" $@ >&2
    false
}

log::info() {
    local tag=$1
    shift
    log::_color "0;49;90" "[$tag`[[ '$LOGGING_TIME_FORMAT' = '1' ]] && date '$LOGGING_TIME_FORMAT'`]" $@ 
}

log::success() {
    log::_color "1;49;92" "[Success`[[ '$LOGGING_TIME_FORMAT' = '1' ]] && date '$LOGGING_TIME_FORMAT'`]" $@ 
}