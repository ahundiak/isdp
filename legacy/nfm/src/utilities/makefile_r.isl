.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmruti.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= UTIRchoose.$(OBJEXT) UTIRerrors.$(OBJEXT) UTIRintern.$(OBJEXT)

#====================================================
.c.$(OBJEXT):
	@echo " $*.c -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	$(CC) -c $(CFLAGS) $(CPUFLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.c
	@echo
	@mv $*.o $*.$(OBJEXT)
#====================================================
.rc.$(OBJEXT):
	@echo " $*.rc -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	$(RISCC) -r $(CFLAGS) $(CPUFLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.rc
	@echo
	$(CC) -c $(CFLAGS) $(CPUFLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.c
	@echo
	@mv $*.o $*.$(OBJEXT)
#====================================================
$(LIBDIR)/$(ARCHNAME) : $(OBJECTS)
	@echo
	ar ruv $(LIBDIR)/$(ARCHNAME) $(OBJECTS)
	@echo
	@ls -l $(LIBDIR)/$(ARCHNAME)
	@echo
#====================================================


UTIRchoose.$(OBJEXT) :   ../include/machine.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NDXstruct.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/UTIerrordef.h

UTIRerrors.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/UTIerrordef.h

UTIRintern.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NFIerrordef.h \
  ../include/UTIerrordef.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/UTIui.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h



