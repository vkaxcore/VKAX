# =============================================================================
# VKAX depends/hosts/default.mk  —  minimal, robust host tool/flags setup
# -----------------------------------------------------------------------------
# Why this file exists:
#   The previous version used "define/endef" + "$(eval …)" macros. One stray
#   tab, CRLF line ending, or syntax hiccup causes "missing separator" errors.
#   This pared-down variant avoids eval/macros entirely and is resilient on CI.
#
# What it does:
#   - Ensures $(host) is defined (derives from HOST, falls back to $(build)).
#   - Derives $(host_arch) and $(host_os) from $(host).
#   - Defines $(host_toolchain) prefix when cross-compiling.
#   - Sets host_* tools (CC/CXX/AR/…) from env if provided, otherwise falls back
#     to $(host_toolchain){clang,gcc} etc. (Clang preferred for Android).
#   - Mirrors top-level flags into host_* flags so packages inherit them.
#
# Notes:
#   - No recipe lines in this file, so there MUST NOT be any leading TABs.
#   - Use LF line endings. If you ever get “missing separator” again, run
#       dos2unix depends/hosts/default.mk
# =============================================================================

# 0) Normalize inputs ----------------------------------------------------------
# Some callers pass HOST (all caps). Make sure $(host) is set.
host ?= $(HOST)

# If still empty, try falling back to $(build) (usually defined by depends core).
ifeq ($(strip $(host)),)
  host := $(build)
endif

# As a last resort (keeps config.sub happy). Adjust if your default differs.
ifeq ($(strip $(host)),)
  host := aarch64-linux-android
endif

# 1) Derive host triplet fields -----------------------------------------------
# For aarch64-linux-android this yields:
#   host_arch = aarch64
#   host_os   = android
host_arch := $(firstword  $(subst -, ,$(host)))
host_os   := $(lastword   $(subst -, ,$(host)))

# If not building for native, prefix tool names with "<triplet>-".
ifeq ($(strip $(host)),$(strip $(build)))
  host_toolchain :=
else
  host_toolchain := $(host)-
endif

# 2) Tool selection (env overrides > sane defaults) ---------------------------
# If the workflow exports CC/CXX/AR/RANLIB/STRIP/NM these win.
# Otherwise prefer clang for Android; fall back to gcc/g++ if clang is absent.
host_CC     ?= $(CC)
host_CXX    ?= $(CXX)
host_AR     ?= $(AR)
host_RANLIB ?= $(RANLIB)
host_STRIP  ?= $(STRIP)
host_NM     ?= $(NM)
host_LIBTOOL?= $(LIBTOOL)
host_INSTALL_NAME_TOOL ?= $(INSTALL_NAME_TOOL)
host_OTOOL ?= $(OTOOL)

# Defaults if not provided by env:
ifeq ($(strip $(host_CC)),)
  # Prefer clang for Android; many NDK setups expect it.
  host_CC := $(host_toolchain)clang
endif
ifeq ($(strip $(host_CXX)),)
  host_CXX := $(host_toolchain)clang++
endif
ifeq ($(strip $(host_AR)),)
  host_AR := $(host_toolchain)ar
endif
ifeq ($(strip $(host_RANLIB)),)
  host_RANLIB := $(host_toolchain)ranlib
endif
ifeq ($(strip $(host_STRIP)),)
  host_STRIP := $(host_toolchain)strip
endif
ifeq ($(strip $(host_NM)),)
  host_NM := $(host_toolchain)nm
endif
ifeq ($(strip $(host_LIBTOOL)),)
  host_LIBTOOL := $(host_toolchain)libtool
endif
# These are Darwin-specific; harmless elsewhere.
ifeq ($(strip $(host_INSTALL_NAME_TOOL)),)
  host_INSTALL_NAME_TOOL := $(host_toolchain)install_name_tool
endif
ifeq ($(strip $(host_OTOOL)),)
  host_OTOOL := $(host_toolchain)otool
endif

# 3) Flags (inherit from top-level if set) ------------------------------------
# Make’s pattern is: host_* are the variables packages read.
host_CFLAGS   += $(CFLAGS)
host_CXXFLAGS += $(CXXFLAGS)
host_CPPFLAGS += $(CPPFLAGS)
host_LDFLAGS  += $(LDFLAGS)

# Android niceties: position-independent code by default for static deps.
# (Won’t override if caller already provided flags above.)
ifeq ($(host_os),android)
  ifeq ($(findstring -fPIC,$(host_CFLAGS)),)
    host_CFLAGS   += -fPIC
  endif
  ifeq ($(findstring -fPIC,$(host_CXXFLAGS)),)
    host_CXXFLAGS += -fPIC
  endif
endif

# 4) Export (optional): some packages look for plain tool names ----------------
# We don’t *force* these, but it helps when 3rd-party buildsystems ignore host_*.
# Uncomment if you need them propagated.
# CC      ?= $(host_CC)
# CXX     ?= $(host_CXX)
# AR      ?= $(host_AR)
# RANLIB  ?= $(host_RANLIB)
# STRIP   ?= $(host_STRIP)
# NM      ?= $(host_NM)
# CFLAGS  += $(host_CFLAGS)
# CXXFLAGS+= $(host_CXXFLAGS)
# CPPFLAGS+= $(host_CPPFLAGS)
# LDFLAGS += $(host_LDFLAGS)

# 5) Keep old variable names for compatibility (some packages expect these) ----
default_host_CC               := $(host_CC)
default_host_CXX              := $(host_CXX)
default_host_AR               := $(host_AR)
default_host_RANLIB           := $(host_RANLIB)
default_host_STRIP            := $(host_STRIP)
default_host_LIBTOOL          := $(host_LIBTOOL)
default_host_INSTALL_NAME_TOOL:= $(host_INSTALL_NAME_TOOL)
default_host_OTOOL            := $(host_OTOOL)
default_host_NM               := $(host_NM)

# End of file — no tabs anywhere, no recipes, no evals. 🎯
