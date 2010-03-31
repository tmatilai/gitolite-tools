#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# List accessible gitolite repositories with permissions
# by calling gitolite's "expand" command

. git-gl-helpers

NONGIT_OK=Yes
OPTIONS_SPEC="\
git gl-ls [options] [<server>]
--
q,quiet        be quiet
v,verbose      be verbose
o,output=!     write the description to the specified file

 Filter options
e,grep=!       list only repos that match the specified pattern
u,creator=!    list wildcard repos created by the specified user
creater=*!     synonym of creator for sitaram ;)
mine           list wildcard repos created by the user ($GL_USER)
wildcard       list (non-)wildcard repositories

    <server>      Host name, git URL or remote name
"

. git-sh-setup

output= pattern= creators= wildcard=
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
	-o|--output)
		output="$2"
		shift
		;;
	-e|--grep)
		pattern="$2"
		shift
		;;
	-u|--creator|--creater)
		creators="$creators ($2)"
		shift
		;;
	--mine)
		creators="$creators ($GL_USER)"
		;;
	--wildcard)
		wildcard=1
		;;
	--no-wildcard)
		creators="$creators <gitolite>"
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

filter=
if test -n "$wildcard"; then
	filter='$2 ~ /^\(.+\)$/ { print; next }'
fi
if test -n "$creators"; then
	filter="$filter"'
		BEGIN { split(c, creators, " ") }
		{ for (i in creators)
			if (creators[i] == $2) { print; next }
		}'
fi

test -n "$output" && exec >"$output"
if test -n "$filter"; then
	gl_ssh_command expand "$pattern" |
		awk -F'\t' -v c="$creators" "$filter"
else
	gl_ssh_command expand "$pattern"
fi
