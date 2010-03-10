#!/bin/sh
#
# Copyright (c) 2010 Teemu Matilainen
#
# Helper routines for gitolite-tools

GL_HOST=
GL_PORT=22
GL_PATH=

# own gitolite username
test -n "$GL_USER" ||
	GL_USER=$(git config gitolite.username || echo "$USER")

is_git_repository() {
	git rev-parse --git-dir >/dev/null 2>&1
}

resolve_remote() {
	test -n "$GL_HOST" && return

	remote="$1"
	test -n "$remote" || remote=$(git config gitolite.remote)

	if is_git_repository; then
		. git-parse-remote
		test -n "$remote" || remote=$(get_default_remote)
		url=$(get_remote_url "$remote")
	elif test -z "$remote"; then
		url=$(git config gitolite.defaultRemote)
	else
		url="$remote"
	fi
	case "$url" in
		"")
			cat >&2 <<-_EOF
			fatal: Remote repository/host not specified

			Remote name, Git URL or SSH hostname should be given as a parameter.
			The default value can also be specified in git configuration variable
			"gitolite.remote" or (globally) "gitolite.defaultremote".
			_EOF
			exit 1
			;;
		*ssh*://*)
			tmp=${url#*://}
			GL_HOST=${tmp%%/*}
			case "$GL_HOST" in
			*:*)
				GL_PORT=${GL_HOST#*:}
				GL_HOST=${GL_HOST%%:*}
				;;
			esac
			case "$tmp" in
			*/*) GL_PATH=${tmp#*/} ;;
			esac
			;;
		*://*)
			die "fatal: Not an ssh protocol: '$url'"
			;;
		*:*)
			GL_HOST=${url%%:*}
			GL_PATH=${url#*:}
			;;
		*)
			GL_HOST=${url}
			;;
	esac
	test -n "$GL_HOST" || die "fatal: Invalid URL: '$url'"
	test -n "$GL_PATH_NEEDED" -a -z "$GL_PATH" && die "fatal: Invalid URL: '$url'"
}

gl_ssh_command() {
	test  -z "$GIT_QUIET" &&
		printf '+ ssh "%s" -p "%s" %s\n' "$GL_HOST" "$GL_PORT" "$*" >&2
	ssh "$GL_HOST" -p "$GL_PORT" "$@"
}
