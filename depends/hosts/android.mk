# File: depends/hosts/android.mk
# Android NDK toolchain wiring for VKAX depends (Bitcoin/Dash style).
# Intent: absolute tool paths, RELATIVE install prefix (no writes to /), legacy-safe; do not touch consensus.
# Director: Setvin | Summary: prevents mkdir '/aarch64-linux-android' by keeping prefix relative; exports host_prefix; loud guards.

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

# Resolve NDK + toolchain
ANDROID_NDK       ?= $(ANDROID_NDK_HOME)
ANDROID_API_LEVEL ?= $(if $(ANDROID_API),$(ANDROID_API),21)
ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK is not set; expected e.g. /path/to/android-ndk-r23c)
endif

ANDROID_TOOLCHAIN_BIN ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
ifeq ($(wildcard $(ANDROID_TOOLCHAIN_BIN)),)
  $(error ANDROID_TOOLCHAIN_BIN not found: "$(ANDROID_TOOLCHAIN_BIN)"; check ANDROID_NDK and NDK_HOST_TAG "$(NDK_HOST_TAG)")
endif

android_SYSROOT := $(ANDROID_TOOLCHAIN_BIN)/../sysroot

# Compose absolute tool paths for $(HOST)
ifeq ($(HOST),armv7a-linux-android)
  _HOST_TRIPLE_CC  := $(HOST)eabi$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)eabi$(ANDROID_API_LEVEL)-clang++
else
  _HOST_TRIPLE_CC  := $(HOST)$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)$(ANDROID_API_LEVEL)-clang++
endif

android_CC      := $(ANDROID_TOOLCHAIN_BIN)/$(_HOST_TRIPLE_CC)
android_CXX     := $(ANDROID_TOOLCHAIN_BIN)/$(_HOST_TRIPLE_CXX)
android_AR      := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB  := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_NM      := $(ANDROID_TOOLCHAIN_BIN)/llvm-nm
android_STRIP   := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_LIBTOOL :=

# Common flags
android_CPPFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CXXFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_LDFLAGS  := --sysroot=$(android_SYSROOT)

# Staging prefix/id (MUST be relative; funcs.mk rm/mkdir/cd into this)
android_prefix    := $(strip $(host))   # critical: no leading slash
android_id_string := android-ndk=$(notdir $(ANDROID_NDK)) api=$(ANDROID_API_LEVEL)

# Guard against accidental absolute prefix
ifneq (,$(filter /%,$(android_prefix)))
  $(error android_prefix must be relative, got "$(android_prefix)")
endif

# Export for funcs.mk configured stage
host_prefix ?= $(notdir $(android_prefix))  # FIXED: ensure host_prefix is relative

# Qt is not needed on Android
NO_QT ?= 1
export NO_QT

# Per-type blocks (type == $(host_arch)_android)
aarch64_android_host      := aarch64-linux-android
aarch64_android_CC        := $(ANDROID_TOOLCHAIN_BIN)/$(aarch64_android_host)$(ANDROID_API_LEVEL)-clang
aarch64_android_CXX       := $(ANDROID_TOOLCHAIN_BIN)/$(aarch64_android_host)$(ANDROID_API_LEVEL)-clang++
aarch64_android_AR        := $(android_AR)
aarch64_android_RANLIB    := $(android_RANLIB)
aarch64_android_NM        := $(android_NM)
aarch64_android_LIBTOOL   :=
aarch64_android_CPPFLAGS  := $(android_CPPFLAGS)
aarch64_android_CFLAGS    := $(android_CFLAGS)
aarch64_android_CXXFLAGS  := $(android_CXXFLAGS)
aarch64_android_LDFLAGS   := $(android_LDFLAGS)
aarch64_android_prefix    := $(android_prefix)
aarch64_android_id_string := $(android_id_string)

armv7a_android_host      := armv7a-linux-androideabi
armv7a_android_CC        := $(ANDROID_TOOLCHAIN_BIN)/$(armv7a_android_host)$(ANDROID_API_LEVEL)-clang
armv7a_android_CXX       := $(ANDROID_TOOLCHAIN_BIN)/$(armv7a_android_host)$(ANDROID_API_LEVEL)-clang++
armv7a_android_AR        := $(android_AR)
armv7a_android_RANLIB    := $(android_RANLIB)
armv7a_android_NM        := $(android_NM)
armv7a_android_LIBTOOL   :=
armv7a_android_CPPFLAGS  := $(android_CPPFLAGS)
armv7a_android_CFLAGS    := $(android_CFLAGS)
armv7a_android_CXXFLAGS  := $(android_CXXFLAGS)
armv7a_android_LDFLAGS   := $(android_LDFLAGS)
armv7a_android_prefix    := $(android_prefix)
armv7a_android_id_string := $(android_id_string)

x86_64_android_host      := x86_64-linux-android
x86_64_android_CC        := $(ANDROID_TOOLCHAIN_BIN)/$(x86_64_android_host)$(ANDROID_API_LEVEL)-clang
x86_64_android_CXX       := $(ANDROID_TOOLCHAIN_BIN)/$(x86_64_android_host)$(ANDROID_API_LEVEL)-clang++
x86_64_android_AR        := $(android_AR)
x86_64_android_RANLIB    := $(android_RANLIB)
x86_64_android_NM        := $(android_NM)
x86_64_android_LIBTOOL   :=
x86_64_android_CPPFLAGS  := $(android_CPPFLAGS)
x86_64_android_CFLAGS    := $(android_CFLAGS)
x86_64_android_CXXFLAGS  := $(android_CXXFLAGS)
x86_64_android_LDFLAGS   := $(android_LDFLAGS)
x86_64_android_prefix    := $(android_prefix)
x86_64_android_id_string := $(android_id_string)

i686_android_host      := i686-linux-android
i686_android_CC        := $(ANDROID_TOOLCHAIN_BIN)/$(i686_android_host)$(ANDROID_API_LEVEL)-clang
i686_android_CXX       := $(ANDROID_TOOLCHAIN_BIN)/$(i686_android_host)$(ANDROID_API_LEVEL)-clang++
i686_android_AR        := $(android_AR)
i686_android_RANLIB    := $(android_RANLIB)
i686_android_NM        := $(android_NM)
i686_android_LIBTOOL   :=
i686_android_CPPFLAGS  := $(android_CPPFLAGS)
i686_android_CFLAGS    := $(android_CFLAGS)
i686_android_CXXFLAGS  := $(android_CXXFLAGS)
i686_android_LDFLAGS   := $(android_LDFLAGS)
i686_android_prefix    := $(android_prefix)
i686_android_id_string := $(android_id_string)

# Aliases some recipes expect
host_AR     ?= $(android_AR)
host_RANLIB ?= $(android_RANLIB)
host_STRIP  ?= $(android_STRIP)

# Export helpers
export ANDROID_NDK
export ANDROID_API_LEVEL
export ANDROID_TOOLCHAIN_BIN
export ANDROID_SYSROOT := $(android_SYSROOT)

# CI debug (V=1)
ifeq ($(V),1)
  $(info [depends/android] HOST=$(HOST))
  $(info [depends/android] ANDROID_NDK=$(ANDROID_NDK))
  $(info [depends/android] NDK_HOST_TAG=$(NDK_HOST_TAG))
  $(info [depends/android] ANDROID_API_LEVEL=$(ANDROID_API_LEVEL))
  $(info [depends/android] ANDROID_TOOLCHAIN_BIN=$(ANDROID_TOOLCHAIN_BIN))
  $(info [depends/android] android_CC=$(android_CC))
  $(info [depends/android] android_CXX=$(android_CXX))
  $(info [depends/android] android_AR=$(android_AR))
  $(info [depends/android] android_RANLIB=$(android_RANLIB))
  $(info [depends/android] android_STRIP=$(android_STRIP))
  $(info [depends/android] android_SYSROOT=$(android_SYSROOT))
  $(info [depends/android] host_prefix=$(host_prefix))
endif

# Summary: relative android_prefix + exported host_prefix + guards; prevents writes to '/',
# tool paths are absolute; Qt disabled for Android; legacy layout preserved.  Signed: Setvin
