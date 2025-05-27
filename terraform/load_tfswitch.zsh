autoload -U add-zsh-hook
load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"
  local version_tf_path="version.tf"
  local versions_tf_path="versions.tf"
  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
  elif [ -f "$version_tf_path" ]; then
    tfswitch
  elif [ -f "$versions_tf_path" ]; then
    tfswitch
  else
    tfswitch 1.11.1 >/dev/null 2>&1
  fi
  export TG_TF_PATH=`which terraform`
}
add-zsh-hook chpwd load-tfswitch
load-tfswitch
