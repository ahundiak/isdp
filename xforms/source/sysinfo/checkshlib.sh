
RELEASE_NUMBER=${1:-01000400}

set -x

slcmp \
  $SYSTEM_LOCATION/save_shlib/$RELEASE_NUMBER/libXFI_s \
  $SYSTEM_BUILD/xfi/lib/libXFI_s \
  _libxfi_getenv -
# dmb:0225/92:That form yields a long list.
# dmb:0225/92:This form is more terse
#  _libxfi_getenv _libxfi_getenv
