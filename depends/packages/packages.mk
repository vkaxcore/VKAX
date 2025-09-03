# Core packages
packages := boost libevent gmp sodium bls-dash backtrace cmake immer

# Native/protobuf/openssl/qt packages
protobuf_native_packages = native_protobuf
protobuf_packages = protobuf

openssl_packages = openssl

qt_packages = qrencode zlib

qt_linux_packages := qt expat dbus libxcb xcb_proto libXau xproto freetype fontconfig
qt_android_packages = qt
qt_darwin_packages = qt
qt_mingw32_packages = qt

# Wallet / networking
wallet_packages = bdb
zmq_packages = zeromq
upnp_packages = miniupnpc
natpmp_packages = libnatpmp

# macOS native packages
darwin_native_packages = native_ds_store native_mac_alias

# Host architecture specific native packages
$(host_arch)_$(host_os)_native_packages += native_b2

ifneq ($(build_os),darwin)
darwin_native_packages += native_cctools native_libtapi native_libdmg-hfsplus

ifeq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
darwin_native_packages += native_clang
endif

endif

# Include package definitions
include packages/sodium.mk
include packages/bls-dash.mk
