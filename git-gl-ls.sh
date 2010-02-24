#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# List accessible gitolite repositories with permissions
# by calling gitolite's "expand" command

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-ls [-q] [--grep=<pattern>] [<server>]
--
e,grep=       list only repos that match the specified pattern
q,quiet       be quiet

    <server>      Host name, git URL or remote name
"

. git-sh-setup
. git-gl-helpers

pattern=
while test $# != 0; do
	case "$1" in
	-e)
		pattern="$2"
		shift
		;;
	-q)
		GIT_QUIET=1
		;;
	--)
		shift
		break
		;;
	*)
		usage
		;;
	esac
	shift
done
test "$#" -le 1 || usage

resolve_remote "$1"
gl_ssh_command expand "$pattern"
