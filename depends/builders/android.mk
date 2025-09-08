# depends/builders/android.mk

ifndef ANDROID_NDK
$(error ANDROID_NDK is not set)
endif

# Allow override by external host_tag and toolchain_bin
NDK_HOST_TAG ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')-$(shell uname -m)
ANDROID_TOOLCHAIN_BIN ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
ANDROID_SYSROOT        ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/sysroot

ANDROID_CC       := $(ANDROID_TOOLCHAIN_BIN)/clang
ANDROID_CXX      := $(ANDROID_TOOLCHAIN_BIN)/clang++
ANDROID_AR       := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
ANDROID_LD       := $(ANDROID_TOOLCHAIN_BIN)/ld.lld
ANDROID_RANLIB   := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
ANDROID_STRIP    := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip

# Optional: add toolchain sanity checks
TOOLCHAIN_SANITY_CHECK := \
	$(ANDROID_CC) --version && \
	$(ANDROID_CXX) --version && \
	$(ANDROID_AR) --version

# Toolchain flags
ANDROID_SYSROOT_CFLAGS := --sysroot=$(ANDROID_SYSROOT)
ANDROID_SYSROOT_LDFLAGS := --sysroot=$(ANDROID_SYSROOT)

# Cross-toolchain export for make depends
export ANDROID_TOOLCHAIN_BIN ANDROID_SYSROOT
export ANDROID_CC ANDROID_CXX ANDROID_AR ANDROID_LD ANDROID_RANLIB ANDROID_STRIP
export ANDROID_SYSROOT_CFLAGS ANDROID_SYSROOT_LDFLAGS
