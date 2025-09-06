# ============================================
# depends/hosts/default.mk
# Maps cross "HOST" (e.g. aarch64-linux-android) tools & flags.
# ============================================

ifneq ($(host),$(build))
host_toolchain := $(host)-
endif

default_host_CC                = $(host_toolchain)gcc
default_host_CXX               = $(host_toolchain)g++
default_host_AR                = $(host_toolchain)ar
default_host_RANLIB            = $(host_toolchain)ranlib
default_host_STRIP             = $(host_toolchain)strip
default_host_LIBTOOL           = $(host_toolchain)libtool
default_host_INSTALL_NAME_TOOL = $(host_toolchain)install_name_tool
default_host_OTOOL             = $(host_toolchain)otool
default_host_NM                = $(host_toolchain)nm

# $1 is the tool var name (CC, CXX, ...)
define add_host_tool_func
ifneq ($(filter $(origin $1),undefined default),)
  $(host_os)_$1 ?= $$(default_host_$1)
  $(host_arch)_$(host_os)_$1 ?= $$($(host_os)_$1)
  $(host_arch)_$(host_os)_$(release_type)_$1 ?= $$($(host_os)_$1)
else
  $(host_os)_$1 = $(or $($1),$($(host_os)_$1),$(default_host_$1))
  $(host_arch)_$(host_os)_$1 = $(or $($1),$($(host_arch)_$(host_os)_$1),$$($(host_os)_$1))
  $(host_arch)_$(host_os)_$(release_type)_$1 = $(or $($1),$($(host_arch)_$(host_os)_$(release_type)_$1),$$($(host_os)_$1))
endif
host_$1 = $$($(host_arch)_$(host_os)_$1)
endef

# Apply explicitly to avoid foreach fragility
$(eval $(call add_host_tool_func,CC))
$(eval $(call add_host_tool_func,CXX))
$(eval $(call add_host_tool_func,AR))
$(eval $(call add_host_tool_func,RANLIB))
$(eval $(call add_host_tool_func,STRIP))
$(eval $(call add_host_tool_func,NM))
$(eval $(call add_host_tool_func,LIBTOOL))
$(eval $(call add_host_tool_func,OTOOL))
$(eval $(call add_host_tool_func,INSTALL_NAME_TOOL))

# Flag mapping
define add_host_flags_func
$(host_arch)_$(host_os)_$1 += $($(host_os)_$1)
$(host_arch)_$(host_os)_$(release_type)_$1 += $($(host_os)_$(release_type)_$1)
host_$1 = $$($(host_arch)_$(host_os)_$1)
host_$(release_type)_$1 = $$($(host_arch)_$(host_os)_$(release_type)_$1)
endef

$(eval $(call add_host_flags_func,CFLAGS))
$(eval $(call add_host_flags_func,CXXFLAGS))
$(eval $(call add_host_flags_func,CPPFLAGS))
$(eval $(call add_host_flags_func,LDFLAGS))

# ============================================
# Notes:
# - Keep LF endings to avoid "*** missing separator".
# - The workflow exports CC/CXX/AR/RANLIB etc. to NDK llvm tools, which override these defaults.
# ============================================
