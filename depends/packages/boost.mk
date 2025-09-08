# =============================================================================
# File: depends/packages/boost.mk
# Purpose: Clean, deterministic Boost build for VKAX depends (Android-friendly)
# Notes:
#   - ASCII only, no fancy punctuation, no bidi chars.
#   - System layout so autotools finds libboost_*.a without toolset suffixes.
#   - On Android, generate user-config.jam with <target-os>android.
#   - Keep static link to dodge NDK shared-runtime headaches.
#   - Use -j$(nproc) for parallelism.
# =============================================================================

package=boost

# Version and source (also exported for native_b2)
boost_version=1_81_0
boost_download_path=https://downloads.sourceforge.net/project/boost/boost/$(subst _,.,$(boost_version))/
boost_file_name=boost_$(boost_version).tar.bz2
boost_sha256_hash=71feeed900fbccca04a3b4f2f84a7c217186f28a940ed8b7ed4725986baf99fa

$(package)_version=$(boost_version)
$(package)_download_path=$(boost_download_path)
$(package)_file_name=$(boost_file_name)
$(package)_sha256_hash=$(boost_sha256_hash)

# Dependencies
$(package)_dependencies=native_b2

# Host toolset selection
ifneq (,$(findstring clang,$($(package)_cxx)))
  $(package)_toolset_$(host_os)=clang
else
  $(package)_toolset_$(host_os)=gcc
endif

# Libraries used by VKAX
$(package)_config_libraries=filesystem,thread,date_time,chrono,regex,system

# Global config opts
$(package)_config_opts=--layout=system --build-type=complete --user-config=user-config.jam
$(package)_config_opts+=threading=multi link=static runtime-link=static -sNO_COMPRESSION=1
$(package)_config_opts_release=variant=release
$(package)_config_opts_debug=variant=debug

# Platform-specific opts
$(package)_config_opts_linux=target-os=linux threadapi=pthread
$(package)_config_opts_android=target-os=android threadapi=pthread
$(package)_config_opts_darwin=target-os=darwin
$(package)_config_opts_mingw32=target-os=windows binary-format=pe threadapi=win32

# Architecture/address-model
$(package)_config_opts_x86_64=architecture=x86 address-model=64
$(package)_config_opts_i686=architecture=x86 address-model=32
$(package)_config_opts_aarch64=architecture=arm address-model=64
$(package)_config_opts_armv7a=architecture=arm address-model=32
$(package)_config_opts_i686_android=address-model=32
$(package)_config_opts_aarch64_android=address-model=64
$(package)_config_opts_x86_64_android=address-model=64
$(package)_config_opts_armv7a_android=address-model=32

# Extra C++ flags
$(package)_cxxflags=-std=c++17 -fvisibility=hidden
$(package)_cxxflags_linux=-fPIC
$(package)_cxxflags_android=-fPIC

# CPU cores detection
ifndef nproc
nproc := $(shell sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)
endif

define $(package)_set_vars
  # rely on depends core for $(package)_cxx, cflags, cppflags, ldflags, ar, ranlib
endef

# Emit user-config.jam (OWNED HERE)
define $(package)_preprocess_cmds
  rm -f user-config.jam && \
  if [ "$(host_os)" = "android" ]; then \
    addr_model=32; arch_feature=arm; \
    case "$(host_arch)" in \
      aarch64) addr_model=64; arch_feature=arm;; \
      armv7a)  addr_model=32; arch_feature=arm;; \
      *)       addr_model=32; arch_feature=arm;; \
    esac; \
    cxx_path="$($(package)_cxx)"; \
    printf '%s\n' \
      "using clang : android-$(host_arch) : $$cxx_path :" \
      "  <target-os>android <architecture>$$arch_feature <address-model>$$addr_model" \
      "  <compileflags>\"$($(package)_cflags) $($(package)_cxxflags) $($(package)_cppflags)\"" \
      "  <linkflags>\"$($(package)_ldflags)\" ;" \
      > user-config.jam; \
  else \
    printf '%s\n' \
      "using $($(package)_toolset_$(host_os)) : : $($(package)_cxx) :" \
      "  <compileflags>\"$($(package)_cflags) $($(package)_cxxflags) $($(package)_cppflags)\"" \
      "  <linkflags>\"$($(package)_ldflags)\" ;" \
      > user-config.jam; \
  fi
endef

# Configure Boost's build system
define $(package)_config_cmds
  ./bootstrap.sh --without-icu --with-libraries=$($(package)_config_libraries) \
    --with-toolset=$($(package)_toolset_$(host_os)) --with-bjam=b2
endef

# Build
define $(package)_build_cmds
  if [ "$(host_os)" = "android" ]; then rm -rf bin.v2; fi && \
  b2 -d2 -j$(nproc) --prefix=$($(package)_staging_prefix_dir) \
     $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) stage
endef

# Install into staging prefix
define $(package)_stage_cmds
  b2 -d0 -j$(nproc) --prefix=$($(package)_staging_prefix_dir) \
     $($(package)_config_opts) toolset=$($(package)_toolset_$(host_os)) install
endef

# End of file
# Path: depends/packages/boost.mk | 2025-09-08 UTC
