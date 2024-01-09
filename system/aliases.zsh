# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
case $( uname -s ) in
  Linux)
    alias ls="ls -Fh --color"
    alias l="ls -lA --color"
    alias ll="ls -l --color"
    alias la='ls -A --color'
    ;;
  Darwin)
    alias uuid="uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]'  | pbcopy && pbpaste && echo"
    if $(gls &>/dev/null)
    then
      alias ls="gls -Fh --color"
      alias l="ls -lAh --color"
      alias ll="ls -l --color"
      alias la='ls -A --color'
    fi
    alias tar="gtar"
    ;;
  esac

    if $(bat -h &>/dev/null)
    then
      alias cat=bat
    fi
