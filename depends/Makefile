# =============================================================================
# depends/Makefile — merged + hardened
# - Robust BUILD/HOST detection (no more "config.sub: missing argument")
# - Includes ordered so packages/*.mk are loaded BEFORE assembling all_packages
# - Safe defaults + guards for $(package)_source_dir (fixes "mkdir: missing operand")
# - doctor/print helpers for quick diagnostics
# =============================================================================

SHELL       := /bin/bash
.SHELLFLAGS := -ec
.NOTPARALLEL:

# --- Utility: print a variable (e.g. `make print-host_os`)
print-%:
	@echo $* = $($*)

# Only propagate V=% (verbosity) to sub-makes to keep logs sane
MAKEOVERRIDES := $(filter V=%,$(MAKEOVERRIDES))

# -----------------------------------------------------------------------------
# Layout / paths
# -----------------------------------------------------------------------------
BASEDIR      = $(CURDIR)
WORK_PATH    = $(BASEDIR)/work
BASE_CACHE   = $(BASEDIR)/built
SDK_PATH     = $(BASEDIR)/SDKs
PATCHES_PATH = $(BASEDIR)/patches
SOURCES_PATH = $(BASEDIR)/sources

# Cache/build dirs used by package macros
base_build_dir    = $(WORK_PATH)/build
base_staging_dir  = $(WORK_PATH)/staging
base_download_dir = $(WORK_PATH)/download

# Salts + hashes
HOST_ID_SALT             ?= salt
BUILD_ID_SALT            ?= salt
HASH_LENGTH              ?= 11
DOWNLOAD_CONNECT_TIMEOUT ?= 30

# -----------------------------------------------------------------------------
# Robust config.guess / config.sub selection (prefer local, fallback to system)
# -----------------------------------------------------------------------------
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
$(error config.guess not found; keep one in depends/ or install /usr/share/misc/config.guess)
endif
ifeq (,$(wildcard $(CONFIG_SUB)))
$(error config.sub not found; keep one in depends/ or install /usr/share/misc/config.sub)
endif

# -----------------------------------------------------------------------------
# Canonicalize BUILD/HOST triples (fixes: 'config.sub: missing argument')
# -----------------------------------------------------------------------------
BUILD ?= $(shell $(CONFIG_GUESS))

host  := $(or $(HOST),$(BUILD))     # internal
HOST  ?= $(host)                    # exported for scripts

build_canon := $(shell $(CONFIG_SUB) $(BUILD))
host_canon  := $(shell $(CONFIG_SUB) $(host))

# Split canonical triples: <arch>-<vendor>-<os...>
build_arch    := $(firstword $(subst -, ,$(build_canon)))
build_vendor  := $(word 2,$(subst -, ,$(build_canon)))
build_full_os := $(subst $(build_arch)-$(build_vendor)-,,$(build_canon))

host_arch     := $(firstword $(subst -, ,$(host_canon)))
host_vendor   := $(word 2,$(subst -, ,$(host_canon)))
host_full_os  := $(subst $(host_arch)-$(host_vendor)-,,$(host_canon))

# Normalize OS names
define _pick_os
$(strip \
  $(if $(findstring android,$(1)),android, \
  $(if $(findstring darwin,$(1)),darwin, \
  $(if $(findstring mingw32,$(1)),mingw32, \
  $(if $(findstring linux,$(1)),linux,$(1)))))))
endef

build_os := $(call _pick_os,$(build_full_os))
host_os  := $(call _pick_os,$(host_full_os))

# -----------------------------------------------------------------------------
# Prefixes (config.site ends up in depends/<host>/share/config.site)
# -----------------------------------------------------------------------------
$(host_arch)_$(host_os)_prefix := $(BASEDIR)/$(host)
$(host_arch)_$(host_os)_host   := $(host)
host_prefix                    := $($(host_arch)_$(host_os)_prefix)
build_prefix                   := $(host_prefix)/native
build_host                     := $(build_canon)

# Release type derived from DEBUG
ifeq ($(strip $(DEBUG)),)
  release_type := release
else
  release_type := debug
endif

# -----------------------------------------------------------------------------
# Android helpers (Make-friendly; CI usually sets these env vars)
# -----------------------------------------------------------------------------
ANDROID_SDK ?= $(ANDROID_SDK_ROOT)
ANDROID_API ?= 25  # override via env if needed

ifneq ($(strip $(ANDROID_NDK)),)
ANDROID_TOOLCHAIN_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
android_CC      := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang
android_CXX     := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang++
android_AR      := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB  := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP   := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_SYSROOT := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot
export ANDROID_NDK ANDROID_API android_CC android_CXX android_AR android_RANLIB android_STRIP android_SYSROOT
endif

ifeq ($(host_os),android)
  ifeq ($(strip $(ANDROID_SDK)$(ANDROID_SDK_ROOT)),)
    $(error ANDROID_SDK/ANDROID_SDK_ROOT is not set. Export it before building.)
  endif
endif

# -----------------------------------------------------------------------------
# Includes: hosts/builders FIRST, packages SECOND (important ordering)
# -----------------------------------------------------------------------------
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

# Packages (must come BEFORE we assemble package lists)
include packages/packages.mk

# funcs.mk macro helpers (used below)
include funcs.mk

# -----------------------------------------------------------------------------
# Assemble package sets (honors your feature toggles)
# -----------------------------------------------------------------------------
# Your explicit list — fine to keep; add to native_packages later.
PACKAGES := miniupnpc boost openssl protobuf zmq

NO_QT       ?=
NO_PROTOBUF ?=
NO_OPENSSL  ?=
NO_WALLET   ?=
NO_ZMQ      ?=
NO_UPNP     ?=
NO_NATPMP   ?=

qt_packages_$(NO_QT)         = $(qt_packages) $(qt_$(host_os)_packages) $(qt_$(host_arch)_$(host_os)_packages)
wallet_packages_$(NO_WALLET) = $(wallet_packages)
upnp_packages_$(NO_UPNP)     = $(upnp_packages)
natpmp_packages_$(NO_NATPMP) = $(natpmp_packages)
zmq_packages_$(NO_ZMQ)       = $(zmq_packages)

protobuf_packages_$(NO_PROTOBUF) = $(protobuf_packages)
openssl_packages_$(NO_OPENSSL)   = $(openssl_packages)

packages  += $($(host_arch)_$(host_os)_packages) $($(host_os)_packages) \
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

# Your explicit list included in native group (as you had)
native_packages += $(PACKAGES)

all_packages = $(packages) $(native_packages)

# -----------------------------------------------------------------------------
# Safety net: default any missing $(package)_source_dir to a sensible path
# (prevents 'mkdir: missing operand' if a package .mk forgot to set it)
# -----------------------------------------------------------------------------
$(foreach package,$(all_packages), \
  $(if $($(package)_source_dir),, \
    $(eval $(package)_source_dir := $(SOURCES_PATH)/$(package)) ) )

# -----------------------------------------------------------------------------
# Build IDs (invalidate cache on toolchain change)
# -----------------------------------------------------------------------------
config_site_in := $(BASEDIR)/depends/config.site.in

build_id_string   := $(BUILD_ID_SALT)
build_id_string   += $(shell $(build_CC)  --version 2>/dev/null)
build_id_string   += $(shell $(build_AR)  --version 2>/dev/null)
build_id_string   += $(shell $(build_CXX) --version 2>/dev/null)
build_id_string   += $(shell $(build_RANLIB) --version 2>/dev/null)
build_id_string   += $(shell $(build_STRIP) --version 2>/dev/null)

$(host_arch)_$(host_os)_id_string := $(HOST_ID_SALT)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CC)  --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_AR)  --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CXX) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_RANLIB) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_STRIP) --version 2>/dev/null)

ifneq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
  build_id_string                   += system_clang
  $(host_arch)_$(host_os)_id_string += system_clang
endif

final_build_id_long += $(shell $(build_SHA256SUM) $(config_site_in))
final_build_id      += $(shell echo -n "$(final_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH))

# -----------------------------------------------------------------------------
# Core targets
# -----------------------------------------------------------------------------
AT_$(V) :=
AT_      := @
AT       := $(AT_$(V))

all: install

# -----------------------------------------------------------------------------
# Cache/source checks (now bulletproof)
# -----------------------------------------------------------------------------
define check_or_remove_cached
  mkdir -p $(BASE_CACHE)/$(host)/$(package) && cd $(BASE_CACHE)/$(host)/$(package); \
  $(build_SHA256SUM) -c $($(package)_cached_checksum) >/dev/null 2>/dev/null || \
  ( rm -f $($(package)_cached_checksum); \
    if test -f "$($(package)_cached)"; then echo "Checksum mismatch for $(package). Forcing rebuild.."; rm -f $($(package)_cached_checksum) $($(package)_cached); fi )
endef

define check_or_remove_sources
  sd="$($(package)_source_dir)"; \
  if [ -n "$$sd" ]; then \
    mkdir -p "$$sd"; cd "$$sd"; \
    if [ -n "$($(package)_fetched)" ] && [ -f "$($(package)_fetched)" ]; then \
      $(build_SHA256SUM) -c "$($(package)_fetched)" >/dev/null 2>/dev/null || \
      ( echo "Checksum missing or mismatched for $(package) source. Forcing re-download."; \
        rm -f $($(package)_all_sources) "$($(package)_fetched)"); \
    fi; \
  else \
    echo "WARNING: $(package): missing _source_dir; skipping source check"; \
  fi
endef

check-packages:
	@$(foreach package,$(all_packages),$(call check_or_remove_cached,$(package));)

check-sources:
	@$(foreach package,$(all_packages),$(call check_or_remove_sources,$(package));)

# -----------------------------------------------------------------------------
# config.site (must be depends/<host>/share/config.site)
# -----------------------------------------------------------------------------
$(host_prefix)/share/config.site: $(config_site_in) $(host_prefix)/.stamp_$(final_build_id)
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

# -----------------------------------------------------------------------------
# Stage unpack cached artifacts into <host> prefix
# -----------------------------------------------------------------------------
$(host_prefix)/.stamp_$(final_build_id): $(native_packages) $(packages)
	$(AT)rm -rf $(@D)
	$(AT)mkdir -p $(@D)
	$(AT)echo "Copying packages: $^"
	$(AT)echo "To: $(@D)"
	$(AT)cd $(@D); $(foreach package,$^, tar xf $($(package)_cached); )
	$(AT)touch $@

# Wiring
$(host_prefix)/share/config.site: check-packages
check-packages: check-sources

# -----------------------------------------------------------------------------
# Doctor & debug helpers
# -----------------------------------------------------------------------------
.PHONY: doctor print-all_packages
doctor:
	@echo "== depends doctor =="
	@fail=0; \
	for p in $(all_packages); do \
	  sd=$$($${p}_source_dir); fn=$$($${p}_file_name); url=$$($${p}_download_path); \
	  if [ -z "$$sd" ] || [ -z "$$fn" ] || [ -z "$$url" ]; then \
	    echo "!! $$p: missing one of [source_dir|file_name|download_path]"; \
	    echo "   source_dir='$$sd' file_name='$$fn' url='$$url'"; \
	    fail=1; \
	  fi; \
	done; \
	test $$fail -eq 0

print-all_packages:
	@echo "all_packages = $(all_packages)"

# -----------------------------------------------------------------------------
# Clean / install
# -----------------------------------------------------------------------------
clean-all: clean
	@rm -rf $(SOURCES_PATH) x86_64* i686* mips* arm* aarch64* riscv32* riscv64*

clean:
	@rm -rf $(WORK_PATH) $(BASE_CACHE) $(BUILD)

install: check-packages $(host_prefix)/share/config.site

# -----------------------------------------------------------------------------
# Download helpers
# -----------------------------------------------------------------------------
download-one: check-sources $(all_sources)

download-osx:
	@$(MAKE) -s HOST=x86_64-apple-darwin download-one
download-linux:
	@$(MAKE) -s HOST=x86_64-unknown-linux-gnu download-one
download-win:
	@$(MAKE) -s HOST=x86_64-w64-mingw32 download-one
download: download-osx download-linux download-win

# Expand package stages declared in packages/*.mk via funcs.mk
$(foreach package,$(all_packages),$(eval $(call ext_add_stages,$(package))))

.PHONY: install cached clean clean-all download-one download-osx download-linux download-win download check-packages check-sources
