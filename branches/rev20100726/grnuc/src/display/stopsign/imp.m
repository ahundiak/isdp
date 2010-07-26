SOURCE
stopsign.c

SRC
$(GRNUC)/src/display/stopsign

#if defined( NT )
EXEC
$(GRLIB)\bin\stopsign.exe
#else
EXEC
$(GRLIB)/bin/stopsign
#endif

#ifdef CLIX 

CC
acc

COPT
-ansi

#ifdef X11

LINKLIB
-lXFI_s -lXFS_s -lX11_s -lbsd -lm -lc_s

#else

LINKLIB
-lforms_s -ltools_s -lm -lc_s

#endif /* X11 */

INCLUDE
$(GRNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

#endif /* CLIX */


#ifdef SUNOS_2.4

CC
cc

COPT
-DX11

LINKLIB
/usr/lib/libXFI.a -lXFS /usr/ip32/mgui/lib/libX11.a -lm -lc

EXECOPT
-L /usr/5lib

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include

#endif /* SUNOS */

#ifdef IRIX 

CC
cc

COPT
-DX11

LINKLIB
-lXFI -lXFS -lX11 -lm -lc

EXECOPT
-L $(INGRHOME)/lib

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include

#endif /* IRIX */

#ifdef NT

CC
acc

COPT
-ansi

LINKOPT
-subsystem:windows
-entry:WinMainCRTStartup

LINKLIB
$(SHAMROCK)\lib\shamrock.lib

INCLUDE
$(GRNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

#endif /* NT */


#ifdef SUNOS5

CC
cc

COPT 
-DX11

#ifdef INTEL

LINKLIB
-lXFI -lXFS /usr/openwin/lib/libX11.so -lm -lnsl -lsocket -lw -ldl

#elif XGL

LINKLIB
-lXFI -lXFS /usr/openwin/lib/libX11.so -lm -lnsl -lsocket -lw -ldl

#else

LINKLIB
-lXFI -lXFS /usr/openwin/lib/libX11.a -lm -lnsl -lsocket -lw -ldl

#endif

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(FORMS)/include

#endif /* SUNOS5 */
