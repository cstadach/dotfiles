autoload -U add-zsh-hook
load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"
  if [ -f "$tfswitchrc_path" ]; then
    tfswitch -b $HOME/.local/bin/terraform
  fi
}
add-zsh-hook chpwd load-tfswitch
load-tfswitch
