# ============================================
# depends/hosts/default.mk
# Minimal, eval-free mapping of cross "HOST" tools & flags.
# This avoids '*** missing separator' issues from CRLF/whitespace
# and still obeys CC/CXX/... from the environment (which we export in CI).
# ============================================

# If host != build, prefix with $(host)- (e.g. aarch64-linux-android-)
host_toolchain :=
ifneq ($(host),$(build))
host_toolchain := $(host)-
endif

# Prefer environment overrides (CC, CXX, ...) else fallback to cross prefix.
host_CC                ?= $(or $(CC),$(host_toolchain)gcc)
host_CXX               ?= $(or $(CXX),$(host_toolchain)g++)
host_AR                ?= $(or $(AR),$(host_toolchain)ar)
host_RANLIB            ?= $(or $(RANLIB),$(host_toolchain)ranlib)
host_STRIP             ?= $(or $(STRIP),$(host_toolchain)strip)
host_LIBTOOL           ?= $(or $(LIBTOOL),$(host_toolchain)libtool)
host_INSTALL_NAME_TOOL ?= $(or $(INSTALL_NAME_TOOL),$(host_toolchain)install_name_tool)
host_OTOOL             ?= $(or $(OTOOL),$(host_toolchain)otool)
host_NM                ?= $(or $(NM),$(host_toolchain)nm)

# Flags: pass through whatever CI exports so depends picks them up.
host_CFLAGS   += $(CFLAGS)
host_CXXFLAGS += $(CXXFLAGS)
host_CPPFLAGS += $(CPPFLAGS)
host_LDFLAGS  += $(LDFLAGS)

# NOTE:
# - No recipes/commands in this file (nothing requires leading TABs).
# - Keep LF (Unix) endings; CI runs `dos2unix` before building.
# ============================================
