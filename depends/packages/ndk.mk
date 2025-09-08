# File: depends/packages/ndk.mk
# Purpose: NDK validator shim for depends. Single ndk_install validates toolchain path. No downloads.
# Key targets:
#   ndk_install: ensures $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/<host>/bin exists
# Notes:
#   - ASCII-only, readable. Avoid duplicate rules and misleading "version" labels.
#   - No network access here. CI provides ANDROID_NDK_HOME/ANDROID_NDK.
#   - Fails fast with a clear message.

ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

package := ndk

.PHONY: $(package)_install ndk_install

$(package)_install:
	@echo "[ndk.mk] ANDROID_NDK_HOME=$${ANDROID_NDK_HOME:-<unset>}"
	@if [ -z "$$ANDROID_NDK_HOME" ] && [ -n "$$ANDROID_NDK" ]; then export ANDROID_NDK_HOME="$$ANDROID_NDK"; fi; \
	if [ -z "$$ANDROID_NDK_HOME" ]; then \
		echo "[ndk.mk] ERROR: ANDROID_NDK_HOME is not set"; \
		exit 1; \
	fi; \
	os=$$(uname -s | tr '[:upper:]' '[:lower:]'); \
	case "$$os" in \
	  linux*) os=linux ;; \
	  darwin*) os=darwin ;; \
	  msys*|cygwin*|mingw*) os=windows ;; \
	  *) os=linux ;; \
	esac; \
	arch=$$(uname -m); \
	if echo "$$arch" | grep -qiE 'aarch64|arm64'; then host="$$os-arm64"; else host="$$os-x86_64"; fi; \
	tool="$$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$$host/bin"; \
	if [ ! -d "$$tool" ]; then \
		echo "[ndk.mk] ERROR: toolchain bin not found under $$tool"; \
		echo "[ndk.mk] HINT: CI must install ndk;<version> and set ANDROID_NDK_HOME"; \
		exit 1; \
	fi; \
	echo "[ndk.mk] OK: $$tool"
	@true

ndk_install: $(package)_install
	@true

endif

# Path: depends/packages/ndk.mk | 2025-09-08 UTC
