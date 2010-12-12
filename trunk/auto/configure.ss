#!/bin/sh

# Avoid -fPIC for now and see if libtools will set
# -m32 for 32 bit memory model
# -L,-R to control libraries
./configure \
  CC=/opt/solstudio12.2/bin/cc \
  CFLAGS="-Xc -xCC -m32 -g -Dunix " \
  LDFLAGS="-L/opt/ingr/lib -L/usr/local/lib -R/opt/ingr/lib -R/usr/local/lib" \
  RIS=$ISDP_SOURCE/ris  \
  VDS=$ISDP_SOURCE/vds  \
  --prefix=/opt/ingr

