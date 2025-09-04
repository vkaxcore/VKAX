PACKAGE=qt
$(PACKAGE)_version=5.9.6
$(PACKAGE)_download_path=https://download.qt.io/new_archive/qt/5.9/$($(PACKAGE)_version)/submodules
$(PACKAGE)_suffix=opensource-src-$($(PACKAGE)_version).tar.xz

$(PACKAGE)_sha256_hash_qtbase=8ff623dd4fd3e2c4c8352cf8f2cf58d9d5632e80e2e33d42dd67b5ab3ed24759
$(PACKAGE)_sha256_hash_qtsvg=93b7fd4957332b26738f34c8db9d314fe42d42100437f827141b140ba5c28a7b
$(PACKAGE)_sha256_hash_qttools=186a0b6c6fe4b8b37fc5f76a3e39fb8bcb7d734c7df749b1689cc27c1375c323
$(PACKAGE)_sha256_hash_qttranslations=3871e307ff57f75ec6b15c93dffa50e1399c049b58289f6a1ebf7af5120a0615
$(PACKAGE)_sha256_hash_qtmacextras=6c94b91e80eb2b4597e6ebfdcb50948c3e1a61c7950b3018d95e32b7a98ae0d0

$(PACKAGE)_dependencies=openssl zlib

define $(PACKAGE)_set_vars
  $(PACKAGE)_config_opts_release = -release
  $(PACKAGE)_config_opts_debug = -debug
  $(PACKAGE)_config_opts = -opensource -confirm-license -prefix=$($(PACKAGE)_staging_dir)/$(host) \
    -no-opengl -no-icu -no-dbus -no-qml-debug -nomake examples -nomake tests \
    -no-feature-printer -no-feature-printdialog -skip qttest
  $(PACKAGE)_cxxflags = -std=c++17
endef

define $(PACKAGE)_fetch_cmds
  $(call fetch_file,$($(PACKAGE)_download_path),qtbase-$($(PACKAGE)_suffix),$($(PACKAGE)_sha256_hash_qtbase)) && \
  $(call fetch_file,$($(PACKAGE)_download_path),qtsvg-$($(PACKAGE)_suffix),$($(PACKAGE)_sha256_hash_qtsvg)) && \
  $(call fetch_file,$($(PACKAGE)_download_path),qttools-$($(PACKAGE)_suffix),$($(PACKAGE)_sha256_hash_qttools)) && \
  $(call fetch_file,$($(PACKAGE)_download_path),qttranslations-$($(PACKAGE)_suffix),$($(PACKAGE)_sha256_hash_qttranslations)) && \
  $(call fetch_file,$($(PACKAGE)_download_path),qtmacextras-$($(PACKAGE)_suffix),$($(PACKAGE)_sha256_hash_qtmacextras))
endef

define $(PACKAGE)_extract_cmds
  tar --no-same-owner -xf $($(PACKAGE)_source_dir)/qtbase-$($(PACKAGE)_suffix) && \
  tar --no-same-owner -xf $($(PACKAGE)_source_dir)/qtsvg-$($(PACKAGE)_suffix) && \
  tar --no-same-owner -xf $($(PACKAGE)_source_dir)/qttools-$($(PACKAGE)_suffix) && \
  tar --no-same-owner -xf $($(PACKAGE)_source_dir)/qttranslations-$($(PACKAGE)_suffix) && \
  tar --no-same-owner -xf $($(PACKAGE)_source_dir)/qtmacextras-$($(PACKAGE)_suffix)
endef

define $(PACKAGE)_preprocess_cmds
endef

define $(PACKAGE)_config_cmds
  cd qtbase-opensource-src-$($(PACKAGE)_version) && ./configure $($(PACKAGE)_config_opts)
endef

define $(PACKAGE)_build_cmds
  cd qtbase-opensource-src-$($(PACKAGE)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qtsvg-opensource-src-$($(PACKAGE)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qttools-opensource-src-$($(PACKAGE)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qttranslations-opensource-src-$($(PACKAGE)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qtmacextras-opensource-src-$($(PACKAGE)_version) && $(MAKE) -j$(JOBS)
endef

define $(PACKAGE)_stage_cmds
  cd qtbase-opensource-src-$($(PACKAGE)_version) && $(MAKE) install && \
  cd ../qtsvg-opensource-src-$($(PACKAGE)_version) && $(MAKE) install && \
  cd ../qttools-opensource-src-$($(PACKAGE)_version) && $(MAKE) install && \
  cd ../qttranslations-opensource-src-$($(PACKAGE)_version) && $(MAKE) install && \
  cd ../qtmacextras-opensource-src-$($(PACKAGE)_version) && $(MAKE) install
endef

define $(PACKAGE)_postprocess_cmds
  rm -f $($(PACKAGE)_staging_dir)/$(host)/lib/libQt5Designer* && \
  rm -f $($(PACKAGE)_staging_dir)/$(host)/lib/libQt5UiTools* && \
  rm -f $($(PACKAGE)_staging_dir)/$(host)/lib/libQt5Test* && \
  rm -rf $($(PACKAGE)_staging_dir)/$(host)/bin && \
  rm -rf $($(PACKAGE)_staging_dir)/$(host)/mkspecs && \
  rm -rf $($(PACKAGE)_staging_dir)/$(host)/include/QtUiTools && \
  rm -rf $($(PACKAGE)_staging_dir)/$(host)/include/QtDesigner && \
  rm -rf $($(PACKAGE)_staging_dir)/$(host)/include/QtTest
endef
