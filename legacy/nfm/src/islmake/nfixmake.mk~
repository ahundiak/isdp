SUNFLAGS=
CC=/opt/SUNWspro/bin/cc 
CPUFLAG=
OPT=
CFLAGS=	-g -I../include -L/usr/openwin/lib -L/opt/ingr/lib 
XWINDOWS_FLAG=-DXWINDOWS
OSFLAG=-Dsolaris
LIBDIR=../tdlib
BINDIR=../tdbin
TARGSTR=
OBJEXT=9

NFMFI_XDIR = ../nfmfi_x

NFMFI_XLIB =\
	 $(LIBDIR)/libnfmfi_x.a

NFMLIB=\
      $(LIBDIR)/libqui.a \
      $(LIBDIR)/libnfmr.a \
      $(LIBDIR)/libfilexfer.a \
      $(LIBDIR)/libnfmtools.a \
      $(LIBDIR)/libsystools.a \
      $(LIBDIR)/libnfmnet.a \
      $(LIBDIR)/libnfmmem.a \
      $(LIBDIR)/libtli.a \
      $(LIBDIR)/libnfmerr.a \
      $(LIBDIR)/NFMversion.a \
      $(LIBDIR)/libalter.a


LIBRARIES= \
	-lw\
	-lX11 \
	-lhlib \
	-ldl \
	/opt/xforms63/xforms/source/xfi/lib/i86pc/libXFI.a \
	-lnsl \
	-lUMS \
	-lsocket \
	-lm \
	-lelf

EXECUTABLE = $(BINDIR)/Nfmfix

#	/usr/ccs/lib/libmalloc.a 
$(EXECUTABLE) : $(NFMFI_XDIR)/NFFmain.$(OBJEXT) $(NFMFI_XLIB) $(NFMLIB)
	$(CC)  -DXWINDOWS  $(CFLAGS) $(TARGSTR) $(OSFLAG) \
	-o $(EXECUTABLE) \
	$(NFMFI_XDIR)/NFFmain.$(OBJEXT) \
	/opt/ingr/resrc/fontserver/libXFS.so.1.1 \
	$(NFMFI_XLIB) \
	$(NFMLIB) \
	$(LIBRARIES)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""



