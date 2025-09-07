depends/packages/ndk.mk
# Guarded NDK r25.2 setup; API-parameterized wrappers; respects env; verifies SHA; zero duplicate-target spam.

ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

package                := ndk
$(package)_version     := r25.2.9519653
$(package)_sha256_hash := dcccb6f92ef9f6debeabb31f1ad0d0cf30c2f70a88fc9ff2eb991d165a71322a
$(package)_zip_name    := android-ndk-$($(package)_version)-linux.zip
$(package)_download    := https://dl.google.com/android/repository/$($(package)_zip_name)

ANDROID_API ?= 25
NDK_HOME ?= $(if $(ANDROID_NDK_HOME),$(ANDROID_NDK_HOME),$(if $(ANDROID_NDK),$(ANDROID_NDK),$(if $(ANDROID_NDK_ROOT),$(ANDROID_NDK_ROOT),$(ANDROID_SDK_ROOT)/ndk/$($(package)_version))))
TOOLCHAIN_BIN := $(NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin
$(package)_install_dir := $(DEPENDS_DIR)/$(package)-$($(package)_version)
$(package)_env_file    := $(DEPENDS_DIR)/.env

download = curl -fL --retry 5 --retry-delay 2 "$1" -o "$2"
extract  = unzip -q "$2" -d "$3"

.NOTPARALLEL: $(package)_install $(package)_create_wrapper

define $(package)_ensure_ndk
	@if [ ! -d "$(NDK_HOME)" ]; then \
	  echo "[ndk] downloading $($(package)_zip_name) ..."; \
	  $(call download,$($(package)_download),$($(package)_zip_name)); \
	  echo "$($(package)_sha256_hash)  $($(package)_zip_name)" | sha256sum -c -; \
	  mkdir -p "$($(package)_install_dir)"; \
	  $(call extract,$($(package)_zip_name),$($(package)_install_dir)); \
	  export ANDROID_NDK_HOME="$($(package)_install_dir)/android-ndk-$($(package)_version)"; \
	  echo "ANDROID_NDK_HOME=$$ANDROID_NDK_HOME" >> "$($(package)_env_file)"; \
	  NDK_PATH="$$ANDROID_NDK_HOME"; \
	else \
	  echo "[ndk] Using existing NDK at $(NDK_HOME)"; \
	  NDK_PATH="$(NDK_HOME)"; \
	fi; \
	echo "ANDROID_NDK_ROOT=$$NDK_PATH" >> "$($(package)_env_file)"; \
	echo "ANDROID_NDK=$$NDK_PATH" >> "$($(package)_env_file)"; \
	echo "PATH=$$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin:$$PATH" >> "$($(package)_env_file)"
endef

$(package)_add_to_path:
	@echo "[ndk] export PATH to toolchain"
	@mkdir -p "$(dir $($(package)_env_file))"
	@echo "ANDROID_NDK_HOME=$(NDK_HOME)" >> "$($(package)_env_file)"
	@echo "PATH=$(TOOLCHAIN_BIN):$$PATH" >> "$($(package)_env_file)"

$(package)_create_wrapper:
	@echo "[ndk] creating API $(ANDROID_API) clang wrappers"
	@mkdir -p "$($(package)_install_dir)/bin"
	@CC_SRC="$(TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang"; \
	CXX_SRC="$(TOOLCHAIN_BIN)/aarch64-linux-android$(ANDROID_API)-clang++"; \
	if [ -x "$$CC_SRC" ] && [ -x "$$CXX_SRC" ]; then \
	  cp -f "$$CC_SRC"  "$($(package)_install_dir)/bin/" || true; \
	  cp -f "$$CXX_SRC" "$($(package)_install_dir)/bin/" || true; \
	else \
	  printf '%s\n' '#!/usr/bin/env bash' "exec '$(TOOLCHAIN_BIN)/clang' --target=aarch64-linux-android$(ANDROID_API) \"\$$@\"" > "$($(package)_install_dir)/bin/aarch64-linux-android$(ANDROID_API)-clang"; \
	  printf '%s\n' '#!/usr/bin/env bash' "exec '$(TOOLCHAIN_BIN)/clang++' --target=aarch64-linux-android$(ANDROID_API) \"\$$@\"" > "$($(package)_install_dir)/bin/aarch64-linux-android$(ANDROID_API)-clang++"; \
	  chmod +x "$($(package)_install_dir)/bin/aarch64-linux-android$(ANDROID_API)-clang" "$($(package)_install_dir)/bin/aarch64-linux-android$(ANDROID_API)-clang++"; \
	fi
	@echo "[ndk] wrappers ready"

$(package)_install:
	@$(call $(package)_ensure_ndk)
	@$(MAKE) $(package)_add_to_path
	@$(MAKE) $(package)_create_wrapper
	@echo "[ndk] install complete (API=$(ANDROID_API) NDK=$(NDK_HOME))"

.PHONY: $(package)_install $(package)_add_to_path $(package)_create_wrapper

endif  # VKAX_NDK_MK_INCLUDED
# depends/packages/ndk.mk • Setvin • 2025-09-06
