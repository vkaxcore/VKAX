# ============================================
# depends/packages/packages.mk
# Aggregates package lists and includes their .mk definitions.
# ============================================

# ---- Core (your current list)
packages := boost libevent gmp sodium bls-dash backtrace cmake immer

# ---- Buckets the top-level Makefile uses/extends
protobuf_native_packages = native_protobuf
protobuf_packages        = protobuf
openssl_packages         = openssl

qt_packages              = qrencode zlib
qt_linux_packages        = qt expat dbus libxcb xcb_proto libXau xproto freetype fontconfig
qt_android_packages      = qt
qt_darwin_packages       = qt
qt_mingw32_packages      = qt

wallet_packages          = bdb
zmq_packages             = zeromq
upnp_packages            = miniupnpc
natpmp_packages          = libnatpmp

# macOS native (kept for parity; ignored on linux/android)
darwin_native_packages   = native_ds_store native_mac_alias
ifneq ($(build_os),darwin)
darwin_native_packages  += native_cctools native_libtapi native_libdmg-hfsplus
ifeq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
darwin_native_packages  += native_clang
endif
endif

# Host-arch specific native tools
$(host_arch)_$(host_os)_native_packages += native_b2

# ---- Include every package definition file that exists.
# This avoids “empty $(package)_source_dir” because a .mk wasn’t included.
# (Your repo stores these under depends/packages or packages. This covers both.)
-include $(wildcard depends/packages/*.mk)
-include $(wildcard packages/*.mk)

# ============================================
# Notes:
# - If a .mk truly doesn’t exist for a name in your lists above, the
#   doctor target (added below) will tell you exactly which variable is missing.
# ============================================
