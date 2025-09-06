# builders/android.mk

# Set up the Android-specific configurations

# Path to the NDK
ANDROID_NDK := $(BASEDIR)/android-sdk/ndk/android-ndk-r23c

# Define the Android API version
ANDROID_API := 21

# Set up the Android toolchain and sysroot
ANDROID_TOOLCHAIN_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
android_CC := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang
android_CXX := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang++
android_AR := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_SYSROOT := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot

# Set up environment variables for Android
export ANDROID_NDK
export ANDROID_API
export android_CC
export android_CXX
export android_AR
export android_RANLIB
export android_STRIP
export android_SYSROOT

# Set the NDK path for Qt build (if you're building Qt)
QT_ANDROID_NDK_PATH := $(ANDROID_NDK)
QT_ANDROID_API_LEVEL := $(ANDROID_API)

# Adding Android-specific Qt configuration options
QT_ANDROID_CONFIG_OPTS = -xplatform android-clang
QT_ANDROID_CONFIG_OPTS += -android-sdk $(ANDROID_SDK)
QT_ANDROID_CONFIG_OPTS += -android-ndk $(QT_ANDROID_NDK_PATH)
QT_ANDROID_CONFIG_OPTS += -android-ndk-platform android-$(ANDROID_API_LEVEL)
QT_ANDROID_CONFIG_OPTS += -device-option CROSS_COMPILE="$(host)-"
QT_ANDROID_CONFIG_OPTS += -egl  # Enable EGL support for Android

# Export the Android-specific Qt configuration
export QT_ANDROID_CONFIG_OPTS

# To ensure Qt uses the right Android-specific settings during the build
$(package)_config_opts_android = $(QT_ANDROID_CONFIG_OPTS)

