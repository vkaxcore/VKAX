depends/packages/ndk.mk
# modules: pins • paths/env • helpers • targets(ndk_add_to_path, ndk_create_wrapper, ndk_install)
# include-guard prevents duplicate recipe definitions when packages/ndk.mk is included more than once.

ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

package := ndk
# Installed directory name used by sdkmanager (keep in sync with workflow)
$(package)_version_dir := 25.2.9519653

# Safe default DEPENDS_DIR if undefined (avoid writing to /)
ifeq ($(origin DEPENDS_DIR), undefined)
DEPENDS_DIR := $(CURDIR)
endif

# Respect env; do not download here (workflow installs NDK)
ANDROID_API ?= 25
NDK_HOME    ?= $(or $(ANDROID_NDK_HOME),$(ANDROID_NDK_ROOT),$(ANDROID_NDK),$(addsuffix /ndk/$(package)_version_dir,$(ANDROID_SDK_ROOT)))
TOOLCHAIN_BIN := $(NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin

# Internal staging for wrappers and an env file other packages can source
$(package)_install_dir := $(abspath $(DEPENDS_DIR))/$(package)-$($(package)_version_dir)
$(package)_env_file    := $(abspath $(DEPENDS_DIR))/.env

# Helper macros
download = curl -fL --retry 5 --retry-delay 2 "$1" -o "$2"
extract  = unzip -q "$2" -d "$3"

# Verbose pinning when V=1
ifneq ($(V),)
$(info [ndk.mk] ANDROID_API=$(ANDROID_API))
$(info [ndk.mk] NDK_HOME=$(NDK_HOME))
$(info [ndk.mk] TOOLCHAIN_BIN=$(TOOLCHAIN_BIN))
endif

# Export NDK paths for downstream steps
$(package)_add_to_path:
	@echo "[ndk] export toolchain bin to PATH"
	@mkdir -p "$(dir $($(package)_env_file))"
	@echo "ANDROID_NDK_HOME=$(NDK_HOME)" >> "$($(package)_env_file)"
	@echo "ANDROID_NDK_ROOT=$(NDK_HOME)" >> "$($(package)_env_file)"
	@echo "ANDROID_NDK=$(NDK_HOME)" >> "$($(package)_env_file)"
	@echo "PATH=$(TOOLCHAIN_BIN):$$PATH" >> "$($(package)_env_file)"

# Create ${HOST}${ANDROID_API}-clang(++) wrappers if the NDK doesn't ship them
$(package)_create_wrapper:
	@echo "[ndk] creating wrappers for API $(ANDROID_API)"
	@mkdir -p "$($(package)_install_dir)/bin"
	@CC_TGT="aarch64-linux-android$(ANDROID_API)-clang"; \
	CXX_TGT="aarch64-linux-android$(ANDROID_API)-clang++"; \
	if [ -x "$(TOOLCHAIN_BIN)/$$CC_TGT" ] && [ -x "$(TOOLCHAIN_BIN)/$$CXX_TGT" ]; then \
	  cp -f "$(TOOLCHAIN_BIN)/$$CC_TGT"  "$($(package)_install_dir)/bin/" || true; \
	  cp -f "$(TOOLCHAIN_BIN)/$$CXX_TGT" "$($(package)_install_dir)/bin/" || true; \
	else \
	  printf '%s\n' '#!/usr/bin/env bash' "exec '$(TOOLCHAIN_BIN)/clang' --target=aarch64-linux-android$(ANDROID_API) \"\$$@\"" > "$($(package)_install_dir)/bin/$$CC_TGT"; \
	  printf '%s\n' '#!/usr/bin/env bash' "exec '$(TOOLCHAIN_BIN)/clang++' --target=aarch64-linux-android$(ANDROID_API) \"\$$@\"" > "$($(package)_install_dir)/bin/$$CXX_TGT"; \
	  chmod +x "$($(package)_install_dir)/bin/$$CC_TGT" "$($(package)_install_dir)/bin/$$CXX_TGT"; \
	fi
	@echo "[ndk] wrappers ready under $($(package)_install_dir)/bin"

# Public entrypoint
$(package)_install: $(package)_add_to_path $(package)_create_wrapper
	@echo "[ndk] install complete (NDK=$(NDK_HOME) API=$(ANDROID_API))"

.PHONY: $(package)_install $(package)_add_to_path $(package)_create_wrapper
endif  # VKAX_NDK_MK_INCLUDED

# depends/packages/ndk.mk • Setvin • 2025-09-06
