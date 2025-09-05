# NDK - Android Native Development Kit (version r23c)
# Download and install NDK as part of the dependencies

package=ndk
$(package)_version=r23c
$(package)_download_path=https://dl.google.com/android/repository/android-ndk-r23c-linux.zip
$(package)_file_name=android-ndk-r23c-linux.zip
$(package)_sha256_hash=e5053c126a47e84726d9f7173a04686a71f9a67a

# Define the installation directory
$(package)_install_dir=$(DEPENDS_DIR)/$(package)-$(package)_version

# Download and install NDK
define $(package)_download_and_extract
    $(call download,$(package)_download_path,$(package)_file_name,$(package)_sha256_hash)
    $(call extract,$(package)_file_name,$(package)_install_dir)
endef

# Add NDK to the build path
$(package)_add_to_path:
    @echo "Adding NDK to path..."
    @export ANDROID_NDK_HOME=$(DEPENDS_DIR)/$(package)-$(package)_version
    @echo "ANDROID_NDK_HOME=$(ANDROID_NDK_HOME)" >> $(DEPENDS_DIR)/.env
    @export PATH=$(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# Create NDK wrapper for cross-compilation
$(package)_create_wrapper:
    @echo "Creating wrapper for NDK toolchain..."
    @mkdir -p $(DEPENDS_DIR)/$(package)-$(package)_version/bin
    @cp $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++ $(DEPENDS_DIR)/$(package)-$(package)_version/bin/
    @cp $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang $(DEPENDS_DIR)/$(package)-$(package)_version/bin/

# Target rules
$(package)_install: $(package)_download_and_extract $(package)_add_to_path $(package)_create_wrapper
    @echo "$(package) installation complete."

.PHONY: $(package)_install
