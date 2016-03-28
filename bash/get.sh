source2 wav/bash/check.sh

download() {
	local target=$1
	local url=$2
	nonEmpty target url || return 1	

	local -i code=0
	if [ -f $target.lock ]; then
		echo"get failed: '$target.lock' exists" >&2
		return 1
	fi
	
	if [[ "$UPDATE" = "yes" ]] && [[ -f $target ]]; then
		echo "GET $url (update if newer)" >&2
		touch $target.lock
		curl -s -L -o $target -z $target $url || code=$?
		rm $target.lock
	elif [[ -f $target ]]; then
		echo "GET $url (cached)" >&2
	else
		touch $target.lock
		echo "GET $url" >&2
		curl -L -o $target $url || code=$?
		rm $target.lock
	fi
	[[ $code -eq 0 ]]
}

clone::_impl() {
  nonEmpty host provider REPO_DIR || return 1
  local repo=$1
  nonEmpty repo || return 1
  local group name
  read group name <<<$(echo $repo | tr '/' ' ')
  nonEmpty group name || return 1

  [[ ! -d "$REPO_DIR" ]] && mkdir -p "$REPO_DIR"

  source2::git::pull "$REPO_DIR/src/$provider/$group/$name" "$host/$group/$name"
}

clone::github() {
  local host="https://github.com"
  local provider="github.com"
  clone::_impl $1
}