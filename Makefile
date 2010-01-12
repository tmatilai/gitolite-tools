gitexecdir = $(shell git --exec-path || true)
ifeq (,$(gitexecdir))
$(error gitexecdir not defined)
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

install: all install-git-programs

.PHONY: all clean install install-git-programs
