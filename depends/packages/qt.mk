package=qt
$(package)_version=5.9.6
$(package)_download_path=https://download.qt.io/new_archive/qt/5.9/$($(package)_version)/submodules
$(package)_suffix=opensource-src-$($(package)_version).tar.xz

$(package)_sha256_hash_qtbase=8ff623dd4fd3e2c4c8352cf8f2cf58d9d5632e80e2e33d42dd67b5ab3ed24759
$(package)_sha256_hash_qtsvg=93b7fd4957332b26738f34c8db9d314fe42d42100437f827141b140ba5c28a7b
$(package)_sha256_hash_qttools=186a0b6c6fe4b8b37fc5f76a3e39fb8bcb7d734c7df749b1689cc27c1375c323
$(package)_sha256_hash_qttranslations=3871e307ff57f75ec6b15c93dffa50e1399c049b58289f6a1ebf7af5120a0615
$(package)_sha256_hash_qtmacextras=6c94b91e80eb2b4597e6ebfdcb50948c3e1a61c7950b3018d95e32b7a98ae0d0

$(package)_dependencies=openssl zlib

define $(package)_set_vars
  $(package)_config_opts_release = -release
  $(package)_config_opts_debug = -debug
  $(package)_config_opts = -opensource -confirm-license -prefix=$($(package)_staging_dir)/$(host) \
    -no-opengl -no-icu -no-dbus -no-qml-debug -nomake examples -nomake tests \
    -no-feature-printer -no-feature-printdialog
  $(package)_cxxflags = -std=c++14 -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION
endef

define $(package)_fetch_cmds
  $(call fetch_file,$($(package)_download_path),qtbase-$($(package)_suffix),$($(package)_sha256_hash_qtbase)) && \
  $(call fetch_file,$($(package)_download_path),qtsvg-$($(package)_suffix),$($(package)_sha256_hash_qtsvg)) && \
  $(call fetch_file,$($(package)_download_path),qttools-$($(package)_suffix),$($(package)_sha256_hash_qttools)) && \
  $(call fetch_file,$($(package)_download_path),qttranslations-$($(package)_suffix),$($(package)_sha256_hash_qttranslations)) && \
  $(call fetch_file,$($(package)_download_path),qtmacextras-$($(package)_suffix),$($(package)_sha256_hash_qtmacextras))
endef

define $(package)_extract_cmds
  tar --no-same-owner -xf $($(package)_source_dir)/qtbase-$($(package)_suffix) && \
  tar --no-same-owner -xf $($(package)_source_dir)/qtsvg-$($(package)_suffix) && \
  tar --no-same-owner -xf $($(package)_source_dir)/qttools-$($(package)_suffix) && \
  tar --no-same-owner -xf $($(package)_source_dir)/qttranslations-$($(package)_suffix) && \
  tar --no-same-owner -xf $($(package)_source_dir)/qtmacextras-$($(package)_suffix)
endef

define $(package)_preprocess_cmds
endef

define $(package)_config_cmds
  cd qtbase-opensource-src-$($(package)_version) && ./configure $($(package)_config_opts)
endef

define $(package)_build_cmds
  cd qtbase-opensource-src-$($(package)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qtsvg-opensource-src-$($(package)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qttools-opensource-src-$($(package)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qttranslations-opensource-src-$($(package)_version) && $(MAKE) -j$(JOBS) && \
  cd ../qtmacextras-opensource-src-$($(package)_version) && $(MAKE) -j$(JOBS)
endef

define $(package)_stage_cmds
  cd qtbase-opensource-src-$($(package)_version) && $(MAKE) install && \
  cd ../qtsvg-opensource-src-$($(package)_version) && $(MAKE) install && \
  cd ../qttools-opensource-src-$($(package)_version) && $(MAKE) install && \
  cd ../qttranslations-opensource-src-$($(package)_version) && $(MAKE) install && \
  cd ../qtmacextras-opensource-src-$($(package)_version) && $(MAKE) install
endef

define $(package)_postprocess_cmds
  rm -f $($(package)_staging_dir)/$(host)/lib/libQt5Designer* && \
  rm -f $($(package)_staging_dir)/$(host)/lib/libQt5UiTools* && \
  rm -f $($(package)_staging_dir)/$(host)/lib/libQt5Test* && \
  rm -rf $($(package)_staging_dir)/$(host)/bin && \
  rm -rf $($(package)_staging_dir)/$(host)/mkspecs && \
  rm -rf $($(package)_staging_dir)/$(host)/include/QtUiTools && \
  rm -rf $($(package)_staging_dir)/$(host)/include/QtDesigner && \
  rm -rf $($(package)_staging_dir)/$(host)/include/QtTest
endef
