#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display or edit description of gitolite wildcard repositories.

GL_PATH_NEEDED=Yes
. git-gl-helpers

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-desc [--get] [<repository>]
git gl-desc --set[=<description> | --file=<file>] [<repository>]
git gl-desc --edit [<repository>]
git gl-desc --delete [<repository>]
--
q,quiet           be quiet

  Actions
get!              display description (default)
set?!             set description (from stdin if not specified)
edit!             edit description
delete!           remove description

  Options
F,file=!          set the description from the specified file

    <repository>       Git URL or remote name
"

. git-sh-setup

action= desc=
while test $# != 0; do
	case "$1" in
	-q|--quiet)
		GIT_QUIET=1
		;;
	--no-quiet)
		GIT_QUIET=
		;;
	--get|--edit|--delete)
		test -z "$action" || usage
		action=${1#--}
		;;
	--set)
		test -z "$action" -o "$action" = "set" || usage
		action="set"
		case "$2" in
			-*) ;;
			*) desc="$2"; shift ;;
		esac
		;;
	-F|--file)
		test -z "$action" -o "$action" = "set" || usage
		action="set"
		desc=$(cat "$2") || exit $?
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
test -n "$action" || action="get"

resolve_remote "$1"

case "$action" in
get)
	gl_ssh_command getdesc "$GL_PATH"
	;;
set)
	if test -z "$desc"; then
		desc=$(cat) || exit $?
	fi
	test -n "$GIT_QUIET" && exec >/dev/null
	printf '%s\n' "$desc" | gl_ssh_command setdesc "$GL_PATH"
	;;
edit)
	set -e
	desc_file=$(tempfile -s .gl-desc)
	trap "rm -f '$desc_file'" 0 1 2 3 15
	gl_ssh_command getdesc "$GL_PATH" > "$desc_file"
	git_editor "$desc_file"
	test -n "$GIT_QUIET" && exec >/dev/null
	test -s "$desc_file" && gl_ssh_command setdesc "$GL_PATH" < "$desc_file"
	;;
delete)
	test -n "$GIT_QUIET" && exec >/dev/null
	gl_ssh_command setdesc "$GL_PATH" < /dev/null
	;;
esac
