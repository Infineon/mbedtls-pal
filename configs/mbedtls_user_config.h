/*
 * MINIMAL user config overlay for upstream mbedtls 4.2.0 on PSoC Edge.
 * This is the version that produced the GREEN build in ws1.
 * Included by build_info.h after the default mbedtls_config.h.
 */
#ifndef MBEDTLS_USER_CONFIG_H
#define MBEDTLS_USER_CONFIG_H

/* No filesystem on target: disables mbedtls_x509_crt_parse_path(), which
 * needs POSIX dirent.h/readdir()/closedir(). */
#undef MBEDTLS_FS_IO

/* No BSD/Windows sockets on target (net_sockets.c is excluded via .cyignore). */
#undef MBEDTLS_NET_C

/* No time() on bare metal. */
#undef MBEDTLS_HAVE_TIME
#undef MBEDTLS_HAVE_TIME_DATE

/* timing.c is a host-side benchmarking helper and requires MBEDTLS_HAVE_TIME. */
#undef MBEDTLS_TIMING_C

#endif /* MBEDTLS_USER_CONFIG_H */
