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
path-only      list only repository paths, no ACLs etc.

 Filter options
e,grep=!       list only repos that match the specified pattern
u,creator=!    list wildcard repos created by the specified user
creater=*!     synonym of creator for sitaram ;)
mine!          list wildcard repos created by you
wildcard       list (non-)wildcard repositories

    <server>      Host name, git URL or remote name
"

. git-sh-setup

output= path_only= pattern= creators= mine= wildcard=
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
	--path-only)
		path_only=1
		;;
	--no-path-only)
		path_only=
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
		mine=1
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
	filter="$filter"'
		$2 ~ /^\(.+\)$/ { gl_print(); next }'
fi
if test -n "$creators" -o -n "$mine"; then
	filter="$filter"'
		BEGIN { split(c, creators, " ") }
		{ for (i in creators)
			if (creators[i] == $2) { gl_print(); next }
		}'
	if test -n "$mine"; then
		filter="$filter"'
			NR == 1 {
				split($0, tmp, /[ ,]*/)
				if (tmp[1] ~ /^hello$/) { u=tmp[2]; creators[u]="("u")" }
			}'
	fi
fi
if test -z "$filter"; then
	filter='NR > 2 { gl_print() }'
fi
if test -z "$GIT_QUIET"; then
	filter="$filter"'
		NR <= 2 { gl_print(); next }'
fi
if test -n "$path_only"; then
	filter="$filter"'
		function gl_print() { print $3 }'
else
	filter="$filter"'
		function gl_print() { print }'
fi

test -n "$output" && exec >"$output"
gl_ssh_command expand "$pattern" |
	awk -F'\t' -v c="$creators" "$filter"
