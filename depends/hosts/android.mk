# depends/hosts/android.mk
# Path: depends/hosts/android.mk
# Modules: [A] host tag detect  [B] NDK vars/guards  [C] sysroot  [D] tool paths by $(HOST)  [E] common flags  [F] relative staging  [G] exports  [H] debug (V=1)
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

ANDROID_NDK       ?= $(ANDROID_NDK_HOME)
ANDROID_API_LEVEL ?= $(if $(ANDROID_API),$(ANDROID_API),21)
ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK is not set; expected $${ANDROID_SDK_ROOT}/ndk/25.2.9519653)
endif

ANDROID_TOOLCHAIN_BIN ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
ifeq ($(wildcard $(ANDROID_TOOLCHAIN_BIN)),)
  $(error ANDROID_TOOLCHAIN_BIN not found: "$(ANDROID_TOOLCHAIN_BIN)"; check ANDROID_NDK and NDK_HOST_TAG "$(NDK_HOST_TAG)")
endif

android_SYSROOT := $(ANDROID_TOOLCHAIN_BIN)/../sysroot

# Tool tuple by $(HOST)
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

# Relative staging (never absolute)
android_prefix    := $(strip $(host))
android_id_string := android-ndk=$(notdir $(ANDROID_NDK)) api=$(ANDROID_API_LEVEL)
ifneq (,$(filter /%,$(android_prefix)))
  $(error android_prefix must be relative, got "$(android_prefix)")
endif
host_prefix ?= $(notdir $(android_prefix))

# For daemon phase only
NO_QT ?= 1
export NO_QT

# Arch exports (extend if you add x86_64/i686/armv7 builds)
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

# Aliases
host_AR     ?= $(android_AR)
host_RANLIB ?= $(android_RANLIB)
host_STRIP  ?= $(android_STRIP)

# Exports
export ANDROID_NDK
export ANDROID_API_LEVEL
export ANDROID_TOOLCHAIN_BIN
export ANDROID_SYSROOT := $(android_SYSROOT)

# Debug
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
# depends/hosts/android.mk  • Setvin • 2025-09-07
