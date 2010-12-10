#!/bin/sh

# Avoid -fPIC for now and see if libtools will set
# -m32 for 32 bit memory model
# -L,-R to control libraries
./configure \
  CC=/opt/sunstudio12.1/bin/cc \
  CFLAGS="-Xc -xCC -m32 -g -Dunix " \
  LDFLAGS="-L/opt/ingr/lib -L/usr/local/lib -R/opt/ingr/lib -R/usr/local/lib" \
  --prefix=/opt/ingr

