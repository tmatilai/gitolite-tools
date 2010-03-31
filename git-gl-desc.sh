#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Display or edit description of gitolite wildcard repositories.

GL_PATH_NEEDED=Yes
. git-gl-helpers

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-desc [--get] [--output=<file>] [<repository>]
git gl-desc --set[=<description> | --file=<file>] [<repository>]
git gl-desc --edit [<repository>]
git gl-desc --delete [<repository>]
--
q,quiet           be quiet
v,verbose         be verbose

  Actions
get!              display description (default)
set?!             set description (from stdin if not specified)
edit!             edit description
delete!           remove description

  Options
o,output=!        write the description to the specified file
F,file=!          set the description from the specified file

    <repository>       Git URL or remote name
"

. git-sh-setup

action= desc= output=
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
			*) desc="$2"; shift ;;
		esac
		;;
	-F|--file)
		test -z "$action" -o "$action" = "set" || usage
		action="set"
		desc=$(cat "$2") || exit $?
		shift
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
	get)    gl_get_property "desc" "$output" ;;
	set)    gl_set_property "desc" "$desc" ;;
	edit)   gl_edit_property "desc" ;;
	delete) gl_delete_property "desc" ;;
esac
