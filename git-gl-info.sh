#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display gitolite server information

. git-gl-helpers

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-info [options] [<server>]
--
q,quiet        be quiet
v,verbose      be verbose
u,user=!       display info for the specied user (needs gitolite-admin access)

    <server>      Host name, git URL or remote name
"

. git-sh-setup

users=
while test $# != 0; do
	case "$1" in
	-q|--quiet)
		GIT_QUIET=1
		VERBOSE=
		;;
	--no-quiet)
		GIT_QUIET=
		;;
	-v|--verbose)
		GIT_QUIET=
		VERBOSE=1
		;;
	--no-verbose)
		VERBOSE=
		;;
	-u|--user)
		users="$users $2"
		shift
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
gl_ssh_command info $users
