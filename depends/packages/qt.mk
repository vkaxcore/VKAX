PACKAGE=qt
$(package)_version=5.15.10
$(package)_download_path=https://download.qt.io/archive/qt/5.15/5.15.10/single
$(package)_suffix=opensource-src-$(package)_version.tar.xz
$(package)_file_name=qt-everywhere-src-$(package)_suffix
$(package)_sha256_hash=0c37696f3fa3cb4c0c1f9247fa38e7d946b2cfb53a36a67b61ff61877e3fca43

$(package)_qttranslations_file_name=qttranslations-$(package)_suffix
$(package)_qttranslations_sha256_hash=9822084f8e2d2939ba39f4af4c0c2320e45d5996762a9423f833055607604ed8

$(package)_qttools_file_name=qttools-$(package)_suffix
$(package)_qttools_sha256_hash=3764356d80b61550ab1a07fb67c3e872c7755149accec8b153e1cbf51e02633b

$(package)_extra_sources = $(package)_qttranslations_file_name $(package)_qttools_file_name

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
    $(package)_config_opts += -release -silent -opensource -optimized-tools -static
    $(package)_config_opts += -prefix $($(package)_staging_dir)
    $(package)_config_opts += -hostprefix $($(package)_staging_dir)
    $(package)_config_opts += -no-compile-examples -nomake examples -nomake tests
    $(package)_config_opts += -qt-libpng -qt-libjpeg -qt-harfbuzz -system-zlib
ifeq ($(NO_OPENSSL),)
    $(package)_config_opts += -openssl-linked
endif

    # macOS
    $(package)_config_opts_darwin = -no-dbus -no-opengl
    $(package)_config_opts_aarch64_darwin += -device-option QMAKE_APPLE_DEVICE_ARCHS=arm64

    # Linux
    $(package)_config_opts_linux = -qt-xkbcommon-x11 -qt-xcb -no-xcb-xlib -no-feature-xlib
    $(package)_config_opts_linux += -system-freetype -fontconfig
    $(package)_config_opts_linux += -no-opengl

    # Linux ARM
    $(package)_config_opts_arm_linux = -xplatform linux-g++ -device-option CROSS_COMPILE="$(host)-"

    # Windows / MinGW
    $(package)_config_opts_mingw32 = -no-opengl -no-dbus -xplatform win32-g++
endef

define $(package)_fetch_cmds
    $(call fetch_file,$(package),$($(package)_download_path),$($(package)_file_name),$($(package)_file_name),$($(package)_sha256_hash)) && \
    $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
    $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash))
endef

define $(package)_extract_cmds
    mkdir -p $($(package)_extract_dir) && \
    tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C $($(package)_extract_dir)/qtbase && \
    mkdir -p $($(package)_extract_dir)/qttranslations && \
    tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C $($(package)_extract_dir)/qttranslations && \
    mkdir -p $($(package)_extract_dir)/qttools && \
    tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C $($(package)_extract_dir)/qttools
endef

define $(package)_preprocess_cmds
    for patch in $($(package)_patches); do \
        patch -p1 -d $($(package)_extract_dir) < $($(package)_patch_dir)/$$patch; \
    done && \
    sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" $($(package)_extract_dir)/qttranslations/translations/translations.pro && \
    mkdir -p $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux && \
    cp -f $($(package)_extract_dir)/qtbase/mkspecs/macx-clang/qplatformdefs.h $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux/ && \
    cp -f $($(package)_patch_dir)/mac-qmake.conf $($(package)_extract_dir)/qtbase/mkspecs/macx-clang-linux/qmake.conf
endef

define $(package)_config_cmds
    export PKG_CONFIG_SYSROOT_DIR=/ && \
    export PKG_CONFIG_LIBDIR=$(host_prefix)/lib/pkgconfig && \
    export PKG_CONFIG_PATH=$(host_prefix)/share/pkgconfig && \
    cd $($(package)_extract_dir)/qtbase && \
    ./configure $($(package)_config_opts) && \
    echo "host_build: QT_CONFIG ~= s/system-zlib/zlib" >> mkspecs/qconfig.pri && \
    echo "CONFIG += force_bootstrap" >> mkspecs/qconfig.pri && \
    cd .. && \
    qtbase/bin/qmake -o qttranslations/Makefile qttranslations/qttranslations.pro && \
    qtbase/bin/qmake -o qttranslations/translations/Makefile qttranslations/translations/translations.pro && \
    qtbase/bin/qmake -o qttools/src/linguist/lrelease/Makefile qttools/src/linguist/lrelease/lrelease.pro && \
    qtbase/bin/qmake -o qttools/src/linguist/lupdate/Makefile qttools/src/linguist/lupdate/lupdate.pro
endef

define $(package)_build_cmds
    $(MAKE) -C $($(package)_extract_dir)/qtbase -j8 $(addprefix sub-,$($(package)_qt_libs)) && \
    $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lrelease && \
    $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lupdate && \
    $(MAKE) -C $($(package)_extract_dir)/qttranslations
endef

define $(package)_stage_cmds
    $(MAKE) -C $($(package)_extract_dir)/qtbase INSTALL_ROOT=$($(package)_staging_dir) $(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs))) && \
    $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target && \
    $(MAKE) -C $($(package)_extract_dir)/qttools/src/linguist/lupdate INSTALL_ROOT=$($(package)_staging_dir) install_target && \
    $(MAKE) -C $($(package)_extract_dir)/qttranslations INSTALL_ROOT=$($(package)_staging_dir) install_subtargets
endef

define $(package)_postprocess_cmds
    rm -rf $($(package)_staging_dir)/lib/cmake
endef
