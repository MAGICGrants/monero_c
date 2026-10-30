package=sodium
$(package)_version=1.0.22
$(package)_download_path=https://download.libsodium.org/libsodium/releases/
$(package)_file_name=libsodium-$($(package)_version).tar.gz
$(package)_sha256_hash=adbdd8f16149e81ac6078a03aca6fc03b592b89ef7b5ed83841c086191be3349

define $(package)_set_vars
$(package)_config_env_android=ANDROID_NDK_ROOT="$(host_prefix)/native" PATH="${PATH}:$(host_prefix)/native/bin" CC=clang AR=ar RANLIB=ranlib
$(package)_config_opts=--enable-static --disable-shared --with-pic
$(package)_config_opts+=--prefix=$(host_prefix)
endef

define $(package)_preprocess_cmds
  cp -f $(BASEDIR)/config.guess build-aux/config.guess &&\
  cp -f $(BASEDIR)/config.sub build-aux/config.sub
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) -j1 DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm lib/*.la
endef

