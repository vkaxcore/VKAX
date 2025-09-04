PACKAGE=qt
$(package)_version=5.15.10
$(package)_download_path=https://download.qt.io/archive/qt/5.15/$($(package)_version)/single
$(package)_suffix=opensource-src-$($(package)_version).tar.xz

# Source tarballs
$(package)_file_name=qtbase-$($(package)_suffix)
$(package)_sha256_hash=0c37696f3fa3cb4c0c1f9247fa38e7d946b2cfb53a36a67b61ff61877e3fca43
$(package)_qttranslations_file_name=qttranslations-$($(package)_suffix)
$(package)_qttranslations_sha256_hash=9822084f8e2d2939ba39f4af4c0c2320e45d5996762a9423f833055607604ed8
$(package)_qttools_file_name=qttools-$($(package)_suffix)
$(package)_qttools_sha256_hash=50e75417ec0c74bb8b1989d1d8e981ee83690dce7dfc0c2169f7c00f397e5117

# Dependencies
$(package)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
$(package)_dependencies+= openssl
endif

# QT libraries to build
$(package)_qt_libs=core gui widgets network

# VKAX patches
$(package)_patches=\
  fix_qt_pkgconfig.patch \
  mac-qmake.conf \
  fix_configure_mac.patch \
  fix_rcc_determinism.patch \
  fix_no_printer.patch \
  fix_riscv64_arch.patch \
  xkb-default.patch \
  no-xlib.patch \
  fix_android_qmake_conf.patch \
  fix_android_jni_static.patch \
  dont_hardcode_pwd.patch \
  freetype_back_compat.patch \
  drop_lrelease_dependency.patch \
  fix_powerpc_libpng.patch \
  fix_mingw_cross_compile.patch \
  fix_qpainter_non_determinism.patch \
  fix_limits_header.patch

# Extra sources
$(package)_extra_sources  = $($(package)_qttranslations_file_name) $($(package)_qttools_file_name)

# --- Fetch all sources ---
define $(package)_fetch_cmds
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_file_name),$($(package)_file_name),$($(package)_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash))
endef

# --- Extract all sources ---
define $(package)_extract_cmds
  mkdir -p $($(package)_extract_dir) && \
  $(build_SHA256SUM) -c <(echo "$($(package)_sha256_hash)  $($(package)_source)"; \
  echo "$($(package)_qttranslations_sha256_hash)  $($(package)_source_dir)/$($(package)_qttranslations_file_name)"; \
  echo "$($(package)_qttools_sha256_hash)  $($(package)_source_dir)/$($(package)_qttools_file_name)")) && \
  mkdir -p qtbase qttranslations qttools && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C qtbase && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C qttranslations && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C qttools
endef

# --- Preprocess: Apply VKAX patches ---
define $(package)_preprocess_cmds
  for patch in $($(package)_patches); do \
    patch -p1 -i $($(package)_patch_dir)/$$patch; \
  done
  # Setup mac mkspecs
  mkdir -p qtbase/mkspecs/macx-clang-linux && \
  cp -f qtbase/mkspecs/macx-clang/qplatformdefs.h qtbase/mkspecs/macx-clang-linux/ && \
  cp -f $($(package)_patch_dir)/mac-qmake.conf qtbase/mkspecs/macx-clang-linux/qmake.conf
endef

# --- Configure Qt ---
define $(package)_config_cmds
  cd qtbase && \
  ./configure \
    -prefix $(host_prefix) \
    -release \
    -opensource \
    -optimized-tools \
    -static \
    -no-pch \
    -no-compile-examples \
    -nomake examples \
    -nomake tests \
    -no-dbus \
    -no-opengl \
    -no-cups \
    -no-feature-printdialog \
    -no-feature-printer \
    -no-feature-pdf \
    -qt-libpng \
    -qt-libjpeg \
    -qt-harfbuzz \
    -system-zlib \
    $(if $(NO_OPENSSL),,-openssl-linked)
endef

# --- Build Qt ---
define $(package)_build_cmds
  $(MAKE) -C qtbase -j8 $(addprefix sub-,$($(package)_qt_libs)) && \
  $(MAKE) -C qttools/src/linguist/lrelease && \
  $(MAKE) -C qttools/src/linguist/lupdate && \
  $(MAKE) -C qttranslations
endef

# --- Stage Qt ---
define $(package)_stage_cmds
  $(MAKE) -C qtbase INSTALL_ROOT=$($(package)_staging_dir) $(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs))) && \
  $(MAKE) -C qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C qttools/src/linguist/lupdate INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C qttranslations INSTALL_ROOT=$($(package)_staging_dir) install_subtargets
endef

# --- Postprocess ---
define $(package)_postprocess_cmds
  rm -rf native/mkspecs/ native/lib/ lib/cmake/ && \
  rm -f lib/lib*.la lib/*.prl plugins/*/*.prl
endef
