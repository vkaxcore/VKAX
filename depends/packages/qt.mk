PACKAGE=qt
$(package)_version=5.15.10
$(package)_download_path=https://download.qt.io/archive/qt/5.15/$(package)_version/single
$(package)_suffix=opensource-src-$(package)_version.tar.xz
$(package)_file_name=qt-everywhere-src-$(package)_suffix
$(package)_sha256_hash=0c37696f3fa3cb4c0c1f9247fa38e7d946b2cfb53a36a67b61ff61877e3fca43

$(package)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
  $(package)_dependencies+= openssl
endif

# Extra sources
$(package)_qttranslations_file_name=qttranslations-$(package)_suffix
$(package)_qttranslations_sha256_hash=9822084f8e2d2939ba39f4af4c0c2320e45d5996762a9423f833055607604ed8

$(package)_qttools_file_name=qttools-$(package)_suffix
$(package)_qttools_sha256_hash=50e75417ec0c74bb8b1989d1d8e981ee83690dce7dfc0c2169f7c00f397e5117

$(package)_extra_sources=$(package)_qttranslations_file_name $(package)_qttools_file_name

# All patches (keep all)
$(package)_patches=\
  freetype_back_compat.patch \
  fix_powerpc_libpng.patch \
  drop_lrelease_dependency.patch \
  dont_hardcode_pwd.patch \
  fix_qt_pkgconfig.patch \
  fix_configure_mac.patch \
  fix_no_printer.patch \
  fix_rcc_determinism.patch \
  xkb-default.patch \
  fix_android_qmake_conf.patch \
  fix_android_jni_static.patch \
  fix_riscv64_arch.patch \
  no-xlib.patch \
  fix_mingw_cross_compile.patch \
  fix_qpainter_non_determinism.patch \
  fix_limits_header.patch \
  mac-qmake.conf

# Qt libraries
$(package)_qt_libs=core gui widgets network

define $(package)_set_vars
  $(package)_config_opts += -release -silent -opensource -optimized-tools -static
  $(package)_config_opts += -prefix $(host_prefix) -hostprefix $(build_prefix)
  $(package)_config_opts += -no-compile-examples -nomake examples -nomake tests
  $(package)_config_opts += -no-dbus -no-opengl -no-cups -no-feature-printdialog -no-feature-printer
  $(package)_config_opts += -qt-libpng -qt-libjpeg -qt-harfbuzz -system-zlib
  ifeq ($(NO_OPENSSL),)
    $(package)_config_opts += -openssl-linked
  endif
  $(package)_build_env = QT_RCC_TEST=1 QT_RCC_SOURCE_DATE_OVERRIDE=1
endef

define $(package)_fetch_cmds
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_file_name),$($(package)_file_name),$($(package)_sha256_hash))
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash))
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash))
endef

define $(package)_extract_cmds
  mkdir -p $($(package)_extract_dir)
  tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C qtbase
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C qttranslations
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C qttools
endef

define $(package)_preprocess_cmds
  for patch in $($(package)_patches); do \
    patch -p1 -i $($(package)_patch_dir)/$$patch; \
  done
  # macOS mkspecs
  mkdir -p qtbase/mkspecs/macx-clang-linux
  cp -f qtbase/mkspecs/macx-clang/qplatformdefs.h qtbase/mkspecs/macx-clang-linux/
  cp -f $($(package)_patch_dir)/mac-qmake.conf qtbase/mkspecs/macx-clang-linux/qmake.conf
endef

define $(package)_config_cmds
  cd qtbase && ./configure $($(package)_config_opts)
endef

define $(package)_build_cmds
  $(MAKE) -C qtbase/src $(addprefix sub-,$($(package)_qt_libs))
  $(MAKE) -C qttools/src/linguist/lrelease
  $(MAKE) -C qttools/src/linguist/lupdate
  $(MAKE) -C qttranslations
endef

define $(package)_stage_cmds
  $(MAKE) -C qtbase/src INSTALL_ROOT=$($(package)_staging_dir) $(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs)))
  $(MAKE) -C qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target
  $(MAKE) -C qttools/src/linguist/lupdate INSTALL_ROOT=$($(package)_staging_dir) install_target
  $(MAKE) -C qttranslations INSTALL_ROOT=$($(package)_staging_dir) install_subtargets
endef

define $(package)_postprocess_cmds
  rm -rf native/mkspecs/ native/lib/ lib/cmake/
  rm -f lib/lib*.la lib/*.prl plugins/*/*.prl
endef
