package=qt

# ---- Version & sources (Qt 5.15 single tarball) ----
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

# ---- what we build ----
$(package)_qt_libs=corelib network widgets gui plugins

# ---- patches (kept for legacy compatibility; must exist in patches/qt) ----
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
    # Core configure: static, minimal features; keep widgets/gui; **no -no-sql here** (5.15 error)
    $(package)_config_opts += -release -silent -opensource -confirm-license -optimized-tools -static
    $(package)_config_opts += -prefix $(host_prefix)
    $(package)_config_opts += -hostprefix $(build_prefix)
    $(package)_config_opts += -no-compile-examples -nomake examples -nomake tests
    $(package)_config_opts += -qt-libpng -qt-libjpeg -qt-harfbuzz -system-zlib
    $(package)_config_opts += -no-icu -no-cups -no-gif -no-opengl
    # Trim print stack from qtbase/printsupport
    $(package)_config_opts += -no-feature-printdialog -no-feature-printer -no-feature-printpreviewdialog -no-feature-printpreviewwidget
ifeq ($(NO_OPENSSL),)
    $(package)_config_opts += -openssl-linked
    # help the finder: add include/lib search paths
    $(package)_config_opts += -I$(host_prefix)/include -L$(host_prefix)/lib
endif

    # macOS (qmake spec + no dbus/opengl once; avoid duplicates)
    $(package)_config_opts_darwin += -platform macx-clang
    $(package)_config_opts_darwin += -no-dbus

    # Linux (kept for future cross builds)
    $(package)_config_opts_linux  = -qt-xkbcommon-x11 -qt-xcb -no-xcb-xlib -no-feature-xlib
    $(package)_config_opts_linux += -system-freetype -fontconfig -no-opengl

    # Linux ARM cross (future)
    $(package)_config_opts_arm_linux     = -xplatform linux-g++ -device-option CROSS_COMPILE="$(host)-"
    $(package)_config_opts_aarch64_linux = -xplatform linux-aarch64-gnu-g++

    # Windows / MinGW (future)
    $(package)_config_opts_mingw32 = -no-opengl -no-dbus -xplatform win32-g++ -device-option CROSS_COMPILE="$(host)-"

    # Android (future)
    $(package)_config_opts_android  = -xplatform android-clang
    $(package)_config_opts_android += -android-sdk $(ANDROID_SDK) -android-ndk $(ANDROID_NDK) -android-ndk-platform android-$(ANDROID_API_LEVEL)
    $(package)_config_opts_android += -device-option CROSS_COMPILE="$(host)-" -egl -no-eglfs -no-dbus -opengl es2 -qt-freetype -no-fontconfig
    $(package)_config_opts_android += -L $(host_prefix)/lib -I $(host_prefix)/include
    $(package)_config_opts_aarch64_android += -android-arch arm64-v8a
    $(package)_config_opts_armv7a_android += -android-arch armeabi-v7a
    $(package)_config_opts_x86_64_android += -android-arch x86_64
    $(package)_config_opts_i686_android   += -android-arch i686

    # Deterministic rcc
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
    # point lrelease from qttools into translations.pro (path exists in single tarball)
    sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" \
        $($(package)_extract_dir)/qttranslations/translations/translations.pro; \
    # custom mac mkspec for cross/macx-clang-linux compatibility
    mkdir -p $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux; \
    cp -f $($(package)_extract_dir)/qtbase/mkspecs/macx-clang/qplatformdefs.h \
          $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux/; \
    cp -f $($(package)_patch_dir)/mac-qmake.conf \
          $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux/qmake.conf; \
    # Xcode 15 parser guard
    sed -i.old "s/error(\\\"failed to parse default search paths from compiler output\\\")/!darwin: error(\\\"failed to parse default search paths from compiler output\\\")/g" \
        $($(package)_extract_dir)/qtbase/mkspecs/features/toolchain.prf
endef

# ---- configure (force SDKROOT + locale; wire OpenSSL vars on mac) ----
define $(package)_config_cmds
    export LC_ALL=C; export LANG=C; \
    export SDKROOT="$$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)"; \
    export QMAKESPEC=macx-clang; export QMAKE_MACOSX_DEPLOYMENT_TARGET=11.0; \
    export PKG_CONFIG_SYSROOT_DIR=/; \
    export PKG_CONFIG_LIBDIR=$(host_prefix)/lib/pkgconfig; \
    export PKG_CONFIG_PATH=$(host_prefix)/share/pkgconfig; \
    if [ -z "$(NO_OPENSSL)" ]; then \
      export OPENSSL_INCDIR="$(host_prefix)/include"; \
      export OPENSSL_LIBS="-L$(host_prefix)/lib -lssl -lcrypto"; \
    fi; \
    cd $($(package)_extract_dir)/qtbase && \
    ./configure $($(package)_config_opts) && \
    echo "host_build: QT_CONFIG ~= s/system-zlib/zlib" >> mkspecs/qconfig.pri && \
    echo "CONFIG += force_bootstrap" >> mkspecs/qconfig.pri && \
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
