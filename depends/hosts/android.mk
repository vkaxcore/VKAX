# depends/hosts/android.mk
# Structured Android toolchain; supports aarch64 + armv7; stable flags; no downloads.

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
ANDROID_TOOLCHAIN_BIN ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
ifeq ($(wildcard $(ANDROID_TOOLCHAIN_BIN)),)
  $(error ANDROID_TOOLCHAIN_BIN not found: "$(ANDROID_TOOLCHAIN_BIN)")
endif

android_SYSROOT := $(ANDROID_TOOLCHAIN_BIN)/../sysroot

# Compose clang tuples from HOST + API.
ifneq (,$(filter armv7a-linux-android,$(HOST)))
  _HOST_TRIPLE_CC  := $(HOST)$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)$(ANDROID_API_LEVEL)-clang++
else ifneq (,$(filter arm-linux-androideabi,$(HOST)))
  _HOST_TRIPLE_CC  := armv7a-linux-android$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := armv7a-linux-android$(ANDROID_API_LEVEL)-clang++
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
android_LIBTOOL :=

android_CPPFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CXXFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_LDFLAGS  := --sysroot=$(android_SYSROOT)

android_prefix    := $(strip $(host))
ifneq (,$(filter /%,$(android_prefix)))
  $(error android_prefix must be relative, got "$(android_prefix)")
endif
host_prefix ?= $(notdir $(android_prefix))
android_id_string := android-ndk=$(notdir $(ANDROID_NDK)) api=$(ANDROID_API_LEVEL)

export ANDROID_NDK
export ANDROID_API_LEVEL
export ANDROID_TOOLCHAIN_BIN
export ANDROID_SYSROOT := $(android_SYSROOT)

NO_QT ?= 1
export NO_QT

host_AR     ?= $(android_AR)
host_RANLIB ?= $(android_RANLIB)
host_STRIP  ?= $(android_STRIP)

ifeq ($(V),1)
  $(info [depends/android] HOST=$(HOST))
  $(info [depends/android] NDK_HOST_TAG=$(NDK_HOST_TAG))
  $(info [depends/android] ANDROID_NDK=$(ANDROID_NDK))
  $(info [depends/android] ANDROID_API_LEVEL=$(ANDROID_API_LEVEL))
  $(info [depends/android] ANDROID_TOOLCHAIN_BIN=$(ANDROID_TOOLCHAIN_BIN))
  $(info [depends/android] android_CC=$(android_CC))
  $(info [depends/android] android_CXX=$(android_CXX))
  $(info [depends/android] android_SYSROOT=$(android_SYSROOT))
  $(info [depends/android] host_prefix=$(host_prefix))
endif
