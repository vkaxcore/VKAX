# NDK - Android Native Development Kit (version r23c)
# This section handles the downloading and installing of the NDK as part of the dependencies.

# Package details
package=ndk
$(package)_version=r23c
$(package)_download_path=https://dl.google.com/android/repository/android-ndk-r23c-linux.zip  # URL for downloading NDK
$(package)_file_name=android-ndk-r23c-linux.zip  # The downloaded file name
$(package)_sha256_hash=e5053c126a47e84726d9f7173a04686a71f9a67a  # SHA256 hash for file integrity check

# Define the installation directory where the NDK will be placed
$(package)_install_dir=$(DEPENDS_DIR)/$(package)-$(package)_version

# Download and extract NDK
define $(package)_download_and_extract
	$(call download,$(package)_download_path,$(package)_file_name,$(package)_sha256_hash)  # Download the NDK
	$(call extract,$(package)_file_name,$(package)_install_dir)  # Extract the NDK to the appropriate directory
endef

# Add NDK to the build path
$(package)_add_to_path:
	@echo "Adding NDK to path..."
	@export ANDROID_NDK_HOME=$(DEPENDS_DIR)/$(package)-$(package)_version  # Set the NDK home path
	@echo "ANDROID_NDK_HOME=$(ANDROID_NDK_HOME)" >> $(DEPENDS_DIR)/.env  # Write NDK path to .env for environment variable persistence
	@export PATH=$(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH  # Add the NDK binaries to the system path

# Create wrapper for NDK toolchain (for cross-compilation)
$(package)_create_wrapper:
	@echo "Creating wrapper for NDK toolchain..."
	@mkdir -p $(DEPENDS_DIR)/$(package)-$(package)_version/bin  # Create the necessary directory for the wrapper
	@cp $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++ $(DEPENDS_DIR)/$(package)-$(package)_version/bin/  # Copy the clang++ binary
	@cp $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang $(DEPENDS_DIR)/$(package)-$(package)_version/bin/  # Copy the clang binary

# Target rule to install the NDK
$(package)_install: $(package)_download_and_extract $(package)_add_to_path $(package)_create_wrapper
	@echo "$(package) installation complete."  # Print a message after successful installation

.PHONY: $(package)_install  # Mark the install target as phony to avoid conflicts with files named 'install'
