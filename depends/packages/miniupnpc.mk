# depends/packages/miniupnpc.mk
# VKAX — miniupnpc static for Android cross; PIC + proper AR/RANLIB; headers under include/miniupnpc; libminiupnpc.a staged. — Setvin
package=miniupnpc
$(package)_version=2.0.20180203
$(package)_download_path=https://miniupnp.tuxfamily.org/files/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=90dda8c7563ca6cd4a83e23b3c66dbbea89603a1675bfdb852897c2c9cc220b7
$(package)_patches=dont_use_wingen.patch

define $(package)_set_vars
	# ensure PIC for NDK static linkers
	$(package)_cflags+=-fPIC
	# pass toolchain to makefile (upstream honors CC/AR/RANLIB/STRIP)
	$(package)_build_opts=CC="$($(package)_cc)" AR="$($(package)_ar)" RANLIB="$(host_RANLIB)" STRIP="$(host_STRIP)"
	$(package)_build_opts_darwin+=LIBTOOL="$($(package)_libtool)"
	# feed flags via env to avoid Makefile override surprises
	$(package)_build_env+=CFLAGS="$($(package)_cflags) $($(package)_cppflags)" LDFLAGS="$($(package)_ldflags)"
endef

define $(package)_preprocess_cmds
	mkdir -p dll && \
	sed -e 's|MINIUPNPC_VERSION_STRING "version"|MINIUPNPC_VERSION_STRING "$($(package)_version)"|' \
	    -e 's|OS/version|$(host)|' miniupnpcstrings.h.in > miniupnpcstrings.h && \
	patch -p1 < $($(package)_patch_dir)/dont_use_wingen.patch
endef

define $(package)_build_cmds
	$($(package)_build_env) $(MAKE) $($(package)_build_opts) -j$(nproc) libminiupnpc.a
endef

define $(package)_stage_cmds
	mkdir -p $($(package)_staging_prefix_dir)/include/miniupnpc $($(package)_staging_prefix_dir)/lib && \
	install -m644 *.h $($(package)_staging_prefix_dir)/include/miniupnpc && \
	install -m644 libminiupnpc.a $($(package)_staging_prefix_dir)/lib/
endef

# Signed: Setvin
