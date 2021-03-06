# Description:  Use paths that are aliased in a `source2.conf` file.
# Author:       wav at github
#
# Usage: Define paths and git repos in a `source2.conf`
#        then source `source2.sh` in a script or environment
#
#   `source2 home/rc.sh` # source 'rc.sh' in the path 'home'
#
# Using `source2.sh` in your env:
#   1. Put `source2.sh` and source2.conf` in ~/.profile/
#   2. In your `.bash_profile` do:
#   ```
#   . ~/.profile/source2.sh
#   ```
# Requires: git-config

declare -rx SOURCE2_CONF=${SOURCE2_CONF:=$(pushd $(dirname $BASH_SOURCE)>/dev/null; pwd; popd>/dev/null)/source2.conf} &>/dev/null

source2::path() {
  if [[ ! "$1" =~ ^[a-z]+$ ]]; then
    echo "source2::path: invalid path name '$1'" >&2
    return 1
  fi
  local path=`git config --file "$SOURCE2_CONF" "paths.$1"`
  if [ $? -ne 0 ] || [ "$path" == "" ]; then
    echo "source2::path: path name not found '$1'" >&2
    return 1
  fi
  echo "$path" | sed 's|${HOME}|'$HOME'|g'
}
readonly -f source2::path

source2::script() {
  local name=${1%%/*}
  local path=`source2::path $name`
  [[ "$path" == "" ]] && return 1
  printf "$path/${1#*/}"
}
readonly -f source2::script

source2::scripts() {
  local s=
  for s in $@; do
    s=`source2::script "$s"`
    [[ "$s" == "" ]] && return 1
    echo "$s"
  done
}
readonly -f source2::scripts

source2::_keys() {
  git config --file "$SOURCE2_CONF" -l | grep ^$1 | sed -E "s|^$1\.([a-z]+).*$|\1|g"
}
readonly -f source2::_keys

# ? respository not found
# ! commit not found
# = commit matches
# c commit exists
# t is a tag
# b is a branch
source2::git::commitId() {
  [[ "$1" == "" ]] && return 1
  local path=$1
  local head=${2:=HEAD} # branch, tag or commit
  [[ "$path" == "" ]] && return 1
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
readonly -f source2::git::commitId

source2::git::pull() {
  ([[ "$1" == "" ]] || [[ "$2" == "" ]]) && return 1
  local path=$1
  local url=$2
  local remote=${url%#*}
  local head=HEAD # branch, tag or commit
  if [[ "$url" =~ '#' ]]; then
    head=${url#*#}
  fi
  local commitType commitId
  read commitType commitId <<<$(source2::git::commitId $path $head)

  local desc="$remote#$head"
  if [ "$commitType" == "!" ]; then
    echo "[pull] $desc"
    (cd "$path" && git pull origin master) || return 1
    read commitType commitId <<<$(source2::git::commitId $path $head)
  elif [ "$commitType" == "?" ]; then
    echo "[clone] $name: $remote#$head"
    [[ ! -d "$path" ]] && mkdir -p "$path"
    (cd "$path" && \
      git init && \
      git remote add origin "$remote" && \
      git pull origin master)
    local exitCode=$?
    if [ $exitCode -ne 0 ]; then
      rm -Rf "$path"
      return $exitCode
    fi
    read commitType commitId <<<$(source2::git::commitId $path $head) || return 1
  fi
  
  echo "[checkout $commitType] $desc"
  case "$commitType" in
    c) (cd $path; git checkout "$commitId") && return 0;;
    t) (cd $path; git checkout "$head") && return 0;;
    b) (cd $path; git checkout "$head") && return 0;;
  esac

  return 1
}
readonly -f source2::git::pull

source2::_pullById() {
  local path=`source2::path $1`
  [[ "$path" == "" ]] && return 1
  local url=`git config --file "$SOURCE2_CONF" repos.$1`
  [[ "$url" == "" ]] && return 1
  source2::git::pull "$path" "$url"
}
readonly -f source2::_pullById

source2::_pullAll() {  
  local repoNames=(`source2::_keys repos`)
  local pathNames=(`source2::_keys paths`)
  local missing=(`comm -23 <(echo ${repoNames[@]} | tr [:space:] '\\n' | sort) <(echo ${pathNames[@]} | tr [:space:] '\\n' | sort)`)
  if [ ${#missing[@]} -gt 0 ]; then
    echo "source2::pull: repos with missing path (${missing[@]})" >&2
    return 1
  fi
  local name
  # check the directories that we will clone to.
  for name in ${repoNames[@]}; do
    path=`source2::path $name`
    if [ -d "$path" ]; then
      if [ $(ls $path | wc -l) -gt 0 ] && [ ! -d "$path/.git" ]; then
        echo "source2::pull: non-empty directory is not a git repository ($path)" >&2
        return 1
      fi
    else
      source2::_pullById "$name" || return 1
    fi
  done
}
readonly -f source2::_pullAll

# tip: for this to work seamlessly, use keys for authentication.
source2::pull() {
  if [[ "$1" =~ ^--?[a-z]+$ ]]; then
    case `echo $1 | tr -d '-'` in
      a) source2::_pullAll || return 1;;
    esac
  elif [ "$1" != "" ]; then
    source2::_pullById "$1" || return 1
    return 0
  fi
  return 1
}
readonly -f source2::pull

source2::_confChanged() {
  local shaPath="$SOURCE2_CONF.shasum"
  local SHA=`shasum "$shaPath" | grep -oE "^[0-9a-z]+" >/dev/null`
  if [[ -f "$shaPath" ]]; then
    local oldSHA=`cat $shaPath`
    if [[ "$SHA" = "$oldSHA" ]]; then
      return 1;
    fi
  fi
  echo "$SHA" > "$shaPath"
}

source2::init() {
  source2::_confChanged && source2::pull -a
}

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