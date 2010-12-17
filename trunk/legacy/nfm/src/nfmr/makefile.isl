.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmr.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMRacl_t.$(OBJEXT) NFMRadd_acl.$(OBJEXT) NFMRadd_d_wa.$(OBJEXT) \
 NFMRadd_item.$(OBJEXT) NFMRadd_node.$(OBJEXT) NFMRadd_proj.$(OBJEXT) \
 NFMRadd_sa.$(OBJEXT) NFMRadd_user.$(OBJEXT) NFMRcan_iflg.$(OBJEXT) \
 NFMRcan_item.$(OBJEXT) NFMRcan_pflg.$(OBJEXT) NFMRcan_set.$(OBJEXT) \
 NFMRcan_sflg.$(OBJEXT) NFMRcat_map.$(OBJEXT) NFMRcat_t.$(OBJEXT) \
 NFMRchg_cat.$(OBJEXT) NFMRchg_node.$(OBJEXT) NFMRchg_proj.$(OBJEXT) \
 NFMRchg_pwd.$(OBJEXT) NFMRchg_sa.$(OBJEXT) NFMRchg_tab.$(OBJEXT) \
 NFMRchg_tmp.$(OBJEXT) NFMRchg_user.$(OBJEXT) NFMRci_item.$(OBJEXT) \
 NFMRci_set.$(OBJEXT) NFMRclass_t.$(OBJEXT) NFMRclient.$(OBJEXT) \
 NFMRcmd_t.$(OBJEXT) NFMRco_item.$(OBJEXT) NFMRco_set.$(OBJEXT) \
 NFMRconnect.$(OBJEXT) NFMRcopy_acl.$(OBJEXT) NFMRcp_item.$(OBJEXT) \
 NFMRcp_set.$(OBJEXT) NFMRcr_cat.$(OBJEXT) NFMRcr_tab.$(OBJEXT) \
 NFMRcr_tmp.$(OBJEXT) NFMRd_cfile.$(OBJEXT) NFMRdates.$(OBJEXT) \
 NFMRdbg_str.$(OBJEXT) NFMRdebug.$(OBJEXT) NFMRdel_cat.$(OBJEXT) \
 NFMRdel_item.$(OBJEXT) NFMRdel_lab.$(OBJEXT) NFMRdel_node.$(OBJEXT) \
 NFMRdel_proj.$(OBJEXT) NFMRdel_sa.$(OBJEXT) NFMRdel_user.$(OBJEXT) \
 NFMRdisplays.$(OBJEXT) NFMRerr_buff.$(OBJEXT) NFMRerr_load.$(OBJEXT) \
 NFMRerror.$(OBJEXT) NFMRfile_inf.$(OBJEXT) NFMRflg_item.$(OBJEXT) \
 NFMRflg_proj.$(OBJEXT) NFMRflg_set.$(OBJEXT) NFMRget_bulk.$(OBJEXT) \
 NFMRget_udef.$(OBJEXT) NFMRglobals.$(OBJEXT) NFMRitem_t.$(OBJEXT) \
 NFMRlItmTape.$(OBJEXT) NFMRlSaveset.$(OBJEXT) NFMRl_arch.$(OBJEXT) \
 NFMRl_back.$(OBJEXT) NFMRl_del.$(OBJEXT) NFMRl_item_s.$(OBJEXT) \
 NFMRl_rstr.$(OBJEXT) NFMRlfm.$(OBJEXT) NFMRload_wf.$(OBJEXT) \
 NFMRlock.$(OBJEXT) NFMRlog_in.$(OBJEXT) NFMRlogin.$(OBJEXT) \
 NFMRlogout.$(OBJEXT) NFMRmaint.$(OBJEXT) NFMRmod_acl.$(OBJEXT) \
 NFMRmod_i_wf.$(OBJEXT) NFMRnci_item.$(OBJEXT) NFMRnci_set.$(OBJEXT) \
 NFMRnco_item.$(OBJEXT) NFMRnco_set.$(OBJEXT) NFMRncp_item.$(OBJEXT) \
 NFMRncp_set.$(OBJEXT) NFMRnode_t.$(OBJEXT) NFMRplt_item.$(OBJEXT) \
 NFMRplt_set.$(OBJEXT) NFMRpr_util.$(OBJEXT) NFMRprog_t.$(OBJEXT) \
 NFMRproj_map.$(OBJEXT) NFMRproj_t.$(OBJEXT) NFMRq_cat.$(OBJEXT) \
 NFMRq_chgcat.$(OBJEXT) NFMRq_chgtab.$(OBJEXT) NFMRq_chgtmp.$(OBJEXT) \
 NFMRq_cit.$(OBJEXT) NFMRq_item.$(OBJEXT) NFMRq_loc.$(OBJEXT) \
 NFMRq_lop.$(OBJEXT) NFMRq_set.$(OBJEXT) NFMRq_tab.$(OBJEXT) \
 NFMRq_tmp.$(OBJEXT) NFMRq_util.$(OBJEXT) NFMRqry_can.$(OBJEXT) \
 NFMRqry_flag.$(OBJEXT) NFMRquery.$(OBJEXT) NFMRrebuild.$(OBJEXT) \
 NFMRrec_buff.$(OBJEXT) NFMRrev_st.$(OBJEXT) NFMRsa_t.$(OBJEXT) \
 NFMRset_inf.$(OBJEXT) NFMRset_st.$(OBJEXT) NFMRset_udef.$(OBJEXT) \
 NFMRsignoff.$(OBJEXT) NFMRsqlquery.$(OBJEXT) NFMRsqlstmt.$(OBJEXT) \
 NFMRsr_a_cat.$(OBJEXT) NFMRstate_t.$(OBJEXT) NFMRsv_files.$(OBJEXT) \
 NFMRsv_sfile.$(OBJEXT) NFMRtab_t.$(OBJEXT) NFMRterm.$(OBJEXT) \
 NFMRtic.$(OBJEXT) NFMRtools.$(OBJEXT) NFMRtrans.$(OBJEXT) \
 NFMRupd_proj.$(OBJEXT) NFMRupd_set.$(OBJEXT) NFMRupd_st.$(OBJEXT) \
 NFMRupdate.$(OBJEXT) NFMRuser_def.$(OBJEXT) NFMRuser_t.$(OBJEXT) \
 NFMRval_info.$(OBJEXT) NFMRvalid.$(OBJEXT) NFMRversions.$(OBJEXT) \
 NFMRwf_t.$(OBJEXT)

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


NFMRacl_t.$(OBJEXT) :   ../include/machine.h  ../include/NFIerrordef.h \
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

NFMRadd_acl.$(OBJEXT) :   ../include/machine.h \
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

NFMRadd_d_wa.$(OBJEXT) :   ../include/machine.h \
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

NFMRadd_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRadd_node.$(OBJEXT) :   ../include/machine.h \
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

NFMRadd_proj.$(OBJEXT) :   ../include/machine.h \
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

NFMRadd_sa.$(OBJEXT) :   ../include/machine.h \
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

NFMRadd_user.$(OBJEXT) :   ../include/machine.h \
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

NFMRcan_iflg.$(OBJEXT) :   ../include/machine.h \
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

NFMRcan_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRcan_pflg.$(OBJEXT) :   ../include/machine.h \
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

NFMRcan_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRcan_sflg.$(OBJEXT) :   ../include/machine.h \
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

NFMRcat_map.$(OBJEXT) :   ../include/machine.h \
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

NFMRcat_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_cat.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_node.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_proj.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_pwd.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_sa.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_tab.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_tmp.$(OBJEXT) :   ../include/machine.h \
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

NFMRchg_user.$(OBJEXT) :   ../include/machine.h \
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

NFMRci_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRci_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRclass_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRclient.$(OBJEXT) :   ../include/machine.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMRformats.h \
  /usr/include/sys/utsname.h  /usr/include/sys/stat.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  /usr/include/pwd.h  ../include/NFMporttypes.h

NFMRcmd_t.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRco_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRco_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRconnect.$(OBJEXT) :   ../include/machine.h \
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

NFMRcopy_acl.$(OBJEXT) :   ../include/machine.h \
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

NFMRcp_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRcp_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRcr_cat.$(OBJEXT) :   ../include/machine.h \
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

NFMRcr_tab.$(OBJEXT) :   ../include/machine.h \
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

NFMRcr_tmp.$(OBJEXT) :   ../include/machine.h \
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

NFMRd_cfile.$(OBJEXT) :   ../include/machine.h \
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

NFMRdates.$(OBJEXT) :   ../include/machine.h \
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

NFMRdbg_str.$(OBJEXT) :   ../include/machine.h \
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

NFMRdebug.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  ../include/NFMdef.h

NFMRdel_cat.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRdel_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRdel_lab.$(OBJEXT) :   ../include/machine.h \
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

NFMRdel_node.$(OBJEXT) :   ../include/machine.h \
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

NFMRdel_proj.$(OBJEXT) :   ../include/machine.h \
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

NFMRdel_sa.$(OBJEXT) :   ../include/machine.h \
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

NFMRdel_user.$(OBJEXT) :   ../include/machine.h \
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

NFMRdisplays.$(OBJEXT) :   ../include/machine.h \
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

NFMRerr_buff.$(OBJEXT) :   ../include/machine.h \
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

NFMRerr_load.$(OBJEXT) :   ../include/machine.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/UTIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMRerror.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MEMstruct.h \
  ../include/NETstruct.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h

NFMRfile_inf.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRflg_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRflg_proj.$(OBJEXT) :   ../include/machine.h \
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

NFMRflg_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRget_bulk.$(OBJEXT) :   ../include/machine.h \
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

NFMRget_udef.$(OBJEXT) :   ../include/machine.h \
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

NFMRglobals.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMRstruct.h

NFMRitem_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRlItmTape.$(OBJEXT) :   ../include/machine.h \
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

NFMRlSaveset.$(OBJEXT) :   ../include/machine.h \
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

NFMRl_arch.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  ../include/SCdef.h  ../include/UTIerrordef.h

NFMRl_back.$(OBJEXT) :  \
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
  ../include/NFMRextern.h  ../include/SCdef.h  ../include/UTIerrordef.h

NFMRl_del.$(OBJEXT) :  \
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
  ../include/NFMRextern.h  ../include/SCdef.h  ../include/UTIerrordef.h

NFMRl_item_s.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRl_rstr.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  ../include/SCdef.h  ../include/UTIerrordef.h

NFMRlfm.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRload_wf.$(OBJEXT) :   ../include/machine.h \
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

NFMRlock.$(OBJEXT) :   ../include/machine.h \
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

NFMRlog_in.$(OBJEXT) :   ../include/machine.h \
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

NFMRlogin.$(OBJEXT) :   ../include/machine.h \
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

NFMRlogout.$(OBJEXT) :   ../include/machine.h \
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

NFMRmaint.$(OBJEXT) :   ../include/machine.h \
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

NFMRmod_acl.$(OBJEXT) :   ../include/machine.h \
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

NFMRmod_i_wf.$(OBJEXT) :   ../include/machine.h \
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

NFMRnci_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRnci_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRnco_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRnco_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRncp_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRncp_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRnode_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRplt_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRplt_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRpr_util.$(OBJEXT) :   ../include/machine.h \
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

NFMRprog_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRproj_map.$(OBJEXT) :   ../include/machine.h \
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

NFMRproj_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_cat.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_chgcat.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_chgtab.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_chgtmp.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_cit.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_item.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_loc.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_lop.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_tab.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_tmp.$(OBJEXT) :   ../include/machine.h \
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

NFMRq_util.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  ../include/UTIerrordef.h

NFMRqry_can.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRqry_flag.$(OBJEXT) :   ../include/machine.h \
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

NFMRquery.$(OBJEXT) :   ../include/machine.h \
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

NFMRrebuild.$(OBJEXT) :   ../include/machine.h \
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

NFMRrec_buff.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  ../include/NFMdef.h

NFMRrev_st.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRsa_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRset_inf.$(OBJEXT) :   ../include/machine.h \
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

NFMRset_st.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  /opt/ingr/include/UMS.h

NFMRset_udef.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRsignoff.$(OBJEXT) :   ../include/machine.h \
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

NFMRsqlquery.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  ../include/NFMdef.h

NFMRsqlstmt.$(OBJEXT) :  \
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
  ../include/NFMRextern.h  ../include/NFMdef.h

NFMRsr_a_cat.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRstate_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRsv_files.$(OBJEXT) :   ../include/machine.h \
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

NFMRsv_sfile.$(OBJEXT) :   ../include/machine.h \
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

NFMRtab_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRterm.$(OBJEXT) :   ../include/machine.h \
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

NFMRtic.$(OBJEXT) :   ../include/machine.h \
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

NFMRtools.$(OBJEXT) :   ../include/machine.h \
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

NFMRtrans.$(OBJEXT) :   ../include/machine.h \
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

NFMRupd_proj.$(OBJEXT) :   ../include/machine.h \
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

NFMRupd_set.$(OBJEXT) :   ../include/machine.h \
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

NFMRupd_st.$(OBJEXT) :   ../include/machine.h \
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

NFMRupdate.$(OBJEXT) :   ../include/machine.h \
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

NFMRuser_def.$(OBJEXT) :   ../include/machine.h \
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

NFMRuser_t.$(OBJEXT) :   ../include/machine.h \
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

NFMRval_info.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMRextern.h  ../include/NFMdef.h

NFMRvalid.$(OBJEXT) :  \
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
  ../include/NFMRextern.h

NFMRversions.$(OBJEXT) :   ../include/machine.h \
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

NFMRwf_t.$(OBJEXT) :   ../include/machine.h \
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



