# Copyright (c) 2010 Teemu Matilainen
#
# Bash completion for gitolite-tools
#
# For git versions older than 1.7.1 this should be processed _after_ the
# git completion script (contrib/completion/git-completion.bash in git
# source tree) as "_git" completion function is overridden to support
# external git commands.
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

# Temporary function to compare version number strings
# Usage: cmp_versions <version1> <version2>
# Returns:
#  99 if version1 < version2
# 100 if version1 == version2
# 101 if version1 > version2
__git_cmp_versions ()
{
	local v1=$( tr '.' ' ' <<<"$1" )
	local v2=$( tr '.' ' ' <<<"$2" )
	local max1=${#v1[@]} max2=${#v2[@]}
	local i a1 a2
	for (( i=0; i<max1 || i<max2; i++ )); do
		a1=${v1[i]} a2=${v2[i]}
		for op in '-lt' '<'; do
			[ "$a1" "$op" "$a2" ] && return 99
			[ $? = 1 ] && [ "$a2" "$op" "$a1" ] && return 101
		done 2>/dev/null
	done
	return 100
}

# Override _git completion function for git version < 1.7.1
# to support external git commands.
__git_version="$(git --version | sed -ne 's/^git version //p')"
__git_cmp_versions "$__git_version" "1.7.1"
[ $? -lt 100 ] &&
_git ()
{
	local i c=1 command __git_dir

	while [ $c -lt $COMP_CWORD ]; do
		i="${COMP_WORDS[c]}"
		case "$i" in
		--git-dir=*) __git_dir="${i#--git-dir=}" ;;
		--bare)      __git_dir="." ;;
		--version|-p|--paginate) ;;
		--help) command="help"; break ;;
		*) command="$i"; break ;;
		esac
		c=$((++c))
	done

	if [ -z "$command" ]; then
		case "${COMP_WORDS[COMP_CWORD]}" in
		--*)   __gitcomp "
			--paginate
			--no-pager
			--git-dir=
			--bare
			--version
			--exec-path
			--html-path
			--work-tree=
			--help
			"
			;;
		*)
			if declare -F __git_compute_porcelain_commands >/dev/null; then
				__git_compute_porcelain_commands
				__gitcomp "$__git_porcelain_commands $(__git_aliases)"
			elif declare -F __git_porcelain_commands >/dev/null; then
				__gitcomp "$(__git_porcelain_commands) $(__git_aliases)"
			else
				__gitcomp "$(__git_commands) $(__git_aliases)"
			fi
			;;
		esac
		return
	fi

	local completion_func="_git_${command//-/_}"
	declare -F $completion_func >/dev/null && $completion_func && return

	local expansion=$(__git_aliased_command "$command")
	if [ -n "$expansion" ]; then
		completion_func="_git_${expansion//-/_}"
		declare -F $completion_func >/dev/null && $completion_func
	fi
}

unset -f __git_cmp_versions
