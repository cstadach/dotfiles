tfswitch() {
	/opt/homebrew/bin/tfswitch -b $HOME/.local/bin/terraform $1
}

export TF_PLUGIN_CACHE_DIR=$HOME/.terraform
