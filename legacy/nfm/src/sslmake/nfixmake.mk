SUNFLAGS=-Xa
CC=acc -g
CPUFLAG=
OPT=
CFLAGS=	-I../include
XWINDOWS_FLAG=-DXWINDOWS
OSFLAG=-Dsolaris
LIBDIR=../sollib
BINDIR=../solbin
TARGSTR=
OBJEXT=7

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
      $(LIBDIR)/alter.a

LIBRARIES= \
	-lw\
	-lX11 \
	-lhlib \
	-ldl \
        -lXFS \
	-lXFI \
	-lnsl \
	-lUMS \
	-lsocket \
	-lm 

EXECUTABLE = $(BINDIR)/Nfmfix

#	/usr/ccs/lib/libmalloc.a 
$(EXECUTABLE) : $(NFMFI_XDIR)/NFFmain.$(OBJEXT) $(NFMFI_XLIB) $(NFMLIB)
	acc -g -Xa -DXWINDOWS  $(CFLAGS) $(TARGSTR) \
	-o $(EXECUTABLE) \
	$(NFMFI_XDIR)/NFFmain.$(OBJEXT) \
	$(NFMFI_XLIB) \
	$(NFMLIB) \
	$(LIBRARIES)
	@echo ""
#	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""



