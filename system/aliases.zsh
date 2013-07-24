# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
case $( uname -s ) in
  Linux)
    alias ls="ls -F --color"
    alias l="ls -lAh --color"
    alias ll="ls -l --color"
    alias la='ls -A --color'
    ;;
  Darwin)
    if $(gls &>/dev/null)
    then
      alias ls="gls -F --color"
      alias l="gls -lAh --color"
      alias ll="gls -l --color"
      alias la='gls -A --color'
    fi
    ;;
  esac
