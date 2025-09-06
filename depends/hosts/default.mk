# ============================================
# depends/hosts/default.mk
# Cross "host" toolchain mapping (no $(eval), LF line endings).
# ============================================

# Expect "host" and "build" triplets to be provided by top-level make.
# Our workflow passes both host=<triplet> and HOST=<triplet>.
host  ?=
build ?=

# If cross, prefix with "$host-"; otherwise empty.
ifneq ($(host),$(build))
host_toolchain := $(host)-
else
host_toolchain :=
endif

# Final host tool variables (simple/static; override from env if needed)
host_CC                ?= $(host_toolchain)gcc
host_CXX               ?= $(host_toolchain)g++
host_AR                ?= $(host_toolchain)ar
host_RANLIB            ?= $(host_toolchain)ranlib
host_STRIP             ?= $(host_toolchain)strip
host_LIBTOOL           ?= $(host_toolchain)libtool
host_INSTALL_NAME_TOOL ?= $(host_toolchain)install_name_tool
host_OTOOL             ?= $(host_toolchain)otool
host_NM                ?= $(host_toolchain)nm

# Flags (exposed for callers; we don’t compute per-OS here)
host_CFLAGS    ?=
host_CXXFLAGS  ?=
host_CPPFLAGS  ?=
host_LDFLAGS   ?=

# Notes:
# - This avoids $(eval) and foreach to prevent "missing separator" errors.
# - Ensure LF endings (Unix) to keep GNU make happy.
# ============================================
