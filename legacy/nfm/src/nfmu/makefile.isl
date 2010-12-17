.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmu.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMadd_item.$(OBJEXT) NFMadd_sa.$(OBJEXT) NFMall_debug.$(OBJEXT) \
 NFMcan_item.$(OBJEXT) NFMcan_proj.$(OBJEXT) NFMcan_set.$(OBJEXT) \
 NFMcancoitem.$(OBJEXT) NFMcancoset.$(OBJEXT) NFMcco_item.$(OBJEXT) \
 NFMcco_set.$(OBJEXT) NFMchg_pwd.$(OBJEXT) NFMci_item.$(OBJEXT) \
 NFMci_qtools.$(OBJEXT) NFMci_satool.$(OBJEXT) NFMci_set.$(OBJEXT) \
 NFMci_tools.$(OBJEXT) NFMciitem.$(OBJEXT) NFMciset.$(OBJEXT) \
 NFMclient.$(OBJEXT) NFMco_item.$(OBJEXT) NFMco_qtools.$(OBJEXT) \
 NFMco_set.$(OBJEXT) NFMco_tools.$(OBJEXT) NFMcoitem.$(OBJEXT) \
 NFMcoset.$(OBJEXT) NFMcp_item.$(OBJEXT) NFMcp_item_n.$(OBJEXT) \
 NFMcp_set.$(OBJEXT) NFMcpitmfile.$(OBJEXT) NFMcpsetfile.$(OBJEXT) \
 NFMdef_query.$(OBJEXT) NFMdeffile.$(OBJEXT) NFMdefmember.$(OBJEXT) \
 NFMdel_dev.$(OBJEXT) NFMdel_item.$(OBJEXT) NFMdel_query.$(OBJEXT) \
 NFMdel_user.$(OBJEXT) NFMdelcpfile.$(OBJEXT) NFMfl_tools.$(OBJEXT) \
 NFMflag_item.$(OBJEXT) NFMflag_proj.$(OBJEXT) NFMflag_set.$(OBJEXT) \
 NFMftrcii.$(OBJEXT) NFMftrcis.$(OBJEXT) NFMftrcp.$(OBJEXT) \
 NFMftrsave.$(OBJEXT) NFMgetfile.$(OBJEXT) NFMgetmem.$(OBJEXT) \
 NFMgetpre.$(OBJEXT) NFMgetthe.$(OBJEXT) NFMgetwor.$(OBJEXT) \
 NFMghilight.$(OBJEXT) NFMgkeywords.$(OBJEXT) NFMitem_lock.$(OBJEXT) \
 NFMiteminfo1.$(OBJEXT) NFMlogin.$(OBJEXT) NFMmaint.$(OBJEXT) \
 NFMmake_tran.$(OBJEXT) NFMn_usrdef.$(OBJEXT) NFMnew_tools.$(OBJEXT) \
 NFMo_login.$(OBJEXT) NFMplot_item.$(OBJEXT) NFMplot_set.$(OBJEXT) \
 NFMpost_lg.$(OBJEXT) NFMprint_gp.$(OBJEXT) NFMqa_item.$(OBJEXT) \
 NFMqa_item_n.$(OBJEXT) NFMqry_can.$(OBJEXT) NFMqry_flag.$(OBJEXT) \
 NFMqry_set.$(OBJEXT) NFMresetinfo.$(OBJEXT) NFMret_query.$(OBJEXT) \
 NFMsave_item.$(OBJEXT) NFMsave_set.$(OBJEXT) NFMset.$(OBJEXT) \
 NFMset_func.$(OBJEXT) NFMset_mem.$(OBJEXT) NFMsetfunc1.$(OBJEXT) \
 NFMsetgflag.$(OBJEXT) NFMsetrol_bk.$(OBJEXT) NFMsignoff.$(OBJEXT) \
 NFMto_state.$(OBJEXT) NFMupd_item.$(OBJEXT) NFMupd_mem.$(OBJEXT) \
 NFMuser_def.$(OBJEXT) NFMusr_del.$(OBJEXT) NFMval_info.$(OBJEXT) \
 NFMvalid.$(OBJEXT)

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


NFMadd_item.$(OBJEXT) :   ../include/machine.h  ../include/NFMdb.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/WFstruct.h

NFMadd_sa.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMall_debug.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h

NFMcan_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMcan_proj.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMcan_set.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MSGstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMcancoitem.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/MSGstruct.h  ../include/NFMfto_buf.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h

NFMcancoset.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/MSGstruct.h  ../include/NFMfto_buf.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/WFstruct.h

NFMcco_item.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h

NFMcco_set.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h  ../include/NFMfile.h

NFMchg_pwd.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h

NFMci_item.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMlocks.h \
  ../include/NFMfile.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/times.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h  ../include/WFstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr_def.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MSGstruct.h

NFMci_qtools.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMattr_def.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMstruct.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMci_satool.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFMattr_def.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/MSGstruct.h

NFMci_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMlocks.h  ../include/NFMfile.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/MEMstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMci_tools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h  ../include/NFMfile.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFMattr_def.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMciitem.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/NFMfto_buf.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/UTIerrordef.h \
  ../include/NFMschema.h  ../include/NFMuinc.h  ../include/NFMuglobal.h \
  ../include/NFMuindexes.h

NFMciset.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/NFMfto_buf.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/UTIerrordef.h \
  ../include/NFMschema.h  ../include/NFMuinc.h

NFMclient.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/errno.h \
  /usr/include/sys/stat.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMU.h  /usr/include/unistd.h \
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
  /usr/include/sys/time.h  /usr/include/signal.h

NFMco_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMlocks.h \
  ../include/NFMfile.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/times.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/WFstruct.h  ../include/DEBUG.h

NFMco_qtools.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMattr_def.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MSGstruct.h

NFMco_set.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMlocks.h  ../include/NFMfile.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMco_tools.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMattr_def.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/MSGstruct.h

NFMcoitem.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/NFMfto_buf.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMproto.h

NFMcoset.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/NFMfto_buf.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMcp_item.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMlocks.h \
  ../include/NFMfile.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/times.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/machparam.h \
  /usr/include/sys/unistd.h  /usr/include/sys/param.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/WFstruct.h  ../include/DEBUG.h

NFMcp_item_n.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/SQLstruct.h  /usr/include/stdarg.h \
  ../include/ERRerrordef.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h  ../include/WFstruct.h  ../include/NFMschema.h \
  ../include/NFMfto_buf.h  ../include/WFcommands.h  ../include/NFMitemfiles.h \
  /usr/include/memory.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h

NFMcp_set.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMlocks.h  ../include/NFMfile.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMcpitmfile.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/NFMfto_buf.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMcpsetfile.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/NFMfto_buf.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMdef_query.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMapi.h  ../include/NFMmach_id.h  /usr/include/string.h \
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

NFMdeffile.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMitemfiles.h  ../include/NFMapi.h  ../include/NFMitems.h \
  ../include/NFMfto_buf.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/WFstruct.h  ../include/UTIerrordef.h

NFMdefmember.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMdel_dev.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMdel_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMU.h \
  ../include/NFMfto_buf.h  ../include/NFMschema.h  ../include/WFstruct.h \
  ../include/UTIerrordef.h

NFMdel_query.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h

NFMdel_user.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMdelcpfile.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMitems.h \
  ../include/MEMstruct.h  ../include/NFMitemfiles.h  ../include/NFMschema.h \
  ../include/NFMfto_buf.h

NFMfl_tools.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMschema.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMflag_item.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMflag_proj.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMflag_set.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMschema.h

NFMftrcii.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h

NFMftrcis.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h

NFMftrcp.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h

NFMftrsave.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h

NFMgetfile.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h

NFMgetmem.$(OBJEXT) :  \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMitemfiles.h \
  ../include/NFMschema.h  ../include/NFMitems.h

NFMgetpre.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMapi.h  ../include/NFMitemfiles.h  ../include/NFMschema.h \
  ../include/NFMitems.h  ../include/UTIerrordef.h

NFMgetthe.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFTftr.h  ../include/UTIerrordef.h

NFMgetwor.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMitemfiles.h  ../include/NFMschema.h  ../include/NFMitems.h \
  ../include/UTIerrordef.h

NFMghilight.$(OBJEXT) :   ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMitems.h \
  ../include/NFMitemfiles.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/UTIerrordef.h

NFMgkeywords.$(OBJEXT) :  \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMschema.h \
  ../include/NFMitems.h  ../include/NFMitemfiles.h  ../include/MEMstruct.h \
  ../include/UTIerrordef.h

NFMitem_lock.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h

NFMiteminfo1.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMlogin.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMU.h \
  ../include/NFMschema.h  ../include/NFMfto_buf.h  ../include/UTIerrordef.h

NFMmaint.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NFMdb.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMschema.h

NFMmake_tran.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h

NFMn_usrdef.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMqlu.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h

NFMnew_tools.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMo_login.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLstruct.h  ../include/NFMstruct.h  ../include/NFMUproto.h \
  ../include/NFMU.h  /usr/include/pwd.h  /usr/include/sys/auxv.h \
  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/sys/copyops.h  /usr/include/sys/watchpoint.h \
  /usr/include/sys/segment.h  /usr/include/sys/proc.h \
  /usr/include/sys/procset.h  /usr/include/sys/wait.h  /usr/include/stdlib.h \
  /usr/include/string.h  /usr/include/ctype.h  /usr/include/sys/stat.h \
  /usr/include/sys/statfs.h  /usr/include/sys/ustat.h  /usr/include/ustat.h \
  /usr/include/sys/utsname.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/uio.h  /usr/include/sys/resource.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/kstat.h \
  /usr/include/sys/buf.h  /usr/include/sys/vnode.h  /usr/include/sys/poll.h \
  /usr/include/sys/strmdep.h  /usr/include/sys/cred.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/lwp.h \
  /usr/include/sys/klwp.h  /usr/include/sys/machparam.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/sys/unistd.h \
  /usr/include/sys/reg.h  /usr/include/sys/regset.h \
  /usr/include/sys/ucontext.h  /usr/include/sys/signal.h \
  /usr/include/vm/page.h  /usr/include/sys/thread.h \
  /usr/include/sys/semaphore.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/int_types.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/sys/model.h  /usr/include/sys/stream.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/byteorder.h \
  /usr/include/netinet/in.h  /usr/include/netdb.h  ../include/NFMfto_buf.h \
  ../include/DEBUG.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFMxferstrct.h  ../include/NDXstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMxferextrn.h \
  ../include/NFMxfer_def.h  ../include/NFMsysstruct.h \
  ../include/NFMsysextern.h  ../include/NETnetstruct.h \
  ../include/NETnetextern.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/NETdef.h  ../include/NETstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/TFERproto.h  ../include/NFMTproto.h  ../include/SYSTproto.h \
  ../include/MEMproto.h  ../include/NETproto.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/NFMf_xferinc.h

NFMplot_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMitems.h \
  ../include/NFMfto_buf.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/WFstruct.h

NFMplot_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMitemfiles.h \
  ../include/NFMitems.h  ../include/NFMfto_buf.h  ../include/NFMschema.h \
  ../include/WFstruct.h

NFMpost_lg.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h

NFMprint_gp.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/feature_tests.h  /usr/include/string.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h

NFMqa_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMU.h \
  ../include/NFMschema.h  ../include/WFstruct.h

NFMqa_item_n.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMU.h \
  ../include/NFMschema.h  ../include/WFstruct.h

NFMqry_can.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h

NFMqry_flag.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMflag.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMqry_set.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h

NFMresetinfo.$(OBJEXT) :   ../include/machine.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFMitemfiles.h  ../include/NFMschema.h  ../include/NFMitems.h \
  ../include/MEMstruct.h

NFMret_query.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/DEBUG.h \
  ../include/NFMmach_id.h

NFMsave_item.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/NFMfto_buf.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFTftr.h  ../include/UTIerrordef.h

NFMsave_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/NFMfto_buf.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFTftr.h  ../include/UTIerrordef.h

NFMset.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h  ../include/NFMapi.h \
  ../include/NFMitems.h  ../include/WFstruct.h  ../include/MSGstruct.h \
  ../include/NFMfto_buf.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMset_func.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMattr_def.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NFMfile.h

NFMset_mem.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h

NFMsetfunc1.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMattr_def.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NFMfile.h

NFMsetgflag.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMitems.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMitemfiles.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMsetrol_bk.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h

NFMsignoff.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h

NFMto_state.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/WFstruct.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMschema.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h \
  ../include/NFIerrordef.h  ../include/NFFdef.h  /opt/ingr/include/UMS.h

NFMupd_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMlocks.h \
  ../include/NFMfto_buf.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/SQLstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMU.h

NFMupd_mem.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMuser_def.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/NFMdb.h  ../include/NFMdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMusr_del.$(OBJEXT) :   ../include/machine.h

NFMval_info.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMdef.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h

NFMvalid.$(OBJEXT) :  \
  ../include/machine.h



