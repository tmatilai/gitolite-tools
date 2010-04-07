# Copyright (c) 2010 Teemu Matilainen
#
# Bash completion for gitolite-tools
# Requires completion script of git v1.7.1 or newer

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
		__gitcomp "$(__git_remotes)"
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
		__gitcomp "$(__git_remotes)"
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
			--grep=
			--creator= --no-creator --mine
			--wildcard --no-wildcard
			"
		;;
	*)
		__gitcomp "$(__git_remotes)"
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
		__gitcomp "$(__git_remotes)"
		;;
	esac
}
