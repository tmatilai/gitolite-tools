gitolite-tools
==============

Description
-----------

Collection of tools to work with [gitolite][] repositories.

So far implemented:

* git gl-perms - Display or edit permissions of
  [gitolite wildcard repositories][wildrepos].
* git gl-info - Display [gitolite][] server information

Installation
------------

Makefile (or something similar) will come some day, but so far just

	sudo cp git-gl-* $(git --exec-path)/

Copyright
---------

Copyright (c) 2010 Teemu Matilainen <teemu.matilainen@iki.fi>

License: [Apache 2](http://www.apache.org/licenses/LICENSE-2.0)

[gitolite]: http://github.com/sitaramc/gitolite
[wildrepos]: http://github.com/sitaramc/gitolite/tree/wildrepos
