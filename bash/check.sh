fail() {
	local code=$1; shift
	trace "$@" 1 >&2
	exit $code
}

trace() {
	local -i depth=$1; shift # the location in the stack for which the reported message applies
	local lineDesc="<no source>: "
	[[ "$BASH_SOURCE" != "" ]] && lineDesc="${BASH_SOURCE[$((1+$depth))]}: line ${BASH_LINENO[$(($depth))]}"
	local funcName="${FUNCNAME[$((1+$depth))]}"
	funcName=${funcName:-"<global>"}
	echo "$lineDesc: $funcName: $@"
}

#
#  fn() {
#    local var=$1
#    nonEmpty var || return 1
#
#    # do something ...
#  }
#
nonEmpty() {
	local __missing__=()
	for __env__ in $@; do [[ "${!__env__}" = "" ]] && __missing__+=($__env__); done
	[[ ${#__missing__} -gt 0 ]] && trace 1 "$(echo ${__missing__[@]}| tr '[[:space:]]' ',') are empty." >&2 && return 1
	return 0
}

#
#  true; require Must be true
#  false; require Must be true
#
require() {
	local lastCode=$?
	[[ $lastCode -ne 0 ]] && trace 1 "Requirement failed: $@" >&2 && return $lastCode
	return 0
}