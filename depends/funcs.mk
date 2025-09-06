# File: depends/funcs.mk
# Director: Setvin
# Intent: Core dependency build orchestration for VKAX "depends" with legacy layout preserved.
# Master fix: safe Android prefix; quoted PKG_CONFIG_* and PATH; filter Qt on Android; and
#             robust default configure logic with OpenSSL special-case (uses perl ./Configure).

AT ?= @

# --- Android prefix safety -----------------------------------------------------
ifeq ($(host_os),android)
  host_prefix ?= $(host)
  ifneq (,$(filter /%,$(host_prefix)))
    $(error host_prefix must be relative for Android, got "$(host_prefix)")
  endif
  build_prefix ?= $(host_prefix)/native
endif

# --- Android NDK glue (wrapper exports if env-only) ----------------------------
ifeq ($(host_os),android)
  ANDROID_API_LEVEL ?= $(ANDROID_API)
  HOST ?= $(host)

  ifneq ($(ANDROID_TOOLCHAIN_BIN),)
    android_toolchain_bin := $(ANDROID_TOOLCHAIN_BIN)
  else ifneq ($(ANDROID_NDK),)
    android_toolchain_bin := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
  else
    android_toolchain_bin :=
  endif

  android_SYSROOT := $(if $(android_toolchain_bin),$(abspath $(android_toolchain_bin)/../sysroot),)

  android_CC     := $(if $(android_toolchain_bin),$(android_toolchain_bin)/$(HOST)$(ANDROID_API_LEVEL)-clang,$(HOST)$(ANDROID_API_LEVEL)-clang)
  android_CXX    := $(if $(android_toolchain_bin),$(android_toolchain_bin)/$(HOST)$(ANDROID_API_LEVEL)-clang++,$(HOST)$(ANDROID_API_LEVEL)-clang++)
  android_AR     := $(if $(android_toolchain_bin),$(android_toolchain_bin)/llvm-ar,llvm-ar)
  android_RANLIB := $(if $(android_toolchain_bin),$(android_toolchain_bin)/llvm-ranlib,llvm-ranlib)
  android_STRIP  := $(if $(android_toolchain_bin),$(android_toolchain_bin)/llvm-strip,llvm-strip)

  ifneq ($(android_SYSROOT),)
    android_CPPFLAGS += --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
    android_CFLAGS   += --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
    android_CXXFLAGS += --sysroot=$(android_SYSROOT) -D__ANDROID_API__=$(ANDROID_API_LEVEL)
    android_LDFLAGS  += --sysroot=$(android_SYSROOT)
  endif

  export ANDROID_CC:=$(android_CC)
  export ANDROID_CXX:=$(android_CXX)
  export ANDROID_AR:=$(android_AR)
  export ANDROID_RANLIB:=$(android_RANLIB)
  export ANDROID_STRIP:=$(android_STRIP)
  export ANDROID_SYSROOT:=$(android_SYSROOT)
  export ANDROID_CPPFLAGS:=$(android_CPPFLAGS)
  export ANDROID_CFLAGS:=$(android_CFLAGS)
  export ANDROID_CXXFLAGS:=$(android_CXXFLAGS)
  export ANDROID_LDFLAGS:=$(android_LDFLAGS)

  ifneq ($(ANDROID_API_LEVEL),)
    export ANDROID_API:=$(ANDROID_API_LEVEL)
  endif

  # Android build is daemon/cli/tx only.
  NO_QT ?= 1
endif

# --- Filter out Qt when disabled or on Android --------------------------------
ifeq ($(NO_QT),1)
  packages        := $(filter-out qt% Qt%,$(packages))
  native_packages := $(filter-out native_qt%,$(native_packages))
endif

# --- Package defaults template -------------------------------------------------
define int_vars
$(1)_cc=$$($$($(1)_type)_CC)
$(1)_cxx=$$($$($(1)_type)_CXX)
$(1)_objc=$$($$($(1)_type)_OBJC)
$(1)_objcxx=$$($$($(1)_type)_OBJCXX)
$(1)_ar=$$($$($(1)_type)_AR)
$(1)_ranlib=$$($$($(1)_type)_RANLIB)
$(1)_libtool=$$($$($(1)_type)_LIBTOOL)
$(1)_nm=$$($$($(1)_type)_NM)
$(1)_cflags=$$($$($(1)_type)_CFLAGS) \
            $$($$($(1)_type)_$$(release_type)_CFLAGS)
$(1)_cxxflags=$$($$($(1)_type)_CXXFLAGS) \
              $$($$($(1)_type)_$$(release_type)_CXXFLAGS)
$(1)_ldflags=$$($$($(1)_type)_LDFLAGS) \
             $$($$($(1)_type)_$$(release_type)_LDFLAGS) \
             -L$$($($(1)_type)_prefix)/lib
$(1)_cppflags=$$($$($(1)_type)_CPPFLAGS) \
              $$($$($(1)_type)_$$(release_type)_CPPFLAGS) \
              -I$$($$($(1)_type)_prefix)/include
$(1)_recipe_hash:=
endef

define int_get_all_dependencies
$(sort $(foreach dep,$(2),$(2) $(call int_get_all_dependencies,$(1),$($(dep)_dependencies))))
endef

define fetch_file_inner
    ( mkdir -p $$($(1)_download_dir) && echo Fetching $(3) from $(2) && \
    $(build_DOWNLOAD) "$$($(1)_download_dir)/$(4).temp" "$(2)/$(3)" && \
    echo "$(5)  $$($(1)_download_dir)/$(4).temp" > $$($(1)_download_dir)/.$(4).hash && \
    $(build_SHA256SUM) -c $$($(1)_download_dir)/.$(4).hash && \
    mv $$($(1)_download_dir)/$(4).temp $$($(1)_source_dir)/$(4) && \
    rm -rf $$($(1)_download_dir) )
endef

define fetch_file
    ( test -f $$($(1)_source_dir)/$(4) || \
    ( $(call fetch_file_inner,$(1),$(2),$(3),$(4),$(5)) || \
      (sleep 5 && $(call fetch_file_inner,$(1),$(2),$(3),$(4),$(5))) || \
      (sleep 10 && $(call fetch_file_inner,$(1),$(2),$(3),$(4),$(5))) || \
      $(call fetch_file_inner,$(1),$(FALLBACK_DOWNLOAD_PATH),$(3),$(4),$(5))))
endef

define int_get_build_recipe_hash
$(eval $(1)_all_file_checksums:=$(shell $(build_SHA256SUM) $(meta_depends) packages/$(1).mk $(addprefix $(PATCHES_PATH)/$(1)/,$($(1)_patches)) | cut -d" " -f1))
$(eval $(1)_recipe_hash:=$(shell echo -n "$($(1)_all_file_checksums)" | $(build_SHA256SUM) | cut -d" " -f1))
endef

define int_get_build_id
$(eval $(1)_dependencies += $($(1)_$(host_arch)_$(host_os)_dependencies) $($(1)_$(host_os)_dependencies))
$(eval $(1)_all_dependencies:=$(call int_get_all_dependencies,$(1),$($($(1)_type)_native_toolchain) $($($(1)_type)_native_binutils) $($(1)_dependencies)))
$(foreach dep,$($(1)_all_dependencies),$(eval $(1)_build_id_deps+=$(dep)-$($(dep)_version)-$($(dep)_recipe_hash)))
$(eval $(1)_build_id_long:=$(1)-$($(1)_version)-$($(1)_recipe_hash)-$(release_type) $($(1)_build_id_deps) $($($(1)_type)_id_string))
$(eval $(1)_build_id:=$(shell echo -n "$($(1)_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH)))
final_build_id_long+=$($(1)_build_id_long)

$(1)_build_subdir?=.
$(1)_download_file?=$($(1)_file_name)
$(1)_source_dir:=$(SOURCES_PATH)
$(1)_source:=$$($(1)_source_dir)/$($(1)_file_name)
$(1)_staging_dir=$(base_staging_dir)/$(host)/$(1)/$($(1)_version)-$($(1)_build_id)
$(1)_staging_prefix_dir:=$$($(1)_staging_dir)$($($(1)_type)_prefix)
$(1)_extract_dir:=$(base_build_dir)/$(host)/$(1)/$($(1)_version)-$($(1)_build_id)
$(1)_download_dir:=$(base_download_dir)/$(1)-$($(1)_version)
$(1)_build_dir:=$$($(1)_extract_dir)/$$($(1)_build_subdir)
$(1)_cached_checksum:=$(BASE_CACHE)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz.hash
$(1)_patch_dir:=$(base_build_dir)/$(host)/$(1)/$($(1)_version)-$($(1)_build_id)/.patches-$($(1)_build_id)
$(1)_prefixbin:=$($($(1)_type)_prefix)/bin/
$(1)_cached:=$(BASE_CACHE)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz
$(1)_all_sources=$($(1)_file_name) $($(1)_extra_sources)

$(1)_fetched=$(SOURCES_PATH)/download-stamps/.stamp_fetched-$(1)-$($(1)_file_name).hash
$(1)_extracted=$$($(1)_extract_dir)/.stamp_extracted
$(1)_preprocessed=$$($(1)_extract_dir)/.stamp_preprocessed
$(1)_cleaned=$$($(1)_extract_dir)/.stamp_cleaned
$(1)_built=$$($(1)_build_dir)/.stamp_built
$(1)_configured=$$($(1)_build_dir)/.stamp_configured
$(1)_staged=$$($(1)_staging_dir)/.stamp_staged
$(1)_postprocessed=$$($(1)_staging_prefix_dir)/.stamp_postprocessed
$(1)_download_path_fixed=$(subst :,\:,$$($(1)_download_path))

$(1)_fetch_cmds ?= $(call fetch_file,$(1),$(subst \:,:,$$($(1)_download_path_fixed)),$$($(1)_download_file),$($(1)_file_name),$($(1)_sha256_hash))
$(1)_extract_cmds ?= mkdir -p $$($(1)_extract_dir) && echo "$$($(1)_sha256_hash)  $$($(1)_source)" > $$($(1)_extract_dir)/.$$($(1)_file_name).hash &&  $(build_SHA256SUM) -c $$($(1)_extract_dir)/.$$($(1)_file_name).hash && tar --no-same-owner --strip-components=1 -xf $$($(1)_source)
$(1)_preprocess_cmds ?=
$(1)_build_cmds ?=
$(1)_config_cmds ?=
$(1)_stage_cmds ?=
$(1)_set_vars ?=

all_sources+=$$($(1)_fetched)
endef

# --- Attach build config and create a robust default configure path ------------
define int_config_attach_build_config
$(eval $(call $(1)_set_vars,$(1)))
$(1)_cflags+=$($(1)_cflags_$(release_type))
$(1)_cflags+=$($(1)_cflags_$(host_arch)) $($(1)_cflags_$(host_arch)_$(release_type))
$(1)_cflags+=$($(1)_cflags_$(host_os)) $($(1)_cflags_$(host_os)_$(release_type))
$(1)_cflags+=$($(1)_cflags_$(host_arch)_$(host_os)) $($(1)_cflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_cxxflags+=$($(1)_cxxflags_$(release_type))
$(1)_cxxflags+=$($(1)_cxxflags_$(host_arch)) $($(1)_cxxflags_$(host_arch)_$(release_type))
$(1)_cxxflags+=$($(1)_cxxflags_$(host_os)) $($(1)_cxxflags_$(host_os)_$(release_type))
$(1)_cxxflags+=$($(1)_cxxflags_$(host_arch)_$(host_os)) $($(1)_cxxflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_cppflags+=$($(1)_cppflags_$(release_type))
$(1)_cppflags+=$($(1)_cppflags_$(host_arch)) $($(1)_cppflags_$(host_arch)_$(release_type))
$(1)_cppflags+=$($(1)_cppflags_$(host_os)) $($(1)_cppflags_$(host_os)_$(release_type))
$(1)_cppflags+=$($(1)_cppflags_$(host_arch)_$(host_os)) $($(1)_cppflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_ldflags+=$($(1)_ldflags_$(release_type))
$(1)_ldflags+=$($(1)_ldflags_$(host_arch)) $($(1)_ldflags_$(host_arch)_$(release_type))
$(1)_ldflags+=$($(1)_ldflags_$(host_os)) $($(1)_ldflags_$(host_os)_$(release_type))
$(1)_ldflags+=$($(1)_ldflags_$(host_arch)_$(host_os)) $($(1)_ldflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_build_opts+=$$($(1)_build_opts_$(release_type))
$(1)_build_opts+=$$($(1)_build_opts_$(host_arch)) $$($(1)_build_opts_$(host_arch)_$(release_type))
$(1)_build_opts+=$$($(1)_build_opts_$(host_os)) $$($(1)_build_opts_$(host_os)_$(release_type))
$(1)_build_opts+=$$($(1)_build_opts_$(host_arch)_$(host_os)) $$($(1)_build_opts_$(host_arch)_$(host_os)_$(release_type))

$(1)_config_opts+=$$($(1)_config_opts_$(release_type))
$(1)_config_opts+=$$($(1)_config_opts_$(host_arch)) $$($(1)_config_opts_$(host_arch)_$(release_type))
$(1)_config_opts+=$$($(1)_config_opts_$(host_os)) $$($(1)_config_opts_$(host_os)_$(release_type))
$(1)_config_opts+=$$($(1)_config_opts_$(host_arch)_$(host_os)) $$($(1)_config_opts_$(host_arch)_$(host_os)_$(release_type))

$(1)_config_env+=$$($(1)_config_env_$(release_type))
$(1)_config_env+=$($(1)_config_env_$(host_arch)) $($(1)_config_env_$(host_arch)_$(release_type))
$(1)_config_env+=$($(1)_config_env_$(host_os)) $($(1)_config_env_$(host_os)_$(release_type))
$(1)_config_env+=$($(1)_config_env_$(host_arch)_$(host_os)) $($(1)_config_env_$(host_arch)_$(host_os)_$(release_type))

# QUOTED to avoid space-splitting in CI
$(1)_config_env+=PKG_CONFIG_LIBDIR="$($($(1)_type)_prefix)/lib/pkgconfig"
$(1)_config_env+=PKG_CONFIG_PATH="$($($(1)_type)_prefix)/share/pkgconfig"
$(1)_config_env+=PATH="$(build_prefix)/bin:$(PATH)"
$(1)_build_env+=PATH="$(build_prefix)/bin:$(PATH)"
$(1)_stage_env+=PATH="$(build_prefix)/bin:$(PATH)"

# Autoconf line (used by default path below if ./configure exists)
$(1)_autoconf=./configure --host=$($($(1)_type)_host) --disable-dependency-tracking --prefix=$($($(1)_type)_prefix) $$($(1)_config_opts) CC="$$($(1)_cc)" CXX="$$($(1)_cxx)"

ifneq ($($(1)_nm),)
$(1)_autoconf += NM="$$($(1)_nm)"
endif
ifneq ($($(1)_ranlib),)
$(1)_autoconf += RANLIB="$$($(1)_ranlib)"
endif
ifneq ($($(1)_ar),)
$(1)_autoconf += AR="$$($(1)_ar)"
endif
ifneq ($($(1)_cflags),)
$(1)_autoconf += CFLAGS="$$($(1)_cflags)"
endif
ifneq ($($(1)_cxxflags),)
$(1)_autoconf += CXXFLAGS="$$($(1)_cxxflags)"
endif
ifneq ($($(1)_cppflags),)
$(1)_autoconf += CPPFLAGS="$$($(1)_cppflags)"
endif
ifneq ($($(1)_ldflags),)
$(1)_autoconf += LDFLAGS="$$($(1)_ldflags)"
endif

# --- Robust default configure command -----------------------------------------
# If a package recipe didn't provide $(1)_config_cmds, choose a smart default:
#   * Use ./configure when present (Autotools)
#   * For OpenSSL, prefer 'perl ./Configure <target> no-shared' (static) to avoid the
#     infamous "Usage: Configure ..." error you hit when calling ./configure.
ifeq ($($(1)_config_cmds),)
  ifeq ($(1),openssl)
    # Minimal target mapping that works across 1.0.x on Android toolchains
    $(1)_ossl_target := linux-generic64
    ifeq ($(host_arch),armv7a)
      $(1)_ossl_target := linux-armv4
    endif
    ifeq ($(host_arch),x86_64)
      $(1)_ossl_target := linux-x86_64
    endif
    ifeq ($(host_arch),i686)
      $(1)_ossl_target := linux-elf
    endif
    $(1)_config_cmds = \
      if test -f ./Configure; then \
        AR="$$($(1)_ar)" RANLIB="$$($(1)_ranlib)" CC="$$($(1)_cc)" perl ./Configure $$($(1)_ossl_target) no-shared no-asm --prefix=$$($$($(1)_type)_prefix) --openssldir=$$($$($(1)_type)_prefix)/ssl; \
      elif test -x ./config; then \
        AR="$$($(1)_ar)" RANLIB="$$($(1)_ranlib)" CC="$$($(1)_cc)" ./config no-shared no-asm --prefix=$$($$($(1)_type)_prefix) --openssldir=$$($$($(1)_type)_prefix)/ssl; \
      else \
        echo "error: OpenSSL Configure script not found"; exit 1; \
      fi
  else
    $(1)_config_cmds = \
      if test -x ./configure; then \
        $$($(1)_autoconf); \
      else \
        echo "note: no ./configure for $(1), skipping"; \
      fi
  endif
endif
endef

# --- Build steps ---------------------------------------------------------------
define int_add_cmds
$($(1)_fetched):
	$(AT)mkdir -p $$(@D) $(SOURCES_PATH)
	$(AT)rm -f $$@
	$(AT)touch $$@
	$(AT)cd $$(@D); $(call $(1)_fetch_cmds,$(1))
	$(AT)cd $($(1)_source_dir); $(foreach source,$($(1)_all_sources),$(build_SHA256SUM) $(source) >> $$(@);)
	$(AT)touch $$@
$($(1)_extracted): | $($(1)_fetched)
	$(AT)echo Extracting $(1)...
	$(AT)mkdir -p $$(@D)
	$(AT)cd $$(@D); $(call $(1)_extract_cmds,$(1))
	$(AT)touch $$@
$($(1)_preprocessed): | $($(1)_extracted)
	$(AT)echo Preprocessing $(1)...
	$(AT)mkdir -p $$(@D) $($(1)_patch_dir)
	$(AT)$(foreach patch,$($(1)_patches),cd $(PATCHES_PATH)/$(1); cp $(patch) $($(1)_patch_dir) ;)
	$(AT)cd $$(@D); $(call $(1)_preprocess_cmds, $(1))
	$(AT)touch $$@
$($(1)_configured): | $($(1)_dependencies) $($(1)_preprocessed)
	$(AT)echo Configuring $(1)...
	$(AT)case "$(host_prefix)" in /*) echo "ERROR: host_prefix is absolute: $(host_prefix)"; exit 1;; esac
	$(AT)rm -rf $(host_prefix); mkdir -p $(host_prefix)/lib; cd $(host_prefix); $(foreach package,$($(1)_all_dependencies), tar --no-same-owner -xf $($(package)_cached); )
	$(AT)mkdir -p $$(@D)
	$(AT)echo "[$(1)] HOST_PREFIX='$(host_prefix)'  BUILD_PREFIX='$(build_prefix)'"
	$(AT)echo "[$(1)] CC=$$($(1)_cc)  CXX=$$($(1)_cxx)  AR=$$($(1)_ar)  RANLIB=$$($(1)_ranlib)  NM=$$($(1)_nm)"
	$(AT)echo "[$(1)] CFLAGS='$$($(1)_cflags)'"
	$(AT)echo "[$(1)] CXXFLAGS='$$($(1)_cxxflags)'"
	$(AT)echo "[$(1)] CPPFLAGS='$$($(1)_cppflags)'"
	$(AT)echo "[$(1)] LDFLAGS='$$($(1)_ldflags)'"
	$(AT)+cd $$(@D); $($(1)_config_env) $(call $(1)_config_cmds, $(1))
	$(AT)touch $$@
$($(1)_built): | $($(1)_configured)
	$(AT)echo Building $(1)...
	$(AT)mkdir -p $$(@D)
	$(AT)+cd $$(@D); $($(1)_build_env) $(call $(1)_build_cmds, $(1))
	$(AT)touch $$@
$($(1)_staged): | $($(1)_built)
	$(AT)echo Staging $(1)...
	$(AT)mkdir -p $($(1)_staging_dir)/$(host_prefix)
	$(AT)cd $($(1)_build_dir); $($(1)_stage_env) $(call $(1)_stage_cmds, $(1))
	$(AT)rm -rf $($(1)_extract_dir)
	$(AT)touch $$@
$($(1)_postprocessed): | $($(1)_staged)
	$(AT)echo Postprocessing $(1)...
	$(AT)cd $($(1)_staging_prefix_dir); $(call $(1)_postprocess_cmds)
	$(AT)touch $$@
$($(1)_cached): | $($(1)_dependencies) $($(1)_postprocessed)
	$(AT)echo Caching $(1)...
	$(AT)cd $$($(1)_staging_dir)/$(host_prefix); find . | sort | tar --no-recursion -czf $$($(1)_staging_dir)/$$(@F) -T -
	$(AT)mkdir -p $$(@D)
	$(AT)rm -rf $$(@D) && mkdir -p $$(@D)
	$(AT)mv $$($(1)_staging_dir)/$$(@F) $$(@)
	$(AT)rm -rf $($(1)_staging_dir)
$($(1)_cached_checksum): $($(1)_cached)
	$(AT)cd $$(@D); $(build_SHA256SUM) $$(<F) > $$(@)

.PHONY: $(1)
$(1): | $($(1)_cached_checksum)
.SECONDARY: $($(1)_cached) $($(1)_postprocessed) $($(1)_staged) $($(1)_built) $($(1)_configured) $($(1)_preprocessed) $($(1)_extracted) $($(1)_fetched)
endef

stages = fetched extracted preprocessed configured built staged postprocessed cached cached_checksum
define ext_add_stages
$(foreach stage,$(stages),
          $(1)_$(stage): $($(1)_$(stage))
          .PHONY: $(1)_$(stage))
endef

# --- Orchestration -------------------------------------------------------------
$(foreach native_package,$(native_packages),$(eval $(native_package)_type=build))
$(foreach package,$(packages),$(eval $(package)_type=$(host_arch)_$(host_os)))
$(foreach package,$(all_packages),$(eval $(call int_vars,$(package))))
$(foreach native_package,$(native_packages),$(eval include packages/$(native_package).mk))
$(foreach package,$(packages),$(eval include packages/$(package).mk))
$(foreach package,$(all_packages),$(eval $(call int_get_build_recipe_hash,$(package))))
$(foreach package,$(all_packages),$(eval $(call int_get_build_id,$(package))))
$(foreach package,$(all_packages),$(eval $(call int_config_attach_build_config,$(package))))
$(foreach package,$(all_packages),$(eval $(call int_add_cmds,$(package))))
$(foreach package,$(packages),$(eval $($(package)_extracted): |$($($(host_arch)_$(host_os)_native_toolchain)_cached) $($($(host_arch)_$(host_os)_native_binutils)_cached) ))

# Signed: Setvin
