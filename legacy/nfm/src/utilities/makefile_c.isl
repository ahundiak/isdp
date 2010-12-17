.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmcuti.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= UTICcmd.$(OBJEXT) UTICerrors.$(OBJEXT) UTICinit_ums.$(OBJEXT) \
 UTICinput.$(OBJEXT) UTICmain.$(OBJEXT) UTICreq.$(OBJEXT) \
 UTICscripts.$(OBJEXT) UTICtjb.$(OBJEXT) UTICtools.$(OBJEXT)

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


UTICcmd.$(OBJEXT) :   ../include/machine.h  ../include/MEMstruct.h \
  ../include/NFMtypes.h  ../include/MSGstruct.h  ../include/UNIX_or_VMS.h \
  ../include/UTIclient.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/UTIdef.h \
  ../include/UTIextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/UTImacros.h \
  ../include/UTIstruct.h  ../include/UTIglobals.h  ../include/UTICinclude.h

UTICerrors.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MSGstruct.h \
  ../include/UNIX_or_VMS.h  ../include/UTIclient.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/UTIdef.h  ../include/UTIextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/UTImacros.h  ../include/UTIstruct.h \
  ../include/UTIglobals.h  ../include/UTICinclude.h

UTICinit_ums.$(OBJEXT) :  \
  ../include/machine.h  /opt/ingr/include/UMS.h  ../include/UTIclient.h \
  ../include/UTImacros.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h

UTICinput.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MSGstruct.h  ../include/UNIX_or_VMS.h \
  ../include/UTIclient.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/UTIdef.h \
  ../include/UTIextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/UTImacros.h \
  ../include/UTIstruct.h  ../include/UTIglobals.h  ../include/UTICinclude.h

UTICmain.$(OBJEXT) :  \
  ../include/machine.h  ../include/MSGstruct.h  ../include/UTIclient.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/UTIdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/UTImacros.h  ../include/UTIstruct.h \
  ../include/DEBUG.h

UTICreq.$(OBJEXT) :   ../include/machine.h \
  ../include/WFcommands.h  ../include/UTIdef.h  ../include/UTIclient.h \
  ../include/UTIextern.h  ../include/UTImacros.h  ../include/UTIstruct.h \
  ../include/UTIglobals.h  ../include/NFIerrordef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NDXstruct.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/pwd.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h

UTICscripts.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MSGstruct.h \
  ../include/UNIX_or_VMS.h  ../include/UTIclient.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/UTIdef.h  ../include/UTIextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/UTImacros.h  ../include/UTIstruct.h \
  ../include/UTIglobals.h  ../include/UTICinclude.h

UTICtjb.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MSGstruct.h \
  ../include/UNIX_or_VMS.h  ../include/UTIclient.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/UTIdef.h  ../include/UTIextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/UTImacros.h  ../include/UTIstruct.h \
  ../include/UTIglobals.h  ../include/UTICinclude.h

UTICtools.$(OBJEXT) :  \
  ../include/MEMstruct.h  ../include/MSGstruct.h  ../include/UNIX_or_VMS.h \
  ../include/UTIclient.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/UTIdef.h \
  ../include/UTIextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/UTImacros.h \
  ../include/UTIstruct.h  ../include/UTIglobals.h  ../include/UTICinclude.h



