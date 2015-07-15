export REPO_DIR=$HOME/Repositories
export TEMPLATES_REPO=github/wav/resources
export TEMPLATES_PATH=templates

repo::pull() {
  declare -F "source2::git::pull" &>/dev/null || return 1
  ([[ ! -d "$REPO_DIR" ]] || [[ ${#@} -lt 1 ]]) && return 1
  local provider group name
  read provider group name <<<$(echo $1 | tr '/' ' ')
  ([[ "$provider" == "" ]] || [[ "$group" == "" ]] || [[ "$name" == "" ]]) || return 1
  local url=$2
  if [ "$provider" == "github" ]; then
    url=${url:="https://github.com/$1/$2"}
  fi
  source2::git::pull "$REPO_DIR/$provider/$group/$name" "$url"
}

repo::list() {
  [[ ! -d "$REPO_DIR" ]] && return 1
  local repo lsDir cdDir
  if [[ "$1" = "-f" ]]; then
    lsDir=$REPO_DIR/
  else
    cdDir=$REPO_DIR
  fi
  for repo in `cd $cdDir; ls -d $lsDir*/*/*/.git/`; do
    echo "${repo::-6}"
  done
}

repo::templates() {
  [[ ! -d "$REPO_DIR" ]] && return 1
  local list=(`repo::list`)
  local templateDir=$REPO_DIR/$TEMPLATES_REPO/$TEMPLATES_PATH
  if [[ -z "${list[$1]}" ]]; then
    repo::pull "$TEMPLATES_REPO" || return 1
  fi
  for repo in `cd $templateDir; ls -d */*/`; do
    echo "${repo::-1}"
  done
}

repo::copy-template() {
  ([[ "$1" == "" ]] || [[ "$2" == "" ]]) && return 1
  local template=`repo::templates | grep -oi $2`
  local templateDir=$REPO_DIR/$TEMPLATES_REPO/$TEMPLATES_PATH
  [[ "$template" == "" ]] && return 1
  if [ "$1" == "." ]; then
    cp -Rf $templateDir/$2/* .
  else
    mkdir -p "$1"
    cp -Rf $templateDir/$2/* $1/.
  fi
}