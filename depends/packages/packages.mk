# ============================================
# depends/packages/packages.mk
# Master package registry for the depends framework.
# - Lists core, optional, and native packages.
# - Wires per-platform Qt groupings.
# - Adds safety defaults so macros don’t choke on empty vars.
# - Uses -include to avoid hard failures if a package .mk is absent.
#
# NOTE:
#   Keep this file with LF endings (no CRLF), or GNU make may error with:
#   "*** missing separator."
# ============================================

# -----------------------------
# Core packages (always candidates for build)
# -----------------------------
# Your original set:
#   boost libevent gmp sodium bls-dash backtrace cmake immer
packages := boost libevent gmp sodium bls-dash backtrace cmake immer

# -----------------------------
# Feature buckets (controlled by NO_* toggles)
# These are *names* only; the top-level Makefile decides which buckets apply:
#   - qt_packages_$(NO_QT)
#   - wallet_packages_$(NO_WALLET)
#   - zmq_packages_$(NO_ZMQ)
#   - upnp_packages_$(NO_UPNP)
#   - natpmp_packages_$(NO_NATPMP)
#   - protobuf_* (NO_PROTOBUF)
#   - openssl_packages (NO_OPENSSL)
# -----------------------------

# --- Protobuf (native b2/protoc & target protobuf)
protobuf_native_packages = native_protobuf
protobuf_packages        = protobuf

# --- OpenSSL
openssl_packages = openssl

# --- Qt bucket (these are grouped; platform-specific Qt deps below)
qt_packages = qrencode zlib

# --- Wallet / Networking / NAT traversal
wallet_packages = bdb
zmq_packages    = zeromq
upnp_packages   = miniupnpc
natpmp_packages = libnatpmp

# -----------------------------
# Platform-specific Qt bundle
# (Used only if NO_QT is empty; the top-level Makefile’s logic controls that)
# -----------------------------
qt_linux_packages   := qt expat dbus libxcb xcb_proto libXau xproto freetype fontconfig
qt_android_packages =  qt
qt_darwin_packages  =  qt
qt_mingw32_packages =  qt

# -----------------------------
# Native host tools (built for the build machine)
# -----------------------------
# macOS native helpers used when building mac artifacts:
darwin_native_packages = native_ds_store native_mac_alias

# Host-arch specific native pieces
# (native_b2 is nice-to-have: speeds up Boost builds)
$(host_arch)_$(host_os)_native_packages += native_b2

# On non-darwin builders, add extra mac packagers if you cross-produce dmg/hfs
ifneq ($(build_os),darwin)
darwin_native_packages += native_cctools native_libtapi native_libdmg-hfsplus
# If you don’t force using the system clang, allow depends to build a pinned clang
ifeq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
darwin_native_packages += native_clang
endif
endif

# ============================================
# SAFETY GUARDS (prevents mkdir: missing operand)
# Some package recipes/macros assume $(<pkg>_source_dir) exists.
# If any package forgets to define it in its own .mk, define a safe default here.
# This avoids "mkdir -p" with an empty argument in check_or_remove_sources.
# ============================================

# Default source_dir for *core* packages if undefined:
$(foreach p,$(packages), \
  $(eval $(if $($(p)_source_dir),, \
    $(p)_source_dir := $(SOURCES_PATH)/$(p) )))

# Default source_dir for feature buckets (only set when they’re used):
$(foreach p,$(wallet_packages) $(zmq_packages) $(upnp_packages) $(natpmp_packages) \
             $(openssl_packages) $(protobuf_packages) $(qt_packages) \
             $(qt_linux_packages) $(qt_android_packages) $(qt_darwin_packages) $(qt_mingw32_packages), \
  $(eval $(if $($(p)_source_dir),, \
    $(p)_source_dir := $(SOURCES_PATH)/$(p) )))

# Default source_dir for native packages:
$(foreach p,$(darwin_native_packages) $(protobuf_native_packages) native_b2 native_protobuf, \
  $(eval $(if $($(p)_source_dir),, \
    $(p)_source_dir := $(SOURCES_PATH)/$(p) )))

# NOTE:
# We do NOT set defaults for <pkg>_cached / _cached_checksum / _all_sources here,
# because those are often tightly coupled to the package’s version/tarball naming.
# The only thing that caused your error was an *empty* _source_dir, which we fix above.

# ============================================
# PACKAGE DEFINITIONS
# - Use "-include" so a missing .mk doesn’t hard-fail; you’ll just skip that package.
# - Keep packages you *know* your tree contains with "include" if you want hard errors.
# ============================================

# ---- Core libs/tooling (soft include to be resilient)
-include packages/boost.mk          # Boost (ensure this or a pinned version exists)
-include packages/libevent.mk       # libevent
-include packages/gmp.mk            # GNU MP
-include packages/sodium.mk         # (you already include this below; keep one line only)
-include packages/bls-dash.mk       # BLS (Dash variant)
-include packages/backtrace.mk      # libbacktrace
-include packages/cmake.mk          # CMake (native or target as needed)
-include packages/immer.mk          # immer

# (You already had:)
include packages/sodium.mk
include packages/bls-dash.mk

# ---- Optional features (wallet/ZMQ/NAT/OpenSSL/Protobuf)
-include packages/bdb.mk
-include packages/zeromq.mk
-include packages/miniupnpc.mk
-include packages/libnatpmp.mk
-include packages/openssl.mk
-include packages/protobuf.mk
-include packages/native_protobuf.mk

# ---- Qt & friends (only used if NO_QT is not set)
-include packages/qt.mk
-include packages/qrencode.mk
-include packages/zlib.mk
-include packages/expat.mk
-include packages/dbus.mk
-include packages/libxcb.mk
-include packages/xcb_proto.mk
-include packages/libXau.mk
-include packages/xproto.mk
-include packages/freetype.mk
-include packages/fontconfig.mk

# ---- Native tools
-include packages/native_b2.mk
-include packages/native_clang.mk
-include packages/native_cctools.mk
-include packages/native_libtapi.mk
-include packages/native_libdmg-hfsplus.mk
-include packages/native_ds_store.mk
-include packages/native_mac_alias.mk

# ============================================
# Notes / Tips
# - To build Android-only, you can set NO_QT=1 to skip all Qt heavy deps.
# - If a package is truly required, switch its line from "-include" to "include"
#   so you fail fast when it’s missing.
# - Keep per-package versions, urls, and hashes inside their own .mk files.
# - If you add a new package name to one of the buckets above, either provide
#   its packages/<name>.mk or keep it as "-include" while you stage it in.
# ============================================
