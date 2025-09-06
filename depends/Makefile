# .NOTPARALLEL : Avoid parallel build issues for certain targets.

# Define variables
MAKEOVERRIDES := $(filter V=%,$(MAKEOVERRIDES))
BASEDIR := $(CURDIR)
WORK_PATH := $(BASEDIR)/work
BASE_CACHE := $(BASEDIR)/built
SDK_PATH := $(BASEDIR)/SDKs
HOST := $(shell ./config.guess)
HOST_ID_SALT := salt
BUILD_ID_SALT := salt
HASH_LENGTH := 11
DOWNLOAD_CONNECT_TIMEOUT := 30

# Default build directories
base_build_dir := $(WORK_PATH)/build
base_staging_dir := $(WORK_PATH)/staging
base_download_dir := $(WORK_PATH)/download
canonical_host := $(shell ./config.sub $(HOST))
build := $(shell ./config.sub $(BUILD))

# Set up the host architecture and OS
build_arch := $(firstword $(subst -, ,$(build)))
build_vendor := $(word 2,$(subst -, ,$(build)))
full_build_os := $(subst $(build_arch)-$(build_vendor)-,,$(build))
build_os := $(findstring linux,$(full_build_os))
build_os += $(findstring darwin,$(full_build_os))
build_os := $(strip $(build_os))
ifeq ($(build_os),)
  build_os := $(full_build_os)
endif

# Host specific architecture and OS
host_arch := $(firstword $(subst -, ,$(canonical_host)))
host_vendor := $(word 2,$(subst -, ,$(canonical_host)))
full_host_os := $(subst $(host_arch)-$(host_vendor)-,,$(canonical_host))
host_os := $(findstring linux,$(full_host_os))
host_os += $(findstring darwin,$(full_host_os))
host_os += $(findstring mingw32,$(full_host_os))

ifeq (android,$(findstring android,$(full_host_os)))
  host_os := android
endif

host_os := $(strip $(host_os))
ifeq ($(host_os),)
  host_os := $(full_host_os)
endif

# Path to NDK and dependencies
ANDROID_NDK := $(BASEDIR)/android-sdk/ndk/android-ndk-r23c
ANDROID_API := 21
HOST_PREFIX := $(BASEDIR)/$(HOST)
host_prefix := $(HOST_PREFIX)/native

# Define the toolchain
ANDROID_TOOLCHAIN_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
android_CC := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang
android_CXX := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang++
android_AR := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_SYSROOT := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot

# Package management
PACKAGES := miniupnpc boost openssl protobuf zmq
native_packages := $(PACKAGES)

# Handle patches and source directories
PATCHES_PATH := $(BASEDIR)/patches
SOURCES_PATH := $(BASEDIR)/sources

# Meta dependencies
meta_depends := Makefile funcs.mk builders/default.mk hosts/default.mk hosts/$(host_os).mk builders/$(build_os).mk

# Include necessary makefiles for host and builder-specific settings
include hosts/$(host_os).mk
include hosts/default.mk
include builders/$(build_os).mk
include builders/default.mk
include packages/packages.mk

# Build ID generation for versioning
build_id_string := $(BUILD_ID_SALT)
build_id_string += $(shell $(build_CC) --version 2>/dev/null)
build_id_string += $(shell $(build_AR) --version 2>/dev/null)
build_id_string += $(shell $(build_CXX) --version 2>/dev/null)
build_id_string += $(shell $(build_RANLIB) --version 2>/dev/null)
build_id_string += $(shell $(build_STRIP) --version 2>/dev/null)

# Rule for generating config.site file
config_site_path := $(BASEDIR)/depends/config.site.in
$(host_prefix)/share/config.site: $(config_site_path) $(host_prefix)/.stamp_$(final_build_id)
	$(AT)@mkdir -p $(@D)
	$(AT)sed -e 's|@HOST@|$(host)|' \
            -e 's|@CC@|$(host_CC)|' \
            -e 's|@CXX@|$(host_CXX)|' \
            -e 's|@AR@|$(host_AR)|' \
            -e 's|@RANLIB@|$(host_RANLIB)|' \
            -e 's|@STRIP@|$(host_STRIP)|' \
            -e 's|@CFLAGS@|$(strip $(host_CFLAGS) $(host_$(release_type)_CFLAGS))|' \
            -e 's|@CXXFLAGS@|$(strip $(host_CXXFLAGS) $(host_$(release_type)_CXXFLAGS))|' \
            -e 's|@LDFLAGS@|$(strip $(host_LDFLAGS) $(host_$(release_type)_LDFLAGS))|' \
            -e 's|@no_qt@|$(NO_QT)|' \
            -e 's|@no_zmq@|$(NO_ZMQ)|' \
            -e 's|@no_upnp@|$(NO_UPNP)|' \
            $< > $@

# Final build ID calculation based on version and configuration
final_build_id_long += $(shell $(build_SHA256SUM) $(config_site_path))
final_build_id += $(shell echo -n "$(final_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH))

# Build dependencies
$(host_prefix)/.stamp_$(final_build_id): $(native_packages) $(packages)
	$(AT)rm -rf $(@D)
	$(AT)mkdir -p $(@D)
	$(AT)echo "Copying packages: $^"
	$(AT)echo "To: $(@D)"
	$(AT)cd $(@D); $(foreach package,$^, tar xf $($(package)_cached); )
	$(AT)touch $@

# Dependencies download and verification
define check_or_remove_cached
  mkdir -p $(BASE_CACHE)/$(host)/$(package) && cd $(BASE_CACHE)/$(host)/$(package); \
  $(build_SHA256SUM) -c $($(package)_cached_checksum) >/dev/null 2>/dev/null || \
  ( rm -f $($(package)_cached_checksum); \
    if test -f "$($(package)_cached)"; then echo "Checksum mismatch for $(package). Forcing rebuild.."; rm -f $($(package)_cached_checksum) $($(package)_cached); fi )
endef

define check_or_remove_sources
  mkdir -p $($(package)_source_dir); cd $($(package)_source_dir); \
  test -f $($(package)_fetched) && ( $(build_SHA256SUM) -c $($(package)_fetched) >/dev/null 2>/dev/null || \
    ( echo "Checksum missing or mismatched for $(package) source. Forcing re-download."; \
      rm -f $($(package)_all_sources) $($(1)_fetched))) || true
endef

check-packages:
	@$(foreach package,$(all_packages),$(call check_or_remove_cached,$(package));)
check-sources:
	@$(foreach package,$(all_packages),$(call check_or_remove_sources,$(package));)

$(host_prefix)/share/config.site: check-packages

check-packages: check-sources

clean-all: clean
	@rm -rf $(SOURCES_PATH) x86_64* i686* mips* arm* aarch64* riscv32* riscv64*

clean:
	@rm -rf $(WORK_PATH) $(BASE_CACHE) $(BUILD)

install: check-packages $(host_prefix)/share/config.site

download-one: check-sources $(all_sources)

download-osx:
	@$(MAKE) -s HOST=x86_64-apple-darwin download-one
download-linux:
	@$(MAKE) -s HOST=x86_64-unknown-linux-gnu download-one
download-win:
	@$(MAKE) -s HOST=x86_64-w64-mingw32 download-one
download: download-osx download-linux download-win

$(foreach package,$(all_packages),$(eval $(call ext_add_stages,$(package))))

.PHONY: install cached clean clean-all download-one download-osx download-linux download-win download check-packages check-sources
