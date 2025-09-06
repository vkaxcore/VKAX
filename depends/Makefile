# =============================================================================
# depends/Makefile — hardened and annotated
# - Robust build/host detection (no more "config.sub: missing argument")
# - Guarded includes (no more "include .mk")
# - Safe defaults for Android SDK variables
# - Keeps your original stages and targets intact
# =============================================================================

.SHELLFLAGS := -ec
SHELL := /bin/bash

.NOTPARALLEL :

# --- Utility: print a variable (e.g. `make print-host_os`)
print-%:
	@echo $* = $($*)

# --- Only propagate V=% to sub-makes to keep logs tidy
MAKEOVERRIDES := $(filter V=%,$(MAKEOVERRIDES))

# --- Layout
BASEDIR      = $(CURDIR)
SOURCES_PATH ?= $(BASEDIR)/sources
WORK_PATH     = $(BASEDIR)/work
BASE_CACHE   ?= $(BASEDIR)/built
SDK_PATH     ?= $(BASEDIR)/SDKs
PATCHES_PATH  = $(BASEDIR)/patches

# --- Feature gates (honor your existing flags)
NO_QT      ?=
NO_PROTOBUF?=
NO_OPENSSL ?=
NO_WALLET  ?=
NO_ZMQ     ?=
NO_UPNP    ?=
NO_NATPMP  ?=

FALLBACK_DOWNLOAD_PATH ?= https://bitcoincore.org/depends-sources

HASH_LENGTH            := 11
DOWNLOAD_CONNECT_TIMEOUT := 30
HOST_ID_SALT           ?= salt
BUILD_ID_SALT          ?= salt

# =============================================================================
# CONFIG.GUESS / CONFIG.SUB — robust selection (local if present, else system)
# =============================================================================

# Prefer local helper scripts if present in depends/
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

# Guard: both must exist and be executable
ifeq (,$(wildcard $(CONFIG_GUESS)))
$(error "config.guess not found; ensure it exists in depends/ or install /usr/share/misc/config.guess")
endif
ifeq (,$(wildcard $(CONFIG_SUB)))
$(error "config.sub not found; ensure it exists in depends/ or install /usr/share/misc/config.sub")
endif

# =============================================================================
# BUILD/HOST canonicalization
# =============================================================================

# BUILD from guess unless explicitly overridden outside
BUILD ?= $(shell $(CONFIG_GUESS))

# Accept either uppercase HOST (env/CLI) or internal 'host'
# If HOST (uppercase) isn't set, default host := BUILD
host  := $(or $(HOST),$(BUILD))
HOST  ?= $(host)   # keep HOST exported for consumers that look for it

# Canonical triples (fixes the "config.sub: missing argument" if HOST was empty)
build_canon := $(shell $(CONFIG_SUB) $(BUILD))
host_canon  := $(shell $(CONFIG_SUB) $(host))

# Split canonical triples: <arch>-<vendor>-<os...>
build_arch     := $(firstword $(subst -, ,$(build_canon)))
build_vendor   := $(word 2,$(subst -, ,$(build_canon)))
build_full_os  := $(subst $(build_arch)-$(build_vendor)-,,$(build_canon))

host_arch      := $(firstword $(subst -, ,$(host_canon)))
host_vendor    := $(word 2,$(subst -, ,$(host_canon)))
host_full_os   := $(subst $(host_arch)-$(host_vendor)-,,$(host_canon))

# Normalize OS names into ones our tree expects
# - linux-gnu    -> linux
# - anything with 'android' -> android
# - mingw32      -> mingw32
# - darwin       -> darwin
define _pick_os
$(strip \
  $(if $(findstring android,$(1)),android, \
  $(if $(findstring darwin,$(1)),darwin, \
  $(if $(findstring mingw32,$(1)),mingw32, \
  $(if $(findstring linux,$(1)),linux,$(1)))))))
endef

build_os := $(call _pick_os,$(build_full_os))
host_os  := $(call _pick_os,$(host_full_os))

# Final prefixes/hosts
$(host_arch)_$(host_os)_prefix := $(BASEDIR)/$(host)
$(host_arch)_$(host_os)_host   := $(host)
host_prefix                    := $($(host_arch)_$(host_os)_prefix)
build_prefix                   := $(host_prefix)/native
build_host                     := $(build_canon)

# Release type
ifeq ($(strip $(DEBUG)),)
  release_type := release
else
  release_type := debug
endif

# =============================================================================
# Android SDK/NDK helpers — make life easier if CI sets only ANDROID_SDK_ROOT
# =============================================================================
ANDROID_SDK      ?= $(ANDROID_SDK_ROOT)
export ANDROID_SDK ANDROID_SDK_ROOT ANDROID_NDK

# =============================================================================
# Include fragments — GUARDED to avoid "include .mk"
# =============================================================================
# Order matters: OS-specific first (if present), then default.

# Hosts
ifneq ($(wildcard hosts/$(host_os).mk),)
  include hosts/$(host_os).mk
endif
include hosts/default.mk

# Builders
ifneq ($(wildcard builders/$(build_os).mk),)
  include builders/$(build_os).mk
endif
include builders/default.mk

# Packages (unconditional)
include packages/packages.mk

# =============================================================================
# Package set assembly (honors your existing options)
# =============================================================================

qt_packages_$(NO_QT)        = $(qt_packages) $(qt_$(host_os)_packages) $(qt_$(host_arch)_$(host_os)_packages)
wallet_packages_$(NO_WALLET)= $(wallet_packages)
upnp_packages_$(NO_UPNP)    = $(upnp_packages)
natpmp_packages_$(NO_NATPMP)= $(natpmp_packages)
zmq_packages_$(NO_ZMQ)      = $(zmq_packages)

protobuf_packages_$(NO_PROTOBUF) = $(protobuf_packages)
openssl_packages_$(NO_OPENSSL)   = $(openssl_packages)

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

meta_depends = Makefile funcs.mk builders/default.mk hosts/default.mk \
               hosts/$(host_os).mk builders/$(build_os).mk

$(host_arch)_$(host_os)_native_binutils ?= $($(host_os)_native_binutils)
$(host_arch)_$(host_os)_native_toolchain?= $($(host_os)_native_toolchain)

# =============================================================================
# funcs.mk (macro helpers)
# =============================================================================
include funcs.mk

# =============================================================================
# Build IDs (invalidate cache on toolchain change)
# =============================================================================
build_id_string   := $(BUILD_ID_SALT)
build_id_string   += $(shell $(build_CC) --version 2>/dev/null)
build_id_string   += $(shell $(build_AR) --version 2>/dev/null)
build_id_string   += $(shell $(build_CXX) --version 2>/dev/null)
build_id_string   += $(shell $(build_RANLIB) --version 2>/dev/null)
build_id_string   += $(shell $(build_STRIP) --version 2>/dev/null)

$(host_arch)_$(host_os)_id_string := $(HOST_ID_SALT)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CC) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_AR) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CXX) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_RANLIB) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_STRIP) --version 2>/dev/null)

ifneq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
  build_id_string                    += system_clang
  $(host_arch)_$(host_os)_id_string  += system_clang
endif

final_build_id_long += $(shell $(build_SHA256SUM) config.site.in)
final_build_id      += $(shell echo -n "$(final_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH))

# =============================================================================
# Top-level targets
# =============================================================================
AT_$(V) :=
AT_      := @
AT       := $(AT_$(V))

all: install

# ---------------------------------------------------------------------------
# Cache & source checks (unchanged logic, kept intact)
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# config.site (same logic; now fed by robust host/build variables)
# ---------------------------------------------------------------------------
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

# Stamp contains unpacked cached packages
$(host_prefix)/.stamp_$(final_build_id): $(native_packages) $(packages)
	$(AT)rm -rf $(@D)
	$(AT)mkdir -p $(@D)
	$(AT)echo copying packages: $^
	$(AT)echo to: $(@D)
	$(AT)cd $(@D); $(foreach package,$^, tar xf $($(package)_cached); )
	$(AT)touch $@

# --- Target wiring
$(host_prefix)/share/config.site: check-packages
check-packages: check-sources

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

# Expand package stages declared in packages/*.mk
$(foreach package,$(all_packages),$(eval $(call ext_add_stages,$(package))))

.PHONY: install cached clean clean-all download-one download-osx download-linux download-win download check-packages check-sources
