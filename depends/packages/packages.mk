# ============================================
# depends/packages/packages.mk
# Aggregates package lists and includes their .mk definitions.
# ============================================

# ---- Core (always used by VKAX)
packages := boost libevent gmp sodium bls-dash backtrace cmake immer

# ---- Features toggled elsewhere:
# - protobuf & openssl come via *_packages below
# - upnp/zeromq/bdb are appended conditionally by top-level Makefile

# Native/protobuf/openssl/qt buckets
protobuf_native_packages = native_protobuf
protobuf_packages        = protobuf
openssl_packages         = openssl

qt_packages              = qrencode zlib
qt_linux_packages        = qt expat dbus libxcb xcb_proto libXau xproto freetype fontconfig
qt_android_packages      = qt
qt_darwin_packages       = qt
qt_mingw32_packages      = qt

# Wallet / networking
wallet_packages          = bdb
zmq_packages             = zeromq
upnp_packages            = miniupnpc
natpmp_packages          = libnatpmp

# macOS native (unused on Linux/Android but kept for parity)
darwin_native_packages   = native_ds_store native_mac_alias
ifneq ($(build_os),darwin)
darwin_native_packages  += native_cctools native_libtapi native_libdmg-hfsplus
ifeq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
darwin_native_packages  += native_clang
endif
endif

# Host-arch specific native tools
$(host_arch)_$(host_os)_native_packages += native_b2

# ---- Include each package definition (.mk). Missing any of these will yield
#      empty $(package)_source_dir / _download_path / _file_name and crash mkdir.
# Core
include depends/packages/boost.mk
include depends/packages/libevent.mk
include depends/packages/gmp.mk
include depends/packages/sodium.mk
include depends/packages/bls-dash.mk
include depends/packages/backtrace.mk
include depends/packages/cmake.mk
include depends/packages/immer.mk

# Feature / networking / wallet
include depends/packages/miniupnpc.mk
include depends/packages/zeromq.mk
include depends/packages/bdb.mk
include depends/packages/libnatpmp.mk

# Crypto / serialization
include depends/packages/openssl.mk
include depends/packages/protobuf.mk
include depends/packages/native_protobuf.mk

# Tools needed by other packages
include depends/packages/native_b2.mk

# Qt stack (these are only used if NO_QT is not set)
include depends/packages/zlib.mk
include depends/packages/qrencode.mk
include depends/packages/qt.mk
include depends/packages/expat.mk
include depends/packages/dbus.mk
include depends/packages/libxcb.mk
include depends/packages/xcb_proto.mk
include depends/packages/libXau.mk
include depends/packages/xproto.mk
include depends/packages/freetype.mk
include depends/packages/fontconfig.mk

# ============================================
# Notes:
# - If your repo doesn’t contain one of the included files above,
#   remove that include or add the file. Do NOT leave a package
#   in the ‘packages’ list without its .mk included.
# ============================================
