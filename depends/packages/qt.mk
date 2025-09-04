PACKAGE=qt
$(package)_version=5.15.10
$(package)_download_path=https://download.qt.io/archive/qt/5.15/$($(package)_version)/single
$(package)_suffix=opensource-src-$($(package)_version).tar.xz
$(package)_file_name=qt-everywhere-src-$($(package)_suffix)
$(package)_sha256_hash=0c37696f3fa3cb4c0c1f9247fa38e7d946b2cfb53a36a67b61ff61877e3fca43
$(package)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
$(package)_dependencies+= openssl
endif
$(package)_qt_libs=core gui widgets network printsupport testlib
$(package)_patches=fix_qt_pkgconfig.patch mac-qmake.conf fix_configure_mac.patch fix_no_printer.patch fix_rcc_determinism.patch

# Extra sources if needed (translations, tools)
$(package)_qttranslations_file_name=qttranslations-$($(package)_suffix)
$(package)_qttranslations_sha256_hash=9822084f8e2d2939ba39f4af4c0c2320e45d5996762a9423f833055607604ed8
$(package)_qttools_file_name=qttools-$($(package)_suffix)
$(package)_qttools_sha256_hash=50e75417ec0c74bb8b1989d1d8e981ee83690dce7dfc0c2169f7c00f397e5117

$(package)_extra_sources  = $($(package)_qttranslations_file_name)
$(package)_extra_sources += $($(package)_qttools_file_name)

define $(package)_set_vars
$(package)_config_opts += -prefix $(host_prefix)
$(package)_config_opts += -release
$(package)_config_opts += -silent
$(package)_config_opts += -opensource
ifeq ($(NO_OPENSSL),)
$(package)_config_opts += -openssl-linked
endif
$(package)_config_opts += -optimized-tools
$(package)_config_opts += -no-pch
$(package)_config_opts += -no-compile-examples
$(package)_config_opts += -nomake examples
$(package)_config_opts += -nomake tests
$(package)_config_opts += -no-dbus
$(package)_config_opts += -no-opengl
$(package)_config_opts += -no-cups
$(package)_config_opts += -no-feature-printdialog
$(package)_config_opts += -no-feature-printer
$(package)_config_opts += -no-feature-pdf
$(package)_config_opts += -qt-libpng
$(package)_config_opts += -qt-libjpeg
$(package)_config_opts += -qt-harfbuzz
$(package)_config_opts += -system-zlib
$(package)_config_opts += -static
$(package)_config_opts += -v
endef

define $(package)_fetch_cmds
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_file_name),$($(package)_file_name),$($(package)_sha256_hash))
endef

define $(package)_extract_cmds
mkdir -p $($(package)_extract_dir) && \
tar --no-same-owner -xf $($(package)_source) -C $($(package)_extract_dir) --strip-components=1
endef

define $(package)_preprocess_cmds
patch -p1 -i $($(package)_patch_dir)/fix_qt_pkgconfig.patch && \
patch -p1 -i $($(package)_patch_dir)/mac-qmake.conf && \
patch -p1 -i $($(package)_patch_dir)/fix_configure_mac.patch && \
patch -p1 -i $($(package)_patch_dir)/fix_no_printer.patch && \
patch -p1 -i $($(package)_patch_dir)/fix_rcc_determinism.patch
endef

define $(package)_config_cmds
cd $($(package)_extract_dir) && \
./configure $($(package)_config_opts)
endef

define $(package)_build_cmds
$(MAKE) -C $($(package)_extract_dir) -j8
endef

define $(package)_stage_cmds
$(MAKE) -C $($(package)_extract_dir) INSTALL_ROOT=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
rm -rf $($(package)_staging_dir)/lib/cmake
endef
