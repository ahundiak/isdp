.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
COMBINE_FLAG=-DCOMBINED_MAKE
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnucleus.a
OSFLAG=-Dsolaris
RISFLAGS=-DRIS5
MISCFLAG=-Disl
TARGSTR=
CFLAGS=-Xa 	-I../inc	-I../../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= add_err.$(OBJEXT) dmalloc.$(OBJEXT) load_opt.$(OBJEXT) setup.$(OBJEXT) \
 append_error.$(OBJEXT) exit.$(OBJEXT) load_tmp.$(OBJEXT) std_err.$(OBJEXT) \
 avl.$(OBJEXT) exit_err.$(OBJEXT) look_lib.$(OBJEXT) stralloc.$(OBJEXT) \
 blk_und.$(OBJEXT) expbs.$(OBJEXT) lower.$(OBJEXT) strchr.$(OBJEXT) \
 check_max14.$(OBJEXT) ext_temp.$(OBJEXT) mal_nuc.$(OBJEXT) strip.$(OBJEXT) \
 chunk.$(OBJEXT) f_nuc.$(OBJEXT) movefile.$(OBJEXT) temptype.$(OBJEXT) \
 code_to_tic.$(OBJEXT) g_deltmp.$(OBJEXT) nuc_mgr.$(OBJEXT) text_lib.$(OBJEXT) \
 compress.$(OBJEXT) g_libndx.$(OBJEXT) nuc_util.$(OBJEXT) \
 tic_to_code.$(OBJEXT) crash.$(OBJEXT) get_msg.$(OBJEXT) open_msg.$(OBJEXT) \
 typed_temps.$(OBJEXT) creat_rtblib.$(OBJEXT) get_temp_typ.$(OBJEXT) \
 out_er.$(OBJEXT) undel.$(OBJEXT) d_strcmp.$(OBJEXT) i_bldfnc.$(OBJEXT) \
 pad_string.$(OBJEXT) upper.$(OBJEXT) dba_get_opt.$(OBJEXT) i_cvtfnc.$(OBJEXT) \
 parse_string.$(OBJEXT) ustrcmp.$(OBJEXT) dba_init.$(OBJEXT) \
 i_fncexi.$(OBJEXT) parse_tics.$(OBJEXT) wild.$(OBJEXT) dba_sort.$(OBJEXT) \
 i_prcscr.$(OBJEXT) parse_var.$(OBJEXT) win32s.$(OBJEXT) dba_strdup.$(OBJEXT) \
 init_err.$(OBJEXT) r_c_w.$(OBJEXT) write_temp.$(OBJEXT) dba_swap.$(OBJEXT) \
 ins_temp.$(OBJEXT) regfunc.$(OBJEXT) dbd_abort.$(OBJEXT) int_stak.$(OBJEXT) \
 save_blk.$(OBJEXT) del_temp.$(OBJEXT) list_lib.$(OBJEXT) search_str.$(OBJEXT)

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


add_err.$(OBJEXT) :   /usr/include/sys/stat.h  /usr/include/sys/fcntl.h \
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
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h  ../inc/dbadev.h \
  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro \
  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro \
  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro \
  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def \
  ../inc/sce.pro  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
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

dmalloc.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/dmalloc.def

load_opt.$(OBJEXT) :  \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h

setup.$(OBJEXT) :  \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/report.h  ../inc/max_gadg.def  ../inc/mb.h \
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
  /usr/include/sys/procset.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/signal.h  /usr/include/string.h \
  /usr/include/memory.h  /usr/include/malloc.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../../include/tools.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/include/UMS.h  ../inc/dba_err.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/rb.h  ../inc/ustn.h \
  ../inc/dba.h  ../inc/keys.def  /usr/include/libintl.h \
  /usr/include/locale.h

append_error.$(OBJEXT) :   /usr/include/sys/stat.h \
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

exit.$(OBJEXT) :  \
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

load_tmp.$(OBJEXT) :   /usr/include/sys/stat.h \
  /usr/include/sys/fcntl.h  /usr/include/fcntl.h  /usr/include/ctype.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h  ../inc/dbadev.h \
  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro \
  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro \
  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro \
  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def \
  ../inc/sce.pro  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
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
  /usr/include/sys/errno.h  /usr/include/errno.h

std_err.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

avl.$(OBJEXT) :  \
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
  ../inc/dmalloc.def  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def

exit_err.$(OBJEXT) :  \
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

look_lib.$(OBJEXT) :   /usr/include/sys/stat.h \
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

stralloc.$(OBJEXT) :  \
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
  ../inc/dmalloc.def  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def

blk_und.$(OBJEXT) :  \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h

expbs.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

lower.$(OBJEXT) : 

strchr.$(OBJEXT) : 

check_max14.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

ext_temp.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../inc/dba_err.h \
  ../inc/dbadev.h  /usr/include/sys/errno.h  /usr/include/errno.h

mal_nuc.$(OBJEXT) :  \
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
  ../inc/dmalloc.def

strip.$(OBJEXT) : 

chunk.$(OBJEXT) :   /usr/include/sys/stat.h \
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

f_nuc.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

movefile.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h  ../inc/dbadev.h \
  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro \
  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro \
  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro \
  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def \
  ../inc/sce.pro  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
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
  /usr/include/sys/errno.h  /usr/include/errno.h

temptype.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

code_to_tic.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

g_deltmp.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dmalloc.def

nuc_mgr.$(OBJEXT) :  \
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

text_lib.$(OBJEXT) :   /usr/include/ctype.h \
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
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  ../inc/dmalloc.def  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h

compress.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/keys.def

g_libndx.$(OBJEXT) :  \
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
  ../inc/dmalloc.def

nuc_util.$(OBJEXT) :   /usr/include/sys/stat.h \
  /usr/include/sys/fcntl.h  /usr/include/fcntl.h  /usr/include/ctype.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/X11/Xmd.h \
  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
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
  /usr/include/sys/procset.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/signal.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/keys.def

tic_to_code.$(OBJEXT) :  \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h  ../inc/dmalloc.def

crash.$(OBJEXT) :  \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/sys/cred.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/signal.h

get_msg.$(OBJEXT) :  \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h  ../inc/dmalloc.def

open_msg.$(OBJEXT) :  \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h  ../inc/dmalloc.def

typed_temps.$(OBJEXT) :  \
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
  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro \
  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro \
  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro \
  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def \
  ../inc/sce.pro  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../inc/dba_err.h \
  ../inc/dbadev.h

creat_rtblib.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  ../inc/keys.def

get_temp_typ.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  ../inc/dmalloc.def

out_er.$(OBJEXT) :   /usr/include/sys/stat.h \
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

undel.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  ../inc/dba_err.h  ../inc/dbadev.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/sys/errno.h \
  /usr/include/errno.h

d_strcmp.$(OBJEXT) :   /usr/include/sys/stat.h \
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

i_bldfnc.$(OBJEXT) :  \
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

pad_string.$(OBJEXT) :   /usr/include/sys/stat.h \
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

upper.$(OBJEXT) : 

dba_get_opt.$(OBJEXT) :  \
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
  ../inc/keys.def  ../inc/dmalloc.def

i_cvtfnc.$(OBJEXT) :  \
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

parse_string.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h

ustrcmp.$(OBJEXT) :  \
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
  ../inc/dmalloc.def

dba_init.$(OBJEXT) :   /usr/include/sys/stat.h \
  /usr/include/sys/fcntl.h  /usr/include/fcntl.h  /usr/include/ctype.h \
  /usr/include/signal.h  /usr/include/string.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/X11/Xmd.h \
  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
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
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/condvar.h \
  /usr/include/sys/t_lock.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h \
  /usr/include/sys/wait.h  /usr/include/stdlib.h  ../inc/dmalloc.def

i_fncexi.$(OBJEXT) :  \
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

parse_tics.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h  ../inc/dmalloc.def

wild.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

dba_sort.$(OBJEXT) :  \
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
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/dmalloc.def

i_prcscr.$(OBJEXT) :  \
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

parse_var.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  /usr/include/memory.h \
  /usr/include/malloc.h  ../../include/tools.h  /opt/ingr/include/UMS.h \
  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def \
  ../inc/operator.def  ../inc/operand.def  ../inc/format.def \
  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h \
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/forms.def \
  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h \
  ../inc/dbadev.h  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro \
  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro \
  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro \
  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro \
  ../inc/cretab.def  ../inc/sce.pro  /opt/ingr/include/FSTypes.h \
  /opt/ingr/include/FS.h  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h \
  ../inc/x.pro  ../inc/xdv.pro  ../inc/clipper.pro  ../inc/dde.pro \
  ../inc/wforms.pro  ../inc/v_gui.pro  ../inc/v_pub.pro \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h

win32s.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

dba_strdup.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

init_err.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

r_c_w.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

write_temp.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h  ../inc/dbadev.h \
  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro \
  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro \
  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro \
  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def \
  ../inc/sce.pro  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
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
  /usr/include/sys/errno.h  /usr/include/errno.h  ../inc/keys.def

dba_swap.$(OBJEXT) : 

ins_temp.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/memory.h  /usr/include/malloc.h  ../../include/tools.h \
  /opt/ingr/include/UMS.h  ../inc/att.def  ../inc/linfld.def  ../inc/trm.def \
  ../inc/reserve.def  ../inc/operator.def  ../inc/operand.def \
  ../inc/format.def  ../inc/temptyp.def  ../inc/options.def  ../inc/sort.def \
  ../inc/dba_msg.h  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def \
  ../inc/forms.def  ../inc/gdg_type.def  ../inc/gadgets.def  ../inc/dba.def \
  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro \
  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro \
  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro \
  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def \
  ../inc/sce.pro  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/string.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/select.h  /usr/include/sys/time.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  ../inc/dba_err.h \
  ../inc/dbadev.h

regfunc.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/dmalloc.def

dbd_abort.$(OBJEXT) : 

int_stak.$(OBJEXT) :  \
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

save_blk.$(OBJEXT) :  \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

del_temp.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dba_err.h  ../inc/dbadev.h \
  ../inc/dbforms.pro  ../inc/dbformsc.pro  ../inc/dbnuc.pro  ../inc/dload.pro \
  ../inc/gui.pro  ../inc/mb.pro  ../inc/nfm.pro  ../inc/nucleus.pro \
  ../inc/private.pro  ../inc/rb.pro  ../inc/rbc.pro  ../inc/report.pro \
  ../inc/script.pro  ../inc/ustn.pro  ../inc/debug.pro  ../inc/cretab.def \
  ../inc/sce.pro  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
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
  /usr/include/sys/errno.h  /usr/include/errno.h  ../inc/keys.def

list_lib.$(OBJEXT) :  \
  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h  /usr/include/fcntl.h \
  /usr/include/ctype.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/string.h  /usr/include/memory.h  /usr/include/malloc.h \
  ../../include/tools.h  /opt/ingr/include/UMS.h  ../inc/att.def \
  ../inc/linfld.def  ../inc/trm.def  ../inc/reserve.def  ../inc/operator.def \
  ../inc/operand.def  ../inc/format.def  ../inc/temptyp.def \
  ../inc/options.def  ../inc/sort.def  ../inc/dba_msg.h  ../inc/screrr.def \
  ../inc/smm.def  ../inc/script.def  ../inc/forms.def  ../inc/gdg_type.def \
  ../inc/gadgets.def  ../inc/dba.def  ../inc/dbforms.pro  ../inc/dbformsc.pro \
  ../inc/dbnuc.pro  ../inc/dload.pro  ../inc/gui.pro  ../inc/mb.pro \
  ../inc/nfm.pro  ../inc/nucleus.pro  ../inc/private.pro  ../inc/rb.pro \
  ../inc/rbc.pro  ../inc/report.pro  ../inc/script.pro  ../inc/ustn.pro \
  ../inc/debug.pro  ../inc/cretab.def  ../inc/sce.pro \
  /opt/ingr/include/FSTypes.h  /opt/ingr/include/FS.h \
  /opt/ingr/xformsdp/xfi/include/XFIproto_pub.h  ../inc/x.pro  ../inc/xdv.pro \
  ../inc/clipper.pro  ../inc/dde.pro  ../inc/wforms.pro  ../inc/v_gui.pro \
  ../inc/v_pub.pro  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/MI.h \
  /opt/ingr/xformsdp/xfi/include/FIproto_pub.h  ../inc/n_dba.pro \
  ../inc/dba_g.def  ../inc/dba_g_s.def  ../inc/raster.pro \
  ../inc/rasnodll.pro  ../inc/dba_dmc.pro  ../inc/dba_red.pro \
  ../inc/win16.pro  ../inc/windows.pro  ../inc/win32.pro  ../inc/unix.pro \
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  ../inc/dba_err.h  ../inc/dbadev.h  ../inc/dmalloc.def

search_str.$(OBJEXT) : 



