#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display gitolite server information

NONGIT_OK=Yes
OPTIONS_SPEC=
USAGE='[<remote>]'
LONG_USAGE='git gl-info [<remote>]
        display remote server information

<remote>     Git URL or repository name'

. git-sh-setup
. git-gl-helpers

info() {
	resolve_remote "$1"
	gl_ssh_command info
}

case "$1" in
	-*) usage ;;
	*)  info  "$@" ;;
esac
