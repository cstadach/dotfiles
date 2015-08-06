#!/bin/zsh
#
# This script display a warning when Git stash contains more that one item
#

autoload -U colors && colors

GIT_STASH_LIST=`git stash list | wc -l | xargs`
if [[ $GIT_STASH_LIST != "0" && $GIT_STASH_LIST != "1" ]]; then
        echo $fg[red] "WARNING: You have $GIT_STASH_LIST stashes!"
        echo $reset_color
fi
