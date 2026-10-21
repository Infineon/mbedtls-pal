/*
 * MINIMAL user config overlay for the tf-psa-crypto core bundled in
 * mbedtls 4.2.0. This is the version that produced the GREEN build in ws1.
 * tf-psa-crypto has its own config chain, so the mbedtls user config does
 * not apply here.
 */
#ifndef TF_PSA_CRYPTO_USER_CONFIG_H
#define TF_PSA_CRYPTO_USER_CONFIG_H

/* The built-in mbedtls_ms_time() needs POSIX clock_gettime() or Win32. */
#undef MBEDTLS_HAVE_TIME
#undef MBEDTLS_HAVE_TIME_DATE

/* The built-in entropy sources only work on Unix/Windows; use the driver
 * callback mbedtls_platform_get_entropy() instead. */
#undef MBEDTLS_PSA_BUILTIN_GET_ENTROPY
#define MBEDTLS_PSA_DRIVER_GET_ENTROPY

#endif /* TF_PSA_CRYPTO_USER_CONFIG_H */
