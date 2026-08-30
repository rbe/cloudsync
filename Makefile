# cloudsync — thin wrapper around `cloudsync setup`
#
#   make setup      copy cloudsync + rclone into ~/.local/bin, seed config
#   make upgrade    re-fetch ~/.local/bin/rclone
#   make uninstall  remove the installed cloudsync (rclone and config stay)
#
# GNU Make 3.81-compatible (stock macOS).

PREFIX     ?= $(HOME)/.local
BINDIR     ?= $(PREFIX)/bin
NAME       := cloudsync
ROOT       := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SRC        := $(ROOT)/$(NAME)
DEST       := $(BINDIR)/$(NAME)

.PHONY: all help setup install upgrade uninstall check doctor

all: help

help:
	@echo "cloudsync  —  $(SRC)"
	@echo
	@echo "  make setup        $(SRC) setup   (copy script + rclone into $(BINDIR))"
	@echo "  make upgrade      $(SRC) setup --upgrade   (re-fetch rclone)"
	@echo "  make install      alias for setup"
	@echo "  make check        syntax-check the script"
	@echo "  make doctor       run 'cloudsync doctor'"
	@echo "  make uninstall    remove $(DEST)  (leaves rclone and config)"
	@echo
	@echo "Or run the script directly:  $(SRC) setup"

setup install:
	@"$(SRC)" setup

upgrade:
	@"$(SRC)" setup --upgrade

uninstall:
	@if [ -L "$(DEST)" ] || [ -f "$(DEST)" ]; then \
	  rm -f "$(DEST)"; \
	  echo "removed $(DEST)"; \
	else \
	  echo "not installed at $(DEST)"; \
	fi
	@echo "Config, logs, launchd agent, and rclone were left in place."
	@echo "Remove the schedule with:  cloudsync schedule uninstall"

check:
	@test -f "$(SRC)" || { echo >&2 "missing $(SRC)"; exit 1; }
	@/bin/bash -n "$(SRC)"
	@echo "syntax: $(SRC) OK"

doctor:
	@"$(SRC)" doctor
