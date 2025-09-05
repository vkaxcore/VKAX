# NDK r25+: use llvm-* binutils, and force sysroot+API into flags so tools never retarget. — Setvin

ifeq ($(HOST),armv7a-linux-android)
android_CXX=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)eabi$(ANDROID_API_LEVEL)-clang++
android_CC=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)eabi$(ANDROID_API_LEVEL)-clang
else
android_CXX=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)$(ANDROID_API_LEVEL)-clang++
android_CC=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)$(ANDROID_API_LEVEL)-clang
endif

android_AR=$(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB=$(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP=$(ANDROID_TOOLCHAIN_BIN)/llvm-strip

android_SYSROOT:=$(ANDROID_TOOLCHAIN_BIN)/../sysroot
android_CPPFLAGS+= --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS+=   --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CXXFLAGS+= --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_LDFLAGS+=  --sysroot=$(android_SYSROOT)

# Ensure the NDK is being used properly by setting the correct toolchain
export ANDROID_CXX=$(android_CXX)
export ANDROID_CC=$(android_CC)
export ANDROID_AR=$(android_AR)
export ANDROID_RANLIB=$(android_RANLIB)
export ANDROID_STRIP=$(android_STRIP)
export ANDROID_SYSROOT=$(android_SYSROOT)
export ANDROID_CPPFLAGS=$(android_CPPFLAGS)
export ANDROID_CFLAGS=$(android_CFLAGS)
export ANDROID_CXXFLAGS=$(android_CXXFLAGS)
export ANDROID_LDFLAGS=$(android_LDFLAGS)
