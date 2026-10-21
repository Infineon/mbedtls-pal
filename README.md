# mbedtls-pal

ModusToolbox&trade; porting layer for **upstream Mbed TLS 4.x**
(`https://github.com/ARMmbed/mbedtls`).

Upstream Mbed TLS is not ModusToolbox-aware: it ships no `.cyignore` and no
`*.mk`, and it expects a CMake/Make *configure* step that ModusToolbox does not
have. Added to an MTB application as-is, it fails to build.

This asset supplies the missing pieces. It is registered in the middleware
dependencies manifest as a dependency of `mbedtls`, so an application only has
to add the Mbed TLS `.mtb` - `mbedtls-pal` is then pulled in automatically by
`make getlibs`, and **no Makefile changes are required**.

## Contents

| Path | Purpose |
|---|---|
| `.cyignore` | Excludes upstream test/host/tooling subtrees from MTB auto-discovery, plus the `mldsa-native` `.c`/`.S` pairs that collide in a flat object directory. |
| `library.mk` | Auto-included by the build system. Adds `configs/` and `generated/` to `INCLUDES` and names the config files via `DEFINES`. |
| `configs/mbedtls_user_config.h` | Bare-metal overlay for Mbed TLS: no filesystem, no sockets, no `time()`. |
| `configs/tf_psa_crypto_user_config.h` | Bare-metal overlay for the bundled tf-psa-crypto core, which has its own independent config chain. |
| `generated/` | Pre-generated PSA driver dispatch layer (see below). |

## Configuration

`library.mk` defines `MBEDTLS_USER_CONFIG_FILE` and
`TF_PSA_CRYPTO_USER_CONFIG_FILE` **only if the application has not already
defined them**, so an application with its own Mbed TLS configuration keeps
full control:

```make
DEFINES+=MBEDTLS_USER_CONFIG_FILE='"my_mbedtls_config.h"'
INCLUDES+=./configs
```

Note that Mbed TLS and tf-psa-crypto read *separate* config chains. Undefining
a symbol in `mbedtls_user_config.h` does not affect the tf-psa-crypto core;
both files must be kept in sync.

## Pre-generated PSA driver wrappers

`tf-psa-crypto/core/psa_crypto.c` includes `psa_crypto_driver_wrappers.h` and
`psa_crypto_driver_wrappers_no_static.h`, the generated dispatch layer that
routes each PSA operation to either a software implementation or a hardware
accelerator. Upstream ships these only as Jinja templates under
`tf-psa-crypto/scripts/data_files/driver_templates/`, rendered by
`tf-psa-crypto/scripts/generate_driver_wrappers.py` at configure time.

Because ModusToolbox has no configure step, the rendered files are committed
here in `generated/` and added to the include path. This keeps the build free
of any Python/Jinja dependency and avoids writing into `mtb_shared`.

To regenerate after an Mbed TLS version bump:

```bash
python tf-psa-crypto/scripts/generate_driver_wrappers.py --project-root <mbedtls-root>
```

then copy `tf-psa-crypto/core/psa_crypto_driver_wrappers.h` and
`psa_crypto_driver_wrappers_no_static.c` into `generated/`.

The generated sources reference `../drivers/...` relative paths, but only
inside `MBEDTLS_PSA_P256M_DRIVER_ENABLED`, `TF_PSA_CRYPTO_PQCP_MLDSA_ENABLED`
and `PSA_CRYPTO_DRIVER_TEST` guards, all of which are disabled by default.
Enabling any of them requires revisiting the relocation.

## Scope and limitations

This release is **packaging only**. It makes upstream Mbed TLS compile and link
in a ModusToolbox application; it does not provide platform glue code.

In particular `configs/tf_psa_crypto_user_config.h` selects
`MBEDTLS_PSA_DRIVER_GET_ENTROPY`, so an application that actually exercises PSA
crypto must provide `mbedtls_platform_get_entropy()`. An application that never
calls into PSA crypto links cleanly because the linker discards the unused
sections.

Hardware acceleration (`cy-mbedtls-acceleration`), RTOS threading
(`MBEDTLS_THREADING_ALT`) and TLS transport are out of scope.
