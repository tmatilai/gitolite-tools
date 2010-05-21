# Makefile for gitolite-tools
# Based heavily on git

gitexecdir = $(shell git --exec-path)
ifeq (,$(gitexecdir))
	$(error gitexecdir not defined)
endif
ifeq (/usr, $(gitexecdir:/usr/%=/usr))
	vimdir = /etc/vim
else
	vimdir = $(HOME)/.vim
endif

INSTALL = install
RM = rm -f
SHELL_PATH = /bin/sh

SCRIPT_SH =
SCRIPT_SH += git-gl-desc.sh
SCRIPT_SH += git-gl-htpasswd.sh
SCRIPT_SH += git-gl-info.sh
SCRIPT_SH += git-gl-ls.sh
SCRIPT_SH += git-gl-perms.sh

SCRIPT_LIB =
SCRIPT_LIB += git-gl-helpers

GIT_PROGRAMS = $(patsubst %.sh,%,$(SCRIPT_SH))

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
	QUIET_GEN = @echo '   ' GEN $@;
endif
endif

all: $(GIT_PROGRAMS) $(SCRIPT_LIB)

clean:
	$(RM) $(GIT_PROGRAMS) $(SCRIPT_LIB)
	$(RM) gitolite-tools.tar.gz

define cmd_munge_script
$(RM) $@ $@+ && \
sed -e '1s|#!.*/sh|#!$(SHELL_PATH)|' \
    $@.sh >$@+
endef

$(patsubst %.sh,%,$(SCRIPT_SH)) : % : %.sh
	$(QUIET_GEN)$(cmd_munge_script) && \
	chmod +x $@+ && \
	mv $@+ $@

$(SCRIPT_LIB) : % : %.sh
	$(QUIET_GEN)$(cmd_munge_script) && \
	mv $@+ $@

install-git-programs:
	$(INSTALL) -d -m 755 '$(DESTDIR)$(gitexecdir)'
	$(INSTALL) $(GIT_PROGRAMS) '$(DESTDIR)$(gitexecdir)'
	$(INSTALL) -m 644 $(SCRIPT_LIB) '$(DESTDIR)$(gitexecdir)'

install-vim:
	$(INSTALL) -d -m 755 '$(DESTDIR)$(vimdir)/syntax'
	$(INSTALL) -m 644 vim/syntax/glperms.vim '$(DESTDIR)$(vimdir)/syntax'
	$(INSTALL) -d -m 755 '$(DESTDIR)$(vimdir)/ftdetect'
	$(INSTALL) -m 644 vim/ftdetect/gitolite-tools.vim '$(DESTDIR)$(vimdir)/ftdetect'

install: all install-git-programs install-vim

dist:
	git archive --prefix='gitolite-tools/' HEAD | gzip -9 > gitolite-tools.tar.gz

.PHONY: all clean install install-git-programs install-vim dist
