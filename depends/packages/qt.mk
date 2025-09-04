PACKAGE=qt
$(package)_version=5.9.6
$(package)_download_path=https://download.qt.io/new_archive/qt/5.9/$($(package)_version)/submodules
$(package)_suffix=opensource-src-$($(package)_version).tar.xz
$(package)_file_name=qtbase-$($(package)_suffix)
$(package)_sha256_hash=eed620cb268b199bd83b3fc6a471c51d51e1dc2dbb5374fc97a0cc75facbe36f
$(package)_dependencies=zlib
ifeq ($(NO_OPENSSL),)
$(package)_dependencies+= openssl
endif
$(package)_linux_dependencies=freetype fontconfig libxcb
$(package)_qt_libs=corelib network widgets gui plugins testlib
$(package)_patches=fix_qt_pkgconfig.patch mac-qmake.conf fix_configure_mac.patch fix_no_printer.patch fix_riscv64_arch.patch
$(package)_patches+= fix_rcc_determinism.patch xkb-default.patch no-xlib.patch
$(package)_patches+= fix_android_qmake_conf.patch fix_android_jni_static.patch dont_hardcode_pwd.patch
$(package)_patches+= freetype_back_compat.patch drop_lrelease_dependency.patch fix_powerpc_libpng.patch
$(package)_patches+= fix_mingw_cross_compile.patch fix_qpainter_non_determinism.patch fix_limits_header.patch

$(package)_qttranslations_file_name=qttranslations-$($(package)_suffix)
$(package)_qttranslations_sha256_hash=9822084f8e2d2939ba39f4af4c0c2320e45d5996762a9423f833055607604ed8
$(package)_qttools_file_name=qttools-$($(package)_suffix)
$(package)_qttools_sha256_hash=50e75417ec0c74bb8b1989d1d8e981ee83690dce7dfc0c2169f7c00f397e5117

$(package)_extra_sources  = $($(package)_qttranslations_file_name)
$(package)_extra_sources += $($(package)_qttools_file_name)

define $(package)_set_vars
$(package)_config_opts_release = -release -silent
$(package)_config_opts_debug = -debug
$(package)_config_opts += -bindir $(build_prefix)/bin -c++std c++1z -confirm-license -hostprefix $(build_prefix)
$(package)_config_opts += -no-compile-examples -no-cups -no-egl -no-eglfs -no-freetype -no-gif -no-glib -no-icu
$(package)_config_opts += -no-ico -no-iconv -no-kms -no-linuxfb -no-libudev -no-mtdev -no-openvg -no-reduce-relocations
$(package)_config_opts += -no-qml-debug -no-sql-db2 -no-sql-ibase -no-sql-oci -no-sql-tds -no-sql-mysql
$(package)_config_opts += -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-use-gold-linker -no-xinput2
$(package)_config_opts += -nomake examples -nomake tests -opensource
ifeq ($(NO_OPENSSL),)
$(package)_config_opts += -openssl-linked
endif
$(package)_config_opts += -optimized-tools -pch -pkg-config -prefix $(host_prefix)
$(package)_config_opts += -qt-libpng -qt-libjpeg -qt-pcre -qt-harfbuzz -system-zlib -static -v
$(package)_config_opts += -no-feature-bearermanagement -no-feature-colordialog -no-feature-commandlineparser
$(package)_config_opts += -no-feature-concurrent -no-feature-dial -no-feature-fontcombobox -no-feature-ftp
$(package)_config_opts += -no-feature-image_heuristic_mask -no-feature-keysequenceedit -no-feature-lcdnumber
$(package)_config_opts += -no-feature-pdf -no-feature-printdialog -no-feature-printer -no-feature-printpreviewdialog
$(package)_config_opts += -no-feature-printpreviewwidget -no-feature-sessionmanager -no-feature-sql
$(package)_config_opts += -no-feature-statemachine -no-feature-syntaxhighlighter -no-feature-textbrowser
$(package)_config_opts += -no-feature-textodfwriter -no-feature-topleveldomain -no-feature-udpsocket
$(package)_config_opts += -no-feature-undocommand -no-feature-undogroup -no-feature-undostack -no-feature-undoview
$(package)_config_opts += -no-feature-vnc -no-feature-wizard -no-feature-xml

$(package)_config_opts_darwin = -no-dbus -no-opengl
ifneq ($(build_os),darwin)
$(package)_config_opts_darwin += -xplatform macx-clang-linux
$(package)_config_opts_darwin += -device-option MAC_SDK_PATH=$(OSX_SDK)
$(package)_config_opts_darwin += -device-option MAC_SDK_VERSION=$(OSX_SDK_VERSION)
$(package)_config_opts_darwin += -device-option CROSS_COMPILE="$(host)-"
$(package)_config_opts_darwin += -device-option MAC_MIN_VERSION=$(OSX_MIN_VERSION)
$(package)_config_opts_darwin += -device-option MAC_TARGET=$(host)
$(package)_config_opts_darwin += -device-option XCODE_VERSION=$(XCODE_VERSION)
endif

$(package)_config_opts_aarch64_darwin += -device-option QMAKE_APPLE_DEVICE_ARCHS=arm64

$(package)_config_opts_linux  = -qt-xkbcommon-x11 -qt-xcb -no-xcb-xlib -no-feature-xlib
$(package)_config_opts_linux += -system-freetype -fontconfig -no-opengl -dbus-runtime
$(package)_config_opts_arm_linux += -platform linux-g++ -xplatform bitcoin-linux-g++
$(package)_config_opts_i686_linux  = -xplatform linux-g++-32
ifneq (,$(findstring -stdlib=libc++,$($(1)_cxx)))
$(package)_config_opts_x86_64_linux = -xplatform linux-clang-libc++
else
$(package)_config_opts_x86_64_linux = -xplatform linux-g++-64
endif
$(package)_config_opts_aarch64_linux = -xplatform linux-aarch64-gnu-g++
$(package)_config_opts_riscv64_linux = -platform linux-g++ -xplatform bitcoin-linux-g++

$(package)_config_opts_mingw32 = -no-opengl -no-dbus -xplatform win32-g++ -device-option CROSS_COMPILE="$(host)-"

$(package)_config_opts_android = -xplatform android-clang -android-sdk $(ANDROID_SDK) -android-ndk $(ANDROID_NDK)
$(package)_config_opts_android += -android-ndk-platform android-$(ANDROID_API_LEVEL) -device-option CROSS_COMPILE="$(host)-"
$(package)_config_opts_android += -egl -qpa xcb -no-eglfs -no-dbus -opengl es2 -qt-freetype -no-fontconfig
$(package)_config_opts_android += -L $(host_prefix)/lib -I $(host_prefix)/include

$(package)_config_opts_aarch64_android += -android-arch arm64-v8a
$(package)_config_opts_armv7a_android += -android-arch armeabi-v7a
$(package)_config_opts_x86_64_android += -android-arch x86_64
$(package)_config_opts_i686_android += -android-arch i686

$(package)_build_env  = QT_RCC_TEST=1 QT_RCC_SOURCE_DATE_OVERRIDE=1
endef

define $(package)_fetch_cmds
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_download_file),$($(package)_file_name),$($(package)_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash))
endef

define $(package)_extract_cmds
mkdir -p $($(package)_extract_dir) && \
echo "$($(package)_sha256_hash)  $($(package)_source)" > $($(package)_extract_dir)/.$($(package)_file_name).hash && \
echo "$($(package)_qttranslations_sha256_hash)  $($(package)_source_dir)/$($(package)_qttranslations_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
echo "$($(package)_qttools_sha256_hash)  $($(package)_source_dir)/$($(package)_qttools_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
$(build_SHA256SUM) -c $($(package)_extract_dir)/.$($(package)_file_name).hash && \
mkdir qtbase && tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C qtbase && \
mkdir qttranslations && tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C qttranslations && \
mkdir qttools && tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C qttools
endef

define $(package)_preprocess_cmds
for patch in freetype_back_compat fix_powerpc_libpng drop_lrelease_dependency dont_hardcode_pwd fix_qt_pkgconfig fix_configure_mac fix_no_printer fix_rcc_determinism xkb-default fix_android_qmake_conf fix_android_jni_static fix_riscv64_arch no-xlib fix_mingw_cross_compile fix_qpainter_non_determinism fix_limits_header; do \
patch -p1 -i $($(package)_patch_dir)/$$patch.patch; done && \
sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" qttranslations/translations/translations.pro && \
mkdir -p qtbase/mkspecs/macx-clang-linux && \
cp -f qtbase/mkspecs/macx-clang/qplatformdefs.h qtbase/mkspecs/macx-clang-linux/ && \
cp -f $($(package)_patch_dir)/mac-qmake.conf qtbase/mkspecs/macx-clang-linux/qmake.conf && \
cp -r qtbase/mkspecs/linux-arm-gnueabi-g++ qtbase/mkspecs/bitcoin-linux-g++ && \
sed -i.old "s/arm-linux-gnueabi-/$(host)-/g" qtbase/mkspecs/bitcoin-linux-g++/qmake.conf && \
echo "!host_build: QMAKE_CFLAGS     += $($(package)_cflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf && \
echo "!host_build: QMAKE_CXXFLAGS   += $($(package)_cxxflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf && \
echo "!host_build: QMAKE_LFLAGS     += $($(package)_ldflags)" >> qtbase/mkspecs/common/gcc-base.conf && \
sed -i.old "s|QMAKE_CC                = clang|QMAKE_CC                = $($(package)_cc)|" qtbase/mkspecs/common/clang.conf && \
sed -i.old "s|QMAKE_CXX               = clang++|QMAKE_CXX               = $($(package)_cxx)|" qtbase/mkspecs/common/clang.conf && \
sed -i.old "s/error(\"failed to parse default search paths from compiler output\")/\!darwin: error(\"failed to parse default search paths from compiler output\")/g" qtbase/mkspecs/features/toolchain.prf
endef

define $(package)_config_cmds
export PATH=$(build_prefix)/bin:$$PATH && \
cd qtbase && \
./configure $$($(package)_config_opts) $$($(package)_config_opts_$(build_os)) $$($(package)_config_opts_$(build_arch)_$(build_os)) $$($(package)_config_opts_$(build_arch)) $$($(package)_config_opts_release) -- $(MAKEFLAGS)
endef

define $(package)_build_cmds
cd qtbase && \
$(MAKE) -j$(NUM_THREADS)
endef

define $(package)_stage_cmds
cd qtbase && \
$(MAKE) install
endef

define $(package)_postprocess_cmds
rm -rf $(host_prefix)/lib/QtWebKitWidgets.framework $(host_prefix)/lib/QtWebKit.framework
find $(host_prefix)/lib -name "*.prl" -delete
find $(host_prefix)/lib -name "*.la" -delete
endef
