# Copyright (c) 2010 Teemu Matilainen
#
# Bash completion for gitolite-tools
# Requires completion script of git v1.7.1 or newer
#
# Set GIT_GL_COMPLETE_REPOS to "0" to disable completion of remote
# repository paths.  It uses git gl-ls, which can be slow and error
# prone in some cases.


# Complete known ssh hosts and git remote names
# Usage: __git_complete_gl_remote_name [-c] <cur>
__git_complete_gl_remote_name ()
{
	local opts=
	if [ "$1" = "-c" ]; then
		opts="-c"
		shift
	fi
	local cur="$1"
	[ "$cur" == -* ] && return

	if declare -F _known_hosts_real >/dev/null; then
		_known_hosts_real -a $opts "$cur"
	elif declare -F _known_hosts >/dev/null; then
		_known_hosts -a $opts
	else
		[ "$1" = "-c" ] && opts="-S ':'"
		COMPREPLY=( $(compgen -A hostname $opts -- $cur) )
	fi
	COMPREPLY=( "${COMPREPLY[@]}" $(compgen -W "$(__git_remotes)" -- $cur) )
}

# Complete git URI
# __git_complete_gl_remote_uri [<gl-ls params>]
__git_complete_gl_remote_uri ()
{
	local cur=${COMP_WORDS[COMP_CWORD]}
	declare -F _get_cword >/dev/null && cur=$(_get_cword :)
	local pfx= remote= path=
	case "$cur" in
	-*)
		return
		;;
	?*:*)
		remote=${cur%%:*}
		path=${cur#*:}
		;;
	:)
		[ ${#COMP_WORDS[@]} -ge 4 ] || return 0
		remote=${COMP_WORDS[COMP_CWORD-1]}
		;;
	*)
		if [ ${#COMP_WORDS[@]} -ge 5 ] &&
				[ "${COMP_WORDS[COMP_CWORD-1]}" = ":" ]; then
			remote=${COMP_WORDS[COMP_CWORD-2]}
			path="$cur"
		fi
		;;
	esac
	if [ -n "$remote" ]; then
		__gitcomp "$(__git_gl_repos "$remote" "$path" "$@")" "$pfx" "$path"
	else
		__git_complete_gl_remote_name -c "$cur"
	fi
}

# Get repository paths from the specified remote
# Usage: __git_gl_repos <remote> <path> [<gl-ls params>]
__git_gl_repos ()
{
	[ "$GIT_GL_COMPLETE_REPOS" = 0 ] && return

	local remote="$1" path="$2"
	shift 2
	git --git-dir="$(__gitdir)" gl-ls --quiet --path-only --grep "^$path" "$@" \
		-- "$remote" 2>/dev/null
}


_git_gl_desc ()
{
	case "${COMP_WORDS[COMP_CWORD]}" in
	--*)
		__gitcomp "
			--quiet --verbose
			--get --output=
			--set --set= --file=
			--add --add=
			--edit
			--delete
			"
		;;
	*)
		__git_complete_gl_remote_uri --mine
		;;
	esac
}

_git_gl_htpasswd ()
{
	local cur=${COMP_WORDS[COMP_CWORD]}
	case "$cur" in
	--*)
		__gitcomp "
			--quiet --verbose
			--set --set= --file=
			"
		;;
	*)
		__git_complete_gl_remote_name "$cur"
		;;
	esac
}

_git_gl_info ()
{
	local cur=${COMP_WORDS[COMP_CWORD]}
	case "$cur" in
	--*)
		__gitcomp "
			--quiet --verbose
			--output=
			--user=
			"
		;;
	*)
		__git_complete_gl_remote_name "$cur"
		;;
	esac
}

_git_gl_ls ()
{
	local cur=${COMP_WORDS[COMP_CWORD]}
	case "$cur" in
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
		__git_complete_gl_remote_name "$cur"
		;;
	esac
}

_git_gl_perms ()
{
	case "${COMP_WORDS[COMP_CWORD]}" in
	--*)
		__gitcomp "
			--quiet --verbose
			--get --output=
			--set --set= --file=
			--edit
			--delete
			"
		;;
	*)
		__git_complete_gl_remote_uri --mine
		;;
	esac
}
