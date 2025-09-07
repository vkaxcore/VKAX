# depends/packages/ndk.mk
# Path: depends/packages/ndk.mk
# Modules: [A] include guard  [B] no-op targets  [C] version tag
# Why: CI provides NDK via ANDROID_NDK_HOME; this shim must never redefine rules or fetch anything.

ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

package := ndk
$(package)_version := 25.2.9519653   # label only; not fetched

.PHONY: $(package)_install ndk_add_to_path ndk_create_wrapper ndk_install
$(package)_install:
	@echo "[ndk.mk] ANDROID_NDK_HOME=$${ANDROID_NDK_HOME:-<unset>} (external; no-op)"

ndk_add_to_path:
	@true

ndk_create_wrapper:
	@true

ndk_install: $(package)_install
	@true

endif
# depends/packages/ndk.mk  • Setvin • 2025-09-07
