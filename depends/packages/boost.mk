package=boost
$(package)_version=1_81_0
$(package)_download_path=https://boostorg.jfrog.io/artifactory/main/release/$(subst _,.,$($(package)_version))/source/
$(package)_file_name=boost_$($(package)_version).tar.bz2
$(package)_sha256_hash=71feeed900fbccca04a3b4f2f84a7c217186f28a940ed8b7ed4725986baf99fa
$(package)_dependencies=native_b2

define $(package)_set_vars
  $(package)_config_opts_release=variant=release
  $(package)_config_opts_debug=variant=debug
  $(package)_config_opts=--layout=tagged --build-type=complete --user-config=user-config.jam
  $(package)_config_opts+=threading=multi link=static -sNO_COMPRESSION=1
  $(package)_config_opts_linux=target-os=linux threadapi=pthread runtime-link=shared
  $(package)_config_opts_darwin=target-os=darwin runtime-link=shared
  $(package)_config_opts_mingw32=target-os=windows binary-format=pe threadapi=win32 runtime-link=static
  $(package)_config_opts_x86_64=architecture=x86 address-model=64
  $(package)_config_opts_i686=architecture=x86 address-model=32
  $(package)_config_opts_aarch64=address-model=64
  $(package)_config_opts_armv7a=address-model=32
  $(package)_config_opts_i686_android=address-model=32
  $(package)_config_opts_aarch64_android=address-model=64
  $(package)_config_opts_x86_64_android=address-model=64
  $(package)_config_opts_armv7a_android=address-model=32

  ifneq (,$(findstring clang,$($(package)_cxx)))
    $(package)_toolset_$(host_os)=clang
  else
    $(package)_toolset_$(host_os)=gcc
  endif

  $(package)_config_libraries=filesystem,thread,system,chrono,date_time,regex,atomic
  $(package)_cxxflags=-std=c++17 -fvisibility=hidden
  $(package)_cxxflags_linux=-fPIC
  $(package)_cxxflags_android=-fPIC
endef

# Small patch for older Boost versions; keeps build happy in CI in some cases
define $(package)_preprocess_cmds
  # Remove unused variable (if present) to avoid build warnings-as-errors in some toolchains
  if [ -f boost/process/detail/posix/wait_group.hpp ]; then \
    sed -i.bak -e 's/int ret_sig = 0;//' boost/process/detail/posix/wait_group.hpp || true; \
  fi
  echo "using $($(package)_toolset_$(host_os)) : : $($(package)_cxx) : \"$($(package)_cflags)\" \"$($(package)_cxxflags)\" \"$($(package)_cppflags)\" \"$($(package)_ldflags)\" \"$($(package)_ar)\" \"$(host_STRIP)\" \"$(host_RANLIB)\" \"$(host_WINDRES)\" : ;" > user-config.jam || true
endef

define $(package)_config_cmds
  ./bootstrap.sh --without-icu --with-libraries=$($(package)_config_libraries) --with-toolset=$($(package)_toolset_$(host_os)) --with-bjam=b2 || true
endef

define $(package)_build_cmds
  b2 -d2 -j$(J) --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) stage || true
endef

define $(package)_stage_cmds
  b2 -d0 -j$(J) --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) install || true
endef
