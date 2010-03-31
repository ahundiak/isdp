SRC
$(PWD)
EXEC
$(MODEL)/bin/preview
DEPLIB
#if defined (NT)
$(EXNUC)/lib/wl.lib
#else
$(EXNUC)/lib/wl.o
#endif
LINKLIB
#if defined (CLIX)
/usr/lib/libtools_s.a
/lib/libm.a
/lib/libc_s.a
#endif
#if defined (XGL)
-lxgl
#endif
#if defined (X11)
-lXt
-lX11
-lXext
#endif
#if defined (OPENGL)
-lGL
-lGLU
-lGLcore
#endif
#if defined (NT)
c:\msvc20\lib\user32.lib
c:\msvc20\lib\gdi32.lib
c:\msvc20\lib\winspool.lib
c:\msvc20\lib\advapi32.lib
#endif
INCLUDE
$(HOME)/tools/timing
#if !defined (NT)
$(INGRHOME)/include
$(XINC)
#endif
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
#if defined (XGL)
$(XINC)/xgl
$(XGLHOME)/include/xgl
$(XGLHOME)/include
#endif
SOURCE
BMP.c
#if defined (X11)
timing.c
#endif
cmap.c
color_rgb.c
context.c
event.c
file.c
global.c
preview.c
creat_wind.c
conv.c
options.c
PS.c
readln.c
