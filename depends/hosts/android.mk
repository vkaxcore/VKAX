# depends/hosts/android.mk
# VKAX — Android host mappings for Bitcoin/Dash-style depends.
# Goal: resolve correct NDK llvm toolchain path and API level for all arches,
#       so packages see real CC/CXX/AR/RANLIB and absolute SYSROOT.
# Notes:
#  - We accept either ANDROID_API or ANDROID_API_LEVEL (default 21).
#  - We derive ANDROID_TOOLCHAIN_BIN from ANDROID_NDK and host tag.
#  - We keep legacy $(HOST) use to compose clang triplets, with eabi special-case.
#  - We DO NOT assume PATH; we hand packages absolute tools to avoid surprises.
#  - Verbose builds (V=1) will print a short diagnostic of resolved paths.
#  - Keep variable names "android_*" because depends' int_vars dereferences $(host_os)=android.
# Signed: Setvin

# ----------------------------
# Host tag detection (NDK r23+)
# ----------------------------
# Shell uname info for mapping to NDK prebuilt host tag
UNAME_S ?= $(shell uname -s)
UNAME_M ?= $(shell uname -m)

# OS component
ifeq ($(UNAME_S),Linux)
  _NDK_HOST_OS := linux
else ifeq ($(UNAME_S),Darwin)
  _NDK_HOST_OS := darwin
else
  # Covers MSYS2/CYGWIN/MINGW runners; NDK calls this "windows"
  _NDK_HOST_OS := windows
endif

# Arch component
# Normalize common machine strings to NDK tags
ifeq ($(filter x86_64 amd64,$(UNAME_M)),x86_64)
  _NDK_HOST_ARCH := x86_64
else ifeq ($(filter arm64 aarch64,$(UNAME_M)),arm64)
  _NDK_HOST_ARCH := arm64
else
  _NDK_HOST_ARCH := x86_64
endif

NDK_HOST_TAG ?= $(_NDK_HOST_OS)-$(_NDK_HOST_ARCH)

# --------------------------------------
# Inputs: ANDROID_NDK and API resolution
# --------------------------------------
# Accept old CI env ANDROID_API or newer ANDROID_API_LEVEL
ANDROID_API_LEVEL ?= $(ANDROID_API)
ANDROID_API_LEVEL ?= 21

# Toolchain bin path (absolute); do not add trailing slash
ANDROID_TOOLCHAIN_BIN ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin

# Validate critical inputs early to fail fast with a useful message
ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK is not set; expected e.g. /.../android-ndk-r23c)
endif
ifeq ($(wildcard $(ANDROID_TOOLCHAIN_BIN)),)
  $(error ANDROID_TOOLCHAIN_BIN not found: "$(ANDROID_TOOLCHAIN_BIN)"; check ANDROID_NDK and NDK host tag "$(NDK_HOST_TAG)")
endif

# -----------------------------------------
# Compose absolute tool paths per $(HOST)
# -----------------------------------------
# $(HOST) is provided by depends top-level, e.g. aarch64-linux-android, armv7a-linux-android, x86_64-linux-android, i686-linux-android
# ARMv7 needs the "androideabi" suffix per NDK tool naming.
ifeq ($(HOST),armv7a-linux-android)
  _HOST_TRIPLE_CC  := $(HOST)eabi$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)eabi$(ANDROID_API_LEVEL)-clang++
else
  _HOST_TRIPLE_CC  := $(HOST)$(ANDROID_API_LEVEL)-clang
  _HOST_TRIPLE_CXX := $(HOST)$(ANDROID_API_LEVEL)-clang++
endif

# Absolute tool binaries
android_CC     := $(ANDROID_TOOLCHAIN_BIN)/$(_HOST_TRIPLE_CC)
android_CXX    := $(ANDROID_TOOLCHAIN_BIN)/$(_HOST_TRIPLE_CXX)
android_AR     := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_NM     := $(ANDROID_TOOLCHAIN_BIN)/llvm-nm
android_STRIP  := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_LIBTOOL :=

# -------------------------
# Sysroot and common flags
# -------------------------
android_SYSROOT := $(ANDROID_TOOLCHAIN_BIN)/../sysroot

# Initialize flags if not set by outer layers, then append strict sysroot/API
android_CPPFLAGS ?=
android_CFLAGS   ?=
android_CXXFLAGS ?=
android_LDFLAGS  ?=

android_CPPFLAGS += --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   += --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CXXFLAGS += --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_LDFLAGS  += --sysroot=$(android_SYSROOT)

# -----------------------------------
# Expose for depends package resolver
# -----------------------------------
# The depends framework dereferences $(host_os)=android variables via int_vars.
android_PREFIX       ?= /usr
android_host         ?= $(HOST)
android_id_string    ?= $(HOST)-api$(ANDROID_API_LEVEL)
android_prefix       ?= $(android_PREFIX)

android_CC           := $(android_CC)
android_CXX          := $(android_CXX)
android_AR           := $(android_AR)
android_RANLIB       := $(android_RANLIB)
android_NM           := $(android_NM)
android_LIBTOOL      := $(android_LIBTOOL)

android_CPPFLAGS     := $(android_CPPFLAGS)
android_CFLAGS       := $(android_CFLAGS)
android_CXXFLAGS     := $(android_CXXFLAGS)
android_LDFLAGS      := $(android_LDFLAGS)

# Keep PATH additions minimal; packages already get build_prefix/bin first.
# We do not prepend ANDROID_TOOLCHAIN_BIN to PATH to avoid accidental host tool mixing.

# -----------------
# Verbose diagnostics
# -----------------
# Print resolved tool locations when V=1 to aid CI debugging.
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
endif
