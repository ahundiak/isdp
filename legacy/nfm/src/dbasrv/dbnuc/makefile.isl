.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
COMBINE_FLAG=-DCOMBINED_MAKE
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libdbnuc.a
OSFLAG=-Dsolaris
RISFLAGS=-DRIS5
MISCFLAG=-Disl
TARGSTR=
CFLAGS=-Xa 	-I../inc	-I../../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= add_att.$(OBJEXT) dba_check.$(OBJEXT) get_attnam.$(OBJEXT) \
 rd_mscols.$(OBJEXT) add_column.$(OBJEXT) dbd_add_qry.$(OBJEXT) \
 get_atyp.$(OBJEXT) read_schema.$(OBJEXT) add_ent.$(OBJEXT) \
 dbd_init_qry.$(OBJEXT) get_code_txt.$(OBJEXT) reg_dbnu.$(OBJEXT) \
 add_find.$(OBJEXT) dbd_ris_err.$(OBJEXT) get_commit.$(OBJEXT) \
 replace_sch.$(OBJEXT) add_fnd_ptr.$(OBJEXT) dbd_schema.$(OBJEXT) \
 get_entnam.$(OBJEXT) s_addqry.$(OBJEXT) add_qry_str.$(OBJEXT) \
 dbd_select.$(OBJEXT) get_query.$(OBJEXT) s_dbnuc.$(OBJEXT) \
 add_schema.$(OBJEXT) dbd_table.$(OBJEXT) get_rel.$(OBJEXT) s_getcod.$(OBJEXT) \
 add_table.$(OBJEXT) decl_sch.$(OBJEXT) get_sqlc.$(OBJEXT) s_getqry.$(OBJEXT) \
 att_db.$(OBJEXT) del_att_ptr.$(OBJEXT) i_dbnuc.$(OBJEXT) s_select.$(OBJEXT) \
 attach_sch.$(OBJEXT) del_ent_ptr.$(OBJEXT) init_find.$(OBJEXT) \
 s_tabnum.$(OBJEXT) attached.$(OBJEXT) delete_table.$(OBJEXT) \
 init_tab_qry.$(OBJEXT) save_qry.$(OBJEXT) bld_att.$(OBJEXT) \
 desc_index.$(OBJEXT) join_info.$(OBJEXT) set_att_ptr.$(OBJEXT) \
 bld_ent.$(OBJEXT) double_quote.$(OBJEXT) key_column.$(OBJEXT) \
 set_catt.$(OBJEXT) bld_wher_txt.$(OBJEXT) ex_dbnuc.$(OBJEXT) \
 load_find.$(OBJEXT) set_ent_ptr.$(OBJEXT) branch.$(OBJEXT) f_dbnuc.$(OBJEXT) \
 load_rel.$(OBJEXT) set_sch_ptr.$(OBJEXT) build_where.$(OBJEXT) \
 flush_code.$(OBJEXT) mal_dbnu.$(OBJEXT) set_schent.$(OBJEXT) \
 chk_rel.$(OBJEXT) flush_schema.$(OBJEXT) nam_to_num.$(OBJEXT) \
 set_schlst.$(OBJEXT) chk_tab.$(OBJEXT) flush_table.$(OBJEXT) \
 open_sch.$(OBJEXT) set_table.$(OBJEXT) clr_schlst.$(OBJEXT) \
 format_chk.$(OBJEXT) parse_att.$(OBJEXT) single_quote.$(OBJEXT) \
 code_num.$(OBJEXT) g_colnam.$(OBJEXT) parse_ent.$(OBJEXT) \
 sprintf_spec.$(OBJEXT) codelist.$(OBJEXT) g_colnum.$(OBJEXT) \
 parse_relop.$(OBJEXT) sql_debug.$(OBJEXT) current_col.$(OBJEXT) \
 g_schnam.$(OBJEXT) parse_sch.$(OBJEXT) sqlerr.$(OBJEXT) cvt_date.$(OBJEXT) \
 g_schnum.$(OBJEXT) r_exec.$(OBJEXT) tb_alias.$(OBJEXT) cvt_in.$(OBJEXT) \
 g_tabnam.$(OBJEXT) r_prep_sql.$(OBJEXT) up_sqltype.$(OBJEXT) \
 cvt_out.$(OBJEXT) g_tabnum.$(OBJEXT) r_sql.$(OBJEXT) write_schema.$(OBJEXT)

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


add_att.$(OBJEXT) :   /usr/include/sys/stat.h  /usr/include/sys/fcntl.h \
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
  ../inc/dba.pro  ../inc/dbawin32.h  ../inc/dba_ext.h  ../inc/dba.ext

dba_check.$(OBJEXT) :  \
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

get_attnam.$(OBJEXT) :  \
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

rd_mscols.$(OBJEXT) :  \
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
  /usr/include/sys/feature_tests.h  /usr/include/string.h  ../inc/dmalloc.def \
  ../inc/cursor.def  /opt/ingr/include/ris.h \
  /opt/ingr/ris/risdp/include/sql.h

add_column.$(OBJEXT) :  \
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

dbd_add_qry.$(OBJEXT) :  \
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

get_atyp.$(OBJEXT) :  \
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

read_schema.$(OBJEXT) :  \
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
  /usr/include/sys/errno.h  /usr/include/errno.h  ../inc/dmalloc.def

add_ent.$(OBJEXT) :  \
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

dbd_init_qry.$(OBJEXT) :  \
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

get_code_txt.$(OBJEXT) :  \
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

reg_dbnu.$(OBJEXT) :  \
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
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def \
  /opt/ingr/include/ris.prt  /opt/ingr/ris/risdp/include/sql.h \
  /opt/ingr/include/RISlimits.h  /opt/ingr/include/rislimit.h \
  /opt/ingr/include/ris.h  /opt/ingr/include/RISprototype.h

add_find.$(OBJEXT) :  \
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

dbd_ris_err.$(OBJEXT) : 

get_commit.$(OBJEXT) : 

replace_sch.$(OBJEXT) :  \
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

add_fnd_ptr.$(OBJEXT) :  \
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

dbd_schema.$(OBJEXT) :  \
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

get_entnam.$(OBJEXT) :  \
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

s_addqry.$(OBJEXT) :  \
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

add_qry_str.$(OBJEXT) :  \
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

dbd_select.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/v_pub.pro  /usr/include/stdio.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
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
  ../inc/dmalloc.def  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  /usr/include/stdarg.h  /opt/ingr/ris/risdp/include/sql.h \
  /opt/ingr/include/ris.h  /opt/ingr/include/ris_err.h

get_query.$(OBJEXT) :  \
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

s_dbnuc.$(OBJEXT) :   /usr/include/sys/stat.h \
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

add_schema.$(OBJEXT) :   /usr/include/sys/stat.h \
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

dbd_table.$(OBJEXT) :  \
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

get_rel.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/keys.def  ../inc/dmalloc.def  /usr/include/sys/feature_tests.h \
  /usr/include/string.h

s_getcod.$(OBJEXT) :   /usr/include/sys/wait.h \
  /usr/include/stdlib.h  /usr/include/sys/stat.h  /usr/include/sys/fcntl.h \
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
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
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

add_table.$(OBJEXT) :  \
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

decl_sch.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/keys.def  /opt/ingr/include/ris.h  /opt/ingr/include/ris_err.h

get_sqlc.$(OBJEXT) :  \
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
  /opt/ingr/ris/risdp/include/sql.h  /opt/ingr/include/ris.h

s_getqry.$(OBJEXT) :  \
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

att_db.$(OBJEXT) :  \
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
  ../inc/keys.def  /opt/ingr/include/ris.h  /opt/ingr/include/ris_err.h \
  /opt/ingr/ris/risdp/include/sql.h

del_att_ptr.$(OBJEXT) :  \
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

i_dbnuc.$(OBJEXT) :  \
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
  ../inc/keys.def  /opt/ingr/include/ris.h

s_select.$(OBJEXT) :  \
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
  ../inc/screrr.def  ../inc/smm.def  ../inc/script.def  ../inc/dmalloc.def \
  /opt/ingr/include/ris.h  /opt/ingr/ris/risdp/include/sql.h

attach_sch.$(OBJEXT) :  \
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

del_ent_ptr.$(OBJEXT) :  \
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

init_find.$(OBJEXT) :  \
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

s_tabnum.$(OBJEXT) :   /usr/include/sys/stat.h \
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

attached.$(OBJEXT) :  \
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
  ../inc/cursor.def

delete_table.$(OBJEXT) :   /usr/include/sys/stat.h \
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

init_tab_qry.$(OBJEXT) :  \
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

save_qry.$(OBJEXT) :  \
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

bld_att.$(OBJEXT) :  \
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
  ../inc/cursor.def  ../inc/dmalloc.def  /opt/ingr/include/ris.h \
  /opt/ingr/ris/risdp/include/sql.h

desc_index.$(OBJEXT) :  \
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
  /opt/ingr/include/ris.h  /opt/ingr/ris/risdp/include/sql.h

join_info.$(OBJEXT) :  \
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

set_att_ptr.$(OBJEXT) :  \
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

bld_ent.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/dmalloc.def  ../inc/cursor.def  /opt/ingr/include/ris.h \
  /opt/ingr/include/ris_err.h  /opt/ingr/ris/risdp/include/sql.h

double_quote.$(OBJEXT) :  \
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

key_column.$(OBJEXT) :  \
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
  ../inc/cursor.def  /opt/ingr/include/ris.h  /opt/ingr/include/ris_err.h \
  /opt/ingr/include/rislimit.h  /opt/ingr/ris/risdp/include/sql.h \
  /opt/ingr/include/RISlimits.h

set_catt.$(OBJEXT) :   /usr/include/sys/stat.h \
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

bld_wher_txt.$(OBJEXT) :  \
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

ex_dbnuc.$(OBJEXT) :  \
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

load_find.$(OBJEXT) :  \
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

set_ent_ptr.$(OBJEXT) :   /usr/include/sys/stat.h \
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

branch.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/v_pub.pro  /usr/include/stdio.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
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
  ../inc/keys.def  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  /usr/include/stdarg.h  /opt/ingr/ris/risdp/include/sql.h \
  /opt/ingr/include/ris.h  /opt/ingr/include/ris_err.h

f_dbnuc.$(OBJEXT) :  \
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

load_rel.$(OBJEXT) :  \
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
  ../inc/dmalloc.def  ../inc/keys.def

set_sch_ptr.$(OBJEXT) :  \
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

build_where.$(OBJEXT) :  \
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

flush_code.$(OBJEXT) :  \
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

mal_dbnu.$(OBJEXT) :  \
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

set_schent.$(OBJEXT) :   /usr/include/sys/stat.h \
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

chk_rel.$(OBJEXT) :  \
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

flush_schema.$(OBJEXT) :  \
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
  /opt/ingr/include/ris.h  /opt/ingr/ris/risdp/include/sql.h

nam_to_num.$(OBJEXT) :  \
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

set_schlst.$(OBJEXT) :   /usr/include/sys/stat.h \
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

chk_tab.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/cursor.def  /opt/ingr/include/ris.h \
  /opt/ingr/ris/risdp/include/sql.h

flush_table.$(OBJEXT) :  \
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
  /opt/ingr/include/ris.h  /opt/ingr/ris/risdp/include/sql.h

open_sch.$(OBJEXT) :  \
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
  ../inc/keys.def  /opt/ingr/include/ris.h  /opt/ingr/ris/risdp/include/sql.h

set_table.$(OBJEXT) :  \
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

clr_schlst.$(OBJEXT) :   /usr/include/sys/stat.h \
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

format_chk.$(OBJEXT) :  \
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

parse_att.$(OBJEXT) :  \
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

single_quote.$(OBJEXT) :  \
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

code_num.$(OBJEXT) :  \
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

g_colnam.$(OBJEXT) :  \
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

parse_ent.$(OBJEXT) :  \
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

sprintf_spec.$(OBJEXT) :  \
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

codelist.$(OBJEXT) :   /usr/include/sys/stat.h \
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
  ../inc/cursor.def  ../inc/dmalloc.def  /opt/ingr/include/ris.h \
  /opt/ingr/ris/risdp/include/sql.h

g_colnum.$(OBJEXT) :  \
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

parse_relop.$(OBJEXT) :  \
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

sql_debug.$(OBJEXT) :  \
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

current_col.$(OBJEXT) :  \
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

g_schnam.$(OBJEXT) :  \
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

parse_sch.$(OBJEXT) :  \
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

sqlerr.$(OBJEXT) :  \
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
  /opt/ingr/include/ris.h  /opt/ingr/ris/risdp/include/sql.h

cvt_date.$(OBJEXT) :  \
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
  /opt/ingr/include/ris.prt  /opt/ingr/ris/risdp/include/sql.h \
  /opt/ingr/include/RISlimits.h  /opt/ingr/include/rislimit.h \
  /opt/ingr/include/ris.h  /opt/ingr/include/RISprototype.h

g_schnum.$(OBJEXT) :  \
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

r_exec.$(OBJEXT) :  \
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
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h

tb_alias.$(OBJEXT) :   /usr/include/sys/stat.h \
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

cvt_in.$(OBJEXT) :   /usr/include/sys/stat.h \
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

g_tabnam.$(OBJEXT) :  \
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

r_prep_sql.$(OBJEXT) :  \
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

up_sqltype.$(OBJEXT) :  \
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
  /opt/ingr/include/ris.h  /opt/ingr/ris/risdp/include/sql.h

cvt_out.$(OBJEXT) :  \
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

g_tabnum.$(OBJEXT) :  \
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

r_sql.$(OBJEXT) :  \
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

write_schema.$(OBJEXT) :   /usr/include/sys/stat.h \
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



