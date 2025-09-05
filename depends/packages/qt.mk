package=qt
$(package)_version=5.15.10

# Monolithic Qt 5.15.10
$(package)_download_path=https://download.qt.io/archive/qt/5.15/$($(package)_version)/single
$(package)_file_name=qt-everywhere-src-$($(package)_version).tar.xz
$(package)_download_file=$($(package)_file_name)
$(package)_sha256_hash=B545CB83C60934ADC9A6BBD27E2AF79E5013DE77D46F5B9F5BB2A3C762BF55CA

# Optional submodules (harmless if also in monolith; helps some trees)
$(package)_qttranslations_download_path=https://download.qt.io/archive/qt/5.15/$($(package)_version)/submodules
$(package)_qttools_download_path=https://download.qt.io/archive/qt/5.15/$($(package)_version)/submodules
$(package)_qttranslations_file_name=qttranslations-everywhere-opensource-src-$($(package)_version).tar.xz
$(package)_qttools_file_name=qttools-everywhere-opensource-src-$($(package)_version).tar.xz
$(package)_qttranslations_download_file=$($(package)_qttranslations_file_name)
$(package)_qttools_download_file=$($(package)_qttools_file_name)
$(package)_qttranslations_sha256_hash=38B942BC7E62794DD072945C8A92BB9DFFFED24070AEA300327A3BB42F855609
$(package)_qttools_sha256_hash=66F46C9729C831DCE431778A9C561CCA32DACEAEDE1C7E58568D7A5898167DAE

$(package)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
$(package)_dependencies+=openssl
endif

# Build only libs VKAX links against (no testlib, no printsupport)
$(package)_qt_libs=corelib network widgets gui plugins

define $(package)_set_vars
  $(package)_config_opts = -release -silent -opensource -confirm-license -optimized-tools -static
  $(package)_config_opts += -prefix $(host_prefix) -hostprefix $(build_prefix)
  $(package)_config_opts += -no-compile-examples -nomake examples -nomake tests
  $(package)_config_opts += -system-zlib -qt-libpng -qt-libjpeg -qt-harfbuzz
  $(package)_config_opts += -no-icu -no-qml-debug -no-opengl
  # nuke PrintSupport entirely
  $(package)_config_opts += -no-feature-printer -no-feature-printdialog -no-feature-printpreviewdialog -no-feature-printpreviewwidget
ifeq ($(NO_OPENSSL),)
  $(package)_config_opts += -openssl-linked
endif

  # per-host opts (mac now, others later)
  $(package)_config_opts_darwin = -no-dbus
  $(package)_config_opts_aarch64_darwin += -device-option QMAKE_APPLE_DEVICE_ARCHS=arm64

  $(package)_config_opts_linux  = -qt-xkbcommon-x11 -qt-xcb -no-xcb-xlib -no-feature-xlib
  $(package)_config_opts_linux += -system-freetype -fontconfig -no-opengl

  $(package)_config_opts_mingw32 = -no-opengl -no-dbus -xplatform win32-g++

  $(package)_build_env  = QT_RCC_TEST=1
  $(package)_build_env += QT_RCC_SOURCE_DATE_OVERRIDE=1
endef

define $(package)_fetch_cmds
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_download_file),$($(package)_file_name),$($(package)_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_qttranslations_download_path),$($(package)_qttranslations_download_file),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_qttools_download_path),$($(package)_qttools_download_file),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash))
endef

define $(package)_extract_cmds
  mkdir -p $($(package)_extract_dir) && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C $($(package)_extract_dir) && \
  mkdir -p $($(package)_extract_dir)/qttranslations && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C $($(package)_extract_dir)/qttranslations && \
  mkdir -p $($(package)_extract_dir)/qttools && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C $($(package)_extract_dir)/qttools
endef

define $(package)_preprocess_cmds
  sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" \
    $($(package)_extract_dir)/qttranslations/translations/translations.pro
endef

define $(package)_config_cmds
  export PKG_CONFIG_SYSROOT_DIR=/ && \
  export PKG_CONFIG_LIBDIR=$(host_prefix)/lib/pkgconfig && \
  export PKG_CONFIG_PATH=$(host_prefix)/share/pkgconfig && \
  cd $($(package)_extract_dir)/qtbase && \
  ./configure $($(package)_config_opts) $($(package)_config_opts_$(host_os)) $($(package)_config_opts_$(host_arch)_$(host_os)) && \
  echo "host_build: QT_CONFIG ~= s/system-zlib/zlib" >> mkspecs/qconfig.pri && \
  echo "CONFIG += force_bootstrap" >> mkspecs/qconfig.pri && \
  cd .. && \
  qtbase/bin/qmake -o qttranslations/Makefile qttranslations/qttranslations.pro && \
  qtbase/bin/qmake -o qttranslations/translations/Makefile qttranslations/translations/translations.pro && \
  qtbase/bin/qmake -o qttools/src/linguist/lrelease/Makefile qttools/src/linguist/lrelease/lrelease.pro && \
  qtbase/bin/qmake -o qttools/src/linguist/lupdate/Makefile qttools/src/linguist/lupdate/lupdate.pro
endef

define $(package)_build_cmds
  $(MAKE) -C $($(package)_extract_dir)/qtbase/src $(addprefix sub-,$($(package)_qt_libs)) && \
  $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lrelease && \
  $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lupdate && \
  $(MAKE) -C $($(package)_extract_dir)/qttranslations
endef

define $(package)_stage_cmds
  $(MAKE) -C $($(package)_extract_dir)/qtbase/src INSTALL_ROOT=$($(package)_staging_dir) \
      $(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs))) && \
  $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lupdate  INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C $($(package)_extract_dir)/qttranslations INSTALL_ROOT=$($(package)_staging_dir) install_subtargets
endef

define $(package)_postprocess_cmds
  rm -rf lib/cmake/ && rm -f lib/lib*.la lib/*.prl plugins/*/*.prl
endef
