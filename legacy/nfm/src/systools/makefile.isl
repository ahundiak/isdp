.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libsystools.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMbase36.$(OBJEXT) NFMcrypt.$(OBJEXT) NFMdatetime.$(OBJEXT) \
 NFMerror.$(OBJEXT) NFMfile_oper.$(OBJEXT) NFMg_f_name.$(OBJEXT) \
 NFMgen_tools.$(OBJEXT) NFMnewf_name.$(OBJEXT) NFMnfs.$(OBJEXT) \
 NFMreset_msg.$(OBJEXT) NFMstring.$(OBJEXT) NFMsys_func.$(OBJEXT) \
 NFMstools.$(OBJEXT)

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


NFMbase36.$(OBJEXT) :   ../include/machine.h  /usr/include/string.h \
  /usr/include/sys/utsname.h  /usr/include/sys/stat.h  /usr/include/pwd.h \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMcrypt.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMdatetime.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMerror.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMfile_oper.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMg_f_name.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMgen_tools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h  ../include/NFMporttypes.h

NFMnewf_name.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMnfs.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMreset_msg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMstring.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/sys/utsname.h \
  /usr/include/sys/stat.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../include/NFMsysstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr.h  ../include/NFMnfs.h  ../include/MSGstruct.h \
  ../include/NFMsysextern.h  ../include/NFMsysdef.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMsys_func.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMporttypes.h  /usr/include/sys/cred.h \
  /usr/include/sys/resource.h  /usr/include/sys/auxv.h \
  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/sys/utsname.h  /usr/include/sys/stat.h \
  /usr/include/pwd.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  ../include/NFMsysstruct.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMattr.h  ../include/NFMnfs.h \
  ../include/MSGstruct.h  ../include/NFMsysextern.h  ../include/NFMsysdef.h \
  ../include/DEBUG.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/SYSTproto.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/NFMsysinc.h

NFMstools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h



