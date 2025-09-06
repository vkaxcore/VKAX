# ============================================
# depends/builders/default.mk
# Native "build" toolchain selection (no $(eval), LF line endings).
# ============================================

# Defaults for native tools
default_build_CC                = gcc
default_build_CXX               = g++
default_build_AR                = ar
default_build_RANLIB            = ranlib
default_build_STRIP             = strip
default_build_NM                = nm
default_build_OTOOL             = otool
default_build_INSTALL_NAME_TOOL = install_name_tool

# Utilities used by the depends framework
default_build_SHA256SUM         = sha256sum
default_build_DOWNLOAD          = curl

# Normalize incoming identifiers (optional; build/build_os/build_arch are set by the workflow)
build        ?=
build_os     ?=
build_arch   ?=

# Final native tool vars (keep it simple: defaults unless someone overrides upstream)
build_CC                ?= $(default_build_CC)
build_CXX               ?= $(default_build_CXX)
build_AR                ?= $(default_build_AR)
build_RANLIB            ?= $(default_build_RANLIB)
build_STRIP             ?= $(default_build_STRIP)
build_NM                ?= $(default_build_NM)
build_OTOOL             ?= $(default_build_OTOOL)
build_INSTALL_NAME_TOOL ?= $(default_build_INSTALL_NAME_TOOL)
build_SHA256SUM         ?= $(default_build_SHA256SUM)
build_DOWNLOAD          ?= $(default_build_DOWNLOAD)

# Flags (don’t be clever; just expose passthrough vars if someone sets them)
build_CFLAGS   ?=
build_CXXFLAGS ?=
build_LDFLAGS  ?=

# Notes:
# - This file intentionally avoids $(eval) and complex macros to prevent
#   "*** missing separator" on systems with odd make versions or CRLFs.
# - Ensure LF endings (Unix) for all *.mk to keep GNU make happy.
# ============================================
