#!/bin/bash

## Add additional tasks here or in `project/__main__.py`
DEFAULT_PROJECT=BlogService.Data

task.restore() {
    task.clean
    task.link
    wd=`pwd`
    for d in `task.projects`; do
        cd $d
        dnu restore && \
        dnu pack && \
        [ $? -ne 0 ] && echo "restore [failed]" && exit 1
        cd $wd
    done
    python -m project updateReferences
    [ $? -ne 0 ] && echo "restore [failed]" && exit 1
    return 0 
}

task.projects() {
    python -m project projects
}

task.link() {
    wd=`pwd`
    for d in `task.projects`; do
        cd $d
        ln -fs ~/.dnx/packages .
        cd $wd
    done
}

task.clean() {
    for d in `task.projects`; do
        rm -Rf $d/{bin,obj}
    done
}

task.run() {
    wd=`pwd`
    for d in `task.projects`; do
        cd $d
        dnu publish
        cd $wd
    done
    local program=$1
    if [ "$program" = "" ]; then
        program=$DEFAULT_PROJECT
    fi
    cd $program
    dnx . run
}

__TASK__=$1
shift 1
declare -f task.${__TASK__} 1> /dev/null
if [ $? -eq 0 ]; then
    task.${__TASK__} $@
elif [ "${__TASK__}" == "" ]; then
	echo "Usage:   ./project.sh TASK [ARGS]"
    echo "Example: ./project.sh projects"
else
    python -m project ${__TASK__} $@
fi
