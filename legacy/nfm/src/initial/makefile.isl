.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=librisinit.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMi_crdb.$(OBJEXT) NFMi_dbattr.$(OBJEXT) NFMi_enter.$(OBJEXT) \
 NFMi_funct.$(OBJEXT) NFMi_init.$(OBJEXT) NFMi_qry.$(OBJEXT) NFMi_sc.$(OBJEXT) \
 NFMi_util.$(OBJEXT)

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


NFMi_crdb.$(OBJEXT) :   ../include/machine.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/SCdata.h  ../include/SCstruct.h \
  ../include/SCdef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MSGstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMRextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h

NFMi_dbattr.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MSGstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMRextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h

NFMi_enter.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MSGstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMRextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h

NFMi_funct.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MSGstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMRextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h

NFMi_init.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MSGstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMRextern.h  ../include/DEBUG.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/NFMversion.h  ../include/SQLstruct.h

NFMi_qry.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MSGstruct.h \
  ../include/NFMstruct.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMRextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h  ../include/NFMschema.h \
  ../include/NFMapi.h

NFMi_sc.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/SCdata.h  ../include/SCstruct.h \
  ../include/SCdef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MSGstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMRextern.h \
  ../include/DEBUG.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  /usr/include/pwd.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h

NFMi_util.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/SCdata.h  ../include/SCstruct.h \
  ../include/SCdef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MSGstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMRextern.h \
  ../include/DEBUG.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/NDXstruct.h \
  ../include/INITproto.h  ../include/INIT.h  ../include/NFMsysstruct.h \
  /usr/include/sys/stat.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/pwd.h \
  ../include/NFMenv.h  ../include/NFMporttypes.h



