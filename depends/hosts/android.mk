# depends/hosts/android.mk
# Android NDK (r23c+) host toolchain wiring for Bitcoin/Dash-style depends.
# Fixes:
#   - Ensures absolute clang/llvm-* paths (prevents CC="/aarch64-linux-android-clang").
#   - Always defines API level for -D__ANDROID_API__ and compiler targets.
#   - Maps type key "aarch64_android" (etc) used by funcs.mk to proper *_CC/CXX/AR/RANLIB/NM/FLAGS.
#   - Keeps flags minimal and deterministic; no invasive changes to legacy logic elsewhere.
# Maintainers:
#   - ANDROID_NDK, ANDROID_NDK_HOME, or ANDROID_NDK must be exported by CI/environment.
#   - ANDROID_API_LEVEL preferred; falls back to ANDROID_API; default 21 if missing.

# -------- Resolve NDK + API level deterministically --------

ANDROID_NDK       ?= $(ANDROID_NDK_HOME)
ANDROID_API_LEVEL ?= $(if $(ANDROID_API),$(ANDROID_API),21)

# Canonical toolchain bin dir; required so CC/CXX are absolute (no leading '/').
# e.g. $ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin
ifndef ANDROID_TOOLCHAIN_BIN
ANDROID_TOOLCHAIN_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
endif

# NDK sysroot used by all compiler/linker invocations.
android_SYSROOT := $(ANDROID_TOOLCHAIN_BIN)/../sysroot

# -------- Shared per-OS (android) defaults --------

# LLVM binutils provided by NDK; same for all Android arches.
android_AR     := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP  := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_NM     := $(ANDROID_TOOLCHAIN_BIN)/llvm-nm

# Common flags injected for every Android target.
android_CPPFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS   := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CXXFLAGS := --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_LDFLAGS  := --sysroot=$(android_SYSROOT)

# Prefix under the staging dir; depends' funcs.mk appends this to per-package staging path.
# Using /$(host) preserves the canonical layout used by the rest of the framework.
android_prefix := /$(host)

# Human-readable id string mixed into build-id hashing; helps cache coherence across NDK/API bumps.
android_id_string := android-ndk=$(notdir $(ANDROID_NDK)) api=$(ANDROID_API_LEVEL)

# -------- Per-arch triplets and toolchains (type key: <arch>_android) --------
# Note: funcs.mk sets $(package)_type = $(host_arch)_$(host_os), so keys must match that pattern.

# aarch64 (arm64-v8a)
aarch64_android_host    := aarch64-linux-android
aarch64_android_CC      := $(ANDROID_TOOLCHAIN_BIN)/$(aarch64_android_host)$(ANDROID_API_LEVEL)-clang
aarch64_android_CXX     := $(ANDROID_TOOLCHAIN_BIN)/$(aarch64_android_host)$(ANDROID_API_LEVEL)-clang++
aarch64_android_AR      := $(android_AR)
aarch64_android_RANLIB  := $(android_RANLIB)
aarch64_android_NM      := $(android_NM)
aarch64_android_LIBTOOL :=
aarch64_android_CFLAGS  := $(android_CFLAGS)
aarch64_android_CXXFLAGS:= $(android_CXXFLAGS)
aarch64_android_CPPFLAGS:= $(android_CPPFLAGS)
aarch64_android_LDFLAGS := $(android_LDFLAGS)
aarch64_android_prefix  := $(android_prefix)
aarch64_android_id_string := $(android_id_string)

# armv7a (armeabi-v7a) — uses *androideabi* triple and 'eabi' suffix per NDK.
armv7a_android_host     := armv7a-linux-androideabi
armv7a_android_CC       := $(ANDROID_TOOLCHAIN_BIN)/$(armv7a_android_host)$(ANDROID_API_LEVEL)-clang
armv7a_android_CXX      := $(ANDROID_TOOLCHAIN_BIN)/$(armv7a_android_host)$(ANDROID_API_LEVEL)-clang++
armv7a_android_AR       := $(android_AR)
armv7a_android_RANLIB   := $(android_RANLIB)
armv7a_android_NM       := $(android_NM)
armv7a_android_LIBTOOL  :=
armv7a_android_CFLAGS   := $(android_CFLAGS)
armv7a_android_CXXFLAGS := $(android_CXXFLAGS)
armv7a_android_CPPFLAGS := $(android_CPPFLAGS)
armv7a_android_LDFLAGS  := $(android_LDFLAGS)
armv7a_android_prefix   := $(android_prefix)
armv7a_android_id_string := $(android_id_string)

# x86_64
x86_64_android_host     := x86_64-linux-android
x86_64_android_CC       := $(ANDROID_TOOLCHAIN_BIN)/$(x86_64_android_host)$(ANDROID_API_LEVEL)-clang
x86_64_android_CXX      := $(ANDROID_TOOLCHAIN_BIN)/$(x86_64_android_host)$(ANDROID_API_LEVEL)-clang++
x86_64_android_AR       := $(android_AR)
x86_64_android_RANLIB   := $(android_RANLIB)
x86_64_android_NM       := $(android_NM)
x86_64_android_LIBTOOL  :=
x86_64_android_CFLAGS   := $(android_CFLAGS)
x86_64_android_CXXFLAGS := $(android_CXXFLAGS)
x86_64_android_CPPFLAGS := $(android_CPPFLAGS)
x86_64_android_LDFLAGS  := $(android_LDFLAGS)
x86_64_android_prefix   := $(android_prefix)
x86_64_android_id_string := $(android_id_string)

# i686 (x86)
i686_android_host       := i686-linux-android
i686_android_CC         := $(ANDROID_TOOLCHAIN_BIN)/$(i686_android_host)$(ANDROID_API_LEVEL)-clang
i686_android_CXX        := $(ANDROID_TOOLCHAIN_BIN)/$(i686_android_host)$(ANDROID_API_LEVEL)-clang++
i686_android_AR         := $(android_AR)
i686_android_RANLIB     := $(android_RANLIB)
i686_android_NM         := $(android_NM)
i686_android_LIBTOOL    :=
i686_android_CFLAGS     := $(android_CFLAGS)
i686_android_CXXFLAGS   := $(android_CXXFLAGS)
i686_android_CPPFLAGS   := $(android_CPPFLAGS)
i686_android_LDFLAGS    := $(android_LDFLAGS)
i686_android_prefix     := $(android_prefix)
i686_android_id_string  := $(android_id_string)

# -------- Convenience exports (optional) --------
# These help external scripts/tools but are not relied upon by funcs.mk resolution.
export ANDROID_TOOLCHAIN_BIN
export ANDROID_API_LEVEL
export ANDROID_NDK
export ANDROID_SYSROOT := $(android_SYSROOT)

# Signed: Setvin
