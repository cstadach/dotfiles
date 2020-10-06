# Only set this if we haven't set $EDITOR up somewhere else previously.
if [[ "$EDITOR" == "" ]] ; then
  # Use vim for my editor.
  export EDITOR='vim'
fi
# add display for wsl 2
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  export DISPLAY=$(ip route | awk '{print $3; exit}'):0
  export LIBGL_ALWAYS_INDIRECT=1
fi
