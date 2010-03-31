EXEC
solo

LINKLIB
../display_func/display_func.o
../tiler_func/tiler_func.o
../driver_func/HSdriver.o
../driver_func/HStl_feedbck.o
../pbust_func/pbust_func.o
$BS/lib/bnfc_ap.a
$BS/lib/bsem_ap.a
$BS/lib/bslg_ap.a
$BS/lib/bsma_ap.a
$BS/lib/bsmd_ap.a
$EXNUC/lib/libwl.a
/usr/lib/libEG_s.a
/usr/lib/libtools_s.a
/usr/lib/libgpipe_s.a
/usr/lib/libmath.a
/lib/libc_s.a
/usr/lib/libix.a
/usr2/mike/timing/HStiming.o

COPT
-g

CC
cc

INCLUDE
/usr/include
/usr4/ip32/environv
$(MODEL)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes

SOURCE
hsurf_global.c
HSbldphyctbl.c
HScolordown.c
HSstubs.c
standalone.c
color_rgb.c
HSgetopt.c
