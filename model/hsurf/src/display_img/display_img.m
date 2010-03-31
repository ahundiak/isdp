EXEC
display_img

COPT
-ga

CC
acc -knr

LINKLIB
/usr/lib/libforms_s.a
/usr/lib/libtools_s.a
/lib/libm.a
/usr/lib/libc_s.a

SOURCE
display_img.c
match.c
stop.c
stubs.c
fake_out.c

../co_func/HSrecall_rle.o
../co_func/HSformat_rle.o
../co_func/HSread_hdr.o
../render_imp/HRcolor_rgb.o

INCLUDE
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/hsurf/src/include
$(MODEL)/include
