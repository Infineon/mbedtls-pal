################################################################################
# mbedtls-pal - ModusToolbox porting layer for upstream Mbed TLS 4.x
#
# Auto-included by the build system when this asset is present, so an
# application does not need to edit its Makefile.
################################################################################

# Bare-metal-safe config overlays. Mbed TLS and the bundled tf-psa-crypto core
# each have their own independent config chain, so both need an entry.
INCLUDES+=$(SEARCH_mbedtls-pal)/configs

ifneq ($(filter IFX_TF_PSA IFX_TF_PSA_CRYPTO,$(DEFINES)),)
# Pre-generated PSA driver dispatch layer. Upstream ships these only as .jinja
# templates rendered by tf-psa-crypto/scripts/generate_driver_wrappers.py during
# its CMake/Make configure step; MTB has no configure step, so psa_crypto.c
# would otherwise fail on a missing psa_crypto_driver_wrappers.h.
INCLUDES+=$(SEARCH_mbedtls-pal)/generated

# Skip the generated .c source(s) from build (keep the headers on INCLUDES).
# ifx-tf-psa-crypto ships its own psa_crypto_driver_wrappers_no_static.c;
# compiling both causes multiple-definition link errors. Apply only when
# ifx-tf-psa-crypto IS active, i.e. the C-preprocessor guard:
#     #if defined(IFX_TF_PSA) || defined(IFX_TF_PSA_CRYPTO)
CY_IGNORE+=$(SEARCH_mbedtls-pal)/generated/psa_crypto_driver_wrappers_no_static.c
endif # IFX_TF_PSA || IFX_TF_PSA_CRYPTO

# Only supply the config files if the application has not named its own, so an
# application with existing Mbed TLS configuration keeps full control.
ifeq ($(filter MBEDTLS_USER_CONFIG_FILE=%,$(DEFINES)),)
DEFINES+=MBEDTLS_USER_CONFIG_FILE='"mbedtls_user_config.h"'
endif

ifeq ($(filter TF_PSA_CRYPTO_USER_CONFIG_FILE=%,$(DEFINES)),)
DEFINES+=TF_PSA_CRYPTO_USER_CONFIG_FILE='"tf_psa_crypto_user_config.h"'
endif

ifneq ($(SEARCH_ifx-tf-m-ns),)
CY_IGNORE+=$(SEARCH_cy-mbedtls-acceleration)
endif
