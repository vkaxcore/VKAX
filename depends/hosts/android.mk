# File: depends/hosts/android.mk

# Resolve target once; avoid HOST<->host recursion
TARGET_HOST := $(if $(HOST),$(HOST),$(host))

ANDROID_NDK        ?= $(if $(ANDROID_NDK_HOME),$(ANDROID_NDK_HOME),$(ANDROID_NDK))
LEGACY_AARCH64     ?= 0
LEGACY_AARCH64_API ?= 25

# Belt-and-suspenders: error if both are set but disagree
ifeq (1,$(and $(HOST),$(host)))
  ifneq ($(HOST),$(host))
    $(error HOST ($(HOST)) and host ($(host)) differ; set only one)
  endif
endif

# Determine API level (caller wins)
ifndef ANDROID_API_LEVEL
  ifdef ANDROID_API
    ANDROID_API_LEVEL := $(ANDROID_API)
  else
    ANDROID_API_LEVEL := 21
  endif
endif

# Detect host tag for NDK prebuilt
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

# Validate NDK
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

# Legacy bump only if caller did NOT provide API through env/CLI, and current level is default 21
API_FROM_ENV_OR_CLI := $(or $(filter environment command line,$(origin ANDROID_API_LEVEL)),$(filter environment command line,$(origin ANDROID_API)))
ifneq (,$(filter aarch64-linux-android,$(TARGET_HOST)))
  ifeq ($(LEGACY_AARCH64),1)
    ifeq ($(strip $(API_FROM_ENV_OR_CLI)),)
      ifeq ($(ANDROID_API_LEVEL),21)
        ANDROID_API_LEVEL := $(LEGACY_AARCH64_API)
      endif
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

ifneq (,$(filter 32,$(ANDROID_ADDR_MODEL)))
  android_LDFLAGS += -latomic
endif

# Export to depends packages
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
