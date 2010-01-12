gitexecdir = $(shell git --exec-path || true)
ifeq (,$(gitexecdir))
$(error gitexecdir not defined)
endif
ifeq (/usr, $(gitexecdir:/usr/%=/usr))
vimdir = /etc/vim
else
vimdir = $(HOME)/.vim
endif

INSTALL = install

GIT_PROGRAMS += git-gl-helpers
GIT_PROGRAMS += git-gl-info
GIT_PROGRAMS += git-gl-perms

all:

clean:

install-git-programs:
	$(INSTALL) -d -m 755 '$(DESTDIR)$(gitexecdir)'
	$(INSTALL) $(GIT_PROGRAMS) '$(DESTDIR)$(gitexecdir)'

install-vim:
	$(INSTALL) -d -m 755 '$(DESTDIR)$(vimdir)/syntax'
	$(INSTALL) vim/syntax/glperms.vim '$(DESTDIR)$(vimdir)/syntax'
	$(INSTALL) -d -m 755 '$(DESTDIR)$(vimdir)/ftdetect'
	$(INSTALL) vim/ftdetect/gitolite-tools.vim '$(DESTDIR)$(vimdir)/ftdetect'

install: all install-git-programs install-vim

.PHONY: all clean install install-git-programs install-vim
