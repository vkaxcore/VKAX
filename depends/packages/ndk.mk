# depends/packages/ndk.mk
# Purpose: NDK is provided by ANDROID_NDK_HOME; avoid duplicate rules/installs; guard against multiple includes.
ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

package := ndk
$(package)_version := 25.2.9519653
$(package)_note := Provided by ANDROID_NDK_HOME; no downloads, no conflicting recipes.

.PHONY: $(package)_install ndk_add_to_path ndk_create_wrapper ndk_install
$(package)_install:
	@echo "[ndk.mk] using ANDROID_NDK_HOME=$${ANDROID_NDK_HOME:-unset} (no-op)"

ndk_add_to_path:
	@true

ndk_create_wrapper:
	@true

ndk_install: $(package)_install
	@true

endif
# depends/packages/ndk.mk • Setvin • 2025-09-07
