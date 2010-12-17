.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
COMBINE_FLAG=-DCOMBINED_MAKE
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=dba_nfm_calls.a
OSFLAG=-Dsolaris
MISCFLAG=-Disl
RISFLAGS=-DRIS5
TARGSTR=
CFLAGS=-Xa 	-I../inc	-I../../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= c_rdba_stub.$(OBJEXT) d_pnt_struct.$(OBJEXT) drg_graf.$(OBJEXT) \
 risdvw_dummy.$(OBJEXT) d_dmg_init.$(OBJEXT) d_proc_event.$(OBJEXT) \
 drg_menu.$(OBJEXT) risrpt_dummy.$(OBJEXT) d_er_mb.$(OBJEXT) d_rb.$(OBJEXT) \
 drg_nfm.$(OBJEXT) rpt_dummy.$(OBJEXT) d_erase_rb.$(OBJEXT) \
 d_run_select.$(OBJEXT) dummy_link.$(OBJEXT) rptrt_dummy.$(OBJEXT) \
 d_init_bld.$(OBJEXT) d_send_expos.$(OBJEXT) g_stub.$(OBJEXT) \
 run_dummy.$(OBJEXT) d_logkbd.$(OBJEXT) d_write_menu.$(OBJEXT) \
 mc_stub.$(OBJEXT) scr_dummy.$(OBJEXT) d_mb.$(OBJEXT) dbn_stub.$(OBJEXT) \
 no_mcsl.$(OBJEXT) scr_dv_dummy.$(OBJEXT) d_p_mb_opts.$(OBJEXT) \
 dld_dummy.$(OBJEXT) no_ris.$(OBJEXT) script_dummy.$(OBJEXT) \
 d_p_rb_opts.$(OBJEXT) dmgv_dummy.$(OBJEXT) rdvwrt_dummy.$(OBJEXT) \
 w_dummy.$(OBJEXT) d_paint_temp.$(OBJEXT) drg_form.$(OBJEXT) \
 reg_dummy.$(OBJEXT) x_dummy.$(OBJEXT)

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


c_rdba_stub.$(OBJEXT) : 

d_pnt_struct.$(OBJEXT) : 

drg_graf.$(OBJEXT) : 

risdvw_dummy.$(OBJEXT) : 

d_dmg_init.$(OBJEXT) : 

d_proc_event.$(OBJEXT) : 

drg_menu.$(OBJEXT) : 

risrpt_dummy.$(OBJEXT) : 

d_er_mb.$(OBJEXT) : 

d_rb.$(OBJEXT) : 

drg_nfm.$(OBJEXT) : 

rpt_dummy.$(OBJEXT) : 

d_erase_rb.$(OBJEXT) : 

d_run_select.$(OBJEXT) : 

dummy_link.$(OBJEXT) : 

rptrt_dummy.$(OBJEXT) : 

d_init_bld.$(OBJEXT) : 

d_send_expos.$(OBJEXT) : 

g_stub.$(OBJEXT) :  \
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

run_dummy.$(OBJEXT) : 

d_logkbd.$(OBJEXT) : 

d_write_menu.$(OBJEXT) : 

mc_stub.$(OBJEXT) : 

scr_dummy.$(OBJEXT) : 

d_mb.$(OBJEXT) : 

dbn_stub.$(OBJEXT) :  \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../inc/dbn_defs.h  ../inc/dbn.h

no_mcsl.$(OBJEXT) : 

scr_dv_dummy.$(OBJEXT) : 

d_p_mb_opts.$(OBJEXT) : 

dld_dummy.$(OBJEXT) :  \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h

no_ris.$(OBJEXT) : 

script_dummy.$(OBJEXT) : 

d_p_rb_opts.$(OBJEXT) : 

dmgv_dummy.$(OBJEXT) : 

rdvwrt_dummy.$(OBJEXT) : 

w_dummy.$(OBJEXT) : 

d_paint_temp.$(OBJEXT) : 

drg_form.$(OBJEXT) : 

reg_dummy.$(OBJEXT) : 

x_dummy.$(OBJEXT) : 



