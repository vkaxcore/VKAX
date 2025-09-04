PACKAGE=qt
$(PACKAGE)_version=5.9.6
$(PACKAGE)_download_path=https://download.qt.io/new_archive/qt/5.9/$($(PACKAGE)_version)/submodules
$(PACKAGE)_suffix=opensource-src-$($(PACKAGE)_version).tar.xz
$(PACKAGE)_file_name=qtbase-$($(PACKAGE)_suffix)
$(PACKAGE)_sha256_hash=eed620cb268b199bd83b3fc6a471c51d51e1dc2dbb5374fc97a0cc75facbe36f

# Extra sources for tools and translations
$(PACKAGE)_qttranslations_file_name=qttranslations-$($(PACKAGE)_suffix)
$(PACKAGE)_qttranslations_sha256_hash=9822084f8e2d2939ba39f4af4c0c2320e45d5996762a9423f833055607604ed8
$(PACKAGE)_qttools_file_name=qttools-$($(PACKAGE)_suffix)
$(PACKAGE)_qttools_sha256_hash=50e75417ec0c74bb8b1989d1d8e981ee83690dce7dfc0c2169f7c00f397e5117
$(PACKAGE)_extra_sources = $($(PACKAGE)_qttranslations_file_name) $($(PACKAGE)_qttools_file_name)

# Dependencies
$(PACKAGE)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
$(PACKAGE)_dependencies+= openssl
endif

$(PACKAGE)_qt_libs=corelib network widgets gui plugins testlib
$(PACKAGE)_patches=fix_qt_pkgconfig.patch mac-qmake.conf fix_configure_mac.patch fix_no_printer.patch fix_riscv64_arch.patch \
                    fix_rcc_determinism.patch xkb-default.patch no-xlib.patch fix_android_qmake_conf.patch fix_android_jni_static.patch \
                    dont_hardcode_pwd.patch freetype_back_compat.patch drop_lrelease_dependency.patch fix_powerpc_libpng.patch \
                    fix_mingw_cross_compile.patch fix_qpainter_non_determinism.patch fix_limits_header.patch

# Environment and build flags
define $(PACKAGE)_set_vars
  $(PACKAGE)_config_opts += -release -silent
  $(PACKAGE)_config_opts += -bindir $(build_prefix)/bin
  $(PACKAGE)_config_opts += -c++std c++1z
  $(PACKAGE)_config_opts += -confirm-license
  $(PACKAGE)_config_opts += -hostprefix $(build_prefix)
  $(PACKAGE)_config_opts += -no-compile-examples
  $(PACKAGE)_config_opts += -no-cups -no-egl -no-eglfs -no-freetype -no-gif -no-glib -no-icu -no-ico -no-iconv
  $(PACKAGE)_config_opts += -no-kms -no-linuxfb -no-libudev -no-mtdev -no-openvg -no-reduce-relocations -no-qml-debug
  $(PACKAGE)_config_opts += -no-sql-db2 -no-sql-ibase -no-sql-oci -no-sql-tds -no-sql-mysql -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2
  $(PACKAGE)_config_opts += -no-use-gold-linker -no-xinput2 -nomake examples -nomake tests -opensource
  ifeq ($(NO_OPENSSL),)
    $(PACKAGE)_config_opts += -openssl-linked
  endif
  $(PACKAGE)_config_opts += -optimized-tools -pch -pkg-config -prefix $(host_prefix)
  $(PACKAGE)_config_opts += -qt-libpng -qt-libjpeg -qt-pcre -qt-harfbuzz -system-zlib -static -v
  $(PACKAGE)_config_opts += -no-feature-bearermanagement -no-feature-colordialog -no-feature-commandlineparser -no-feature-concurrent
  $(PACKAGE)_config_opts += -no-feature-dial -no-feature-fontcombobox -no-feature-ftp -no-feature-image_heuristic_mask -no-feature-keysequenceedit
  $(PACKAGE)_config_opts += -no-feature-lcdnumber -no-feature-pdf -no-feature-printdialog -no-feature-printer -no-feature-printpreviewdialog
  $(PACKAGE)_config_opts += -no-feature-printpreviewwidget -no-feature-sessionmanager -no-feature-sql -no-feature-statemachine
  $(PACKAGE)_config_opts += -no-feature-syntaxhighlighter -no-feature-textbrowser -no-feature-textodfwriter -no-feature-topleveldomain
  $(PACKAGE)_config_opts += -no-feature-udpsocket -no-feature-undocommand -no-feature-undogroup -no-feature-undostack -no-feature-undoview
  $(PACKAGE)_config_opts += -no-feature-vnc -no-feature-wizard -no-feature-xml

  # Darwin-specific
  $(PACKAGE)_config_opts_darwin += -no-dbus -no-opengl
  $(PACKAGE)_config_opts_aarch64_darwin += -device-option QMAKE_APPLE_DEVICE_ARCHS=arm64
endef

# Fetch commands
define $(PACKAGE)_fetch_cmds
  $(call fetch_file,$(PACKAGE),$($(PACKAGE)_download_path),$($(PACKAGE)_file_name),$($(PACKAGE)_file_name),$($(PACKAGE)_sha256_hash)) && \
  $(call fetch_file,$(PACKAGE),$($(PACKAGE)_download_path),$($(PACKAGE)_qttranslations_file_name),$($(PACKAGE)_qttranslations_file_name),$($(PACKAGE)_qttranslations_sha256_hash)) && \
  $(call fetch_file,$(PACKAGE),$($(PACKAGE)_download_path),$($(PACKAGE)_qttools_file_name),$($(PACKAGE)_qttools_file_name),$($(PACKAGE)_qttools_sha256_hash))
endef

# Extract sources
define $(PACKAGE)_extract_cmds
  mkdir -p $($(PACKAGE)_extract_dir) && \
  tar --no-same-owner --strip-components=1 -xf $($(PACKAGE)_source) -C qtbase && \
  tar --no-same-owner --strip-components=1 -xf $($(PACKAGE)_source_dir)/$($(PACKAGE)_qttranslations_file_name) -C qttranslations && \
  tar --no-same-owner --strip-components=1 -xf $($(PACKAGE)_source_dir)/$($(PACKAGE)_qttools_file_name) -C qttools
endef

# Preprocess (apply patches)
define $(PACKAGE)_preprocess_cmds
  for patch in $($(PACKAGE)_patches); do \
    patch -p1 -i $($(PACKAGE)_patch_dir)/$$patch; \
  done && \
  sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(PACKAGE)_extract_dir)/qttools/bin/lrelease|" qttranslations/translations/translations.pro && \
  mkdir -p qtbase/mkspecs/macx-clang-linux && \
  cp -f qtbase/mkspecs/macx-clang/qplatformdefs.h qtbase/mkspecs/macx-clang-linux/ && \
  cp -f $($(PACKAGE)_patch_dir)/mac-qmake.conf qtbase/mkspecs/macx-clang-linux/qmake.conf
endef

# Configure Qt
define $(PACKAGE)_config_cmds
  cd qtbase && \
  ./configure $($(PACKAGE)_config_opts) && \
  echo "CONFIG += force_bootstrap" >> mkspecs/qconfig.pri && \
  cd ..
endef

# Build Qt
define $(PACKAGE)_build_cmds
  $(MAKE) -C qtbase/src $(addprefix sub-,$($(PACKAGE)_qt_libs)) && \
  $(MAKE) -C qttools/src/linguist/lrelease && \
  $(MAKE) -C qttools/src/linguist/lupdate && \
  $(MAKE) -C qttranslations
endef

# Stage
define $(PACKAGE)_stage_cmds
  $(MAKE) -C qtbase/src INSTALL_ROOT=$($(PACKAGE)_staging_dir) $(addsuffix -install_subtargets,$(addprefix sub-,$($(PACKAGE)_qt_libs))) && \
  $(MAKE) -C qttools/src/linguist/lrelease INSTALL_ROOT=$($(PACKAGE)_staging_dir) install_target && \
  $(MAKE) -C qttools/src/linguist/lupdate INSTALL_ROOT=$($(PACKAGE)_staging_dir) install_target && \
  $(MAKE) -C qttranslations INSTALL_ROOT=$($(PACKAGE)_staging_dir) install_subtargets
endef

# Post-process
define $(PACKAGE)_postprocess_cmds
  rm -rf native/mkspecs/ native/lib/ lib/cmake/ && \
  rm -f lib/lib*.la lib/*.prl plugins/*/*.prl
endef
