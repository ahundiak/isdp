.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
COMBINE_FLAG=-DCOMBINED_MAKE
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=nfm_calls.a
OSFLAG=-Dsolaris
MISCFLAG=-Disl
RISFLAGS=-DRIS5
TARGSTR=
CFLAGS=-Xa 	-I../inc	-I../../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= dbnfm.$(OBJEXT) e_nfm.$(OBJEXT) i_nfm.$(OBJEXT) nfm_util.$(OBJEXT) \
 reg_nfm.$(OBJEXT) s_nfm.$(OBJEXT)

#====================================================
.c.$(OBJEXT):
	@echo " $*.c -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	$(CC) -c $(CFLAGS) $(CPUFLAG) $(COMBINE_FLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.c
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


dbnfm.$(OBJEXT) :   /usr/include/sys/stat.h  /usr/include/sys/fcntl.h \
  /usr/include/fcntl.h  /usr/include/ctype.h  /usr/include/sys/cred.h \
  /usr/include/sys/resource.h  /usr/include/sys/auxv.h \
  /usr/include/sys/errno.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
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
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def \
  ../inc/reserve.def  ../inc/operator.def  ../inc/operand.def \
  ../inc/format.def  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def \
  ../inc/dba_msg.h  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def \
  ../inc/forms.def  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h  /usr/include/X11/Xmd.h \
  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/sys/utsname.h  ../inc/machine.h  ../../include/NETstruct.h \
  ../../include/NETdef.h  ../../include/NFMtypes.h  ../../include/DEBUG.h \
  ../../include/NFMstruct.h  ../../include/NFMUproto.h \
  ../../include/NFMAproto.h  ../../include/DISproto.h \
  ../../include/NFMRstruct.h  ../../include/NFMRproto.h \
  ../../include/NFMcombine.h  ../../include/NFMRinclude.h \
  ../../include/MEMstruct.h  ../../include/MSGstruct.h \
  ../../include/WFcommands.h  ../../include/MEMerrordef.h \
  ../../include/SQLerrordef.h  ../../include/NETerrordef.h \
  ../../include/NFMerrordef.h  ../../include/NDXstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../../include/ERRproto.h  ../../include/ERR.h  ../../include/NFMschema.h \
  ../../include/NFMapi.h  /opt/ingr/include/UMS.h  ../inc/dbn_defs.h \
  ../inc/dbn.h

e_nfm.$(OBJEXT) :   /usr/include/sys/stat.h \
  /usr/include/sys/fcntl.h  /usr/include/fcntl.h  /usr/include/ctype.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/errno.h  /usr/include/sys/user.h \
  /usr/include/sys/timer.h  /usr/include/vm/seg_enum.h \
  /usr/include/sys/pcb.h  /usr/include/sys/msacct.h  /usr/include/sys/synch.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/signal.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h \
  /usr/include/sys/pirec.h  /usr/include/sys/machlock.h \
  /usr/include/sys/sleepq.h  /usr/include/sys/turnstile.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/vm/page.h  /usr/include/sys/thread.h \
  /usr/include/sys/copyops.h  /usr/include/sys/watchpoint.h \
  /usr/include/sys/segment.h  /usr/include/sys/proc.h \
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/string.h \
  /usr/include/memory.h  /usr/include/malloc.h  ../../include/tools.h \
  /opt/ingr/include/UMS.h  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def \
  ../inc/reserve.def  ../inc/operator.def  ../inc/operand.def \
  ../inc/format.def  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def \
  ../inc/dba_msg.h  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def \
  ../inc/forms.def  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

i_nfm.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/errno.h  /usr/include/sys/user.h \
  /usr/include/sys/timer.h  /usr/include/vm/seg_enum.h \
  /usr/include/sys/pcb.h  /usr/include/sys/msacct.h  /usr/include/sys/synch.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/signal.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h \
  /usr/include/sys/pirec.h  /usr/include/sys/machlock.h \
  /usr/include/sys/sleepq.h  /usr/include/sys/turnstile.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/vm/page.h  /usr/include/sys/thread.h \
  /usr/include/sys/copyops.h  /usr/include/sys/watchpoint.h \
  /usr/include/sys/segment.h  /usr/include/sys/proc.h \
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/string.h \
  /usr/include/memory.h  /usr/include/malloc.h  ../../include/tools.h \
  /opt/ingr/include/UMS.h  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def \
  ../inc/reserve.def  ../inc/operator.def  ../inc/operand.def \
  ../inc/format.def  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def \
  ../inc/dba_msg.h  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def \
  ../inc/forms.def  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  ../inc/keys.def

nfm_util.$(OBJEXT) :   /usr/include/sys/stat.h \
  /usr/include/sys/fcntl.h  /usr/include/fcntl.h  /usr/include/ctype.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/errno.h  /usr/include/sys/user.h \
  /usr/include/sys/timer.h  /usr/include/vm/seg_enum.h \
  /usr/include/sys/pcb.h  /usr/include/sys/msacct.h  /usr/include/sys/synch.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/signal.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h \
  /usr/include/sys/pirec.h  /usr/include/sys/machlock.h \
  /usr/include/sys/sleepq.h  /usr/include/sys/turnstile.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/vm/page.h  /usr/include/sys/thread.h \
  /usr/include/sys/copyops.h  /usr/include/sys/watchpoint.h \
  /usr/include/sys/segment.h  /usr/include/sys/proc.h \
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/string.h \
  /usr/include/memory.h  /usr/include/malloc.h  ../../include/tools.h \
  /opt/ingr/include/UMS.h  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def \
  ../inc/reserve.def  ../inc/operator.def  ../inc/operand.def \
  ../inc/format.def  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def \
  ../inc/dba_msg.h  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def \
  ../inc/forms.def  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

reg_nfm.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/errno.h  /usr/include/sys/user.h \
  /usr/include/sys/timer.h  /usr/include/vm/seg_enum.h \
  /usr/include/sys/pcb.h  /usr/include/sys/msacct.h  /usr/include/sys/synch.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/signal.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h \
  /usr/include/sys/pirec.h  /usr/include/sys/machlock.h \
  /usr/include/sys/sleepq.h  /usr/include/sys/turnstile.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/vm/page.h  /usr/include/sys/thread.h \
  /usr/include/sys/copyops.h  /usr/include/sys/watchpoint.h \
  /usr/include/sys/segment.h  /usr/include/sys/proc.h \
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/string.h \
  /usr/include/memory.h  /usr/include/malloc.h  ../../include/tools.h \
  /opt/ingr/include/UMS.h  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def \
  ../inc/reserve.def  ../inc/operator.def  ../inc/operand.def \
  ../inc/format.def  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def \
  ../inc/dba_msg.h  ../inc/forms.def  ../inc/gdg_type.def  ../inc/gadgets.def \
  ../inc/dba.def  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dbforms.pro \
  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro \
  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro \
  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro \
  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def

s_nfm.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/errno.h  /usr/include/sys/user.h \
  /usr/include/sys/timer.h  /usr/include/vm/seg_enum.h \
  /usr/include/sys/pcb.h  /usr/include/sys/msacct.h  /usr/include/sys/synch.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/signal.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h \
  /usr/include/sys/pirec.h  /usr/include/sys/machlock.h \
  /usr/include/sys/sleepq.h  /usr/include/sys/turnstile.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/vm/page.h  /usr/include/sys/thread.h \
  /usr/include/sys/copyops.h  /usr/include/sys/watchpoint.h \
  /usr/include/sys/segment.h  /usr/include/sys/proc.h \
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/string.h \
  /usr/include/memory.h  /usr/include/malloc.h  ../../include/tools.h \
  /opt/ingr/include/UMS.h  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def \
  ../inc/reserve.def  ../inc/operator.def  ../inc/operand.def \
  ../inc/format.def  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def \
  ../inc/dba_msg.h  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def \
  ../inc/forms.def  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  ../inc/keys.def



