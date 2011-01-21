#!/bin/sh

# Still need to explicitly pass to configure
BS=$ISDP_SOURCE/bspmath
UMS=$ISDP_SOURCE/ums
LIBXC=$ISDP_SOURCE/libxc
FORMS=$ISDP_SOURCE/xforms/source/xfi

EXNUC=$ISDP_SOURCE/exnuc

# This works okay
INCLUDES="-I . -I $BS/include -I $UMS/include -I$LIBXC/include -I $FORMS/include -I $FORMS/fs_include -I$EXNUC/include"

DEFINES=$ISDP_C_DEFINES

# OM Pre Processors
IG_CPP=$EXNUC/bin/omcpp
IG_OPP=$EXNUC/bin/opp
IG_OPP_FLAGS=
IG_OPP_INCLUDES="$INCLUDES -I $EXNUC/spec"
IG_OPP_DEFINES=$DEFINES

ERROFF="-erroff=E_NO_EXPLICIT_TYPE_GIVEN,E_NO_IMPLICIT_DECL_ALLOWED,E_OLD_STYLE_DECL_OR_BAD_TYPE"
ERROFF=

./configure \
  CC=/opt/solstudio12.2/bin/cc \
  CFLAGS="-Xc -xCC -m32 -g -errfmt -errtags=yes $INCLUDES $DEFINES $ERROFF" \
  LDFLAGS="-L/opt/ingr/lib -L/usr/local/lib -R/opt/ingr/lib -R/usr/local/lib" \
  \
  IG_CPP=$IG_CPP IG_OPP=$IG_OPP IG_OPP_FLAGS="$IG_OPP_FLAGS" IG_OPP_INCLUDES="$IG_OPP_INCLUDES" IG_OPP_DEFINES="$IG_OPP_DEFINES" \
  \
  --enable-silent-rules \
  --prefix=/opt/ingr

#  UMS=$UMS LIBXC=$LIBXC EXNUC=$EXNUC \
