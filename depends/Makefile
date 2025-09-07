# depends/Makefile
# Modules: [A] shell strict flags • [B] paths/knobs • [C] build/host detect • [D] host_os choose • [E] include order • [F] core targets • [G] aux targets (download/clean) • [H] debug
# Critical lines: [1] .SHELLFLAGS pipefail • [2] HOST/build derivation • [3] host_os routing • [4] single ndk.mk include • [5] all: $(packages) hook
SHELL := bash                                  # [A] use bash consistently
.SHELLFLAGS := -o pipefail -c                  # [1] fail on pipeline errors

# [B] directory layout (Bitcoin/Dash style)
top := $(abspath .)
SOURCES_PATH ?= $(top)/sources
BUILD_PATH   ?= $(top)/work/build
BASE_CACHE   ?= $(top)/built
SDK_PATH     ?= $(top)/SDKs

# [B] knobs
V       ?= 0
NO_QT   ?= 0
JOBS    ?= $(if $(MAKEFLAGS),,$(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2))
DOWNLOAD_CONNECT_TIMEOUT ?= 30

# [C] build/host detection
build      ?= $(shell ./config.guess 2>/dev/null || echo unknown-unknown)
build_os   ?= linux
HOST       ?= $(host)           # allow either HOST or host input
host       ?= $(HOST)
host_arch  ?= $(firstword $(subst -, ,$(host)))
host_os    ?= $(word 3,$(subst -, ,$(host)))

# [D] normalize host_os for selection
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

# [E] includes — order matters
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
  include packages/ndk.mk            # [4] single, guarded include; defines ndk_* passthrough
endif

# Package set & functions
include packages/packages.mk         # defines $(packages) based on NO_QT etc.
include funcs.mk

# [F] top-level targets
.PHONY: all packages native_packages download clean clean-all print-vars

all: $(packages)                     # [5] build whatever packages.mk selected

packages: $(packages)

native_packages: $(native_packages)

download:
	@$(call fetch_files)

# [G] cleaning
clean:
	@echo "[depends] clean $(host)"; \
	rm -rf "$(BUILD_PATH)/$(host)" "$(BASE_CACHE)/$(host)"

clean-all:
	@echo "[depends] clean-all"; \
	rm -rf "$(BUILD_PATH)" "$(BASE_CACHE)" "$(SOURCES_PATH)"

# [H] debug helpers
print-vars:
	@echo "top=$(top)"
	@echo "build=$(build)"
	@echo "build_os=$(build_os)"
	@echo "host=$(host)"
	@echo "host_os=$(host_os)"
	@echo "host_arch=$(host_arch)"
	@echo "NO_QT=$(NO_QT)  V=$(V)  JOBS=$(JOBS)"
	@echo "SOURCES_PATH=$(SOURCES_PATH)"
	@echo "BUILD_PATH=$(BUILD_PATH)"
	@echo "BASE_CACHE=$(BASE_CACHE)"
	@echo "SDK_PATH=$(SDK_PATH)"

# Safety: require real tabs for recipes (devs: do not replace with spaces)
# depends/Makefile • 2025-09-07 • Setvin
