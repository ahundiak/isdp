.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
COMBINE_FLAG=-DCOMBINED_MAKE
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmfms.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= FMacl_t.$(OBJEXT) FMact_data.$(OBJEXT) FMactivate.$(OBJEXT) \
 FMactive_w.$(OBJEXT) FMactiv_src.$(OBJEXT) FMad_s_users.$(OBJEXT) \
 FMadd_acl.$(OBJEXT) FMadd_files.$(OBJEXT) FMadd_mem.$(OBJEXT) \
 FMcan_item.$(OBJEXT) FMcan_itmflg.$(OBJEXT) FMcan_prjflg.$(OBJEXT) \
 FMcan_set.$(OBJEXT) FMcan_setflg.$(OBJEXT) FMcat.$(OBJEXT) \
 FMcat_map.$(OBJEXT) FMcheckin.$(OBJEXT) FMcheckout.$(OBJEXT) \
 FMchg_cat.$(OBJEXT) FMchg_files.$(OBJEXT) FMchg_i_wf.$(OBJEXT) \
 FMchg_node.$(OBJEXT) FMchg_tab.$(OBJEXT) FMcommands.$(OBJEXT) \
 FMcopy.$(OBJEXT) FMcopy_acl.$(OBJEXT) FMcp_files.$(OBJEXT) \
 FMd_choose.$(OBJEXT) FMdebug.$(OBJEXT) FMdef_search.$(OBJEXT) \
 FMdef_sort.$(OBJEXT) FMdel_files.$(OBJEXT) FMdel_mem.$(OBJEXT) \
 FMdelete.$(OBJEXT) FMdisplays.$(OBJEXT) FMenter.$(OBJEXT) FMexit.$(OBJEXT) \
 FMflag_item.$(OBJEXT) FMflag_proj.$(OBJEXT) FMflag_set.$(OBJEXT) \
 FMfunctions.$(OBJEXT) FMglobals.$(OBJEXT) FMitem.$(OBJEXT) \
 FMload_wf.$(OBJEXT) FMlock.$(OBJEXT) FMlogin.$(OBJEXT) FMlogout.$(OBJEXT) \
 FMmaint.$(OBJEXT) FMmake_trans.$(OBJEXT) FMmod_acl.$(OBJEXT) FMnode.$(OBJEXT) \
 FMpasswd.$(OBJEXT) FMplot.$(OBJEXT) FMproj_map.$(OBJEXT) FMproj_mem.$(OBJEXT) \
 FMproject.$(OBJEXT) FMpur_vers.$(OBJEXT) FMrap.$(OBJEXT) FMrev_env.$(OBJEXT) \
 FMrev_search.$(OBJEXT) FMrev_sort.$(OBJEXT) FMreview.$(OBJEXT) \
 FMroll_vers.$(OBJEXT) FMsa.$(OBJEXT) FMsearch.$(OBJEXT) FMsearch_t.$(OBJEXT) \
 FMset.$(OBJEXT) FMset_copy.$(OBJEXT) FMset_in.$(OBJEXT) FMset_out.$(OBJEXT) \
 FMsign_users.$(OBJEXT) FMsignoff.$(OBJEXT) FMsort.$(OBJEXT) \
 FMsqlquery.$(OBJEXT) FMsqlstmt.$(OBJEXT) FMsr_a_cat.$(OBJEXT) \
 FMsr_a_cat_p.$(OBJEXT) FMstate.$(OBJEXT) FMsv_files.$(OBJEXT) \
 FMtools.$(OBJEXT) FMupd_item.$(OBJEXT) FMuser.$(OBJEXT) FMutilities.$(OBJEXT) \
 FMwh_used.$(OBJEXT)

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


FMacl_t.$(OBJEXT) :   ../include/machine.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMact_data.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

FMactivate.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h  ../include/NFMdisplays.h \
  /opt/ingr/include/UMS.h  ../include/NFMtitles.h

FMactive_w.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h  ../include/NFMdisplays.h \
  /opt/ingr/include/UMS.h  ../include/NFMtitles.h

FMactiv_src.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h  ../include/NFMdisplays.h \
  /opt/ingr/include/UMS.h  ../include/NFMtitles.h

FMad_s_users.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

FMadd_acl.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h

FMadd_files.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMadd_mem.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFcommands.h

FMcan_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFcommands.h

FMcan_itmflg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMcan_prjflg.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/DEBUG.h

FMcan_set.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/DEBUG.h  ../include/WFcommands.h

FMcan_setflg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/DEBUG.h

FMcat.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h  ../include/NFMtitles.h \
  ../include/NFMdisplays.h  /opt/ingr/include/UMS.h

FMcat_map.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h

FMcheckin.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMcheckout.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMchg_cat.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h

FMchg_files.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMchg_i_wf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMchg_node.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMchg_tab.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h

FMcommands.$(OBJEXT) :   ../include/machine.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdef.h  ../include/SCdata.h  ../include/SCstruct.h

FMcopy.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMcopy_acl.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMdisplays.h  ../include/NFMRlist.h \
  ../include/NFMtitles.h  /opt/ingr/include/UMS.h  ../include/WFcommands.h

FMcp_files.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMRlist.h \
  ../include/NFMtitles.h  /opt/ingr/include/UMS.h  ../include/NFMdisplays.h

FMd_choose.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdisplays.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h

FMdebug.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/DEBUG.h

FMdef_search.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/tools.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMdef_sort.$(OBJEXT) :   ../include/machine.h \
  /usr/include/string.h  ../include/tools.h  ../include/UNIX_or_VMS.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

FMdel_files.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

FMdel_mem.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMdelete.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h  ../include/NFMdisplays.h \
  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMdisplays.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMdisplays.h  ../include/NFMRlist.h \
  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMenter.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMexit.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMflag_item.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMflag_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NDXstruct.h

FMflag_set.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMfunctions.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFIerrordef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NDXstruct.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/SCextern.h  ../include/NFMRlist.h \
  ../include/NFMdisplays.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMglobals.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h

FMitem.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMdisplays.h  ../include/NFMRlist.h \
  ../include/NFMtitles.h  /opt/ingr/include/UMS.h  ../include/WFcommands.h

FMload_wf.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NDXstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

FMlock.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NDXstruct.h

FMlogin.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMlogout.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMmaint.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

FMmake_trans.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMmod_acl.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h

FMnode.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMpasswd.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NDXstruct.h

FMplot.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMproj_map.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMproj_mem.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  ../include/NFMRlist.h  ../include/NFMdisplays.h

FMproject.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NDXstruct.h  ../include/NFMRlist.h \
  ../include/NFMdisplays.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMpur_vers.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h  ../include/NFMdisplays.h \
  ../include/NFMtitles.h  /opt/ingr/include/UMS.h  ../include/WFcommands.h

FMrap.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/SCrap.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMrev_env.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMrev_search.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMrev_sort.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMreview.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NDXstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

FMroll_vers.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMRlist.h  ../include/NFMdisplays.h

FMsa.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMsearch.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h

FMsearch_t.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/NFMdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRlist.h  ../include/NFMporttypes.h

FMset.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NDXstruct.h

FMset_copy.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMset_in.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdef.h \
  ../include/SCdata.h  ../include/SCstruct.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMset_out.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMsign_users.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

FMsignoff.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  /usr/include/sys/euc.h \
  /usr/include/euc.h  /usr/include/ctype.h  /usr/include/stddef.h \
  /usr/include/wchar.h  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NDXstruct.h  ../include/DEBUG.h

FMsort.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/NFMporttypes.h

FMsqlquery.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NDXstruct.h  ../include/DEBUG.h

FMsqlstmt.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NDXstruct.h  ../include/DEBUG.h

FMsr_a_cat.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMsr_a_cat_p.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMstate.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NDXstruct.h  ../include/DEBUG.h

FMsv_files.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/WFcommands.h  ../include/NFMdisplays.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h

FMtools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/euc.h  /usr/include/euc.h  /usr/include/ctype.h \
  /usr/include/stddef.h  /usr/include/wchar.h  /usr/include/widec.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/termios.h \
  /usr/include/sys/termio.h  /usr/include/termio.h  /usr/include/sgtty.h \
  /usr/include/unctrl.h  /usr/include/curses.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMdef.h

FMupd_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFIerrordef.h

FMuser.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

FMutilities.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFIerrordef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/UTIerrordef.h

FMwh_used.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/ttydev.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdata.h \
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h



