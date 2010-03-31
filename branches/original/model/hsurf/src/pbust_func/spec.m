SRC
$(MODEL)/hsurf/src/pbust_func
LIB
$(MDTARG)/hsurf/src/pbust_func/pbust_func.o
#if defined (sun)
CC
cc
#else
CC
acc -c -knr
#endif
COPT
-ga
INCLUDE
$(INGRHOME)/include
$(GRNUC)/ingrsys
$(MODEL)/hsurf/src/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(MODEL)/proto_include
$(BS)/include
$(BS)/include/prototypes
#ifdef X11
$(XINC)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
SOURCE
HSe2_edges.c
HSe2_regular.c
HSe2_sort.c
HSe2_triangl.c
HSe2_trimesh.c
HStl_maketrp.c
HStl_pbust.c
