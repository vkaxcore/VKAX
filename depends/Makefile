# =============================================================================
# depends/Makefile — robust, Android-friendly, and documented
# - No more "config.sub: missing argument"
# - Guarded includes (avoids `include .mk`)
# - Works even if ANDROID_SDK_ROOT is set (maps to ANDROID_SDK)
# - Keeps your Android NDK toolchain knobs as fallbacks
# =============================================================================

SHELL        := /bin/bash
.SHELLFLAGS  := -ec

# Avoid parallel oddities in certain targets
.NOTPARALLEL :

# ---------------------------------------------------------------------
# Keep only desired CLI overrides propagating to sub-makes
# (V=% is used for verbosity)
# ---------------------------------------------------------------------
MAKEOVERRIDES := $(filter V=%,$(MAKEOVERRIDES))

# ---------------------------------------------------------------------
# Paths & knobs
# ---------------------------------------------------------------------
BASEDIR       := $(CURDIR)
WORK_PATH     := $(BASEDIR)/work
BASE_CACHE    := $(BASEDIR)/built
SDK_PATH      := $(BASEDIR)/SDKs
PATCHES_PATH  := $(BASEDIR)/patches
SOURCES_PATH  := $(BASEDIR)/sources

# Hashing & timeouts
HASH_LENGTH              := 11
DOWNLOAD_CONNECT_TIMEOUT := 30

# Cache salting (affects build-id)
HOST_ID_SALT  ?= salt
BUILD_ID_SALT ?= salt

# ---------------------------------------------------------------------
# Prefer local config.guess/config.sub, else fall back to system copies
# (prevents "config.sub: missing argument" and missing-file surprises)
# ---------------------------------------------------------------------
ifeq (,$(wildcard ./config.guess))
  CONFIG_GUESS := $(shell command -v config.guess 2>/dev/null || echo /usr/share/misc/config.guess)
else
  CONFIG_GUESS := ./config.guess
endif

ifeq (,$(wildcard ./config.sub))
  CONFIG_SUB := $(shell command -v config.sub 2>/dev/null || echo /usr/share/misc/config.sub)
else
  CONFIG_SUB := ./config.sub
endif

ifeq (,$(wildcard $(CONFIG_GUESS)))
$(error config.guess not found; ensure depends/config.guess exists or install /usr/share/misc/config.guess)
endif
ifeq (,$(wildcard $(CONFIG_SUB)))
$(error config.sub not found; ensure depends/config.sub exists or install /usr/share/misc/config.sub)
endif

# ---------------------------------------------------------------------
# BUILD/HOST canonicalization
# - If HOST is not provided by environment/CLI, set host := BUILD
# ---------------------------------------------------------------------
BUILD ?= $(shell $(CONFIG_GUESS))
host  := $(or $(HOST),$(BUILD))
HOST  ?= $(host)

build_canon := $(shell $(CONFIG_SUB) $(BUILD))
host_canon  := $(shell $(CONFIG_SUB) $(host))

# Pieces: <arch>-<vendor>-<os...>
build_arch    := $(firstword $(subst -, ,$(build_canon)))
build_vendor  := $(word 2,$(subst -, ,$(build_canon)))
build_full_os := $(subst $(build_arch)-$(build_vendor)-,,$(build_canon))

host_arch     := $(firstword $(subst -, ,$(host_canon)))
host_vendor   := $(word 2,$(subst -, ,$(host_canon)))
host_full_os  := $(subst $(host_arch)-$(host_vendor)-,,$(host_canon))

# Minimal OS normalizer used by depends
define _pick_os
$(strip \
  $(if $(findstring android,$(1)),android, \
  $(if $(findstring darwin,$(1)),darwin, \
  $(if $(findstring mingw32,$(1)),mingw32, \
  $(if $(findstring linux,$(1)),linux,$(1)))))))
endef

build_os := $(call _pick_os,$(build_full_os))
host_os  := $(call _pick_os,$(host_full_os))

# Prefixes for install/staging
$(host_arch)_$(host_os)_prefix := $(BASEDIR)/$(host)
$(host_arch)_$(host_os)_host   := $(host)
host_prefix                    := $($(host_arch)_$(host_os)_prefix)
build_prefix                   := $(host_prefix)/native
build_host                     := $(build_canon)

# Release/debug
ifeq ($(strip $(DEBUG)),)
  release_type := release
else
  release_type := debug
endif

# ---------------------------------------------------------------------
# Android SDK/NDK environment conveniences
# - ANDROID_SDK is used by many depends scripts; CI usually sets ANDROID_SDK_ROOT
# - Map ANDROID_SDK_ROOT → ANDROID_SDK if the latter is empty
# ---------------------------------------------------------------------
ANDROID_SDK      ?= $(ANDROID_SDK_ROOT)
export ANDROID_SDK ANDROID_SDK_ROOT ANDROID_NDK

# ---------------------------------------------------------------------
# Your Android NDK toolchain fallbacks (kept, but made conditional)
# - These serve as fallback host_* tools if hosts/android.mk doesn’t set them
# - Defaults align with r25c layout; API default is 25 unless overridden
# ---------------------------------------------------------------------
ANDROID_NDK ?= $(BASEDIR)/android-sdk/ndk/25.2.9519653
ANDROID_API ?= 25

ANDROID_TOOLCHAIN_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
android_CC    := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang
android_CXX   := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang++
android_AR    := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB:= $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_SYSROOT := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot

export ANDROID_NDK ANDROID_API android_CC android_CXX android_AR android_RANLIB android_STRIP android_SYSROOT

# ---------------------------------------------------------------------
# Includes (GUARDED) — avoids "include .mk" if an OS file doesn’t exist
# Order: OS-specific first, then defaults; packages last
# ---------------------------------------------------------------------
# Host helpers
ifneq ($(wildcard hosts/$(host_os).mk),)
  include hosts/$(host_os).mk
endif
include hosts/default.mk

# Builder helpers
ifneq ($(wildcard builders/$(build_os).mk),)
  include builders/$(build_os).mk
endif
# If you keep a dedicated Android builder fragment for cross cases:
ifneq (,$(and $(findstring android,$(host_os)),$(wildcard builders/android.mk)))
  include builders/android.mk
endif
include builders/default.mk

# Packages registry (defines $(packages), $(native_packages), etc.)
include packages/packages.mk

# ---------------------------------------------------------------------
# Option gates → compose final package lists
# (kept aligned with Bitcoin Core depends conventions)
# ---------------------------------------------------------------------
qt_packages_$(NO_QT)         = $(qt_packages) $(qt_$(host_os)_packages) $(qt_$(host_arch)_$(host_os)_packages)
wallet_packages_$(NO_WALLET) = $(wallet_packages)
upnp_packages_$(NO_UPNP)     = $(upnp_packages)
natpmp_packages_$(NO_NATPMP) = $(natpmp_packages)
zmq_packages_$(NO_ZMQ)       = $(zmq_packages)

protobuf_packages_$(NO_PROTOBUF) = $(protobuf_packages)
openssl_packages_$(NO_OPENSSL)   = $(openssl_packages)

# If you want to always include your baseline libs, add them here without clobbering:
packages += miniupnpc boost openssl protobuf zmq

# Final sets (respecting gates)
packages += $($(host_arch)_$(host_os)_packages) $($(host_os)_packages) \
            $(qt_packages_) $(wallet_packages_) $(upnp_packages_) $(natpmp_packages_)
native_packages += $($(host_arch)_$(host_os)_native_packages) $($(host_os)_native_packages)

ifneq ($(protobuf_packages_),)
  native_packages += $(protobuf_native_packages)
  packages       += $(protobuf_packages)
endif
ifneq ($(openssl_packages_),)
  packages += $(openssl_packages)
endif
ifneq ($(zmq_packages_),)
  packages += $(zmq_packages)
endif

all_packages = $(packages) $(native_packages)

# ---------------------------------------------------------------------
# Functions/macro helpers (required by ext_add_stages etc.)
# ---------------------------------------------------------------------
include funcs.mk

# ---------------------------------------------------------------------
# Fallback: if cross to Android/aarch64 and host_* weren’t set by host files,
# wire them to your NDK toolchain shims.
# ---------------------------------------------------------------------
ifeq ($(host_os),android)
  ifeq ($(host_arch),aarch64)
    host_CC     ?= $(android_CC)
    host_CXX    ?= $(android_CXX)
    host_AR     ?= $(android_AR)
    host_RANLIB ?= $(android_RANLIB)
    host_STRIP  ?= $(android_STRIP)
    host_CPPFLAGS ?= --sysroot="$(android_SYSROOT)" $(host_CPPFLAGS)
    host_LDFLAGS  ?= --sysroot="$(android_SYSROOT)" $(host_LDFLAGS)
  endif
endif

# ---------------------------------------------------------------------
# Build IDs (cache invalidation when tools change)
# Note: build_* and host_* variables come from the included builder/host files.
# ---------------------------------------------------------------------
build_id_string := $(BUILD_ID_SALT)
build_id_string += $(shell $(build_CC) --version 2>/dev/null)
build_id_string += $(shell $(build_AR) --version 2>/dev/null)
build_id_string += $(shell $(build_CXX) --version 2>/dev/null)
build_id_string += $(shell $(build_RANLIB) --version 2>/dev/null)
build_id_string += $(shell $(build_STRIP) --version 2>/dev/null)

$(host_arch)_$(host_os)_id_string := $(HOST_ID_SALT)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CC) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_AR) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CXX) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_RANLIB) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_STRIP) --version 2>/dev/null)

ifneq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
  build_id_string                   += system_clang
  $(host_arch)_$(host_os)_id_string += system_clang
endif

# Final build-id used for stamp
final_build_id_long += $(shell $(build_SHA256SUM) config.site.in)
final_build_id      += $(shell echo -n "$(final_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH))

# ---------------------------------------------------------------------
# Top-level phony targets and @ echo wrapper
# ---------------------------------------------------------------------
AT_$(V) :=
AT_      := @
AT       := $(AT_$(V))

all: install

# ---------------------------------------------------------------------
# Cache/source sanity checks (kept from your version)
# ---------------------------------------------------------------------
define check_or_remove_cached
  mkdir -p $(BASE_CACHE)/$(host)/$(package) && cd $(BASE_CACHE)/$(host)/$(package); \
  $(build_SHA256SUM) -c $($(package)_cached_checksum) >/dev/null 2>/dev/null || \
  ( rm -f $($(package)_cached_checksum); \
    if test -f "$($(package)_cached)"; then echo "Checksum mismatch for $(package). Forcing rebuild.."; rm -f $($(package)_cached_checksum) $($(package)_cached); fi )
endef

define check_or_remove_sources
  mkdir -p $($(package)_source_dir); cd $($(package)_source_dir); \
  test -f $($(package)_fetched) && ( $(build_SHA256SUM) -c $($(package)_fetched) >/dev/null 2>/dev/null || \
    ( echo "Checksum missing or mismatched for $(package) source. Forcing re-download."; \
      rm -f $($(package)_all_sources) $($(1)_fetched))) || true
endef

check-packages:
	@$(foreach package,$(all_packages),$(call check_or_remove_cached,$(package));)

check-sources:
	@$(foreach package,$(all_packages),$(call check_or_remove_sources,$(package));)

# ---------------------------------------------------------------------
# config.site (autoconf cache) generation
# ---------------------------------------------------------------------
$(host_prefix)/share/config.site : config.site.in $(host_prefix)/.stamp_$(final_build_id)
	$(AT)@mkdir -p $(@D)
	$(AT)sed -e 's|@HOST@|$(host)|' \
            -e 's|@CC@|$(host_CC)|' \
            -e 's|@CXX@|$(host_CXX)|' \
            -e 's|@AR@|$(host_AR)|' \
            -e 's|@RANLIB@|$(host_RANLIB)|' \
            -e 's|@NM@|$(host_NM)|' \
            -e 's|@STRIP@|$(host_STRIP)|' \
            -e 's|@build_os@|$(build_os)|' \
            -e 's|@host_os@|$(host_os)|' \
            -e 's|@CFLAGS@|$(strip $(host_CFLAGS) $(host_$(release_type)_CFLAGS))|' \
            -e 's|@CXXFLAGS@|$(strip $(host_CXXFLAGS) $(host_$(release_type)_CXXFLAGS))|' \
            -e 's|@CPPFLAGS@|$(strip $(host_CPPFLAGS) $(host_$(release_type)_CPPFLAGS))|' \
            -e 's|@LDFLAGS@|$(strip $(host_LDFLAGS) $(host_$(release_type)_LDFLAGS))|' \
            -e 's|@no_qt@|$(NO_QT)|' \
            -e 's|@no_zmq@|$(NO_ZMQ)|' \
            -e 's|@disable_bip70@|$(NO_PROTOBUF)|' \
            -e 's|@no_wallet@|$(NO_WALLET)|' \
            -e 's|@no_upnp@|$(NO_UPNP)|' \
            -e 's|@no_natpmp@|$(NO_NATPMP)|' \
            -e 's|@debug@|$(DEBUG)|' \
            $< > $@
	$(AT)touch $@

# Unpack cached outputs to a stamp folder
$(host_prefix)/.stamp_$(final_build_id): $(native_packages) $(packages)
	$(AT)rm -rf $(@D)
	$(AT)mkdir -p $(@D)
	$(AT)echo copying packages: $^
	$(AT)echo to: $(@D)
	$(AT)cd $(@D); $(foreach package,$^, tar xf $($(package)_cached); )
	$(AT)touch $@

# Wiring
$(host_prefix)/share/config.site: check-packages
check-packages: check-sources

# ---------------------------------------------------------------------
# Clean/install/download orchestration
# ---------------------------------------------------------------------
clean-all: clean
	@rm -rf $(SOURCES_PATH) x86_64* i686* mips* arm* aarch64* riscv32* riscv64*

clean:
	@rm -rf $(WORK_PATH) $(BASE_CACHE) $(BUILD)

install: check-packages $(host_prefix)/share/config.site

download-one: check-sources $(all_sources)

download-osx:
	@$(MAKE) -s HOST=x86_64-apple-darwin download-one
download-linux:
	@$(MAKE) -s HOST=x86_64-unknown-linux-gnu download-one
download-win:
	@$(MAKE) -s HOST=x86_64-w64-mingw32 download-one
download: download-osx download-linux download-win

# Expand package build stages from packages/* definitions
$(foreach package,$(all_packages),$(eval $(call ext_add_stages,$(package))))

.PHONY: install cached clean clean-all download-one download-osx download-linux download-win download check-packages check-sources
