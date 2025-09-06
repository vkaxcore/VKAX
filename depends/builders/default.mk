# ============================================
# depends/builders/default.mk
# Standardizes "build" (native/tools) toolchain selections.
# This is separate from the cross-compile HOST toolchain.
# ============================================

# ---- Default native tools (override per OS/arch below if needed)
default_build_CC                = gcc
default_build_CXX               = g++
default_build_AR                = ar
default_build_RANLIB            = ranlib
default_build_STRIP             = strip
default_build_NM                = nm
default_build_OTOOL             = otool
default_build_INSTALL_NAME_TOOL = install_name_tool

# Utilities used by the depends framework (give safe defaults)
default_build_SHA256SUM         = sha256sum
default_build_DOWNLOAD          = curl

# ---- Map defaults -> per-OS -> per-arch+OS -> final "build_*" variables
# $1 is the tool var name (CC, CXX, ...)

define add_build_tool_func
build_$(build_os)_$1 ?= $$(default_build_$1)
build_$(build_arch)_$(build_os)_$1 ?= $$(build_$(build_os)_$1)
build_$1 = $$(build_$(build_arch)_$(build_os)_$1)
endef

# Apply explicitly (avoids fragile foreach on some setups)
$(eval $(call add_build_tool_func,CC))
$(eval $(call add_build_tool_func,CXX))
$(eval $(call add_build_tool_func,AR))
$(eval $(call add_build_tool_func,RANLIB))
$(eval $(call add_build_tool_func,STRIP))
$(eval $(call add_build_tool_func,NM))
$(eval $(call add_build_tool_func,OTOOL))
$(eval $(call add_build_tool_func,INSTALL_NAME_TOOL))
$(eval $(call add_build_tool_func,SHA256SUM))
$(eval $(call add_build_tool_func,DOWNLOAD))

# ---- Flags propagation
# $1 is the flags var (CFLAGS, CXXFLAGS, LDFLAGS)

define add_build_flags_func
build_$(build_arch)_$(build_os)_$1 += $$(build_$(build_os)_$1)
build_$1 = $$(build_$(build_arch)_$(build_os)_$1)
endef

$(eval $(call add_build_flags_func,CFLAGS))
$(eval $(call add_build_flags_func,CXXFLAGS))
$(eval $(call add_build_flags_func,LDFLAGS))

# ============================================
# Notes:
# - Ensure this file uses LF endings (no CRLF), or GNU make may emit
#   "*** missing separator" at $(eval ...) lines.
# - Variables build, build_arch, build_os are set by the workflow before "make -C depends".
# ============================================
