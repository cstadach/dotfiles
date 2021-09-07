autoload -U add-zsh-hook
load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"
  local version_tf_path="versions.tf"
  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
  elif [ -f "$version_tf_path" ]; then
    tfswitch
  fi

}
add-zsh-hook chpwd load-tfswitch
load-tfswitch
