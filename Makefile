gitexecdir = $(shell git --exec-path || true)
ifeq (,$(gitexecdir))
$(error gitexecdir not defined)
endif

INSTALL = install

SCRIPTS += git-gl-helpers
SCRIPTS += git-gl-info
SCRIPTS += git-gl-perms

all:

clean:

install: all
	$(INSTALL) -d -m 755 '$(DESTDIR)$(gitexecdir)'
	$(INSTALL) $(SCRIPTS) '$(DESTDIR)$(gitexecdir)'

.PHONY: all clean install
