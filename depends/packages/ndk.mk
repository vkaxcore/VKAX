# depends/packages/ndk.mk
# No-op shim: CI provides ANDROID_NDK_HOME; validate and define targets once.

ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

package := ndk

.PHONY: $(package)_install ndk_install ndk_add_to_path ndk_create_wrapper

$(package)_install:
	@echo "[ndk.mk] ANDROID_NDK_HOME=$${ANDROID_NDK_HOME:-<unset>}"
	@if [ -z "$${ANDROID_NDK_HOME:-}" ]; then \
		echo "[ndk.mk] ERROR: ANDROID_NDK_HOME is not set (CI must export it)"; \
		exit 1; \
	fi
	@if [ ! -d "$${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin" ]; then \
		echo "[ndk.mk] ERROR: toolchain bin not found under $$ANDROID_NDK_HOME"; \
		exit 1; \
	fi
	@true

ndk_install: $(package)_install
	@true

ndk_add_to_path:
	@true

ndk_create_wrapper:
	@true

endif
