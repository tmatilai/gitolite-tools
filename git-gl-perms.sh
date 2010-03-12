#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display or edit permissions of gitolite wildcard repositories.

GL_PATH_NEEDED=Yes
. git-gl-helpers

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-perms [--get] [--output=<file>] [<repository>]
git gl-perms --set[=<permission> | --file=<file>] [<repository>]
git gl-perms --add=<permission> [<repository>]
git gl-perms --edit [<repository>]
git gl-perms --delete [<repository>]
--
q,quiet           be quiet
v,verbose         be verbose

  Actions
get!              display permissions (default)
set?!             set permissions (from stdin if not specified)
add?!             add permissions (from stdin if not specified)
edit!             edit permissions
delete!           remove permissions

  Options
o,output=!        write the permissions to the specified file
F,file=!          set the permissions from the specified file

    <repository>       Git URL or remote name
"

. git-sh-setup

action= perms= output=
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
	--get)
		test -z "$action" -o "$action" = "get" || usage
		action="get"
		;;
	-o|--output)
		test -z "$action" -o "$action" = "get" || usage
		action="get"
		output="$2"
		shift
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
	--edit|--delete)
		test -z "$action" || usage
		action=${1#--}
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
	get)    gl_get_property "perms" "$output" ;;
	set)    gl_set_property "perms" "$perms" ;;
	edit)   gl_edit_property "perms" ;;
	delete) gl_delete_property "perms" ;;
	add)
		if test -z "$perms"; then
			test -z "$GIT_QUIET" &&
				printf 'Reading "perms" from stdin...\n' >&2
			perms=$(cat) || exit $?
		fi
		gl_edit_property "perms" "printf '%s\n' '$perms' >> "
		;;
esac
