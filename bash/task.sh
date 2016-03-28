task::usage() {
	cat <<EOF >&2
Usage: $(basename $BASH_SOURCE) TASK [ARGS]
Tasks:
$(for task in $(declare -F | grep -oE "task::[[:alnum:]:_-]+" | cut -d : -f 3); do echo "  $task"; done)
EOF
}

task() {
	if [[ $# -ne 0 ]]; then
		CMD=task::$1; shift
		$CMD $@	|| exit $?
	else
		task::usage && exit 1
	fi
}