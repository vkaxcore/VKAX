# File: depends/hosts/android.mk
# Android toolchain tuples and flags for depends (daemon/cli/tx only).

# Use a local selector; never assign HOST from host or host from HOST.
TARGET_HOST := $(if $(HOST),$(HOST),$(host))

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

# Map TARGET_HOST to clang triple and address model
ifneq (,$(filter aarch64-linux-android,$(TARGET_HOST)))
  ANDROID_CLANG_TRIPLE := aarch64-linux-android
  ANDROID_ADDR_MODEL   := 64
else ifneq (,$(filter arm-linux-androideabi,$(TARGET_HOST)))
  ANDROID_CLANG_TRIPLE := armv7a-linux-androideabi
  ANDROID_ADDR_MODEL   := 32
else ifneq (,$(filter armv7a-linux-android,$(TARGET_HOST)))
  ANDROID_CLANG_TRIPLE := armv7a-linux-androideabi
  ANDROID_ADDR_MODEL   := 32
else
  $(error Unsupported host "$(TARGET_HOST)"; expected aarch64-linux-android or arm-linux-androideabi)
endif

# Optional legacy bump for aarch64 when enabled and API not provided by caller
ifneq (,$(filter aarch64-linux-android,$(TARGET_HOST)))
  ifeq ($(LEGACY_AARCH64),1)
    ifeq ($(origin ANDROID_API), undefined)
      ANDROID_API_LEVEL := $(LEGACY_AARCH64_API)
    endif
  endif
endif

android_CC   := $(NDK_BIN)/$(ANDROID_CLANG_TRIPLE)$(ANDROID_API_LEVEL)-clang
android_CXX  := $(NDK_BIN)/$(ANDROID_CLANG_TRIPLE)$(ANDROID_API_LEVEL)-clang++
host_AR      := $(NDK_BIN)/llvm-ar
host_RANLIB  := $(NDK_BIN)/llvm-ranlib
host_STRIP   := $(NDK_BIN)/llvm-strip

android_CPPFLAGS := --sysroot=$(NDK_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   := $(android_CPPFLAGS) -fPIC
android_CXXFLAGS := $(android_CPPFLAGS) -fPIC
android_LDFLAGS  := --sysroot=$(NDK_SYSROOT)

ifneq (,$(filter 32,$(ANDROID_ADDR_MODEL)))
  android_LDFLAGS += -latomic
endif

host_CC       ?= $(android_CC)
host_CXX      ?= $(android_CXX)
host_CPPFLAGS ?= $(android_CPPFLAGS)
host_CFLAGS   ?= $(android_CFLAGS)
host_CXXFLAGS ?= $(android_CXXFLAGS) -static-libstdc++
host_LDFLAGS  ?= $(android_LDFLAGS)

export ANDROID_NDK ANDROID_API_LEVEL ANDROID_CLANG_TRIPLE ANDROID_ADDR_MODEL
export NDK_ROOT NDK_BIN NDK_SYSROOT
export host_AR host_RANLIB host_STRIP

ifeq ($(V),1)
  $(info [android.mk] TARGET_HOST=$(TARGET_HOST))
  $(info [android.mk] ANDROID_API_LEVEL=$(ANDROID_API_LEVEL))
  $(info [android.mk] CLANG_TRIPLE=$(ANDROID_CLANG_TRIPLE))
  $(info [android.mk] NDK_BIN=$(NDK_BIN))
  $(info [android.mk] CC=$(android_CC))
  $(info [android.mk] CXX=$(android_CXX))
  $(info [android.mk] LDFLAGS=$(android_LDFLAGS))
endif
