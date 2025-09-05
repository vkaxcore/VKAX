# depends/packages/bdb.mk
# VKAX — Berkeley DB 4.8 static; Android-safe staging; headers into include/db4.8; ensure both -4.8 and unversioned libs. — Setvin
package=bdb
$(package)_version=4.8.30
$(package)_download_path=https://download.oracle.com/berkeley-db
$(package)_file_name=db-$($(package)_version).NC.tar.gz
$(package)_sha256_hash=12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef
$(package)_build_subdir=build_unix
$(package)_patches=clang_cxx_11.patch

define $(package)_set_vars
	# static lib only + C++ API; PIC on linux/android to satisfy NDK linkers
	$(package)_config_opts=--disable-shared --enable-cxx --disable-replication
	$(package)_config_opts_linux=--with-pic
	$(package)_config_opts_android=--with-pic
	$(package)_config_opts_mingw32=--enable-mingw
	$(package)_cxxflags=-std=c++17
endef

define $(package)_preprocess_cmds
	patch -p1 < $($(package)_patch_dir)/clang_cxx_11.patch && \
	cp -f $(BASEDIR)/config.guess $(BASEDIR)/config.sub dist
endef

define $(package)_config_cmds
	../dist/configure --prefix=$(host_prefix) $($(package)_config_opts)
endef

define $(package)_build_cmds
	$(MAKE) libdb-4.8.a libdb_cxx-4.8.a
endef

define $(package)_stage_cmds
	$(MAKE) DESTDIR=$($(package)_staging_dir) install_lib install_include
endef

define $(package)_postprocess_cmds
	# move headers into versioned include dir expected by legacy autoconf checks
	mkdir -p $($(package)_staging_prefix_dir)/include/db4.8 && \
	if [ -d "$($(package)_staging_dir)/$(host_prefix)/include" ]; then \
		cd $($(package)_staging_dir)/$(host_prefix)/include && \
		for h in db.h db_cxx.h db_185.h db_cxx_mpool.h; do \
			[ -f "$$h" ] && cp -f "$$h" db4.8/; \
		done; \
	fi && \
	# ensure versioned libs exist; provide unversioned fallbacks to satisfy alt checks
	cd $($(package)_staging_dir)/$(host_prefix)/lib && \
	[ -f libdb_cxx-4.8.a ] || { [ -f libdb_cxx.a ] && cp -f libdb_cxx.a libdb_cxx-4.8.a; } && \
	[ -f libdb-4.8.a     ] || { [ -f libdb.a     ] && cp -f libdb.a     libdb-4.8.a; } && \
	[ -f libdb_cxx.a     ] || cp -f libdb_cxx-4.8.a libdb_cxx.a && \
	[ -f libdb.a         ] || cp -f libdb-4.8.a     libdb.a
endef

# Signed: Setvin
