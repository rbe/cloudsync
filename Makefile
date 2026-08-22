# cloudsync — macOS rclone orchestrator
#
#   make setup      install deps, link ~/.local/bin/cloudsync, seed config if missing
#   make install    same as setup
#   make uninstall  remove the symlink (does not touch rclone, fzf, config, or launchd)
#
# GNU Make 3.81-compatible (stock macOS). Override with e.g.  make PREFIX=/usr/local install

PREFIX     ?= $(HOME)/.local
BINDIR     ?= $(PREFIX)/bin
NAME       := cloudsync
ROOT       := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SRC        := $(ROOT)/$(NAME)
DEST       := $(BINDIR)/$(NAME)
CONFIG_DIR ?= $(HOME)/.config/cloudsync
EXAMPLES   := $(ROOT)/examples

.PHONY: all help setup install uninstall deps seed-config check doctor install-link need-brew path-hint

all: help

help:
	@echo "cloudsync  —  $(SRC)"
	@echo
	@echo "  make setup        install rclone/fzf if missing, link into $(BINDIR), seed config"
	@echo "  make install      alias for setup"
	@echo "  make deps         install missing Homebrew packages (rclone required, fzf for the menu)"
	@echo "  make check        syntax-check the script; verify rclone is on PATH"
	@echo "  make doctor       run 'cloudsync doctor' (iCloud FDA + remotes)"
	@echo "  make uninstall    remove $(DEST)"
	@echo
	@echo "Config lives in $(CONFIG_DIR) (not in this repo)."
	@echo "After install, ensure $(BINDIR) is on PATH."

# Sequential: deps must finish before check/link (make -j would otherwise race).
setup:
	@$(MAKE) deps
	@$(MAKE) seed-config
	@$(MAKE) install-link
	@echo
	@$(MAKE) -s path-hint
	@echo "Next:"
	@echo "  cloudsync doctor          # iCloud Full Disk Access + remotes"
	@echo "  cloudsync edit            # job map  ($(CONFIG_DIR)/jobs.tsv)"
	@echo "  cloudsync dry <job|all>   # preview before the first real run"
	@echo "  cloudsync help"

install: setup

# --- dependencies ------------------------------------------------------------

deps:
	@if ! command -v rclone >/dev/null 2>&1; then \
	  echo "Installing rclone (required)…"; \
	  $(MAKE) -s need-brew; \
	  brew install rclone; \
	else \
	  echo "rclone: $$(command -v rclone)"; \
	fi
	@if ! command -v fzf >/dev/null 2>&1; then \
	  echo "Installing fzf (interactive menu)…"; \
	  $(MAKE) -s need-brew; \
	  brew install fzf; \
	else \
	  echo "fzf:    $$(command -v fzf)"; \
	fi

need-brew:
	@command -v brew >/dev/null 2>&1 || { \
	  echo >&2 "Homebrew is required to install dependencies: https://brew.sh"; \
	  exit 1; \
	}

# --- link + config -----------------------------------------------------------

install-link: check
	@mkdir -p "$(BINDIR)"
	@ln -sfn "$(SRC)" "$(DEST)"
	@echo "linked  $(DEST) -> $(SRC)"

seed-config:
	@mkdir -p "$(CONFIG_DIR)"
	@if [ ! -f "$(CONFIG_DIR)/jobs.tsv" ]; then \
	  cp "$(EXAMPLES)/jobs.tsv" "$(CONFIG_DIR)/jobs.tsv"; \
	  echo "seeded  $(CONFIG_DIR)/jobs.tsv"; \
	else \
	  echo "keep    $(CONFIG_DIR)/jobs.tsv"; \
	fi
	@if [ ! -f "$(CONFIG_DIR)/icloud.filter" ]; then \
	  cp "$(EXAMPLES)/icloud.filter" "$(CONFIG_DIR)/icloud.filter"; \
	  echo "seeded  $(CONFIG_DIR)/icloud.filter"; \
	else \
	  echo "keep    $(CONFIG_DIR)/icloud.filter"; \
	fi
	@if [ ! -f "$(CONFIG_DIR)/config" ]; then \
	  cp "$(EXAMPLES)/config" "$(CONFIG_DIR)/config"; \
	  echo "seeded  $(CONFIG_DIR)/config"; \
	else \
	  echo "keep    $(CONFIG_DIR)/config"; \
	fi

uninstall:
	@if [ -L "$(DEST)" ] || [ -f "$(DEST)" ]; then \
	  rm -f "$(DEST)"; \
	  echo "removed $(DEST)"; \
	else \
	  echo "no symlink at $(DEST)"; \
	fi
	@echo "Config, logs, launchd agent, rclone, and fzf were left in place."
	@echo "Remove the schedule with:  cloudsync schedule uninstall   (before deleting this repo)"

# --- checks ------------------------------------------------------------------

check:
	@test -f "$(SRC)" || { echo >&2 "missing $(SRC)"; exit 1; }
	@bash -n "$(SRC)"
	@echo "syntax: $(SRC) OK"
	@command -v rclone >/dev/null 2>&1 || { \
	  echo >&2 "rclone not on PATH — run: make deps"; \
	  exit 1; \
	}

doctor: install-link
	@"$(DEST)" doctor

path-hint:
	@case ":$$PATH:" in \
	  *":$(BINDIR):"*) ;; \
	  *) \
	    echo "NOTE: $(BINDIR) is not on PATH. Add to ~/.zprofile:"; \
	    echo "  export PATH=\"$(BINDIR):\$$PATH\""; \
	    echo "then:  hash -r   (or open a new terminal)"; \
	    ;; \
	esac
