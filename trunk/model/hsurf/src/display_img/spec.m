SRC
$(MODEL)/hsurf/src/display_img

EXEC
$(MDTARG)/hsurf/src/display_img/display_img

COPT
-ga

CC
acc -knr

LINKLIB
/usr/lib/libforms_s.a
/usr/lib/libtools_s.a
/lib/libm.a
/usr/lib/libc_s.a
$(MDTARG)/hsurf/src/co_func/HSrecall_rle.o
$(MDTARG)/hsurf/src/co_func/HSformat_rle.o
$(MDTARG)/hsurf/src/co_func/HSread_hdr.o
$(MDTARG)/hsurf/src/render_imp/HRcolor_rgb.o

INCLUDE
$(INGRHOME)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/hsurf/src/include
$(MODEL)/include

SOURCE
