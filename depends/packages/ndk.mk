# depends/packages/ndk.mk
# Modules: [G] include-guard • [E] env/NDK root • [H] host tag • [B] toolchain bin • [X] PATH export (once) • [T] targets ndk_* (no-op safe) • [D] debug echo (V=1)
# Critical: [G] prevents duplicate "overriding recipe" warnings; [E] no hardcoded revs, uses ANDROID_NDK_HOME/ROOT; [X] exports PATH globally only once, zero side effects.
# Intent: provide toolchain discovery and stable PATH for Android depends; CI installs NDK r25.2; never mention r23c; legacy-friendly for Bitcoin/Dash-style depends.

ifndef VKAX_NDK_MK_INCLUDED                                   # [G]
VKAX_NDK_MK_INCLUDED := 1

# [E] Discover NDK root from environment (preferred: ANDROID_NDK_HOME); fail early if missing.
ANDROID_NDK ?= $(or $(ANDROID_NDK_HOME),$(ANDROID_NDK_ROOT))
ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK not set; export ANDROID_NDK_HOME (e.g. $${ANDROID_SDK_ROOT}/ndk/25.2.9519653))
endif
export ANDROID_NDK_HOME := $(ANDROID_NDK)

# [H] Determine host tag for prebuilt toolchain (linux-x86_64 on GitHub runners; darwin-x86_64/arm64 locally).
UNAME_S ?= $(shell uname -s)
UNAME_M ?= $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
  _NDK_HOST_OS := darwin
else ifeq ($(UNAME_S),Linux)
  _NDK_HOST_OS := linux
else
  _NDK_HOST_OS := windows
endif

ifneq (,$(filter aarch64 arm64,$(UNAME_M)))
  _NDK_HOST_ARCH := arm64
else
  _NDK_HOST_ARCH := x86_64
endif

NDK_HOST_TAG ?= $(_NDK_HOST_OS)-$(_NDK_HOST_ARCH)

# [B] LLVM toolchain bin path (r25+ layout) and sysroot; validate existence for fast failure.
NDK_BIN     ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin
NDK_SYSROOT ?= $(NDK_BIN)/../sysroot
ifeq ($(wildcard $(NDK_BIN)),)
  $(error NDK toolchain bin not found: "$(NDK_BIN)"; check ANDROID_NDK and NDK_HOST_TAG="$(NDK_HOST_TAG)")
endif

# [X] Export PATH globally once; guard against re-prefixing if included indirectly by other packages.
ifeq (,$(findstring $(NDK_BIN),$(PATH)))
  export PATH := $(NDK_BIN):$(PATH)
endif

# [T] Historical hooks expected by some recipes; keep them benign and idempotent.
.PHONY: ndk_add_to_path ndk_create_wrapper ndk_install ndk_env

ndk_add_to_path:
	@echo "[ndk.mk] PATH contains NDK_BIN=$(NDK_BIN)"

ndk_create_wrapper:
	@true

ndk_install:
	@true

# [D] Optional diagnostics when V=1 for CI triage.
ifeq ($(V),1)
ndk_env:
	@echo "[ndk.mk] ANDROID_NDK=$(ANDROID_NDK)"
	@echo "[ndk.mk] NDK_HOST_TAG=$(NDK_HOST_TAG)"
	@echo "[ndk.mk] NDK_BIN=$(NDK_BIN)"
	@echo "[ndk.mk] NDK_SYSROOT=$(NDK_SYSROOT)"
else
ndk_env:
	@true
endif

endif  # VKAX_NDK_MK_INCLUDED
# depends/packages/ndk.mk • Setvin • 2025-09-06 • end-of-file
