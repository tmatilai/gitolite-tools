#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Set password on gitolite server to be used with gitweb/apache.
# Requires that the functionality is enabled on the server.

. git-gl-helpers

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-htpasswd [--set[=<password>] | --file=<file>] [<server>]
--
q,quiet        be quiet
v,verbose      be verbose
set?!          set the password (from stdin if not specified)
F,file=!       set the password from the specified file

    <server>      Host name, git URL or remote name
"

. git-sh-setup

passwd=
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
	--set)
		case "$2" in
			-*) ;;
			*) passwd="$2"; shift ;;
		esac
		;;
	-F|--file)
		passwd=$(cat "$2") || exit $?
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
test -n "$GIT_QUIET" -o -z "$VERBOSE" -a -n "$passwd" && exec >/dev/null
if test -n "$passwd"; then
	printf '%s' "$passwd" | gl_ssh_command htpasswd
else
	gl_ssh_command htpasswd
fi
