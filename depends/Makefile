# depends/Makefile
# Path: depends/Makefile
# Modules: [A] shell strict  [B] paths/knobs  [C] host/build detect  [D] host_os route  [E] includes  [F] targets  [G] clean  [H] introspect

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

# [B]
top           := $(abspath .)
SOURCES_PATH  ?= $(top)/sources
BUILD_PATH    ?= $(top)/work/build
BASE_CACHE    ?= $(top)/built
SDK_PATH      ?= $(top)/SDKs
V             ?= 0
NO_QT         ?= 0
JOBS          ?= $(or $(shell nproc 2>/dev/null),$(shell getconf _NPROCESSORS_ONLN 2>/dev/null),$(shell sysctl -n hw.ncpu 2>/dev/null),2)

# [C]
config_guess  := $(top)/config.guess
build         ?= $(shell [ -x "$(config_guess)" ] && "$(config_guess)" 2>/dev/null || echo unknown-unknown)
build_arch    := $(firstword $(subst -, ,$(build)))
build_os      := $(word 3,$(subst -, ,$(build)))
HOST          ?= $(host)
host          ?= $(HOST)
ifeq ($(strip $(host)),)
  host := $(build)
  HOST := $(host)
endif
host_arch     := $(firstword $(subst -, ,$(host)))
host_os       := $(word 3,$(subst -, ,$(host)))

# [D]
ifneq (,$(findstring android,$(host)))
  host_os := android
endif
ifneq (,$(findstring mingw,$(host)))
  host_os := mingw32
endif
ifneq (,$(findstring msys,$(host)))
  host_os := mingw32
endif
ifneq (,$(findstring darwin,$(host)))
  host_os := darwin
endif
ifneq (,$(findstring linux,$(host)))
  host_os := linux
endif

# Autoconf site defaults path (used by configure for all packages)
CONFIG_SITE_DIR  := $(BASE_CACHE)/$(host)/share
CONFIG_SITE_FILE := $(CONFIG_SITE_DIR)/config.site
export CONFIG_SITE := $(CONFIG_SITE_FILE)

# [E]
include hosts/default.mk
ifeq ($(host_os),linux)
  include hosts/linux.mk
endif
ifeq ($(host_os),darwin)
  include hosts/darwin.mk
endif
ifeq ($(host_os),mingw32)
  include hosts/mingw32.mk
endif
ifeq ($(host_os),android)
  include hosts/android.mk
  include packages/ndk.mk
endif
include packages/packages.mk
include funcs.mk

# [F]
.PHONY: all packages native_packages download config-site show-config clean clean-all print-vars

all: config-site $(packages)
packages: config-site $(packages)
native_packages: config-site $(native_packages)

download:
	@$(call fetch_files)

# Ensure CONFIG_SITE exists for any host (fixes CI probe on MSYS2 and others)
config-site:
	@mkdir -p "$(CONFIG_SITE_DIR)"; \
	if [ ! -s "$(CONFIG_SITE_FILE)" ]; then \
	  echo "# Autoconf site defaults for $(host)"            >  "$(CONFIG_SITE_FILE)"; \
	  echo "build_alias='$(build)'"                         >> "$(CONFIG_SITE_FILE)"; \
	  echo "host_alias='$(host)'"                           >> "$(CONFIG_SITE_FILE)"; \
	  case "$(host_os)" in \
	    mingw32) \
	      echo "CC='$(host)-gcc'"                          >> "$(CONFIG_SITE_FILE)"; \
	      echo "CXX='$(host)-g++'"                         >> "$(CONFIG_SITE_FILE)"; \
	      echo "AR='$(host)-ar'"                           >> "$(CONFIG_SITE_FILE)"; \
	      echo "RANLIB='$(host)-ranlib'"                   >> "$(CONFIG_SITE_FILE)"; \
	      echo "STRIP='$(host)-strip'"                     >> "$(CONFIG_SITE_FILE)"; \
	      ;;
	    linux|darwin|android) \
	      : ;; \
	  esac; \
	  echo "[depends] wrote config.site: $(CONFIG_SITE_FILE)"; \
	else \
	  echo "[depends] using existing config.site: $(CONFIG_SITE_FILE)"; \
	fi

show-config:
	@echo "$(CONFIG_SITE_FILE)"; \
	echo "----"; \
	tail -n +1 "$(CONFIG_SITE_FILE)" || true

# [G]
clean:
	@echo "[depends] clean $(host)"; \
	rm -rf "$(BUILD_PATH)/$(host)" "$(BASE_CACHE)/$(host)"

clean-all:
	@echo "[depends] clean-all"; \
	rm -rf "$(BUILD_PATH)" "$(BASE_CACHE)" "$(SOURCES_PATH)"

# [H]
print-vars:
	@echo "top=$(top)"; \
	echo "build=$(build)"; \
	echo "build_os=$(build_os)"; \
	echo "host=$(host)"; \
	echo "host_os=$(host_os)"; \
	echo "host_arch=$(host_arch)"; \
	echo "NO_QT=$(NO_QT)  V=$(V)  JOBS=$(JOBS)"; \
	echo "SOURCES_PATH=$(SOURCES_PATH)"; \
	echo "BUILD_PATH=$(BUILD_PATH)"; \
	echo "BASE_CACHE=$(BASE_CACHE)"; \
	echo "SDK_PATH=$(SDK_PATH)"; \
	echo "CONFIG_SITE=$(CONFIG_SITE)";
# depends/Makefile • final
