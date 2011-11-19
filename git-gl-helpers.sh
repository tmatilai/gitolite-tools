#!/bin/sh
#
# Copyright (c) 2010-2011 Teemu Matilainen
#
# Helper routines for gitolite-tools

GL_HOST=
GL_PORT=
GL_PATH=

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
		url=$(git ls-remote --get-url "$remote" 2>/dev/null ||
			get_remote_url "$remote")
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
	if test -z "$GIT_QUIET"; then
		printf '+++ '
		test -n "$remote" -a "$remote" != "$url" &&
			printf '%s: ' "$remote"
		printf 'ssh://%s' "$GL_HOST"
		test -n "$GL_PORT" && printf ':%s' "$GL_PORT"
		test -n "$GL_PATH_NEEDED" && printf '/%s' "$GL_PATH"
		printf ' +++\n'
	fi >&2
}

gl_ssh_command() {
	test -n "$VERBOSE" && printf '+ %s\n' "$*" >&2
	ssh_args=
	test -n "$GL_PORT" && ssh_args="-p $GL_PORT"
	ssh "$GL_HOST" $ssh_args "$@"
}

gl_get_property() {
	name="$1"
	output="$2"
	test -n "$output" && exec >"$output"
	gl_ssh_command "get$name" "$GL_PATH"
}

gl_set_property() {
	name="$1"
	val="$2"
	if test -z "$val"; then
		test -z "$GIT_QUIET" &&
			printf 'Reading "%s" from stdin...\n' "$name" >&2
		val=$(cat) || exit $?
	fi
	test -n "$GIT_QUIET" && exec >/dev/null
	printf '%s\n' "$val" | gl_ssh_command "set$name" "$GL_PATH"
}

gl_edit_property() {
	name="$1"
	edit_function="$2"
	test -z "$edit_function" && edit_function="git_editor"
	set -e
	file=$(tempfile -s ".gl-$name")
	trap "rm -f '$file'" 0 1 2 3 15
	gl_ssh_command "get$name" "$GL_PATH" > "$file"
	test -n "$VERBOSE" &&
		printf 'Invoking "%s"\n' "$edit_function '$file'..." >&2
	eval "$edit_function" "'$file'"
	test -n "$GIT_QUIET" && exec >/dev/null
	test -s "$file" && gl_ssh_command "set$name" "$GL_PATH" < "$file"
}

gl_delete_property() {
	name="$1"
	test -n "$GIT_QUIET" && exec >/dev/null
	gl_ssh_command "set$name" "$GL_PATH" < /dev/null
}
