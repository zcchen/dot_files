HOME_SRCS   = bash bashrc zsh zshrc
HOME_SRCS  += Xdefaults xinitrc xprofile
HOME_SRCS  += latexmkrc rtorrent.rc

CONFIG_SRCS = $(wildcard config/*)

HOME_DIR    = $${HOME}
HOME_OBJS   = $(foreach s,$(HOME_SRCS),$(HOME_DIR)/.$(s))
CONFIG_OBJS = $(foreach s,$(CONFIG_SRCS),$(HOME_DIR)/.$(s))

REMOVE_CMD  = rm -irf
LINK_CMD    = ln -snf

.PHONY: all clean
.PHONY: install update depends help

all: help

help:
	@echo "make < install | update | uninstall >"
	@echo "       install: Install this plugin on this system via soft-links."
	@echo "       uninstall: Remove the plugin soft-links."
	@echo "       update: Update 3rd-party plugins."

clean:
	$(REMOVE_CMD) $(HOME_OBJS) $(CONFIG_OBJS)

install: $(HOME_OBJS) $(CONFIG_OBJS)
	@echo "tbd"

update:
	@echo "tbd"


$(HOME_DIR)/.%: %
	$(LINK_CMD) "$(CURDIR)/$<" $@
