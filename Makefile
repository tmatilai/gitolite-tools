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

SCRIPT_SH += git-gl-desc.sh
SCRIPT_SH += git-gl-helpers.sh
SCRIPT_SH += git-gl-htpasswd.sh
SCRIPT_SH += git-gl-info.sh
SCRIPT_SH += git-gl-ls.sh
SCRIPT_SH += git-gl-perms.sh

SCRIPTS = $(patsubst %.sh,%,$(SCRIPT_SH))
GIT_PROGRAMS = $(SCRIPTS)

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
	QUIET_GEN = @echo '   ' GEN $@;
endif
endif

all: $(GIT_PROGRAMS)

clean:
	$(RM) $(GIT_PROGRAMS)
	$(RM) gitolite-tools.tar.gz

$(patsubst %.sh,%,$(SCRIPT_SH)) : % : %.sh
	$(QUIET_GEN)$(RM) $@ && \
	ln $@.sh $@ 2>/dev/null || \
	ln -s $@.sh $@ 2>/dev/null || \
	cp $@.sh $@

install-git-programs:
	$(INSTALL) -d -m 755 '$(DESTDIR)$(gitexecdir)'
	$(INSTALL) $(GIT_PROGRAMS) '$(DESTDIR)$(gitexecdir)'

install-vim:
	$(INSTALL) -d -m 755 '$(DESTDIR)$(vimdir)/syntax'
	$(INSTALL) -m 644 vim/syntax/glperms.vim '$(DESTDIR)$(vimdir)/syntax'
	$(INSTALL) -d -m 755 '$(DESTDIR)$(vimdir)/ftdetect'
	$(INSTALL) -m 644 vim/ftdetect/gitolite-tools.vim '$(DESTDIR)$(vimdir)/ftdetect'

install: all install-git-programs install-vim

dist:
	git archive --prefix='gitolite-tools/' HEAD | gzip -9 > gitolite-tools.tar.gz

.PHONY: all clean install install-git-programs install-vim dist
