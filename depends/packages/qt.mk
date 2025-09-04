PACKAGE=qt
$(package)_version=5.15.10
$(package)_download_path=https://download.qt.io/archive/qt/5.15/5.15.10/single
$(package)_suffix=$(package)_version.tar.xz
$(package)_file_name=qt-everywhere-src-$(package)_suffix
$(package)_sha256_hash=0c37696f3fa3cb4c0c1f9247fa38e7d946b2cfb53a36a67b61ff61877e3fca43
$(package)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
$(package)_dependencies+= openssl
endif
$(package)_linux_dependencies=freetype fontconfig libxcb
$(package)_qt_libs=corelib network widgets gui plugins testlib

$(package)_patches=fix_qt_pkgconfig.patch mac-qmake.conf fix_configure_mac.patch fix_no_printer.patch fix_riscv64_arch.patch
$(package)_patches+= fix_rcc_determinism.patch xkb-default.patch no-xlib.patch
$(package)_patches+= fix_android_qmake_conf.patch fix_android_jni_static.patch dont_hardcode_pwd.patch
$(package)_patches+= freetype_back_compat.patch drop_lrelease_dependency.patch fix_powerpc_libpng.patch
$(package)_patches+= fix_mingw_cross_compile.patch fix_qpainter_non_determinism.patch
$(package)_patches+= fix_limits_header.patch

# Extra sources
$(package)_qttranslations_file_name=qttranslations-$($(package)_suffix)
$(package)_qttranslations_sha256_hash=9822084f8e2d2939ba39f4af4c0c2320e45d5996762a9423f833055607604ed8

$(package)_qttools_file_name=qttools-$($(package)_suffix)
$(package)_qttools_sha256_hash=3764356d80b61550ab1a07fb67c3e872c7755149accec8b153e1cbf51e02633b

$(package)_extra_sources = $($(package)_qttranslations_file_name) $($(package)_qttools_file_name)

# ---------------- Set variables ----------------
define $(package)_set_vars
  $(package)_config_opts_release = -release
  $(package)_config_opts_release += -silent
  $(package)_config_opts_debug = -debug
  $(package)_config_opts += -bindir $(build_prefix)/bin
  $(package)_config_opts += -c++std c++1z
  $(package)_config_opts += -confirm-license
  $(package)_config_opts += -hostprefix $(build_prefix)
  $(package)_config_opts += -no-compile-examples
  $(package)_config_opts += -opensource
  $(package)_config_opts += -optimized-tools
  $(package)_config_opts += -pch
  $(package)_config_opts += -pkg-config
  $(package)_config_opts += -prefix $(host_prefix)
  $(package)_config_opts += -qt-libpng
  $(package)_config_opts += -qt-libjpeg
  $(package)_config_opts += -qt-pcre
  $(package)_config_opts += -qt-harfbuzz
  $(package)_config_opts += -system-zlib
  $(package)_config_opts += -static
  $(package)_config_opts += -v
  ifeq ($(NO_OPENSSL),)
    $(package)_config_opts += -openssl-linked
  endif

  # macOS
  $(package)_config_opts_darwin = -no-dbus -no-opengl
  $(package)_config_opts_aarch64_darwin += -device-option QMAKE_APPLE_DEVICE_ARCHS=arm64

  # Linux
  $(package)_config_opts_linux  = -qt-xkbcommon-x11 -qt-xcb -no-xcb-xlib -no-feature-xlib
  $(package)_config_opts_linux += -system-freetype -fontconfig -no-opengl -dbus-runtime
  $(package)_config_opts_arm_linux += -platform linux-g++ -xplatform bitcoin-linux-g++
  $(package)_config_opts_i686_linux  = -xplatform linux-g++-32
  ifneq (,$(findstring -stdlib=libc++,$($(1)_cxx)))
    $(package)_config_opts_x86_64_linux = -xplatform linux-clang-libc++
  else
    $(package)_config_opts_x86_64_linux = -xplatform linux-g++-64
  endif
  $(package)_config_opts_aarch64_linux = -xplatform linux-aarch64-gnu-g++
  $(package)_config_opts_riscv64_linux = -platform linux-g++ -xplatform bitcoin-linux-g++

  # Windows / MinGW
  $(package)_config_opts_mingw32 = -no-opengl -no-dbus -xplatform win32-g++
endef

# ---------------- Fetch ----------------
define $(package)_fetch_cmds
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_file_name),$($(package)_file_name),$($(package)_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash))
endef

# ---------------- Extract ----------------
define $(package)_extract_cmds
  mkdir -p $($(package)_extract_dir) && \
  echo "$($(package)_sha256_hash)  $($(package)_source)" > $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qttranslations_sha256_hash)  $($(package)_source_dir)/$($(package)_qttranslations_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qttools_sha256_hash)  $($(package)_source_dir)/$($(package)_qttools_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  $(build_SHA256SUM) -c $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  mkdir qtbase && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C qtbase && \
  mkdir qttranslations && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C qttranslations && \
  mkdir qttools && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C qttools
endef

# ---------------- Preprocess ----------------
define $(package)_preprocess_cmds
  for patch in $($(package)_patches); do \
    patch -p1 -d $($(package)_extract_dir) < $($(package)_patch_dir)/$$patch; \
  done
  sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" qttranslations/translations/translations.pro
  mkdir -p qtbase/mkspecs/macx-clang-linux
  cp -f qtbase/mkspecs/macx-clang/qplatformdefs.h qtbase/mkspecs/macx-clang-linux/
  cp -f $($(package)_patch_dir)/mac-qmake.conf qtbase/mkspecs/macx-clang-linux/qmake.conf
  cp -r qtbase/mkspecs/linux-arm-gnueabi-g++ qtbase/mkspecs/bitcoin-linux-g++
  sed -i.old "s/arm-linux-gnueabi-/$(host)-/g" qtbase/mkspecs/bitcoin-linux-g++/qmake.conf
  echo "!host_build: QMAKE_CFLAGS     += $($(package)_cflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf
  echo "!host_build: QMAKE_CXXFLAGS   += $($(package)_cxxflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf
  echo "!host_build: QMAKE_LFLAGS     += $($(package)_ldflags)" >> qtbase/mkspecs/common/gcc-base.conf
  sed -i.old "s|QMAKE_CFLAGS           += |!host_build: QMAKE_CFLAGS            = $($(package)_cflags) $($(package)_cppflags) |" qtbase/mkspecs/win32-g++/qmake.conf
  sed -i.old "s|QMAKE_CXXFLAGS         += |!host_build: QMAKE_CXXFLAGS            = $($(package)_cxxflags) $($(package)_cppflags) |" qtbase/mkspecs/win32-g++/qmake.conf
  sed -i.old "0,/^QMAKE_LFLAGS_/s|^QMAKE_LFLAGS_|!host_build: QMAKE_LFLAGS            = $($(package)_ldflags)\n&|" qtbase/mkspecs/win32-g++/qmake.conf
  sed -i.old "s|QMAKE_CC                = clang|QMAKE_CC                = $($(package)_cc)|" qtbase/mkspecs/common/clang.conf
  sed -i.old "s|QMAKE_CXX               = clang++|QMAKE_CXX               = $($(package)_cxx)|" qtbase/mkspecs/common/clang.conf
  sed -i.old "s/error(\"failed to parse default search paths from compiler output\")/\!darwin: error(\"failed to parse default search paths from compiler output\")/g" qtbase/mkspecs/features/toolchain.prf
endef

# ---------------- Config ----------------
define $(package)_config_cmds
  export PKG_CONFIG_SYSROOT_DIR=/ && \
  export PKG_CONFIG_LIBDIR=$(host_prefix)/lib/pkgconfig && \
  export PKG_CONFIG_PATH=$(host_prefix)/share/pkgconfig && \
  cd qtbase && \
  ./configure $($(package)_config_opts) && \
  echo "host_build: QT_CONFIG ~= s/system-zlib/zlib" >> mkspecs/qconfig.pri && \
  echo "CONFIG += force_bootstrap" >> mkspecs/qconfig.pri && \
  cd .. && \
  $(MAKE) -C qtbase sub-src-clean && \
  qtbase/bin/qmake -o qttranslations/Makefile qttranslations/qttranslations.pro && \
  qtbase/bin/qmake -o qttranslations/translations/Makefile qttranslations/translations/translations.pro && \
  qtbase/bin/qmake -o qttools/src/linguist/lrelease/Makefile qttools/src/linguist/lrelease/lrelease.pro && \
  qtbase/bin/qmake -o qttools/src/linguist/lupdate/Makefile qttools/src/linguist/lupdate/lupdate.pro
endef

# ---------------- Build ----------------
define $(package)_build_cmds
  $(MAKE) -C qtbase/src $(addprefix sub-,$($(package)_qt_libs)) && \
  $(MAKE) -C qttools/src/linguist/lrelease && \
  $(MAKE) -C qttools/src/linguist/lupdate && \
  $(MAKE) -C qttranslations
endef

# ---------------- Stage ----------------
define $(package)_stage_cmds
  $(MAKE) -C qtbase/src INSTALL_ROOT=$($(package)_staging_dir) $(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs))) && \
  $(MAKE) -C qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C qttools/src/linguist/lupdate INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C qttranslations INSTALL_ROOT=$($(package)_staging_dir) install_subtargets
endef

# ---------------- Postprocess ----------------
define $(package)_postprocess_cmds
  rm -rf native/mkspecs/ native/lib/ lib/cmake/ && \
  rm -f lib/lib*.la lib/*.prl plugins/*/*.prl
endef
