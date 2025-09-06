# ============================================
# depends/hosts/default.mk
# Eval-free mapping for cross "HOST" toolchain + flags
# ============================================

# If cross-compiling, prefix GNU-style tool names with "<host>-"
ifneq ($(host),$(build))
host_toolchain := $(host)-
endif

# ---- Tools (allow env overrides first, then fall back to prefixed GNU tools)
host_CC     ?= $(if $(CC),$(CC),$(host_toolchain)gcc)
host_CXX    ?= $(if $(CXX),$(CXX),$(host_toolchain)g++)
host_AR     ?= $(if $(AR),$(AR),$(host_toolchain)ar)
host_RANLIB ?= $(if $(RANLIB),$(RANLIB),$(host_toolchain)ranlib)
host_STRIP  ?= $(if $(STRIP),$(STRIP),$(host_toolchain)strip)
host_NM     ?= $(if $(NM),$(NM),$(host_toolchain)nm)
host_LIBTOOL           ?= $(if $(LIBTOOL),$(LIBTOOL),$(host_toolchain)libtool)
host_INSTALL_NAME_TOOL ?= $(if $(INSTALL_NAME_TOOL),$(INSTALL_NAME_TOOL),$(host_toolchain)install_name_tool)
host_OTOOL             ?= $(if $(OTOOL),$(OTOOL),$(host_toolchain)otool)

# ---- Flags (inherit anything the CI/workflow exports)
host_CFLAGS   += $(CFLAGS)
host_CXXFLAGS += $(CXXFLAGS)
host_CPPFLAGS += $(CPPFLAGS)
host_LDFLAGS  += $(LDFLAGS)

# ---- Mirror to per-OS and per-arch+OS names (some depends recipes read these)
# Tools
$(host_os)_CC                ?= $(host_CC)
$(host_os)_CXX               ?= $(host_CXX)
$(host_os)_AR                ?= $(host_AR)
$(host_os)_RANLIB            ?= $(host_RANLIB)
$(host_os)_STRIP             ?= $(host_STRIP)
$(host_os)_NM                ?= $(host_NM)
$(host_os)_LIBTOOL           ?= $(host_LIBTOOL)
$(host_os)_INSTALL_NAME_TOOL ?= $(host_INSTALL_NAME_TOOL)
$(host_os)_OTOOL             ?= $(host_OTOOL)

$(host_arch)_$(host_os)_CC                ?= $($(host_os)_CC)
$(host_arch)_$(host_os)_CXX               ?= $($(host_os)_CXX)
$(host_arch)_$(host_os)_AR                ?= $($(host_os)_AR)
$(host_arch)_$(host_os)_RANIB             ?= $($(host_os)_RANLIB)
$(host_arch)_$(host_os)_STRIP             ?= $($(host_os)_STRIP)
$(host_arch)_$(host_os)_NM                ?= $($(host_os)_NM)
$(host_arch)_$(host_os)_LIBTOOL           ?= $($(host_os)_LIBTOOL)
$(host_arch)_$(host_os)_INSTALL_NAME_TOOL ?= $($(host_os)_INSTALL_NAME_TOOL)
$(host_arch)_$(host_os)_OTOOL             ?= $($(host_os)_OTOOL)

# Flags
$(host_os)_CFLAGS    ?= $(host_CFLAGS)
$(host_os)_CXXFLAGS  ?= $(host_CXXFLAGS)
$(host_os)_CPPFLAGS  ?= $(host_CPPFLAGS)
$(host_os)_LDFLAGS   ?= $(host_LDFLAGS)

$(host_arch)_$(host_os)_CFLAGS    ?= $($(host_os)_CFLAGS)
$(host_arch)_$(host_os)_CXXFLAGS  ?= $($(host_os)_CXXFLAGS)
$(host_arch)_$(host_os)_CPPFLAGS  ?= $($(host_os)_CPPFLAGS)
$(host_arch)_$(host_os)_LDFLAGS   ?= $($(host_os)_LDFLAGS)

# ============================================
# Notes:
# - No define/endef or $(eval) to avoid "missing separator" with CRLF/BOM.
# - Keep LF endings only.
# - CI should export CC/CXX with NDK clang and --target/--sysroot (already done).
# ============================================
