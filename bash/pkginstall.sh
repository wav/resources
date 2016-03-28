source2 wav/bash/progress.sh

pkginstall::report-progress() {
  local line=;
  local next_phase=;
  local PHASE_PREFIX="installer:PHASE:"
  local PROGRESS_PREFIX="installer:%"
  PHASE="pkginstall"
  PROGRESS=0

  while read -es line; do
    if [[ "$line" =~ ^$PHASE_PREFIX ]]; then
      PHASE="${line:${#PHASE_PREFIX}}"
      progress pkginstall $PROGRESS 100 "$PHASE"
    elif [[ "$line" =~ ^$PROGRESS_PREFIX ]]; then
      PROGRESS="${line:${#PROGRESS_PREFIX}}"
      progress pkginstall $PROGRESS 100 "$PHASE"
    fi
  done
}

pkginstall() {
  mkdir -p .pkginstall
  local pkg="$@"
  if [ ! -r "$pkg" ]; then
    echo "pkginstall: $pkg is not readable"
    return 1
  fi
  local PHASE="pkginstall"
  local PROGRESS=0
  local LOG=".pkginstall/$(basename $pkg).log"
  echo "pkginstall: '$pkg' (log=./$LOG)"
  sudo installer -allowUntrusted -verboseR -pkg "$pkg" -target / -lang en 2>&1 | tee "$LOG" | pkginstall::report-progress
  local exitCode=$?
  echo
  if [ $exitCode -eq 0 ]; then
    echo pkginstall: 👍 👍
  else
    echo pkginstall: 😡 😡
    return $exitCode
  fi
}

pkginstall-many() {
  local dir=$1
  dir=${dir:=.}
  local pkg=;
  ls -1 $dir/*.pkg | while read -es pkg; do
    pkginstall $pkg
  done
}