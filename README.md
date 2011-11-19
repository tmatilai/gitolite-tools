gitolite-tools
==============

Description
-----------

Collection of tools to work with [gitolite][] repositories.

* git gl-info - Display [gitolite][] server information
* git gl-ls - List accessible [gitolite][] repositories
* git gl-desc - Display or edit description of
  [gitolite wildcard repositories][wildrepos]
* git gl-perms - Display or edit permissions of
  [gitolite wildcard repositories][wildrepos]
* git gl-htpasswd - Set password for gitweb/apache

Installation
------------

### Debian and Ubuntu Package

The same package should work for all relatively recent Debian and Ubuntu
versions. Ubuntu PPA repository can be found [here][ppa] and the
individual packages [here][downloads].

### Manual

By default, the programs will be installed to "`git --exec-path`".
Just call:

	make && sudo make install

If git is installed to your home directory, `sudo` is not needed.

Installation directory can also be specified by setting `gitexecdir`, e.g.:

	make gitexecdir=$HOME/gitexec install

This can be useful if you can't or don't want to mess with the git
installation. gitolite-tools can then be used by setting `GIT_EXEC_PATH`.
For example:

	GIT_EXEC_PATH="$HOME/gitexec:$(git --exec-path)"

Other useful overridable Make variables are:

* `SHELL_PATH` (default: /bin/sh)
* `AWK_PATH`  (default: gawk)
* `INSTALL` (default: install)

Search more from the Makefile.

Copyright
---------

Copyright (c) 2010-2011 Teemu Matilainen <teemu.matilainen@iki.fi>

License: [Apache 2](http://www.apache.org/licenses/LICENSE-2.0)

[gitolite]: https://github.com/sitaramc/gitolite
[wildrepos]: https://github.com/sitaramc/gitolite/blob/master/doc/wildcard-repositories.mkd
[ppa]: https://launchpad.net/~tmatilai/+archive/ppa
[downloads]: https://github.com/tmatilai/gitolite-tools/downloads
