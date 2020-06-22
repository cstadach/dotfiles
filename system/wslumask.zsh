# https://github.com/microsoft/WSL/issues/352
grep --quiet Microsoft /proc/version 2>/dev/null && [[ "$(umask)" == '000' ]] && umask 022
