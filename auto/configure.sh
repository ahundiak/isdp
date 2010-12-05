#!/bin/sh

# Avoid -fPIC for now and see if libtools will set
# -m32 for 32 bit memory model
# -L,-R to control libraries
./configure \
  CFLAGS="-g -m32" \
  LDFLAGS="-L/opt/ingr/lib -R/opt/ingr/lib" \
  --prefix=/opt/ingr

