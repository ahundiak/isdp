.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
XWINDOWS_FLAG=-DXWINDOWS
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmwff_x.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= WFFadd_cmd.$(OBJEXT) WFFadd_wf.$(OBJEXT) WFFchg_wf.$(OBJEXT) \
 WFFconfig.$(OBJEXT) WFFconfirm.$(OBJEXT) WFFdbg_on.$(OBJEXT) \
 WFFdel_cmd.$(OBJEXT) WFFdel_wf.$(OBJEXT) WFFdump_wf.$(OBJEXT) \
 WFFenv.$(OBJEXT) WFFexit.$(OBJEXT) WFFfgets.$(OBJEXT) WFFfl_tools.$(OBJEXT) \
 WFFhelp.$(OBJEXT) WFFinit.$(OBJEXT) WFFlist_acc.$(OBJEXT) \
 WFFlist_cl.$(OBJEXT) WFFlist_cmd.$(OBJEXT) WFFlist_mcf.$(OBJEXT) \
 WFFlist_pop.$(OBJEXT) WFFlist_st.$(OBJEXT) WFFlist_trn.$(OBJEXT) \
 WFFlist_wf.$(OBJEXT) WFFload_wf.$(OBJEXT) WFFlogin.$(OBJEXT) \
 WFFmain.$(OBJEXT) WFFmain_err.$(OBJEXT) WFFmenu.$(OBJEXT) WFFnotify.$(OBJEXT) \
 WFFpage1.$(OBJEXT) WFFpage2.$(OBJEXT) WFFpage3.$(OBJEXT) WFFpage4.$(OBJEXT) \
 WFFparse.$(OBJEXT) WFFpersist.$(OBJEXT) WFFprint.$(OBJEXT) \
 WFFproc_pg.$(OBJEXT) WFFproc_form.$(OBJEXT) WFFprocess.$(OBJEXT) \
 WFFsignal.$(OBJEXT) WFFscroll.$(OBJEXT) WFFtools.$(OBJEXT) WFFusage.$(OBJEXT) \
 WFFvalidate.$(OBJEXT) WFFvlt.$(OBJEXT) WFFwf.$(OBJEXT)

#====================================================
.c.$(OBJEXT):
	@echo " $*.c -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	$(CC) -c $(CFLAGS) $(CPUFLAG) $(XWINDOWS_FLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.c
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


WFFadd_cmd.$(OBJEXT) :   ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFlist.h  ../include/WFFcmds.h

WFFadd_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFchg_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFconfig.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFconfirm.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFconfirm.h  ../include/WFFlist.h  ../include/NFMschema.h

WFFdbg_on.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFdebug.h

WFFdel_cmd.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFlist.h  ../include/WFFcmds.h

WFFdel_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFlist.h

WFFdump_wf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFldfile.h

WFFenv.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpopup.h  ../include/WFFlogin.h

WFFexit.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFfgets.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h

WFFfl_tools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFconfirm.h

WFFhelp.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFinit.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFlist_acc.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h

WFFlist_cl.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h

WFFlist_cmd.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h

WFFlist_mcf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h  ../include/WFFpersist.h

WFFlist_pop.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h  ../include/WFFpopup.h

WFFlist_st.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h

WFFlist_trn.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h

WFFlist_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h

WFFload_wf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFldfile.h

WFFlogin.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFlogin.h  ../include/WFFlist.h

WFFmain.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFmain_err.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFmain_err.h

WFFmenu.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFnotify.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpage2.h  ../include/WFFconfirm.h  ../include/WFFtimestamp.h

WFFpage1.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFlist.h  ../include/WFFadd_wf.h  ../include/WFFpage1.h

WFFpage2.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFadd_wf.h  ../include/WFFlist.h  ../include/WFFpage2.h \
  ../include/NFMschema.h

WFFpage3.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFadd_wf.h  ../include/WFFlist.h  ../include/WFFpage3.h

WFFpage4.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFadd_wf.h  ../include/WFFlist.h  ../include/WFFpage4.h

WFFparse.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFpersist.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/WFFincl.h  ../include/WFFdef.h \
  ../include/WFGstructs.h  ../include/WFFstructs.h  ../include/DEBUG.h \
  ../include/WFFglobal.h  ../include/WFFforms.h  ../include/WFFcommands.h \
  ../include/NFIerrordef.h  ../include/WFGproto.h  ../include/WFFproto.h \
  ../include/WFF.h  ../include/WFFpersist.h  ../include/WFFlist.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h

WFFprint.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
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
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/WFFincl.h  ../include/WFFdef.h \
  ../include/WFGstructs.h  ../include/WFFstructs.h  ../include/DEBUG.h \
  ../include/WFFglobal.h  ../include/WFFforms.h  ../include/WFFcommands.h \
  ../include/NFIerrordef.h  ../include/WFGproto.h  ../include/WFFproto.h \
  ../include/WFF.h  ../include/WFFlist.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/sys/siginfo.h  /usr/include/time.h

WFFproc_pg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFadd_wf.h

WFFproc_form.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFprocess.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFpersist.h  ../include/WFFlist.h  ../include/NFMtypes.h \
  ../include/WFFtimestamp.h

WFFsignal.$(OBJEXT) :   ../include/machine.h \
  /usr/include/signal.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h

WFFscroll.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/WFFincl.h  ../include/WFFdef.h \
  ../include/WFGstructs.h  ../include/WFFstructs.h  ../include/DEBUG.h \
  ../include/WFFglobal.h  ../include/WFFforms.h  ../include/WFFcommands.h \
  ../include/NFIerrordef.h  ../include/WFGproto.h  ../include/WFFproto.h \
  ../include/WFF.h  /usr/include/sys/feature_tests.h  /usr/include/ctype.h

WFFtools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFlabels.h  ../include/WFFpersist.h

WFFusage.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/feature_tests.h  /usr/include/string.h

WFFvalidate.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFlist.h

WFFvlt.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/WFFvlt.h

WFFwf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/tools.h  /opt/ingr/include/UMS.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFFincl.h  ../include/WFFdef.h  ../include/WFGstructs.h \
  ../include/WFFstructs.h  ../include/DEBUG.h  ../include/WFFglobal.h \
  ../include/WFFforms.h  ../include/WFFcommands.h  ../include/NFIerrordef.h \
  ../include/WFGproto.h  ../include/WFFproto.h  ../include/WFF.h \
  ../include/NFMschema.h  ../include/WFstruct.h  ../include/WFcommands.h \
  ../include/WFFlist.h  ../include/WFFvalidate.h  ../include/WFFtimestamp.h



