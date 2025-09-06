# ===== VKAX depends/hosts/default.mk (safe, explicit, no foreach) =====
# - Avoids 'missing separator' by not using foreach/eval chains
# - Ensures 'host' is always set so config.sub never gets an empty arg

# --- Ensure 'host' is defined ---------------------------------------------------
# Respect already-passed 'host', else use HOST env, else fall back to $(build)
host := $(strip $(or $(host),$(HOST),$(build)))

# If cross-compiling, add standard triplet prefix for binutils
ifneq ($(host),$(build))
host_toolchain := $(host)-
endif

# --- Defaults for tools ---------------------------------------------------------
default_host_CC  = $(host_toolchain)gcc
default_host_CXX = $(host_toolchain)g++
default_host_AR  = $(host_toolchain)ar
default_host_RANLIB = $(host_toolchain)ranlib
default_host_STRIP  = $(host_toolchain)strip
default_host_LIBTOOL = $(host_toolchain)libtool
default_host_INSTALL_NAME_TOOL = $(host_toolchain)install_name_tool
default_host_OTOOL = $(host_toolchain)otool
default_host_NM = $(host_toolchain)nm

# --- Macros used by package .mk files ------------------------------------------
define add_host_tool_func
ifneq ($(filter $(origin $1),undefined default),)
# If $1 (e.g. CC) is undefined or has make's default value, seed OS/tool defaults
$(host_os)_$1?=$$(default_host_$1)
$(host_arch)_$(host_os)_$1?=$$($(host_os)_$1)
$(host_arch)_$(host_os)_$(release_type)_$1?=$$($(host_os)_$1)
else
# Otherwise prefer the explicitly-provided value ($1), then OS default, then default_host_*
$(host_os)_$1=$(or $($1),$($(host_os)_$1),$(default_host_$1))
$(host_arch)_$(host_os)_$1=$(or $($1),$($(host_arch)_$(host_os)_$1),$$($(host_os)_$1))
$(host_arch)_$(host_os)_$(release_type)_$1=$(or $($1),$($(host_arch)_$(host_os)_$(release_type)_$1),$$($(host_os)_$1))
endif
host_$1=$$($(host_arch)_$(host_os)_$1)
endef

define add_host_flags_func
$(host_arch)_$(host_os)_$1 += $($(host_os)_$1)
$(host_arch)_$(host_os)_$(release_type)_$1 += $($(host_os)_$(release_type)_$1)
host_$1 = $$($(host_arch)_$(host_os)_$1)
host_$(release_type)_$1 = $$($(host_arch)_$(host_os)_$(release_type)_$1)
endef

# --- Explicit expansion (replaces the foreach that errors) ----------------------
# Tools:
$(eval $(call add_host_tool_func,CC))
$(eval $(call add_host_tool_func,CXX))
$(eval $(call add_host_tool_func,AR))
$(eval $(call add_host_tool_func,RANLIB))
$(eval $(call add_host_tool_func,STRIP))
$(eval $(call add_host_tool_func,NM))
$(eval $(call add_host_tool_func,LIBTOOL))
$(eval $(call add_host_tool_func,OTOOL))
$(eval $(call add_host_tool_func,INSTALL_NAME_TOOL))

# Flags:
$(eval $(call add_host_flags_func,CFLAGS))
$(eval $(call add_host_flags_func,CXXFLAGS))
$(eval $(call add_host_flags_func,CPPFLAGS))
$(eval $(call add_host_flags_func,LDFLAGS))

# -------------------------------------------------------------------------------
# If you still see "missing separator":
#   - Make sure this file has LF endings (run: dos2unix depends/hosts/default.mk)
#   - Ensure there are no tabs at the start of any non-recipe line.
# -------------------------------------------------------------------------------
