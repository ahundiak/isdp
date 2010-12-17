.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmwf.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMadd_act.$(OBJEXT) NFMaex_proc.$(OBJEXT) NFMbex_proc.$(OBJEXT) \
 NFMqry_act.$(OBJEXT) NFMsend_ml.$(OBJEXT) NFMsh_mem.$(OBJEXT) \
 NFMwf_tools.$(OBJEXT) WFaccess.$(OBJEXT) WFacl_sign.$(OBJEXT) \
 WFacl_users.$(OBJEXT) WFacls.$(OBJEXT) WFclasses.$(OBJEXT) WFcomm.$(OBJEXT) \
 WFcopy_acl.$(OBJEXT) WFdb_tools.$(OBJEXT) WFget_error.$(OBJEXT) \
 WFload.$(OBJEXT) WFmake_trans.$(OBJEXT) WFsign_tools.$(OBJEXT) \
 WFsignoff.$(OBJEXT) WFstates.$(OBJEXT) WFto_state.$(OBJEXT) WFtools.$(OBJEXT) \
 WFtrans.$(OBJEXT) WFvalid.$(OBJEXT) WFwfs.$(OBJEXT) WFcopy.$(OBJEXT) \
 WFinit.$(OBJEXT)

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


NFMadd_act.$(OBJEXT) :   ../include/machine.h  /usr/include/string.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/WFstruct.h \
  ../include/MSGstruct.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

NFMaex_proc.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/stat.h  /usr/include/sys/cred.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /opt/ingr/include/UMS.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

NFMbex_proc.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/stat.h  /usr/include/sys/cred.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/pwd.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

NFMqry_act.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

NFMsend_ml.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

NFMsh_mem.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/ipc.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/pcb.h  /usr/include/sys/msacct.h  /usr/include/sys/synch.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h \
  /usr/include/sys/machparam.h  /usr/include/sys/param.h \
  /usr/include/sys/pirec.h  /usr/include/sys/machlock.h \
  /usr/include/sys/sleepq.h  /usr/include/sys/turnstile.h \
  /usr/include/sys/unistd.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/signal.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/sys/shm.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMbuf_def.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

NFMwf_tools.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFaccess.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFacl_sign.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFacl_users.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h \
  ../include/NFMitemfiles.h

WFacls.$(OBJEXT) :   ../include/machine.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/WFstruct.h \
  ../include/MSGstruct.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFclasses.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFcomm.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFcopy_acl.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFdb_tools.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFget_error.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFload.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/stdio.h  /usr/include/stdarg.h \
  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h \
  /usr/include/sys/feature_tests.h  /usr/include/ctype.h

WFmake_trans.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFsign_tools.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFsignoff.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFstates.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFto_state.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFtools.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFtrans.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFvalid.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h \
  ../include/WFcommands.h

WFwfs.$(OBJEXT) :   ../include/machine.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/WFstruct.h \
  ../include/MSGstruct.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFcopy.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h

WFinit.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h



