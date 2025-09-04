package=boost
$(package)_version=1_81_0
$(package)_download_path=https://boostorg.jfrog.io/artifactory/main/release/$(subst _,.,$($(package)_version))/source/
$(package)_file_name=boost_$($(package)_version).tar.bz2
$(package)_sha256_hash=7d382c156c1fc6f2b00a9c0b7c6b991c37f940f2eea4a55b4b8e8cbbda5d5a35
$(package)_dependencies=native_b2

define $(package)_set_vars
  # Build variants
  $(package)_config_opts_release=variant=release
  $(package)_config_opts_debug=variant=debug
  $(package)_config_opts=--layout=tagged --build-type=complete --user-config=user-config.jam
  $(package)_config_opts+=threading=multi link=static -sNO_COMPRESSION=1

  # Platform-specific options
  $(package)_config_opts_linux=target-os=linux threadapi=pthread runtime-link=shared
  $(package)_config_opts_darwin=target-os=darwin runtime-link=shared
  $(package)_config_opts_mingw32=target-os=windows binary-format=pe threadapi=win32 runtime-link=static

  # Architecture
  $(package)_config_opts_x86_64=architecture=x86 address-model=64
  $(package)_config_opts_i686=architecture=x86 address-model=32
  $(package)_config_opts_aarch64=address-model=64
  $(package)_config_opts_armv7a=address-model=32
  $(package)_config_opts_i686_android=address-model=32
  $(package)_config_opts_aarch64_android=address-model=64
  $(package)_config_opts_x86_64_android=address-model=64
  $(package)_config_opts_armv7a_android=address-model=32

  # Toolset selection
  ifneq (,$(findstring clang,$($(package)_cxx)))
    $(package)_toolset_$(host_os)=clang
  else
    $(package)_toolset_$(host_os)=gcc
  endif

  # Libraries needed
  $(package)_config_libraries=filesystem,thread,date_time,chrono,regex,system

  # Compiler flags
  $(package)_cxxflags=-std=c++17 -fvisibility=hidden
  $(package)_cxxflags_darwin=-std=c++17 -fvisibility=hidden -Wno-enum-constexpr-conversion
  $(package)_cxxflags_linux=-fPIC
  $(package)_cxxflags_android=-fPIC
endef

# Preprocess commands: generate user-config.jam
define $(package)_preprocess_cmds
  echo "using $($(package)_toolset_$(host_os)) : : $($(package)_cxx) : \
  <cflags>\"$($(package)_cflags)\" \
  <cxxflags>\"$($(package)_cxxflags)\" \
  <compileflags>\"$($(package)_cppflags)\" \
  <linkflags>\"$($(package)_ldflags)\" \
  <archiver>\"$($(package)_ar)\" \
  <striper>\"$(host_STRIP)\" \
  <ranlib>\"$(host_RANLIB)\" \
  <rc>\"$(host_WINDRES)\" : ;" > user-config.jam
endef

# Configure commands
define $(package)_config_cmds
  ./bootstrap.sh --without-icu --with-libraries=$($(package)_config_libraries) \
  --with-toolset=$($(package)_toolset_$(host_os)) --with-bjam=b2
endef

# Build commands
define $(package)_build_cmds
  b2 -d2 -j$(nproc) -d1 --prefix=$($(package)_staging_prefix_dir) \
  $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) stage
endef

# Stage/install commands
define $(package)_stage_cmds
  b2 -d0 -j$(nproc) --prefix=$($(package)_staging_prefix_dir) \
  $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) install
endef
