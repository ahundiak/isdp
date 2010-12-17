.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfms.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMSacl_t.$(OBJEXT) NFMSadd_acl.$(OBJEXT) NFMSadd_d_wa.$(OBJEXT) \
 NFMSadd_item.$(OBJEXT) NFMSadd_node.$(OBJEXT) NFMSadd_proj.$(OBJEXT) \
 NFMSadd_sa.$(OBJEXT) NFMSadd_set.$(OBJEXT) NFMSadd_user.$(OBJEXT) \
 NFMScan_iflg.$(OBJEXT) NFMScan_item.$(OBJEXT) NFMScan_pflg.$(OBJEXT) \
 NFMScan_set.$(OBJEXT) NFMScan_sflg.$(OBJEXT) NFMScat_map.$(OBJEXT) \
 NFMScat_t.$(OBJEXT) NFMSchg_cat.$(OBJEXT) NFMSchg_node.$(OBJEXT) \
 NFMSchg_proj.$(OBJEXT) NFMSchg_pwd.$(OBJEXT) NFMSchg_sa.$(OBJEXT) \
 NFMSchg_tab.$(OBJEXT) NFMSchg_tmp.$(OBJEXT) NFMSchg_user.$(OBJEXT) \
 NFMSci_item.$(OBJEXT) NFMSci_set.$(OBJEXT) NFMSclass_t.$(OBJEXT) \
 NFMSclient.$(OBJEXT) NFMScmd_t.$(OBJEXT) NFMScopy_acl.$(OBJEXT) \
 NFMSco_item.$(OBJEXT) NFMSco_set.$(OBJEXT) NFMScp_item.$(OBJEXT) \
 NFMScp_set.$(OBJEXT) NFMScr_cat.$(OBJEXT) NFMScr_tab.$(OBJEXT) \
 NFMScr_tmp.$(OBJEXT) NFMSd_cfile.$(OBJEXT) NFMSdates.$(OBJEXT) \
 NFMSdbg_str.$(OBJEXT) NFMSdebug.$(OBJEXT) NFMSdel_cat.$(OBJEXT) \
 NFMSdel_item.$(OBJEXT) NFMSdel_lab.$(OBJEXT) NFMSdel_node.$(OBJEXT) \
 NFMSdel_proj.$(OBJEXT) NFMSdel_sa.$(OBJEXT) NFMSdel_user.$(OBJEXT) \
 NFMSdisplays.$(OBJEXT) NFMSerr_buff.$(OBJEXT) NFMSerr_ums.$(OBJEXT) \
 NFMSerror.$(OBJEXT) NFMSfile_inf.$(OBJEXT) NFMSflg_item.$(OBJEXT) \
 NFMSflg_proj.$(OBJEXT) NFMSflg_set.$(OBJEXT) NFMSftr.$(OBJEXT) \
 NFMSget_bulk.$(OBJEXT) NFMSget_udef.$(OBJEXT) NFMSitem_t.$(OBJEXT) \
 NFMSlItmTape.$(OBJEXT) NFMSlSaveset.$(OBJEXT) NFMSlfm.$(OBJEXT) \
 NFMSload_wf.$(OBJEXT) NFMSlock.$(OBJEXT) NFMSlog_in.$(OBJEXT) \
 NFMSlogin.$(OBJEXT) NFMSlogout.$(OBJEXT) NFMSmaint.$(OBJEXT) \
 NFMSmod_acl.$(OBJEXT) NFMSmod_i_wf.$(OBJEXT) NFMSnci_item.$(OBJEXT) \
 NFMSnci_set.$(OBJEXT) NFMSnco_item.$(OBJEXT) NFMSnco_set.$(OBJEXT) \
 NFMSncp_item.$(OBJEXT) NFMSncp_set.$(OBJEXT) NFMSnode_t.$(OBJEXT) \
 NFMSplt_item.$(OBJEXT) NFMSplt_set.$(OBJEXT) NFMSpr_util.$(OBJEXT) \
 NFMSprog_t.$(OBJEXT) NFMSproj_map.$(OBJEXT) NFMSproj_t.$(OBJEXT) \
 NFMSq_can.$(OBJEXT) NFMSq_cat.$(OBJEXT) NFMSq_chgcat.$(OBJEXT) \
 NFMSq_chgnod.$(OBJEXT) NFMSq_chgsa.$(OBJEXT) NFMSq_chgtab.$(OBJEXT) \
 NFMSq_chgtmp.$(OBJEXT) NFMSq_chgusr.$(OBJEXT) NFMSq_flag.$(OBJEXT) \
 NFMSq_item.$(OBJEXT) NFMSq_loc.$(OBJEXT) NFMSq_set.$(OBJEXT) \
 NFMSq_tab.$(OBJEXT) NFMSq_tmp.$(OBJEXT) NFMSq_util.$(OBJEXT) \
 NFMSquery.$(OBJEXT) NFMSrev_st.$(OBJEXT) NFMSsa_t.$(OBJEXT) \
 NFMSserver.$(OBJEXT) NFMSset_inf.$(OBJEXT) NFMSset_st.$(OBJEXT) \
 NFMSset_udef.$(OBJEXT) NFMSsignoff.$(OBJEXT) NFMSsnd_buff.$(OBJEXT) \
 NFMSsqlquery.$(OBJEXT) NFMSsqlstmt.$(OBJEXT) NFMSsr_a_cat.$(OBJEXT) \
 NFMSstate_t.$(OBJEXT) NFMSsv_files.$(OBJEXT) NFMSsv_sfile.$(OBJEXT) \
 NFMSswitch.$(OBJEXT) NFMStab_t.$(OBJEXT) NFMStools.$(OBJEXT) \
 NFMStrans.$(OBJEXT) NFMSupd_proj.$(OBJEXT) NFMSupd_set.$(OBJEXT) \
 NFMSupd_st.$(OBJEXT) NFMSupdate.$(OBJEXT) NFMSuser_def.$(OBJEXT) \
 NFMSuser_t.$(OBJEXT) NFMSutil_upd.$(OBJEXT) NFMSval_info.$(OBJEXT) \
 NFMSvalid.$(OBJEXT) NFMSversions.$(OBJEXT) NFMSwf_t.$(OBJEXT) \
 NFMSset_cl_i.$(OBJEXT)

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


NFMSacl_t.$(OBJEXT) :   ../include/machine.h  ../include/MEMstruct.h \
  ../include/NETdef.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSadd_acl.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSadd_d_wa.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSadd_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSadd_node.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSadd_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSadd_sa.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h

NFMSadd_set.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSadd_user.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScan_iflg.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScan_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/NFMapi.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScan_pflg.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScan_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMapi.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScan_sflg.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScat_map.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScat_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSchg_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSchg_node.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSchg_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSchg_pwd.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSchg_sa.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSchg_tab.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSchg_tmp.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h

NFMSchg_user.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMSci_item.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSci_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSclass_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSclient.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScmd_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScopy_acl.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/NFMschema.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSco_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSco_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScp_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScp_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMScr_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMScr_tab.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h

NFMScr_tmp.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h

NFMSd_cfile.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSdates.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSdbg_str.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/DEBUG.h

NFMSdebug.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/DEBUG.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  /usr/include/stdarg.h \
  ../include/ERRerrordef.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/NETstruct.h

NFMSdel_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSdel_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSdel_lab.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSdel_node.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSdel_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSdel_sa.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSdel_user.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSdisplays.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h  ../include/NFMtypes.h \
  ../include/NFMschema.h  ../include/NFMapi.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSerr_buff.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h

NFMSerr_ums.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/NFMapi.h

NFMSerror.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h

NFMSfile_inf.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h

NFMSflg_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSflg_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSflg_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSftr.$(OBJEXT) :  \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMitemfiles.h

NFMSget_bulk.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSget_udef.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSitem_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/NFMdef.h  ../include/DEBUG.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NFMschema.h

NFMSlItmTape.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/pwd.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/NETstruct.h

NFMSlSaveset.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/pwd.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/NETstruct.h

NFMSlfm.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h

NFMSload_wf.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSlock.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSlog_in.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSlogin.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSlogout.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSmaint.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSmod_acl.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSmod_i_wf.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSnci_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMapi.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSnci_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/NFMapi.h

NFMSnco_item.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMSnco_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/NFMapi.h

NFMSncp_item.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMSncp_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/NFMapi.h

NFMSnode_t.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSplt_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSplt_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSpr_util.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/UTIerrordef.h  ../include/UTIstruct.h  ../include/UTIglobals.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMSprog_t.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSproj_map.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSproj_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_can.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/pwd.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/NETstruct.h

NFMSq_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSq_chgcat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_chgnod.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_chgsa.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_chgtab.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_chgtmp.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h

NFMSq_chgusr.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMSq_flag.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_item.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSq_loc.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSq_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_tab.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_tmp.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSq_util.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/UTIerrordef.h  ../include/UTIstruct.h  ../include/UTIglobals.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMSquery.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMSrev_st.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSsa_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSserver.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
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
  /usr/include/sys/time.h  /usr/include/signal.h  ../include/DEBUG.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMtypes.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/UTIstruct.h  ../include/NETdef.h  ../include/NETstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSset_inf.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMapi.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSset_st.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSset_udef.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSsignoff.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSsnd_buff.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMtypes.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h

NFMSsqlquery.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NETdef.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSsqlstmt.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSsr_a_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSstate_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSsv_files.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/NFMapi.h

NFMSsv_sfile.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMSswitch.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/NFMtypes.h  ../include/UTIstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NETstruct.h

NFMStab_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMStools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h

NFMStrans.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSupd_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSupd_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSupd_st.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSupdate.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSuser_def.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMSuser_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSutil_upd.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  ../include/UTIstruct.h  ../include/UTIerrordef.h  ../include/UTIglobals.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/stat.h  ../include/UTIdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MSGstruct.h  ../include/DEBUG.h

NFMSval_info.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/NFMdef.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSvalid.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSversions.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMSextern.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSwf_t.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMSset_cl_i.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/NETdef.h \
  ../include/DEBUG.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  /usr/include/stdarg.h \
  ../include/ERRerrordef.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/NETstruct.h



