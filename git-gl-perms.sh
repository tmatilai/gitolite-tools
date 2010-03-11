#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display or edit permissions of gitolite wildcard repositories.

GL_PATH_NEEDED=Yes
. git-gl-helpers

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-perms [--get] [<repository>]
git gl-perms --set[=<permission> | --file=<file>] [<repository>]
git gl-perms --add=<permission> [<repository>]
git gl-perms --edit [<repository>]
git gl-perms --delete [<repository>]
--
q,quiet           be quiet

  Actions
get!              display permissions (default)
set?!             set permissions (from stdin if not specified)
add?!             add permissions (from stdin if not specified)
edit!             edit permissions
delete!           remove permissions

  Options
F,file=!          set the permissions from the specified file

    <repository>       Git URL or remote name
"

. git-sh-setup

action= perms=
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
			*) perms="$2"; shift ;;
		esac
		;;
	-F|--file)
		test -z "$action" -o "$action" = "set" || usage
		action="set"
		perms=$(cat "$2") || exit $?
		shift
		;;
	--add)
		test -z "$action" || usage
		action="add"
		case "$2" in
			-*) ;;
			*) perms="$2"; shift ;;
		esac
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
	get)    gl_get_property "perms" ;;
	set)    gl_set_property "perms" "$perms";;
	edit)   gl_edit_property "perms" ;;
	delete) gl_delete_property "perms" ;;
	add)
		if test -z "$perms"; then
			perms=$(cat) || exit $?
		fi
		gl_edit_property "perms" "printf '%s\n' '$perms' >> "
		;;
esac
