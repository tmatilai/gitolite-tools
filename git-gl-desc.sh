#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display or edit description of gitolite wildcard repositories.

NONGIT_OK=Yes
OPTIONS_SPEC=
USAGE='(get | set | edit) [<repository>]'
LONG_USAGE='git gl-desc get [<repository>]
        display description

git gl-desc set [<repository>]
        set description from stdin

git gl-desc edir [<repository>]
        edit description

<repository>   Git URL or remote name'

. git-sh-setup

GL_PATH_NEEDED=Yes
. git-gl-helpers

getdesc() {
	resolve_remote "$1"
	gl_ssh_command getdesc "$GL_PATH"
}

setdesc() {
	resolve_remote "$1"
	gl_ssh_command setdesc "$GL_PATH"


}

editdesc() {
	resolve_remote "$1"
	set -e
	desc=$(tempfile -s .gl-desc)
	trap "rm -f '$desc'" 0 1 2 3 15
	getdesc > "$desc"
	git_editor "$desc"
	test -s "$desc" && setdesc < "$desc"
}

test "$#" -eq 0 && usage
cmd="$1"
shift
case "$cmd" in
	help) git gl-desc -h ;;
	get)  getdesc  "$@" ;;
	set)  setdesc  "$@" ;;
	edit) editdesc "$@" ;;
	*)    usage ;;
esac
