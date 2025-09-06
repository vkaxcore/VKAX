# VKAX — Boost 1.81.0 for Android cross-compilation (static, system layout for autotools)
package=boost
$(package)_version=1_81_0
$(package)_download_path=https://downloads.sourceforge.net/project/boost/boost/$(subst _,.,$($(package)_version))/
$(package)_file_name=boost_$($(package)_version).tar.bz2
$(package)_sha256_hash=71feeed900fbccca04a3b4f2f84a7c217186f28a940ed8b7ed4725986baf99fa
$(package)_dependencies=native_b2

# Set the number of cores (defaults to 4 if not set)
ifndef nproc
    nproc := $(shell sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)
endif

# Set Boost build configuration options
define $(package)_set_vars
    # Use system layout for Boost to avoid toolset-specific suffixes (e.g., libboost_filesystem.a)
    $(package)_config_opts=--layout=system --build-type=complete --user-config=user-config.jam
    $(package)_config_opts+=threading=multi link=static runtime-link=static -sNO_COMPRESSION=1
    $(package)_config_opts_release=variant=release
    $(package)_config_opts_debug=variant=debug

    # Platform-specific flags
    $(package)_config_opts_linux=target-os=linux threadapi=pthread
    $(package)_config_opts_android=target-os=android threadapi=pthread
    $(package)_config_opts_darwin=target-os=darwin
    $(package)_config_opts_mingw32=target-os=windows binary-format=pe threadapi=win32

    # Architecture flags for different platforms
    $(package)_config_opts_x86_64=architecture=x86 address-model=64
    $(package)_config_opts_i686=architecture=x86 address-model=32
    $(package)_config_opts_aarch64=address-model=64
    $(package)_config_opts_armv7a=address-model=32
    $(package)_config_opts_i686_android=address-model=32
    $(package)_config_opts_aarch64_android=address-model=64
    $(package)_config_opts_x86_64_android=address-model=64
    $(package)_config_opts_armv7a_android=address-model=32

    # Toolset (use Clang if available, otherwise fallback to GCC)
    ifneq (,$(findstring clang,$($(package)_cxx)))
        $(package)_toolset_$(host_os)=clang
    else
        $(package)_toolset_$(host_os)=gcc
    endif

    # Libraries used by VKAX
    $(package)_config_libraries=filesystem,thread,date_time,chrono,regex,system

    # C++ and platform-specific flags
    $(package)_cxxflags=-std=c++17 -fvisibility=hidden
    $(package)_cxxflags_linux=-fPIC
    $(package)_cxxflags_android=-fPIC
endef

# Preprocess step to create user-config.jam file for cross-compilation (Android-specific)
define $(package)_preprocess_cmds
    if [ "$(host_os)" = "android" ]; then \
        echo "using $($(package)_toolset_$(host_os)) : : $($(package)_cxx) : "\
             "<target-os>android "\
             "<cflags>\"$($(package)_cflags)\" <cxxflags>\"$($(package)_cxxflags)\" "\
             "<compileflags>\"$($(package)_cppflags)\" <linkflags>\"$($(package)_ldflags)\" "\
             "<archiver>\"$($(package)_ar)\" <striper>\"$(host_STRIP)\" <ranlib>\"$(host_RANLIB)\" : ;" \
             > user-config.jam; \
    else \
        echo "using $($(package)_toolset_$(host_os)) : : $($(package)_cxx) : "\
             "<cflags>\"$($(package)_cflags)\" <cxxflags>\"$($(package)_cxxflags)\" "\
             "<compileflags>\"$($(package)_cppflags)\" <linkflags>\"$($(package)_ldflags)\" "\
             "<archiver>\"$($(package)_ar)\" <striper>\"$(host_STRIP)\" <ranlib>\"$(host_RANLIB)\" : ;" \
             > user-config.jam; \
    fi
endef

# Configuration step to bootstrap Boost
define $(package)_config_cmds
    ./bootstrap.sh --without-icu --with-libraries=$($(package)_config_libraries) \
                   --with-toolset=$($(package)_toolset_$(host_os)) --with-bjam=b2
endef

# Build Boost using b2 (staging step)
define $(package)_build_cmds
    if [ "$(host_os)" = "android" ]; then rm -rf bin.v2; fi && \
    b2 -d2 -j$(nproc) -d1 --prefix=$($(package)_staging_prefix_dir) \
       $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) stage
endef

# Stage Boost libraries and install them to the staging prefix directory
define $(package)_stage_cmds
    b2 -d0 -j$(nproc) --prefix=$($(package)_staging_prefix_dir) \
       $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) install
endef
