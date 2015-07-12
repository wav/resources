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

# ? respository not found
# ! commit not found
# = commit matches
# c commit exists
# t is a tag
# b is a branch
source2::_commit() {
  local head=$2 # branch, tag or commit
  local path=`source2::path $1` || return 1
  if [ ! -d "$path/.git" ]; then
    echo "? $head" && return 0
  fi
  local commitId=`cd $path; git rev-parse --quiet --verify $head`
  if [ $? -ne 0 ]; then
    echo "! $head" && return 0
  fi
  [[ "$commitId" == "$head" ]] && echo "= $head" && return 0

  list=(`cd $path; git tag -l --points-at $commitId`)
  [[ ! -z "${list[$head]}" ]] && echo t "$commitId" && return 0

  list=(`cd $path; git branch -l | grep -vE "\*?\s+\(.*\)$" | cut -c 3-`) # filter out detached
  [[ ! -z "${list[$head]}" ]] && echo b "$commitId" && return 0

  echo "c $commitId"    
}

# tip: for this to work seamlessly, use keys for authentication.
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

  # clone
  local remote=
  local head= # branch, tag or commit
  local commitType=
  local commitId=
  local desc
  readCommmit() {
    local res=`source2::_commit $n $head` || return 1
    commitType=`echo $res | cut -c 1-1`
    commitId=`echo $res | cut -c 3-`
    return 0
  }

  for n in ${repoNames[@]}; do
    path=`source2::path $n`
    res=`git config --file "$SOURCE2_CONF" repos.$n` || return 1
    head=${res#*#}
    remote=${res%#*}
    readCommmit || return 1
    desc="$n: $remote#$head"

    if [ "$commitType" == "!" ]; then
      echo "[pull] $desc"
      (cd "$path" && git pull origin master) || return 1
      readCommmit || return 1
    elif [ "$commitType" == "?" ]; then
      echo "[clone] $n: $remote#$head"
      [[ ! -d "$path" ]] && mkdir -p "$path"
      (cd "$path" && \
        git init && \
        git remote add origin "$remote" && \
        git pull origin master) || return 1
      readCommmit || return 1
    fi
    
    echo "[checkout $commitType] $desc"
    case "$commitType" in
      c) (cd $path; git checkout "$commitId") && return 0;;
      t) (cd $path; git checkout "$head") && return 0;;
      b) (cd $path; git checkout "$head") && return 0;;
    esac

    return 1
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