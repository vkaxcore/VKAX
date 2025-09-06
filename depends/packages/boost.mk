# Package name and version
package=boost
$(package)_version=1_73_0  # Define the Boost version
$(package)_download_path=https://archives.boost.io/release/$(subst _,.,$($(package)_version))/source/  # URL to download Boost
$(package)_file_name=boost_$($(package)_version).tar.bz2  # File name of the downloaded Boost package
$(package)_sha256_hash=4eb3b8d442b426dc35346235c8733b5ae35ba431690e38c6a8263dce9fcbb402  # SHA256 checksum for verification
$(package)_dependencies=native_b2  # Boost requires native b2 for building

# Define configuration options based on different platforms
define $(package)_set_vars
  $(package)_config_opts_release=variant=release  # Configuration options for release builds
  $(package)_config_opts_debug=variant=debug  # Configuration options for debug builds
  $(package)_config_opts=--layout=tagged --build-type=complete --user-config=user-config.jam  # Common options for all builds
  $(package)_config_opts+=threading=multi link=static -sNO_COMPRESSION=1  # Threading, static linking, disable compression
  $(package)_config_opts_linux=target-os=linux threadapi=pthread runtime-link=shared  # Linux-specific options
  $(package)_config_opts_darwin=target-os=darwin runtime-link=shared  # macOS-specific options
  $(package)_config_opts_mingw32=target-os=windows binary-format=pe threadapi=win32 runtime-link=static  # Windows-specific options
  $(package)_config_opts_x86_64=architecture=x86 address-model=64  # 64-bit x86 architecture options
  $(package)_config_opts_i686=architecture=x86 address-model=32  # 32-bit x86 architecture options
  $(package)_config_opts_aarch64=address-model=64  # 64-bit ARM architecture options
  $(package)_config_opts_armv7a=address-model=32  # 32-bit ARMv7 architecture options
  $(package)_config_opts_i686_android=address-model=32  # 32-bit x86 Android options
  $(package)_config_opts_aarch64_android=address-model=64  # 64-bit ARM Android options
  $(package)_config_opts_x86_64_android=address-model=64  # 64-bit x86 Android options
  $(package)_config_opts_armv7a_android=address-model=32  # 32-bit ARMv7 Android options
endef

# Automatically detect which compiler (clang or gcc) to use based on the host OS
# In this case, we focus on Clang for Android builds.
define $(package)_set_toolchain
  ifneq (,$(findstring clang,$($(package)_cxx)))  # Check if clang is in the CXX environment variable
    $(package)_toolset_$(host_os)=clang  # If so, use clang as the toolchain
  else
    $(package)_toolset_$(host_os)=gcc  # Otherwise, fallback to gcc
  endif
endef

# The Boost user-config.jam file is crucial for specifying the toolchain and build options.
# For Android, we explicitly use the NDK's Clang.
define $(package)_set_user_config_jam
  # Configure Boost's build system to use the Clang compiler from the Android NDK
  echo "using clang : aarch64-android : ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android${ANDROID_API}-clang++ : <cflags>\"$($(package)_cflags)\" <cxxflags>\"$($(package)_cxxflags)\" <compileflags>\"$($(package)_cppflags)\" <linkflags>\"$($(package)_ldflags)\" <archiver>\"$($(package)_ar)\" <striper>\"$(host_STRIP)\"  <ranlib>\"$(host_RANLIB)\" ;" > user-config.jam  # Generate the user-config.jam for Android
endef

# Boost bootstrap.sh command. This command sets up Boost for building with the specified options.
define $(package)_config_cmds
  ./bootstrap.sh --without-icu --with-libraries=$($(package)_config_libraries) --with-toolset=clang --with-bjam=b2  # Run Boost's bootstrap script with the clang toolchain
endef

# Commands to build Boost using the b2 build system.
# The `-d2` flag provides verbose output during the build process.
define $(package)_build_cmds
  b2 -d2 -j4 -d1 --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) toolset=clang stage  # Build Boost libraries with the clang toolchain
endef

# Commands to install Boost into the staging directory.
define $(package)_stage_cmds
  b2 -d0 -j4 --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) toolset=clang install  # Install Boost libraries
endef

# If using Android, Boost requires custom toolchain setup. We define these steps for Android-specific builds.
define $(package)_android_build_steps
  # Set up environment variables for the Android NDK and API level.
  export ANDROID_NDK_HOME=${ANDROID_NDK_HOME}
  export ANDROID_API=${ANDROID_API}
  export HOST=aarch64-linux-android  # This is the target architecture for Android (ARM 64-bit)

  # Set up Clang toolchain for Android, using the NDK's Clang.
  export CC=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android${ANDROID_API}-clang
  export CXX=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android${ANDROID_API}-clang++
  export AR=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ar
  export RANLIB=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ranlib

  # Ensure Boost uses the Android-specific configuration options.
  make -C depends -j"$(nproc)" HOST=${HOST} ANDROID_NDK=${ANDROID_NDK_HOME} ANDROID_API=${ANDROID_API} NO_QT=1 V=1  # Build Boost dependencies for Android
endef

# This section allows Boost to be configured for other platforms (Linux, macOS, Windows) based on the host OS.
define $(package)_config_for_other_platforms
  # Add platform-specific configuration commands for non-Android builds (Linux/macOS/Windows)
  ifneq ($(host_os),android)  # If we are not targeting Android
    ./bootstrap.sh --without-icu --with-libraries=$($(package)_config_libraries) --with-toolset=$($(package)_toolset_$(host_os)) --with-bjam=b2  # Default toolchain for other platforms
  endif
endef
