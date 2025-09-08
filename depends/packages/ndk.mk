# File: depends/packages/ndk.mk

ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

.PHONY: ndk_install

ndk_install:
	@echo "[ndk.mk] ANDROID_NDK_HOME=$${ANDROID_NDK_HOME:-<unset>} ANDROID_NDK=$${ANDROID_NDK:-<unset>}"
	@set -e; \
	NDK="$${ANDROID_NDK_HOME:-$${ANDROID_NDK:-}}"; \
	if [ -z "$$NDK" ]; then \
	  echo "[ndk.mk] ERROR: ANDROID_NDK_HOME (or ANDROID_NDK) is not set"; \
	  exit 1; \
	fi; \
	os="$$(uname -s | tr '[:upper:]' '[:lower:]')"; \
	case "$$os" in \
	  linux*)   os=linux  ;; \
	  darwin*)  os=darwin ;; \
	  msys*|cygwin*|mingw*) os=windows ;; \
	  *)        os=linux  ;; \
	esac; \
	arch="$$(uname -m)"; \
	case "$$arch" in \
	  aarch64|arm64) arch=arm64 ;; \
	  x86_64|amd64)  arch=x86_64 ;; \
	  *)             arch=x86_64 ;; \
	esac; \
	host_tag="$$os-$$arch"; \
	toolchain_bin="$$NDK/toolchains/llvm/prebuilt/$$host_tag/bin"; \
	if [ ! -d "$$toolchain_bin" ]; then \
	  echo "[ndk.mk] ERROR: NDK toolchain bin not found: $$toolchain_bin"; \
	  echo "[ndk.mk] HINT: Ensure sdkmanager installed 'ndk;<version>' and ANDROID_NDK_HOME points to its root"; \
	  exit 1; \
	fi; \
	echo "[ndk.mk] OK: $$toolchain_bin"
	@true

endif  # VKAX_NDK_MK_INCLUDED
