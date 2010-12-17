.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmwfg.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= WFGaccess.$(OBJEXT) WFGadd_wf.$(OBJEXT) WFGclasses.$(OBJEXT) \
 WFGcommands.$(OBJEXT) WFGcopy_wf.$(OBJEXT) WFGdel_wf.$(OBJEXT) \
 WFGdump_wf.$(OBJEXT) WFGlist.$(OBJEXT) WFGlogin.$(OBJEXT) WFGn_list.$(OBJEXT) \
 WFGqry.$(OBJEXT) WFGstates.$(OBJEXT) WFGtic.$(OBJEXT) WFGtools.$(OBJEXT) \
 WFGtrans.$(OBJEXT) WFGwf.$(OBJEXT)

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


WFGaccess.$(OBJEXT) :   ../include/machine.h  /usr/include/string.h \
  ../include/WFFadd_wf.h  ../include/WFGstructs.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

WFGadd_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h \
  ../include/WFFadd_wf.h

WFGclasses.$(OBJEXT) :   ../include/machine.h \
  /usr/include/string.h  ../include/MEMstruct.h  ../include/WFGstructs.h \
  ../include/WFGproto.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFG.h  ../include/WFFadd_wf.h

WFGcommands.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h \
  ../include/WFGdefs.h

WFGcopy_wf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/string.h  ../include/MEMstruct.h  ../include/WFGstructs.h \
  ../include/WFGproto.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFG.h  ../include/WFFadd_wf.h

WFGdel_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h

WFGdump_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h

WFGlist.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h

WFGlogin.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h

WFGn_list.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h

WFGqry.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h

WFGstates.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h \
  ../include/WFFadd_wf.h  ../include/WFGdefs.h

WFGtic.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h

WFGtools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h \
  ../include/WFGdefs.h

WFGtrans.$(OBJEXT) :   ../include/machine.h \
  /usr/include/string.h  ../include/MEMstruct.h  ../include/WFGstructs.h \
  ../include/WFGproto.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFG.h  ../include/WFFadd_wf.h

WFGwf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/MEMstruct.h \
  ../include/WFGstructs.h  ../include/WFGproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFG.h \
  ../include/WFGdefs.h



