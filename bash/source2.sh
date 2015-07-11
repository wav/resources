# Description:  Use paths that are aliased in a `source2.conf` file.
# Author:       wav at github
#
# Usage: Define paths, collections and git repos in a `source2.conf`
#        then source `source2.sh` in a script or environment
#
#   `source2 home/rc.sh` # source 'rc.sh' in the path 'home'
#   `source2 []init`     # source all scripts defined in the collection 'init'
#
# Using `source2.sh` in your env:
#   1. Put `source2.sh` and source2.conf` in ~/.profile/
#   2. In your `.bash_profile` do:
#   ```
#   . ~/.profile/source2.sh
#   source2 []init
#   ```
# Requires: git-config

declare -rx SOURCE2_CONF=$(pushd $(dirname $BASH_SOURCE)>/dev/null; pwd; popd>/dev/null)/source2.conf 2>/dev/null

source2::path() {
  if [[ ! "$1" =~ ^[a-z]+$ ]]; then
    echo "source2::path: invalid path name '$1'" >&2
    return 1
  fi
  local path=`git config --file "$SOURCE2_CONF" "paths.$1"`
  if [ $? -ne 0 ]; then
    echo "source2::path: path name not found '$1'" >&2
    return 1
  fi
  echo "$path" | sed 's|${HOME}|'$HOME'|g'
}
readonly -f source2::path

source2::script() {
  local name=${1%%/*}
  local path=`source2::path $name` || return 1
  printf "$path/${1#*/}"
}
readonly -f source2::script

source2::collection() {
  if [[ ! "$1" =~ ^'[]'[a-z]+$ ]]; then
    echo "source2::collection: invalid collection '$1'" >&2
    return 1
  fi
  local s=`echo $1 | tr -d '[]'`
  local sources=(`git config --file "$SOURCE2_CONF" --get-all "collection.$s.script"`) || return 1
  for s in ${sources[@]}; do
    s=`source2::script "$s"` || return 1
    echo "$s"
  done
}
readonly -f source2::collection

source2::scripts() {
  local s=
  for s in $@; do
    if [ `echo $s | cut -c 1-2` == "[]" ]; then
      source2::collection "$s" || return 1
    else
      s=`source2::script "$s"` || return 1
      echo "$s"
    fi
  done
}
readonly -f source2::scripts

source2::_keys() {
  git config --file "$SOURCE2_CONF" -l | grep ^$1 | sed -E "s|^$1\.([a-z]+).*$|\1|g"
}

source2::pull() {
  local repoNames=(`source2::_keys repos`)
  local pathNames=(`source2::_keys paths`)
  local missing=(`comm -23 <(echo ${repoNames[@]} | tr [:space:] '\\n' | sort) <(echo ${pathNames[@]} | tr [:space:] '\\n' | sort)`)
  if [ ${#missing[@]} -gt 0 ]; then
    echo "source2::pull: repos with missing path (${missing[@]})" >&2
    return 1
  fi
  # check the directories that we will clone to.
  local n=
  local path=
  for n in ${repoNames[@]}; do
    path=`source2::path $n`
    if [ -d "$path" ]; then
      if [ $(ls $path | wc -l) -gt 0 ] && [ ! -d "$path/.git" ]; then
        echo "source2::pull: non-empty directory is not a git repository ($path)" >&2
        return 1
      fi
    fi
  done
  # clone ..
  local remote=
  local head= # branch, tag or commit
  for n in ${repoNames[@]}; do
    path=`source2::path $n`
    remote=`git config --file "$SOURCE2_CONF" repos.$n` || return 1
    head=${remote#*#}
    remote=${remote%#*}
    echo "Updating $n: $remote#$head"
    if [ -d "$path/.git" ]; then
      (cd "$path" && git pull origin master) || return 1
    else
      ([[ ! -d "$path" ]] && mkdir -p "$path")
      (cd "$path" && \
        git init && \
        git remote add origin "$remote" && \
        git pull origin master) || return 1
    fi
    if [ "$head" != "" ]; then
      git checkout --detach "$head"
    fi
  done
}
readonly -f source2::pull

# TODO: 
#   - detect stack overflow.
source2() {
  local sources=(`source2::scripts $@`) || return 1
  local s=
  for s in ${sources[@]}; do
    . "$s"
  done
}
readonly -f source2
export -f source2