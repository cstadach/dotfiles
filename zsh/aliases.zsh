#################################################################################
# start and stop the vpn from the command line from now on with these two commands
# or rename the aliases as you see fit.
# https://gist.github.com/Andrewpk/7558715
#################################################################################
alias startpulsevpn="sudo launchctl load -w /Library/LaunchDaemons/net.juniper.AccessService.plist; open -a '/Applications/Junos Pulse.app/Contents/Plugins/JamUI/PulseTray.app/Contents/MacOS/PulseTray'"
alias quitpulsevpn="osascript -e 'tell application \"PulseTray.app\" to quit';sudo launchctl unload -w /Library/LaunchDaemons/net.juniper.AccessService.plist"

alias reload!='. ~/.zshrc'
