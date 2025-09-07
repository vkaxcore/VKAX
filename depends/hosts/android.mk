# depends/builders/android.mk
# Android toolchain info from env (ANDROID_NDK_HOME, ANDROID_API); no hardcoded r23c; exports absolute tool paths for aarch64.
ANDROID_NDK ?= $(ANDROID_NDK_HOME)
ANDROID_API ?= 25

ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK/ANDROID_NDK_HOME is not set)
endif

NDK_HOST_TAG ?= linux-x86_64
NDK_BIN      := $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
SYSROOT      := $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/sysroot

android_CC      := $(NDK_BIN)/aarch64-linux-android$(ANDROID_API)-clang
android_CXX     := $(NDK_BIN)/aarch64-linux-android$(ANDROID_API)-clang++
android_AR      := $(NDK_BIN)/llvm-ar
android_RANLIB  := $(NDK_BIN)/llvm-ranlib
android_STRIP   := $(NDK_BIN)/llvm-strip
android_CPPFLAGS:= --sysroot=$(SYSROOT) -D__ANDROID_API__=$(ANDROID_API)
android_CFLAGS  := --sysroot=$(SYSROOT) -D__ANDROID_API__=$(ANDROID_API)
android_CXXFLAGS:= --sysroot=$(SYSROOT) -D__ANDROID_API__=$(ANDROID_API)
android_LDFLAGS := --sysroot=$(SYSROOT)

export ANDROID_NDK ANDROID_API NDK_HOST_TAG NDK_BIN SYSROOT \
       android_CC android_CXX android_AR android_RANLIB android_STRIP \
       android_CPPFLAGS android_CFLAGS android_CXXFLAGS android_LDFLAGS
# depends/builders/android.mk • Setvin • 2025-09-07
