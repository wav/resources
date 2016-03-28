source2 wav/bash/util.sh

# original @ https://github.com/twolfson/sexy-bash-prompt

git_info::get_branch() {
  # On branches, this will return the branch name
  # On non-branches, (no branch)
  local _REF="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
  if [[ $_REF != "" ]]; then
    echo $_REF
  else
    echo "(no branch)"
  fi
}

git_info::is_branch1_behind_branch2 () {
  # Find the first log (if any) that is in branch1 but not branch2
  local _FIRST_LOG="$(git log $1..$2 -1 2> /dev/null)"

  # Exit with 0 if there is a first log, 1 if there is not
  [[ -n $_FIRST_LOG ]]
}

git_info::branch_exists () {
  # List remote branches           | # Find our branch and exit with 0 or 1 if found/not found
  git branch --remote 2> /dev/null | grep --quiet "$1"
}

git_info::status::parse_ahead () {
  # Grab the local and remote branch
  local _BRANCH="$(git_info::get_branch)"
  local _REMOTE_BRANCH=origin/"$_BRANCH"

  # If the remote branch is behind the local branch
  # or it has not been merged into origin (remote branch doesn't exist)
  if (git_info::is_branch1_behind_branch2 "$_REMOTE_BRANCH" "$_BRANCH" ||
      ! git_info::branch_exists "$_REMOTE_BRANCH"); then
    # echo our character
    echo 1
  fi
}

git_info::status::parse_behind () {
  # Grab the branch
  local _BRANCH="$(git_info::get_branch)"
  local _REMOTE_BRANCH=origin/"$_BRANCH"

  # If the local branch is behind the remote branch
  if git_info::is_branch1_behind_branch2 "$_BRANCH" "$_REMOTE_BRANCH"; then
    # echo our character
    echo 1
  fi
}

git_info::status::parse_dirty () {
  # ?? file.txt # Unstaged new files
  # A  file.txt # Staged new files
  #  M file.txt # Unstaged modified files
  # M  file.txt # Staged modified files
  #  D file.txt # Unstaged deleted files
  # D  file.txt # Staged deleted files

  # If the git status has *any* changes (i.e. dirty)
  if [[ -n "$(git status --porcelain 2> /dev/null)" ]]; then
    # echo our character
    echo 1
  fi
}

git_info::status() {
  # Grab the git dirty and git behind
  local _DIRTY_BRANCH="$(git_info::status::parse_dirty)"
  local _BRANCH_AHEAD="$(git_info::status::parse_ahead)"
  local _BRANCH_BEHIND="$(git_info::status::parse_behind)"

  # Iterate through all the cases and if it matches, then echo
  if [[ $_DIRTY_BRANCH == 1 && $_BRANCH_AHEAD == 1 && $_BRANCH_BEHIND == 1 ]]; then
    echo " ✏️ *"
  elif [[ $_DIRTY_BRANCH == 1 && $_BRANCH_AHEAD == 1 ]]; then
    echo " ✏️ ➕ "
  elif [[ $_DIRTY_BRANCH == 1 && $_BRANCH_BEHIND == 1 ]]; then
    echo " ✏️ ➖" 
  elif [[ $_BRANCH_AHEAD == 1 && $_BRANCH_BEHIND == 1 ]]; then
    echo " *"
  elif [[ $_BRANCH_AHEAD == 1 ]]; then
    echo " ➕ "
  elif [[ $_BRANCH_BEHIND == 1 ]]; then
    echo " ➖ "
  elif [[ $_DIRTY_BRANCH == 1 ]]; then
    echo " ➕✏️ "
  fi
}

git_info () {
  local _BRANCH="$(git_info::get_branch)"
  local _REPO_DIR=`git rev-parse --show-toplevel`
  local _REPO_NAME="$(basename $_REPO_DIR)"
  local _REPO_REL_PATH="${PWD:${#_REPO_DIR}}"
  local _OUTPUT=;

  # If there are any branches
  if [[ $_BRANCH != "" ]]; then
    set-title $_REPO_NAME
    echo -en $"\\033[38;5;27m$_REPO_NAME\\033[0m $_BRANCH"$(git_info::status)" .$_REPO_REL_PATH"
  fi
}

PS1=$"\u:\$(is_git && echo -n \"\$(git_info)\" || echo -n \"\W\") ‼️  \\033[0m"