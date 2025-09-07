# depends/Makefile
# Path: depends/Makefile
# Modules: [A] shell strict  [B] paths/knobs  [C] host/build detect  [D] host_os route  [E] includes (single ndk.mk)  [F] targets  [G] clean  [H] introspect
# Why: sane include order; tabbed recipes; relative staging; fixes duplicate ndk.mk and flattened lines issues.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -o pipefail -c

# [B]
top := $(abspath .)
SOURCES_PATH ?= $(top)/sources
BUILD_PATH   ?= $(top)/work/build
BASE_CACHE   ?= $(top)/built
SDK_PATH     ?= $(top)/SDKs
V ?= 0
NO_QT ?= 0
JOBS ?= $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)

# [C]
build      ?= $(shell ./config.guess 2>/dev/null || echo unknown-unknown)
build_os   ?= linux
HOST       ?= $(host)
host       ?= $(HOST)
host_arch  ?= $(firstword $(subst -, ,$(host)))
host_os    ?= $(word 3,$(subst -, ,$(host)))

# [D]
ifeq ($(findstring android,$(host)),android)
  host_os := android
endif
ifeq ($(findstring mingw,$(host)),mingw)
  host_os := mingw32
endif
ifeq ($(findstring darwin,$(host)),darwin)
  host_os := darwin
endif
ifeq ($(findstring linux,$(host)),linux)
  host_os := linux
endif

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
.PHONY: all packages native_packages download clean clean-all print-vars
all: $(packages)
packages: $(packages)
native_packages: $(native_packages)

download:
	@$(call fetch_files)

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
	echo "SDK_PATH=$(SDK_PATH)"
# depends/Makefile  • Setvin • 2025-09-07
