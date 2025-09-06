# .NOTPARALLEL : Prevent parallel builds for certain targets to avoid conflicts.
# This ensures that specific operations like downloading and extracting are done sequentially.

# NDK - Android Native Development Kit (version r25.2.9519653)
# This section handles downloading, installing, and setting up the Android NDK.

# Package details
package=ndk
$(package)_version=r25.2.9519653  # The version of the NDK we are using.
$(package)_download_path=https://dl.google.com/android/repository/android-ndk-r25.2.9519653-linux.zip  # URL to download the NDK.
$(package)_file_name=android-ndk-r25.2.9519653-linux.zip  # The file name for the downloaded NDK.
$(package)_sha256_hash=dcccb6f92ef9f6debeabb31f1ad0d0cf30c2f70a88fc9ff2eb991d165a71322a  # SHA256 hash to verify the integrity of the NDK.

# Define the installation directory where the NDK will be placed
$(package)_install_dir=$(DEPENDS_DIR)/$(package)-$(package)_version  # Set the installation directory within the 'depends' folder.

# Path to store environment variables related to the NDK
$(package)_env_file=$(DEPENDS_DIR)/.env  # The environment file where we will write the NDK path.

# Download and extract NDK with error handling
define $(package)_download_and_extract
	@echo "Downloading NDK..."
	$(call download,$(package)_download_path,$(package)_file_name,$(package)_sha256_hash)  # Download the NDK from the URL.
	@if [ $$? -ne 0 ]; then echo "NDK download failed!"; exit 1; fi  # If download fails, exit with an error.
	@echo "Extracting NDK..."
	$(call extract,$(package)_file_name,$(package)_install_dir)  # Extract the NDK archive into the specified directory.
	@if [ $$? -ne 0 ]; then echo "NDK extraction failed!"; exit 1; fi  # If extraction fails, exit with an error.
	@echo "NDK downloaded and extracted successfully."
endef

# Add NDK to the system PATH for subsequent steps
$(package)_add_to_path:
	@echo "Adding NDK to path..."
	@export ANDROID_NDK_HOME=$(DEPENDS_DIR)/$(package)-$(package)_version  # Set the NDK home path.
	@echo "ANDROID_NDK_HOME=$(ANDROID_NDK_HOME)" >> $(package)_env_file  # Store the NDK home path in the .env file.
	@export PATH=$(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH  # Add the NDK binaries to the PATH.
	@echo "NDK added to PATH."

# Create a wrapper for the NDK toolchain (specifically for cross-compilation)
$(package)_create_wrapper:
	@echo "Creating wrapper for NDK toolchain..."
	@mkdir -p $(DEPENDS_DIR)/$(package)-$(package)_version/bin  # Create a directory for the toolchain wrapper.
	@cp $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android25-clang++ $(DEPENDS_DIR)/$(package)-$(package)_version/bin/  # Copy the clang++ binary for API Level 25.
	@cp $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android25-clang $(DEPENDS_DIR)/$(package)-$(package)_version/bin/  # Copy the clang binary for API Level 25.
	@if [ $$? -ne 0 ]; then echo "Toolchain wrapper creation failed!"; exit 1; fi  # Check if toolchain wrapper creation succeeded.
	@echo "Toolchain wrapper created successfully."

# Target rule to install the NDK (with error handling)
$(package)_install: $(package)_download_and_extract $(package)_add_to_path $(package)_create_wrapper
	@echo "$(package) installation complete."  # Once everything is set up, output that installation is complete.

# .PHONY: This ensures the 'install' target is always executed, even if there's a file named 'install'.
.PHONY: $(package)_install  # Mark the install target as phony to avoid conflicts with files named 'install'.

# Helper functions for downloading and extracting files
download = curl -L $1 -o $2  # Download the file from the given URL.
extract = unzip -q $2 -d $3  # Extract the downloaded zip file to the specified directory.

