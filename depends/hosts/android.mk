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

UNAME_S ?= $(shell uname -s)
UNAME_M ?= $(shell uname -m)

ifeq ($(UNAME_S),Linux)
  _NDK_HOST_OS := linux
else ifeq ($(UNAME_S),Darwin)
  _NDK_HOST_OS := darwin
else
  _NDK_HOST_OS := windows
endif

ifeq ($(findstring 64,$(UNAME_M)),64)
  _NDK_HOST_ARCH := x86_64
else ifneq (,$(filter arm64 aarch64,$(UNAME_M)))
  _NDK_HOST_ARCH := arm64
else
  _NDK_HOST_ARCH := x86_64
endif

NDK_HOST_TAG ?= $(_NDK_HOST_OS)-$(_NDK_HOST_ARCH)

ANDROID_NDK ?= $(ANDROID_NDK_HOME)
ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK is not set; expected $${ANDROID_SDK_ROOT}/ndk/<version>)
endif

ANDROID_API_LEVEL ?= $(if $(ANDROID_API),$(ANDROID_API),21)

LEGACY_AARCH64     ?= 0
LEGACY_AARCH64_API ?= 25
LEGACY_ALLOW_NDK25 ?= 1

NDK_VERSION := $(notdir $(ANDROID_NDK))

# If legacy lane explicitly requested for aarch64 and API not set by caller, bump API
ifneq (,$(filter aarch64-linux-android,$(HOST)))
  ifeq ($(LEGACY_AARCH64),1)
    ifeq ($(origin ANDROID_API_LEVEL), undefined)
      ANDROID_API_LEVEL := $(LEGACY_AARCH64_API)
    endif
  endif
endif

ANDROID_TOOLCHAIN_BIN ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
ifeq ($(wildcard $(ANDROID_TOOLCHAIN_BIN)),)
  $(error ANDROID_TOOLCHAIN_BIN not found: "$(ANDROID_TOOLCHAIN_BIN)")
endif

android_SYSROOT := $(ANDROID_TOOLCHAIN_BIN)/../sysroot

# Compose tuple compilers from HOST + API
ifneq (,$(filter aarch64-linux-android,$(HOST)))
  _HOST_TRIPLE_CC  := $(HOST)$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)$(ANDROID_API_LEVEL)-clang++
else ifneq (,$(filter arm-linux-androideabi,$(HOST)))
  _HOST_TRIPLE_CC  := armv7a-linux-android$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := armv7a-linux-android$(ANDROID_API_LEVEL)-clang++
else ifneq (,$(filter armv7a-linux-android,$(HOST)))
  _HOST_TRIPLE_CC  := $(HOST)$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)$(ANDROID_API_LEVEL)-clang++
else
  _HOST_TRIPLE_CC  := $(HOST)$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)$(ANDROID_API_LEVEL)-clang++
endif

android_CC     := $(ANDROID_TOOLCHAIN_BIN)/$(_HOST_TRIPLE_CC)
android_CXX    := $(ANDROID_TOOLCHAIN_BIN)/$(_HOST_TRIPLE_CXX)
android_AR     := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_NM     := $(ANDROID_TOOLCHAIN_BIN)/llvm-nm
android_STRIP  := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip

# Sysroot/API flags
android_CPPFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CXXFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_LDFLAGS  := --sysroot=$(android_SYSROOT)

# armv7 needs libatomic at API-21 sometimes
ifneq (,$(filter arm-linux-androideabi armv7a-linux-android,$(HOST)))
  android_LDFLAGS += -latomic
endif

# Prefix must be relative
android_prefix := $(strip $(host))
ifneq (,$(filter /%,$(android_prefix)))
  $(error android_prefix must be relative, got "$(android_prefix)")
endif
host_prefix ?= $(notdir $(android_prefix))

# Exports used by depends packages
export ANDROID_NDK
export ANDROID_API_LEVEL
export ANDROID_TOOLCHAIN_BIN
export ANDROID_SYSROOT := $(android_SYSROOT)
NO_QT ?= 1
export NO_QT

# Aliases some packages expect
host_AR     ?= $(android_AR)
host_RANLIB ?= $(android_RANLIB)
host_STRIP  ?= $(android_STRIP)

# Tracing when V=1
ifeq ($(V),1)
  $(info [depends/android] HOST=$(HOST))
  $(info [depends/android] ANDROID_API_LEVEL=$(ANDROID_API_LEVEL))
  $(info [depends/android] NDK_VERSION=$(NDK_VERSION))
  $(info [depends/android] TOOLCHAIN=$(ANDROID_TOOLCHAIN_BIN))
  $(info [depends/android] CC=$(android_CC))
  $(info [depends/android] CXX=$(android_CXX))
  $(info [depends/android] SYSROOT=$(android_SYSROOT))
  $(info [depends/android] LDFLAGS=$(android_LDFLAGS))
endif

# Path: depends/hosts/android.mk | 2025-09-07 UTC
