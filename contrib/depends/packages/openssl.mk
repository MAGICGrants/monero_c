package=openssl
$(package)_version=3.5.9
$(package)_download_path=https://github.com/openssl/openssl/releases/download/openssl-$($(package)_version)
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a

define $(package)_set_vars
$(package)_config_env=AR="$($(package)_ar)" ARFLAGS=$($(package)_arflags) RANLIB="$($(package)_ranlib)" CC="$($(package)_cc)"
$(package)_config_env_android=ANDROID_NDK_ROOT="$(host_prefix)/native" PATH="$(host_prefix)/native/bin" CC=clang AR=ar RANLIB=ranlib
$(package)_build_env_android=ANDROID_NDK_ROOT="$(host_prefix)/native"
# util/mkbuildinf.pl compiles a "built on:" date into libcrypto. Depends runs
# under `env -i`, so without this the date is the wall-clock time of the build,
# and any library that links it in is no longer reproducible.
$(package)_build_env=SOURCE_DATE_EPOCH=0
# OPENSSLDIR is compiled into the library as the default certificate location
# and the home of openssl.cnf. Under the build prefix it would name a directory
# on the build host (a path in /tmp for CI builds) that any local user can
# create on the machine the wallet runs on. /etc/ssl is root-owned on every
# Unix-like target, Windows builds take their roots from the Windows store
# instead, and no-autoload-config stops OpenSSL reading openssl.cnf at all.
$(package)_config_opts=--prefix=$(host_prefix) --openssldir=/etc/ssl --libdir=$(host_prefix)/lib
$(package)_config_opts+=no-autoload-config
$(package)_config_opts+=no-capieng
$(package)_config_opts+=no-dso
$(package)_config_opts+=no-dtls1
$(package)_config_opts+=no-ec_nistp_64_gcc_128
$(package)_config_opts+=no-gost
$(package)_config_opts+=no-md2
# QUIC (on by default since 3.2) is unused by wallet2. Leaving it out keeps the
# TLS code the wallets ship close to 3.0's, and removes its qlog code, the only
# caller of OpenSSL_version(), which is what links the build date in.
$(package)_config_opts+=no-quic
$(package)_config_opts+=no-rc5
$(package)_config_opts+=no-rdrand
$(package)_config_opts+=no-rfc3779
$(package)_config_opts+=no-sctp
$(package)_config_opts+=no-shared
$(package)_config_opts+=no-ssl-trace
$(package)_config_opts+=no-ssl3
$(package)_config_opts+=no-tests
$(package)_config_opts+=no-unit-test
$(package)_config_opts+=no-weak-ssl-ciphers
$(package)_config_opts+=no-zlib
$(package)_config_opts+=no-zlib-dynamic
$(package)_config_opts+=$($(package)_cflags) $($(package)_cppflags)
$(package)_config_opts_linux=-fPIC -Wa,--noexecstack
$(package)_config_opts_freebsd=-fPIC -Wa,--noexecstack
$(package)_config_opts_x86_64_linux=linux-x86_64
$(package)_config_opts_i686_linux=linux-generic32
$(package)_config_opts_arm_linux=linux-generic32
$(package)_config_opts_aarch64_linux=linux-generic64
$(package)_config_opts_armv7a_android=--static android-arm
$(package)_config_opts_aarch64_android=--static android-arm64
$(package)_config_opts_aarch64_darwin=darwin64-arm64-cc
$(package)_config_opts_aarch64_ios=darwin64-arm64-cc
$(package)_config_opts_aarch64_iossimulator=darwin64-arm64-cc
$(package)_config_opts_x86_64_ios=darwin64-x86_64-cc
$(package)_config_opts_x86_64_iossimulator=darwin64-x86_64-cc
$(package)_config_opts_riscv64_linux=linux-generic64
$(package)_config_opts_mipsel_linux=linux-generic32
$(package)_config_opts_mips_linux=linux-generic32
$(package)_config_opts_powerpc_linux=linux-generic32
$(package)_config_opts_x86_64_darwin=darwin64-x86_64-cc
$(package)_config_opts_x86_64_mingw32=mingw64
$(package)_config_opts_i686_mingw32=mingw
$(package)_config_opts_x86_64_freebsd=BSD-x86_64
endef

define $(package)_preprocess_cmds
  sed -i.old 's|crypto ssl apps util tools fuzz providers doc|crypto ssl util tools providers|' build.info
endef

define $(package)_config_cmds
  ./Configure $($(package)_config_opts)
endef

define $(package)_build_cmds
  $(MAKE) -j$(NUM_CORES) build_libs
endef

define $(package)_stage_cmds
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) install_sw
endef

define $(package)_postprocess_cmds
  rm -rf share bin etc
endef
