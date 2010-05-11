# Copyright (c) 2010 Teemu Matilainen
#
# Bash completion for gitolite-tools
# Requires completion script of git v1.7.1 or newer

__git_complete_gl_remote ()
{
	local opts=
	if declare -F _known_hosts >/dev/null; then
		[ "$1" = "-c" ] && opts="-c"
		_known_hosts -a $opts
	else
		[ "$1" = "-c" ] && opts="-S ':'"
		COMPREPLY=( $(compgen -A hostname $opts -- $cur) )
	fi
	COMPREPLY=( "${COMPREPLY[@]}" $(compgen -W "$(__git_remotes)" -- $cur) )
}

# __git_gl_repos <remote> <path> <gl-ls params>
__git_gl_repos ()
{
	local remote="$1" path="$2"
	shift 2
	git --git-dir="$(__gitdir)" gl-ls --quiet --path-only --grep "^$path" "$@" \
		-- "$remote" 2>/dev/null
}

_git_gl_desc ()
{
	local cur=${COMP_WORDS[COMP_CWORD]}
	declare -F _get_cword >/dev/null && cur=$(_get_cword :)
	local pfx= remote= path=
	case "$cur" in
	--*)
		__gitcomp "
			--quiet --verbose
			--get --output=
			--set --set= --file=
			--add --add=
			--edit
			--delete
			"
		return
		;;
	?*:*)
		remote=${cur%%:*}
		path=${cur#*:}
		pfx="$remote"
		;;
	:)
		remote=${COMP_WORDS[COMP_CWORD-1]}
		;;
	*)
		local prev=${COMP_WORDS[COMP_CWORD-1]}
		if [ "$prev" = ":" ]; then
			remote=${COMP_WORDS[COMP_CWORD-2]}
			path="$cur"
		fi
		;;
	esac
	if [ -n "$remote" ]; then
		__gitcomp "$(__git_gl_repos "$remote" "$path")" "$pfx" "$path"
	else
		__git_complete_gl_remote -c
	fi
}

_git_gl_htpasswd ()
{
	case "${COMP_WORDS[COMP_CWORD]}" in
	--*)
		__gitcomp "
			--quiet --verbose
			--set --set= --file=
			"
		;;
	*)
		__git_complete_gl_remote
		;;
	esac
}

_git_gl_info ()
{
	case "${COMP_WORDS[COMP_CWORD]}" in
	--*)
		__gitcomp "
			--quiet --verbose
			--output=
			--user=
			"
		;;
	*)
		__git_complete_gl_remote
		;;
	esac
}

_git_gl_ls ()
{
	case "${COMP_WORDS[COMP_CWORD]}" in
	--*)
		__gitcomp "
			--quiet --verbose
			--output=
			--path-only
			--grep=
			--creator= --mine
			--wildcard --no-wildcard
			"
		;;
	*)
		__git_complete_gl_remote
		;;
	esac
}

_git_gl_perms ()
{
	local cur=${COMP_WORDS[COMP_CWORD]}
	declare -F _get_cword >/dev/null && cur=$(_get_cword :)
	local pfx= remote= path=
	case "$cur" in
	--*)
		__gitcomp "
			--quiet --verbose
			--get --output=
			--set --set= --file=
			--edit
			--delete
			"
		return
		;;
	?*:*)
		remote=${cur%%:*}
		path=${cur#*:}
		pfx="$remote"
		;;
	:)
		remote=${COMP_WORDS[COMP_CWORD-1]}
		;;
	*)
		local prev=${COMP_WORDS[COMP_CWORD-1]}
		if [ "$prev" = ":" ]; then
			remote=${COMP_WORDS[COMP_CWORD-2]}
			path="$cur"
		fi
		;;
	esac
	if [ -n "$remote" ]; then
		__gitcomp "$(__git_gl_repos "$remote" "$path" --mine)" "$pfx" "$path"
	else
		__git_complete_gl_remote -c
	fi
}
