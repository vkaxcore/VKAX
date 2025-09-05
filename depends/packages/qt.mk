package=qt

# ===========================
# Qt 5.15.10 single-tarball (static) for legacy Bitcoin/Dash forks
# macOS-first; Linux/Windows kept compatible later
# OpenSSL is REQUIRED unless NO_OPENSSL=1
# Signed: Setvin (with comments left in for future you)
# ===========================

$(package)_version=5.15.10
$(package)_download_path=https://download.qt.io/archive/qt/5.15/5.15.10/single
$(package)_download_file=qt-everywhere-opensource-src-$($(package)_version).tar.xz
$(package)_file_name=$($(package)_download_file)
$(package)_sha256_hash=B545CB83C60934ADC9A6BBD27E2AF79E5013DE77D46F5B9F5BB2A3C762BF55CA

# ---- deps ----
$(package)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
$(package)_dependencies+=openssl
endif

# Build from qtbase/src; 'plugins' builds platform plugins (cocoa on mac)
$(package)_qt_libs=corelib network widgets gui plugins

# ---- patches (must exist under patches/qt) ----
# Preserve the usual Bitcoin/Dash patchset; do not delete without audit.
$(package)_patches = \
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

define $(package)_set_vars
	# Core: static, release, quiet, no examples/tests
	$(package)_config_opts += -release -silent -opensource -confirm-license -optimized-tools -static
	$(package)_config_opts += -prefix $(host_prefix)
	$(package)_config_opts += -hostprefix $(build_prefix)
	$(package)_config_opts += -no-compile-examples -nomake examples -nomake tests

	# Libraries: prefer bundled for determinism; zlib from depends
	$(package)_config_opts += -qt-libpng -qt-libjpeg -qt-harfbuzz -system-zlib

ifeq ($(NO_OPENSSL),)
	# Force OpenSSL static link from depends; include and lib dirs explicit
	$(package)_config_opts += -openssl-linked -I$(host_prefix)/include -L$(host_prefix)/lib
endif

	# Trim fat; we do NOT use GL, ICU, CUPS, GIF in this legacy GUI
	$(package)_config_opts += -no-icu -no-cups -no-gif -no-opengl
	# Kill printsupport UI bits that drag dynamic junk in static builds
	$(package)_config_opts += -no-feature-printdialog -no-feature-printer -no-feature-printpreviewdialog -no-feature-printpreviewwidget

	# --- per-OS knobs ---
	# macOS: use macx-clang; disable dbus; force OpenSSL over SecureTransport
	$(package)_config_opts_darwin += -platform macx-clang -no-dbus -no-securetransport

	# Linux (for later): XCB without xlib; no GL
	$(package)_config_opts_linux  = -qt-xkbcommon-x11 -qt-xcb -no-xcb-xlib -no-feature-xlib
	$(package)_config_opts_linux += -system-freetype -fontconfig -no-opengl

	# Windows cross (later): mingw without dbus/GL
	$(package)_config_opts_mingw32 = -xplatform win32-g++ -no-dbus -no-opengl -device-option CROSS_COMPILE="$(host)-"

	# RCC determinism
	$(package)_build_env  = QT_RCC_TEST=1
	$(package)_build_env += QT_RCC_SOURCE_DATE_OVERRIDE=1
endef

# ---- fetch ----
define $(package)_fetch_cmds
	$(call fetch_file,$(package),$($(package)_download_path),$($(package)_download_file),$($(package)_file_name),$($(package)_sha256_hash))
endef

# ---- extract ----
define $(package)_extract_cmds
	mkdir -p $($(package)_extract_dir) && \
	tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C $($(package)_extract_dir)
endef

# ---- preprocess ----
define $(package)_preprocess_cmds
	set -e; \
	for p in $($(package)_patches); do \
		patch -p1 -d $($(package)_extract_dir) < $($(package)_patch_dir)/$$p || true; \
	done; \
	# Make translations use the built lrelease path explicitly
	sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" \
		$($(package)_extract_dir)/qttranslations/translations/translations.pro; \
	# Provide macx-clang-linux mkspec for future cross needs
	mkdir -p $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux && \
	cp -f $($(package)_extract_dir)/qtbase/mkspecs/macx-clang/qplatformdefs.h \
	      $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux/ && \
	cp -f $($(package)_patch_dir)/mac-qmake.conf \
	      $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux/qmake.conf; \
	# Guard against Xcode parser weirdness (harmless on 14.x)
	sed -i.old "s/error(\\\"failed to parse default search paths from compiler output\\\")/!darwin: error(\\\"failed to parse default search paths from compiler output\\\")/g" \
		$($(package)_extract_dir)/qtbase/mkspecs/features/toolchain.prf
endef

# ---- configure ----
define $(package)_config_cmds
	export LC_ALL=C LANG=C; \
	export SDKROOT="$$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)"; \
	# Nuke hostile env that poisons configure/qmake
	unset QMAKESPEC XQMAKESPEC QMAKEPATH QMAKEFEATURES QMAKE QMAKE_SPEC QTDIR QT_PLUGIN_PATH QT_QPA_PLATFORM_PLUGIN_PATH PKG_CONFIG_PATH; \
	export PKG_CONFIG_SYSROOT_DIR=/; \
	export PKG_CONFIG_LIBDIR=$(host_prefix)/lib/pkgconfig; \
	export PKG_CONFIG_PATH=$(host_prefix)/share/pkgconfig; \
	if [ -z "$(NO_OPENSSL)" ]; then \
		# Linker flags include -lz to satisfy older OpenSSL static combos
		export OPENSSL_INCDIR="$(host_prefix)/include"; \
		export OPENSSL_LIBS="-L$(host_prefix)/lib -lssl -lcrypto -lz"; \
	fi; \
	cd $($(package)_extract_dir)/qtbase && \
	# Include per-host opts (darwin adds -platform macx-clang and -no-securetransport)
	env -u QMAKESPEC -u XQMAKESPEC -u QMAKEPATH -u QMAKEFEATURES -u QMAKE -u QMAKE_SPEC -u QTDIR -u QT_PLUGIN_PATH -u QT_QPA_PLATFORM_PLUGIN_PATH -u PKG_CONFIG_PATH \
	./configure $($(package)_config_opts) $($(package)_config_opts_$(host_os)) && \
	{ echo "host_build: QT_CONFIG ~= s/system-zlib/zlib"; echo "CONFIG += force_bootstrap"; } >> mkspecs/qconfig.pri && \
	cd $($(package)_extract_dir) && \
	qtbase/bin/qmake -o qttranslations/Makefile qttranslations/qttranslations.pro && \
	qtbase/bin/qmake -o qttools/src/linguist/lrelease/Makefile qttools/src/linguist/lrelease/lrelease.pro && \
	qtbase/bin/qmake -o qttools/src/linguist/lupdate/Makefile  qttools/src/linguist/lupdate/lupdate.pro
endef

# ---- build ----
define $(package)_build_cmds
	$(MAKE) -C $($(package)_extract_dir)/qtbase/src $(addprefix sub-,$($(package)_qt_libs)) && \
	$(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lrelease && \
	$(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lupdate && \
	$(MAKE) -C $($(package)_extract_dir)/qttranslations
endef

# ---- stage ----
define $(package)_stage_cmds
	$(MAKE) -C $($(package)_extract_dir)/qtbase/src INSTALL_ROOT=$($(package)_staging_dir) \
		$(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs))) && \
	$(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target && \
	$(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lupdate  INSTALL_ROOT=$($(package)_staging_dir) install_target && \
	$(MAKE) -C $($(package)_extract_dir)/qttranslations               INSTALL_ROOT=$($(package)_staging_dir) install_subtargets
endef

# ---- tidy ----
define $(package)_postprocess_cmds
	rm -rf $($(package)_staging_dir)/lib/cmake
endef
