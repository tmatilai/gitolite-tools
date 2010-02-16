#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display or edit permissions of gitolite wildcard repositories.

NONGIT_OK=Yes
OPTIONS_SPEC=
USAGE='(get | set | edit) [<repository>]'
LONG_USAGE='git gl-perms get [<repository>]
        display permissions

git gl-perms set [<repository>]
        set permissions from stdin

git gl-perms edir [<repository>]
        edit permissions

<repository>   Git URL or remote name'

. git-sh-setup

GL_PATH_NEEDED=Yes
. git-gl-helpers

getperms() {
	resolve_remote "$1"
	gl_ssh_command getperms "$GL_PATH"
}

setperms() {
	resolve_remote "$1"
	gl_ssh_command setperms "$GL_PATH"


}

editperms() {
	resolve_remote "$1"
	set -e
	perms=$(tempfile -s .gl-perms)
	trap "rm -f '$perms'" 0 1 2 3 15
	getperms > "$perms"
	git_editor "$perms"
	test -s "$perms" && setperms < "$perms"
}

test "$#" -eq 0 && usage
cmd="$1"
shift
case "$cmd" in
	help) git gl-perms -h ;;
	get)  getperms  "$@" ;;
	set)  setperms  "$@" ;;
	edit) editperms "$@" ;;
	*)    usage ;;
esac
