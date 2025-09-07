# depends/packages/ndk.mk
# Modules: [G] include-guard • [E] env NDK root • [H] host tag • [B] toolchain bin/sysroot • [X] PATH once • [T] ndk_* targets (idempotent) • [V] diagnostics
# Critical: no r23c, r25+ LLVM layout, duplicate-include safe, zero side effects; improves noisy overrides without changing semantics.
ifndef VKAX_NDK_MK_INCLUDED
VKAX_NDK_MK_INCLUDED := 1

ANDROID_NDK ?= $(or $(ANDROID_NDK_HOME),$(ANDROID_NDK_ROOT))     # [E]
ifeq ($(strip $(ANDROID_NDK)),)
  $(error ANDROID_NDK not set; export ANDROID_NDK_HOME (e.g. $${ANDROID_SDK_ROOT}/ndk/25.2.9519653))
endif
export ANDROID_NDK_HOME := $(ANDROID_NDK)

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
NDK_HOST_TAG ?= $(_NDK_HOST_OS)-$(_NDK_HOST_ARCH)                # [H]

NDK_BIN     ?= $(ANDROID_NDK)/toolchains/llvm/prebuilt/$(NDK_HOST_TAG)/bin  # [B]
NDK_SYSROOT ?= $(NDK_BIN)/../sysroot
ifeq ($(wildcard $(NDK_BIN)),)
  $(error NDK toolchain bin not found: "$(NDK_BIN)"; check ANDROID_NDK and NDK_HOST_TAG="$(NDK_HOST_TAG)")
endif

ifeq (,$(findstring $(NDK_BIN),$(PATH)))                          # [X]
  export PATH := $(NDK_BIN):$(PATH)
endif

.PHONY: ndk_add_to_path ndk_create_wrapper ndk_install ndk_env     # [T]
ndk_add_to_path:
	@echo "[ndk.mk] PATH ok: $(NDK_BIN)"

ndk_create_wrapper:
	@true

ndk_install:
	@true

ifeq ($(V),1)                                                     # [V]
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
