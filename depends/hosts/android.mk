# File: depends/hosts/android.mk

HOST                ?= $(HOST)                  # do not use $(host); avoid recursive trap
ANDROID_NDK         ?= $(if $(ANDROID_NDK_HOME),$(ANDROID_NDK_HOME),$(ANDROID_NDK))
ANDROID_API_LEVEL   ?= $(if $(ANDROID_API),$(ANDROID_API),21)
LEGACY_AARCH64      ?= 0
LEGACY_AARCH64_API  ?= 25

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

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
else ifneq (,$(filter MSYS_NT-% CYGWIN_NT-% MINGW%,$(UNAME_S)))
  NDK_HOST_TAG := windows-x86_64
else
  NDK_HOST_TAG := linux-x86_64
endif

ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK/ANDROID_NDK_HOME is not set)
endif

NDK_ROOT    := $(ANDROID_NDK)
NDK_BIN     := $(NDK_ROOT)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
NDK_SYSROOT := $(NDK_ROOT)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/sysroot

ifeq ($(wildcard $(NDK_BIN)),)
  $(error NDK toolchain bin not found: $(NDK_BIN))
endif
ifeq ($(wildcard $(NDK_SYSROOT)),)
  $(error NDK sysroot not found: $(NDK_SYSROOT))
endif

# Canonicalize HOST to clang triple and address model
ifneq (,$(filter aarch64-linux-android,$(HOST)))
  ANDROID_CLANG_TRIPLE := aarch64-linux-android
  ANDROID_ADDR_MODEL   := 64
else ifneq (,$(filter arm-linux-androideabi,$(HOST)))
  ANDROID_CLANG_TRIPLE := armv7a-linux-androideabi
  ANDROID_ADDR_MODEL   := 32
else ifneq (,$(filter armv7a-linux-android,$(HOST)))
  ANDROID_CLANG_TRIPLE := armv7a-linux-androideabi
  ANDROID_ADDR_MODEL   := 32
else
  $(error Unsupported HOST "$(HOST)"; expected aarch64-linux-android or arm-linux-androideabi)
endif

# Optional legacy bump for aarch64 when enabled and API not provided
ifneq (,$(filter aarch64-linux-android,$(HOST)))
  ifeq ($(LEGACY_AARCH64),1)
    ifeq ($(origin ANDROID_API), undefined)
      ANDROID_API_LEVEL := $(LEGACY_AARCH64_API)
    endif
  endif
endif

# Tools
android_CC   := $(NDK_BIN)/$(ANDROID_CLANG_TRIPLE)$(ANDROID_API_LEVEL)-clang
android_CXX  := $(NDK_BIN)/$(ANDROID_CLANG_TRIPLE)$(ANDROID_API_LEVEL)-clang++
host_AR      := $(NDK_BIN)/llvm-ar
host_RANLIB  := $(NDK_BIN)/llvm-ranlib
host_STRIP   := $(NDK_BIN)/llvm-strip

# Flags
android_CPPFLAGS := --sysroot=$(NDK_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   := $(android_CPPFLAGS) -fPIC
android_CXXFLAGS := $(android_CPPFLAGS) -fPIC
android_LDFLAGS  := --sysroot=$(NDK_SYSROOT)

# API-21 armv7 needs libatomic
ifneq (,$(filter 32,$(ANDROID_ADDR_MODEL)))
  android_LDFLAGS += -latomic
endif

# Exported host tool vars (consumed by depends)
host_CC       ?= $(android_CC)
host_CXX      ?= $(android_CXX)
host_CPPFLAGS ?= $(android_CPPFLAGS)
host_CFLAGS   ?= $(android_CFLAGS)
host_CXXFLAGS ?= $(android_CXXFLAGS) -static-libstdc++
host_LDFLAGS  ?= $(android_LDFLAGS)

# Optional ccache wrapper; enable via USE_CCACHE=1
ifeq ($(USE_CCACHE),1)
  host_CC  := ccache $(host_CC)
  host_CXX := ccache $(host_CXX)
endif

# Stable debug prefix map to improve ccache reuse; set DEBUG_PREFIX_MAP to "workdir=/src"
ifneq ($(strip $(DEBUG_PREFIX_MAP)),)
  host_CFLAGS   := $(host_CFLAGS)   -fdebug-prefix-map=$(DEBUG_PREFIX_MAP)
  host_CXXFLAGS := $(host_CXXFLAGS) -fdebug-prefix-map=$(DEBUG_PREFIX_MAP)
endif

export ANDROID_NDK ANDROID_API_LEVEL ANDROID_CLANG_TRIPLE ANDROID_ADDR_MODEL
export NDK_ROOT NDK_BIN NDK_SYSROOT
export host_AR host_RANLIB host_STRIP

# Debug trace
ifeq ($(V),1)
  $(info [android.mk] HOST=$(HOST))
  $(info [android.mk] ANDROID_API_LEVEL=$(ANDROID_API_LEVEL))
  $(info [android.mk] CLANG_TRIPLE=$(ANDROID_CLANG_TRIPLE))
  $(info [android.mk] NDK_BIN=$(NDK_BIN))
  $(info [android.mk] CC=$(host_CC))
  $(info [android.mk] CXX=$(host_CXX))
  $(info [android.mk] LDFLAGS=$(host_LDFLAGS))
endif

# Aggregate dumps (for CI audits)
.PHONY: print-all-host
print-all-host:
	@printf '%s=%s\n' 'TARGET_HOST' '$(HOST)'
	@printf '%s=%s\n' 'ANDROID_CLANG_TRIPLE' '$(ANDROID_CLANG_TRIPLE)'
	@printf '%s=%s\n' 'ANDROID_API_LEVEL' '$(ANDROID_API_LEVEL)'
	@printf '%s=%s\n' 'host_CC' '$(host_CC)'
	@printf '%s=%s\n' 'host_CXX' '$(host_CXX)'
	@printf '%s=%s\n' 'host_LDFLAGS' '$(host_LDFLAGS)'

.PHONY: print-all-ndk
print-all-ndk:
	@printf '%s=%s\n' 'NDK_HOST_TAG' '$(NDK_HOST_TAG)'
	@printf '%s=%s\n' 'NDK_BIN' '$(NDK_BIN)'
	@printf '%s=%s\n' 'NDK_SYSROOT' '$(NDK_SYSROOT)'
