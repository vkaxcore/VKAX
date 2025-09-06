# If the host architecture differs from the build architecture, prefix the toolchain name with host architecture.
ifneq ($(host),$(build))
host_toolchain:=$(host)-
endif

# Define the default host tools used for building (GCC, G++, AR, etc.)
default_host_CC = $(host_toolchain)gcc
default_host_CXX = $(host_toolchain)g++
default_host_AR = $(host_toolchain)ar
default_host_RANLIB = $(host_toolchain)ranlib
default_host_STRIP = $(host_toolchain)strip
default_host_LIBTOOL = $(host_toolchain)libtool
default_host_INSTALL_NAME_TOOL = $(host_toolchain)install_name_tool
default_host_OTOOL = $(host_toolchain)otool
default_host_NM = $(host_toolchain)nm

# Function to add host tool variables based on the host and build configuration.
define add_host_tool_func
ifneq ($(filter $(origin $1),undefined default),)
    # If the variable is undefined or set to a default value, use the default_host_ values.
    $(host_os)_$1?=$$(default_host_$1)
    $(host_arch)_$(host_os)_$1?=$$($(host_os)_$1)
    $(host_arch)_$(host_os)_$(release_type)_$1?=$$($(host_os)_$1)
else
    # Otherwise, set the tool using the existing variable or fallback to default_host_
    $(host_os)_$1=$(or $($1),$($(host_os)_$1),$(default_host_$1))
    $(host_arch)_$(host_os)_$1=$(or $($1),$($(host_arch)_$(host_os)_$1),$$($(host_os)_$1))
    $(host_arch)_$(host_os)_$(release_type)_$1=$(or $($1),$($(host_arch)_$(host_os)_$(release_type)_$1),$$($(host_os)_$1))
endif
host_$1=$$($(host_arch)_$(host_os)_$1)
endef

# Function to add flags (CFLAGS, CXXFLAGS, etc.) based on the host and release configuration.
define add_host_flags_func
    $(host_arch)_$(host_os)_$1 += $($(host_os)_$1)
    $(host_arch)_$(host_os)_$(release_type)_$1 += $($(host_os)_$(release_type)_$1)
    host_$1 = $$($(host_arch)_$(host_os)_$1)
    host_$(release_type)_$1 = $$($(host_arch)_$(host_os)_$(release_type)_$1)
endef

# Add the necessary host tools (compiler, linker, etc.) for both CC and CXX, as well as other tools.
$(foreach tool,CC CXX AR RANLIB STRIP NM LIBTOOL OTOOL INSTALL_NAME_TOOL,$(eval $(call add_host_tool_func,$(tool))))

# Add flags such as CFLAGS, CXXFLAGS, LDFLAGS to the build configuration.
$(foreach flags,CFLAGS CXXFLAGS CPPFLAGS LDFLAGS, $(eval $(call add_host_flags_func,$(flags))))
