# NDK r25+: use llvm-* binutils, and force sysroot+API into flags so tools never retarget. — Setvin

ifeq ($(HOST),armv7a-linux-android)
# Set paths for armv7 architecture
android_CXX=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)eabi$(ANDROID_API_LEVEL)-clang++
android_CC=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)eabi$(ANDROID_API_LEVEL)-clang
else
# Set paths for other Android architectures
android_CXX=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)$(ANDROID_API_LEVEL)-clang++
android_CC=$(ANDROID_TOOLCHAIN_BIN)/$(HOST)$(ANDROID_API_LEVEL)-clang
endif

# Define the location for binutils tools for Android
android_AR=$(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB=$(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP=$(ANDROID_TOOLCHAIN_BIN)/llvm-strip

# Define sysroot path for Android NDK
android_SYSROOT:=$(ANDROID_TOOLCHAIN_BIN)/../sysroot

# Add sysroot and Android API level to the C++ preprocessor and compiler flags
android_CPPFLAGS+= --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CFLAGS+=   --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
android_CXXFLAGS+= --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)

# Add sysroot to linker flags for Android
android_LDFLAGS+=  --sysroot=$(android_SYSROOT)

# You can now use the variables like $(android_CXX), $(android_CC), $(android_AR), etc., in your build process.
