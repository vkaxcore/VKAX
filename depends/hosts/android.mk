# File: depends/hosts/android.mk
# Purpose: Android toolchain config for depends (daemon/cli/tx). API default 21 + NDK r23b.
# Key vars/switches:
#   ANDROID_NDK_HOME / ANDROID_NDK: points to NDK root (required)
#   ANDROID_API or ANDROID_API_LEVEL: default 21
#   HOST: aarch64-linux-android | arm-linux-androideabi | armv7a-linux-android
#   LEGACY_AARCH64 (0|1): if 1 and HOST=aarch64-linux-android, bumps API to LEGACY_AARCH64_API when not set upstream
#   LEGACY_AARCH64_API: default 25 (only used when LEGACY_AARCH64=1 and API not set)
# Exports:
#   ANDROID_TOOLCHAIN_BIN, ANDROID_SYSROOT, NO_QT=1, android_* flags, host_{AR,RANLIB,STRIP}
# Behavior:
#   - Correct tuple compilers: aarch64-linux-android21-*, armv7a-linux-android21-*
#   - Adds -latomic only for 32-bit arm at API-21
#   - V=1 prints tracing
#   - Tuple compilers: aarch64-linux-android21-*, armv7a-linux-androideabi21-*
#   - Exports sysroot and -D__ANDROID_API__=21 to C/C++
#   - Adds -latomic only for 32-bit arm at API-21
#   - Optional LEGACY_AARCH64 toggle to bump API if explicitly enabled

# Input vars
HOST                ?= $(host)
ANDROID_NDK         ?= $(ANDROID_NDK_HOME)
ANDROID_API_LEVEL   ?= $(if $(ANDROID_API),$(ANDROID_API),21)
LEGACY_AARCH64      ?= 0
LEGACY_AARCH64_API  ?= 25

# Basic platform detection for host tag
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Host tag for NDK prebuilt
ifeq ($(findstring Linux,$(UNAME_S)),Linux)
  ifeq ($(findstring aarch64,$(UNAME_M)),aarch64)
    NDK_HOST_TAG := linux-arm64
  else
    NDK_HOST_TAG := linux-x86_64
  endif
else ifeq ($(findstring Darwin,$(UNAME_S)),Darwin)
  ifeq ($(findstring arm64,$(UNAME_M)),arm64)
    NDK_HOST_TAG := darwin-arm64
  else
    NDK_HOST_TAG := darwin-x86_64
  endif
else
  NDK_HOST_TAG := linux-x86_64
endif

# Validate NDK root early
ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK is not set. Export ANDROID_NDK_HOME or ANDROID_NDK to the NDK root)
endif

ANDROID_TOOLCHAIN_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
ANDROID_SYSROOT       := $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/sysroot

ifeq ($(wildcard $(ANDROID_TOOLCHAIN_BIN)),)
  $(error NDK toolchain bin not found: $(ANDROID_TOOLCHAIN_BIN))
endif

# API bump for legacy aarch64 lane if not provided by caller
ifneq (,$(filter aarch64-linux-android,$(HOST)))
  ifeq ($(LEGACY_AARCH64),1)
    ifeq ($(origin ANDROID_API_LEVEL), undefined)
      ANDROID_API_LEVEL := $(LEGACY_AARCH64_API)
    endif
  endif
endif

# Canonicalize HOST variants
ifneq (,$(filter arm-linux-androideabi,$(HOST)))
  ANDROID_CLANG_TRIPLE := armv7a-linux-androideabi
  ANDROID_ADDR_MODEL   := 32
else ifneq (,$(filter armv7a-linux-android,$(HOST)))
  ANDROID_CLANG_TRIPLE := armv7a-linux-androideabi
  ANDROID_ADDR_MODEL   := 32
else ifneq (,$(filter aarch64-linux-android,$(HOST)))
  ANDROID_CLANG_TRIPLE := aarch64-linux-android
  ANDROID_ADDR_MODEL   := 64
else
  $(error Unsupported HOST "$(HOST)". Expected aarch64-linux-android or arm-linux-androideabi)
endif

# Tools
android_CC    := $(ANDROID_TOOLCHAIN_BIN)/$(ANDROID_CLANG_TRIPLE)$(ANDROID_API_LEVEL)-clang
android_CXX   := $(ANDROID_TOOLCHAIN_BIN)/$(ANDROID_CLANG_TRIPLE)$(ANDROID_API_LEVEL)-clang++
host_AR       := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
host_RANLIB   := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
host_STRIP    := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip

# Flags
android_CPPFLAGS := --sysroot=$(ANDROID_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   := $(android_CPPFLAGS) -fPIC
android_CXXFLAGS := $(android_CPPFLAGS) -fPIC
android_LDFLAGS  := --sysroot=$(ANDROID_SYSROOT)

# armv7 needs libatomic on API-21
ifneq (,$(filter arm-linux-androideabi armv7a-linux-android,$(HOST)))
  android_LDFLAGS += -latomic
endif

# Map to generic host_* variables consumed by packages
host_CC       ?= $(android_CC)
host_CXX      ?= $(android_CXX)
host_CPPFLAGS ?= $(android_CPPFLAGS)
host_CFLAGS   ?= $(android_CFLAGS)
host_CXXFLAGS ?= $(android_CXXFLAGS) -static-libstdc++
host_LDFLAGS  ?= $(android_LDFLAGS)

# Exports helpful to packages
export ANDROID_NDK ANDROID_SYSROOT ANDROID_TOOLCHAIN_BIN
export ANDROID_API_LEVEL ANDROID_CLANG_TRIPLE ANDROID_ADDR_MODEL

# Tracing when V=1
ifeq ($(V),1)
  $(info [depends/android] HOST=$(HOST))
  $(info [depends/android] ANDROID_API_LEVEL=$(ANDROID_API_LEVEL))
  $(info [depends/android] TOOLCHAIN=$(ANDROID_TOOLCHAIN_BIN))
  $(info [depends/android] CC=$(android_CC))
  $(info [depends/android] CXX=$(android_CXX))
  $(info [depends/android] SYSROOT=$(ANDROID_SYSROOT))
  $(info [depends/android] LDFLAGS=$(android_LDFLAGS))
endif

# Path: depends/hosts/android.mk | 2025-09-08 UTC
