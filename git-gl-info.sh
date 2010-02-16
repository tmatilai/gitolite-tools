#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display gitolite server information

NONGIT_OK=Yes
OPTIONS_SPEC=
USAGE='[<server>]'
LONG_USAGE='    <server>     Host name, git URL or remote name'

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
