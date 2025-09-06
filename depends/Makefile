# .NOTPARALLEL : Avoid parallel build issues for certain targets.
.NOTPARALLEL: $(package)_build $(native_packages)

# --- Define essential variables ---
MAKEOVERRIDES := $(filter V=%,$(MAKEOVERRIDES))        # Allow overriding variables like verbosity
BASEDIR := $(CURDIR)                                   # The current working directory
WORK_PATH := $(BASEDIR)/work                            # Directory for build output
BASE_CACHE := $(BASEDIR)/built                          # Cache directory
SDK_PATH := $(BASEDIR)/SDKs                            # SDK path (e.g., Android SDK)
HOST := $(shell ./config.guess)                         # Guess host architecture
HOST_ID_SALT := salt                                    # Salt for host ID (for uniqueness)
BUILD_ID_SALT := salt                                   # Salt for build ID (for versioning)
HASH_LENGTH := 11                                       # Length for the final build ID hash
DOWNLOAD_CONNECT_TIMEOUT := 30                          # Timeout for downloading dependencies

# Default build directories
base_build_dir := $(WORK_PATH)/build
base_staging_dir := $(WORK_PATH)/staging
base_download_dir := $(WORK_PATH)/download
canonical_host := $(shell ./config.sub $(HOST))         # Canonical form of host architecture
build := $(shell ./config.sub $(BUILD))                 # Build configuration

# --- Set up host architecture and OS ---
build_arch := $(firstword $(subst -, ,$(build)))         # Extract architecture from the build
build_vendor := $(word 2,$(subst -, ,$(build)))         # Extract vendor from the build
full_build_os := $(subst $(build_arch)-$(build_vendor)-,,$(build))  # Extract OS from build configuration
build_os := $(findstring linux,$(full_build_os))       # Detect Linux OS
build_os += $(findstring darwin,$(full_build_os))      # Add Darwin (macOS) to supported OS list
build_os := $(strip $(build_os))                       # Remove any extra spaces
ifeq ($(build_os),)                                     # Set fallback to full OS name if undefined
  build_os := $(full_build_os)
endif

# --- Host-specific architecture and OS ---
host_arch := $(firstword $(subst -, ,$(canonical_host))) # Extract architecture for the host
host_vendor := $(word 2,$(subst -, ,$(canonical_host)))  # Extract vendor for the host
full_host_os := $(subst $(host_arch)-$(host_vendor)-,,$(canonical_host)) # Extract OS for the host
host_os := $(findstring linux,$(full_host_os))          # Detect if host is Linux
host_os += $(findstring darwin,$(full_host_os))         # Detect if host is macOS
host_os += $(findstring mingw32,$(full_host_os))        # Detect if host is Windows (mingw32)
ifeq (android,$(findstring android,$(full_host_os)))    # If Android, set host OS accordingly
  host_os := android
endif
host_os := $(strip $(host_os))                          # Clean up any whitespace from host OS

# --- Android NDK setup ---
ANDROID_NDK ?= $(BASEDIR)/android-sdk/ndk/android-ndk-r25.2.9519653   # Set the NDK path
ANDROID_API := 21                                 # Set the Android API level to 21 (minimum required)
HOST_PREFIX := $(BASEDIR)/$(HOST)                 # Prefix for host
host_prefix := $(HOST_PREFIX)/native             # Prefix for the native host

# --- Define the Android NDK toolchain ---
ANDROID_TOOLCHAIN_BIN := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
android_CC := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang
android_CXX := $(ANDROID_TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang++
android_AR := $(ANDROID_TOOLCHAIN_BIN)/llvm-ar
android_RANLIB := $(ANDROID_TOOLCHAIN_BIN)/llvm-ranlib
android_STRIP := $(ANDROID_TOOLCHAIN_BIN)/llvm-strip
android_SYSROOT := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot

# --- Export the Android toolchain variables ---
export ANDROID_NDK
export ANDROID_API
export android_CC
export android_CXX
export android_AR
export android_RANLIB
export android_STRIP
export android_SYSROOT

# --- Package management ---
PACKAGES := miniupnpc boost openssl protobuf zmq       # List of essential dependencies
native_packages := $(PACKAGES)                        # Native packages to be built

# --- Handle patches and source directories ---
PATCHES_PATH := $(BASEDIR)/patches                    # Path to patches directory
SOURCES_PATH := $(BASEDIR)/sources                    # Path to source files directory

# --- Meta dependencies (other Makefiles for configuration) ---
meta_depends := Makefile funcs.mk builders/default.mk hosts/default.mk hosts/$(host_os).mk builders/$(build_os).mk

# --- Include necessary makefiles for the build ---
ifeq ($(host_os),android)                             # If the host is Android, include android.mk
  include builders/android.mk
endif

include hosts/$(host_os).mk                          # Include platform-specific makefiles
include hosts/default.mk
include builders/$(build_os).mk
include builders/default.mk
include packages/packages.mk                         # Include packages makefile for managing dependencies

# --- Ensure ANDROID_SDK is defined ---
ifeq ($(ANDROID_SDK),)                                 # Check if ANDROID_SDK is not set
  $(error "ANDROID_SDK environment variable is not set. Please set it before building.") # Throw error if not set
endif

# --- Build ID generation ---
build_id_string := $(BUILD_ID_SALT)                   # Start with build ID salt
build_id_string += $(shell $(build_CC) --version 2>/dev/null)   # Add version of build CC (clang)
build_id_string += $(shell $(build_AR) --version 2>/dev/null)   # Add version of AR (archiver)
build_id_string += $(shell $(build_CXX) --version 2>/dev/null)  # Add version of C++ compiler
build_id_string += $(shell $(build_RANLIB) --version 2>/dev/null) # Add version of ranlib
build_id_string += $(shell $(build_STRIP) --version 2>/dev/null)  # Add version of strip

# --- Rule for generating config.site file ---
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

# --- Final build ID calculation ---
final_build_id_long += $(shell $(build_SHA256SUM) $(config_site_path))  # Use SHA256SUM for final build ID
final_build_id += $(shell echo -n "$(final_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH)) # Limit length to the first 11 characters

# --- Build dependencies ---
$(host_prefix)/.stamp_$(final_build_id): $(native_packages) $(packages)
	$(AT)rm -rf $(@D)
	$(AT)mkdir -p $(@D)
	$(AT)echo "Copying packages: $^"
	$(AT)echo "To: $(@D)"
	$(AT)cd $(@D); $(foreach package,$^, tar xf $($(package)_cached); )
	$(AT)touch $@

# --- Dependencies download and verification ---
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

# --- Ensure everything is in place for the build ---
check-packages:
	@$(foreach package,$(all_packages),$(call check_or_remove_cached,$(package));)
check-sources:
	@$(foreach package,$(all_packages),$(call check_or_remove_sources,$(package));)

# --- Ensure the config site is generated ---
$(host_prefix)/share/config.site: check-packages

# --- Clean and install rules ---
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
