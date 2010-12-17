.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
XWINDOWS_FLAG=-DXWINDOWS
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmfi_x.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFFacl_class.$(OBJEXT) NFFacl_clusr.$(OBJEXT) NFFacl_mcf.$(OBJEXT) \
 NFFacl_sign.$(OBJEXT) NFFacl_susr.$(OBJEXT) NFFacl_tools.$(OBJEXT) \
 NFFadd.$(OBJEXT) NFFadd_acl.$(OBJEXT) NFFadd_file.$(OBJEXT) \
 NFFadd_init.$(OBJEXT) NFFadd_map.$(OBJEXT) NFFadd_mcf.$(OBJEXT) \
 NFFadd_usa.$(OBJEXT) NFFarchive.$(OBJEXT) NFFbackup.$(OBJEXT) \
 NFFcan_coitm.$(OBJEXT) NFFcan_coset.$(OBJEXT) NFFcan_iflg.$(OBJEXT) \
 NFFcan_pflg.$(OBJEXT) NFFcan_sflg.$(OBJEXT) NFFcat_acl.$(OBJEXT) \
 NFFcat_sa.$(OBJEXT) NFFcat_tools.$(OBJEXT) NFFcatalog.$(OBJEXT) \
 NFFch_cat.$(OBJEXT) NFFch_files.$(OBJEXT) NFFch_item.$(OBJEXT) \
 NFFch_sa_pwd.$(OBJEXT) NFFch_u_pwd.$(OBJEXT) NFFch_wa_pwd.$(OBJEXT) \
 NFFchg_iwf.$(OBJEXT) NFFci_item.$(OBJEXT) NFFci_set.$(OBJEXT) \
 NFFco_item.$(OBJEXT) NFFco_set.$(OBJEXT) NFFconfig.$(OBJEXT) \
 NFFconfirm.$(OBJEXT) NFFcopy_acl.$(OBJEXT) NFFcopy_item.$(OBJEXT) \
 NFFcp_item.$(OBJEXT) NFFcp_tools.$(OBJEXT) NFFcr_cat.$(OBJEXT) \
 NFFdebug.$(OBJEXT) NFFdef_smem.$(OBJEXT) NFFdef_srch.$(OBJEXT) \
 NFFdefaults.$(OBJEXT) NFFdel_acl.$(OBJEXT) NFFdel_cat.$(OBJEXT) \
 NFFdel_cp.$(OBJEXT) NFFdel_files.$(OBJEXT) NFFdel_item.$(OBJEXT) \
 NFFdel_label.$(OBJEXT) NFFdel_map.$(OBJEXT) NFFdel_mem.$(OBJEXT) \
 NFFdel_node.$(OBJEXT) NFFdel_prj.$(OBJEXT) NFFdel_qry.$(OBJEXT) \
 NFFdel_sa.$(OBJEXT) NFFdel_sort.$(OBJEXT) NFFdel_srch.$(OBJEXT) \
 NFFdel_user.$(OBJEXT) NFFdelete.$(OBJEXT) NFFdisplay.$(OBJEXT) \
 NFFd_items.$(OBJEXT) NFFexit.$(OBJEXT) NFFf_tools.$(OBJEXT) NFFfei.$(OBJEXT) \
 NFFfgets.$(OBJEXT) NFFfile_io.$(OBJEXT) NFFfl_item.$(OBJEXT) \
 NFFfl_proj.$(OBJEXT) NFFfl_set.$(OBJEXT) NFFfl_tools.$(OBJEXT) \
 NFFflag.$(OBJEXT) NFFflag_item.$(OBJEXT) NFFg_confirm.$(OBJEXT) \
 NFFget_map.$(OBJEXT) NFFhelp.$(OBJEXT) NFFinit.$(OBJEXT) NFFjournal.$(OBJEXT) \
 NFFlist.$(OBJEXT) NFFlist_mcf.$(OBJEXT) NFFlock_item.$(OBJEXT) \
 NFFlogin.$(OBJEXT) NFFmain.$(OBJEXT) NFFmain_form.$(OBJEXT) \
 NFFmap_mcf.$(OBJEXT) NFFmcf_tools.$(OBJEXT) NFFmem_tools.$(OBJEXT) \
 NFFmenu.$(OBJEXT) NFFmessage.$(OBJEXT) NFFmk_trans.$(OBJEXT) \
 NFFncp_item.$(OBJEXT) NFFncp_set.$(OBJEXT) NFFnotify.$(OBJEXT) \
 NFFparse.$(OBJEXT) NFFpasswd.$(OBJEXT) NFFplot.$(OBJEXT) NFFpopup.$(OBJEXT) \
 NFFprint.$(OBJEXT) NFFprj_acl.$(OBJEXT) NFFprj_sa.$(OBJEXT) \
 NFFproc_file.$(OBJEXT) NFFproc_form.$(OBJEXT) NFFprocess.$(OBJEXT) \
 NFFpur_so.$(OBJEXT) NFFpur_vers.$(OBJEXT) NFFrestore.$(OBJEXT) \
 NFFsave.$(OBJEXT) NFFsaveset.$(OBJEXT) NFFscroll.$(OBJEXT) \
 NFFset_io.$(OBJEXT) NFFsignal.$(OBJEXT) NFFsignoff.$(OBJEXT) \
 NFFsort.$(OBJEXT) NFFtimestamp.$(OBJEXT) NFFtools.$(OBJEXT) \
 NFFunlk_item.$(OBJEXT) NFFusage.$(OBJEXT) NFFutil_msg.$(OBJEXT) \
 NFFutility.$(OBJEXT) NFFvalid.$(OBJEXT) NFFversions.$(OBJEXT) \
 NFFvlt.$(OBJEXT) NFFwf.$(OBJEXT)

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


NFFacl_class.$(OBJEXT) :   ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFacl_clusr.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFacl_mcf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFacl_sign.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFacl_susr.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFacl_tools.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFadd.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFmain_form.h

NFFadd_acl.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h

NFFadd_file.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFfiles.h

NFFadd_init.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFmain_form.h

NFFadd_map.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFadd_mcf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h

NFFadd_usa.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFaddusa.h

NFFarchive.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFutility.h

NFFbackup.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFutility.h

NFFcan_coitm.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h  ../include/WFcommands.h

NFFcan_coset.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h  ../include/WFcommands.h

NFFcan_iflg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h

NFFcan_pflg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h

NFFcan_sflg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h

NFFcat_acl.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFcat_sa.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFcat_tools.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFcatalog.h

NFFcatalog.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFcatalog.h

NFFch_cat.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFcatalog.h  ../include/NFFmain_form.h

NFFch_files.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFfiles.h

NFFch_item.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h

NFFch_sa_pwd.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFpasswd.h

NFFch_u_pwd.$(OBJEXT) :   /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFpasswd.h

NFFch_wa_pwd.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFpasswd.h

NFFchg_iwf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFtimestamp.h  ../include/NFFchg_wf.h

NFFci_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/WFcommands.h

NFFci_set.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/WFcommands.h

NFFco_item.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/WFcommands.h

NFFco_set.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/WFcommands.h

NFFconfig.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFconfirm.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h  ../include/NFFmain_form.h

NFFcopy_acl.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFcopy_acl.h  ../include/NFFmain_form.h

NFFcopy_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFfiles.h

NFFcp_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFmain_form.h

NFFcp_tools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFfiles.h

NFFcr_cat.$(OBJEXT) :   /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFcatalog.h  ../include/NFFmain_form.h

NFFdebug.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFdebug.h

NFFdef_smem.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFset_mem.h

NFFdef_srch.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/times.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/SQLproto.h \
  ../include/BASproto.h  ../include/NFIerrordef.h  ../include/NFIcommands.h \
  ../include/NFMtitles.h  ../include/NFFforms.h  ../include/NFFdisplay.h \
  ../include/NFFdef.h  ../include/NFFstruct.h  ../include/NFFproto.h \
  ../include/NFF.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h  ../include/NFFmain_form.h

NFFdefaults.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmain_form.h

NFFdel_acl.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmain_form.h  ../include/NFFconfirm.h

NFFdel_cat.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_cp.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h

NFFdel_files.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFfiles.h

NFFdel_item.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_label.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_map.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFdel_mem.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFdel_mem.h

NFFdel_node.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_prj.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_qry.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h  ../include/NFFmain_form.h

NFFdel_sa.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_sort.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_srch.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdel_user.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFdelete.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFutility.h

NFFdisplay.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmain_form.h  ../include/NFFvalidate.h

NFFd_items.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmain_form.h

NFFexit.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFf_tools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFfiles.h

NFFfei.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFjournal.h

NFFfgets.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h

NFFfile_io.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h

NFFfl_item.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h

NFFfl_proj.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h

NFFfl_set.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h

NFFfl_tools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h

NFFflag.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFvalidate.h  ../include/NFFflag.h

NFFflag_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFflag_item.h  ../include/NFMporttypes.h

NFFg_confirm.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h

NFFget_map.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFhelp.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFinit.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  /opt/ingr/xformsdp/xfi/include/FEI.h

NFFjournal.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  /usr/include/sys/stat.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/fcntl.h  /usr/include/fcntl.h  ../include/NFFjournal.h \
  ../include/NFMporttypes.h

NFFlist.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h  ../include/NFFtimestamp.h

NFFlist_mcf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFlock_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFlogin.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFlogin.h  ../include/NFFmain_form.h

NFFmain.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFmain_form.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFMversion.h  ../include/NFFmain_form.h

NFFmap_mcf.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFmcf_tools.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFmem_tools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFset_mem.h  ../include/NFMporttypes.h

NFFmenu.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFmessage.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  ../include/ERRerrordef.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  /usr/include/stdarg.h

NFFmk_trans.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmk_trans.h

NFFncp_item.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/WFcommands.h

NFFncp_set.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/WFcommands.h

NFFnotify.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/times.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/helpif.h \
  /opt/ingr/include/helpifproto.h  ../include/SQLproto.h \
  ../include/BASproto.h  ../include/NFIerrordef.h  ../include/NFIcommands.h \
  ../include/NFMtitles.h  ../include/NFFforms.h  ../include/NFFdisplay.h \
  ../include/NFFdef.h  ../include/NFFstruct.h  ../include/NFFproto.h \
  ../include/NFF.h  ../include/NFFconfirm.h  ../include/NFFtimestamp.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h \
  ../include/NFFmain_form.h

NFFparse.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFpasswd.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFpasswd.h

NFFplot.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFpopup.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFlogin.h  ../include/NFFmain_form.h

NFFprint.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/MEMproto.h \
  ../include/SQLproto.h  ../include/BASproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFIerrordef.h \
  ../include/NFIcommands.h  ../include/NFMtitles.h  ../include/DEBUG.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFFforms.h \
  ../include/NFFdisplay.h  ../include/NFFdef.h  ../include/NFFstruct.h \
  ../include/NFFproto.h  ../include/NFF.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/pwd.h \
  ../include/NFMporttypes.h

NFFprj_acl.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFprj_sa.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFmap.h

NFFproc_file.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFfiles.h  ../include/NFFmain_form.h

NFFproc_form.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFprocess.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFtimestamp.h

NFFpur_so.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFpur_vers.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFadd.h  ../include/NFFconfirm.h

NFFrestore.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFutility.h

NFFsave.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFsaveset.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFscroll.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/MEMproto.h  ../include/SQLproto.h \
  ../include/BASproto.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  /usr/include/sys/feature_tests.h  /usr/include/ctype.h

NFFset_io.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFconfirm.h

NFFsignal.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/cred.h  /usr/include/sys/resource.h \
  /usr/include/sys/auxv.h  /usr/include/sys/user.h  /usr/include/sys/timer.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/copyops.h \
  /usr/include/sys/watchpoint.h  /usr/include/sys/segment.h \
  /usr/include/sys/proc.h  /usr/include/sys/procset.h  /usr/include/signal.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/pcb.h \
  /usr/include/sys/msacct.h  /usr/include/sys/synch.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h \
  /usr/include/sys/machparam.h  /usr/include/sys/unistd.h \
  /usr/include/sys/param.h  /usr/include/sys/pirec.h \
  /usr/include/sys/machlock.h  /usr/include/sys/sleepq.h \
  /usr/include/sys/turnstile.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/sys/signal.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFsignoff.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFsignoff.h

NFFsort.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFsort.h  ../include/NFFmain_form.h  ../include/NFMporttypes.h

NFFtimestamp.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  ../include/ERRerrordef.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  /usr/include/stdarg.h

NFFtools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/times.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/MEMproto.h  ../include/SQLproto.h \
  ../include/BASproto.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_limits.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/unistd.h \
  /usr/include/limits.h  ../include/NFFmap.h

NFFunlk_item.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFusage.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h

NFFutil_msg.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFutil_msg.h

NFFutility.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFutility.h

NFFvalid.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFvalidate.h  ../include/NFFmain_form.h

NFFversions.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/X11/Xatom.h \
  /usr/include/X11/Xfuncproto.h  /usr/include/X11/Xosdefs.h \
  /usr/include/stddef.h  /usr/include/X11/Xlib.h  /usr/include/X11/Xutil.h \
  /usr/include/X11/Xmd.h  /usr/include/X11/X.h  /usr/include/string.h \
  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFversions.h

NFFvlt.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/NFFvlt.h

NFFwf.$(OBJEXT) :   ../include/machine.h \
  /usr/include/X11/Xatom.h  /usr/include/X11/Xfuncproto.h \
  /usr/include/X11/Xosdefs.h  /usr/include/stddef.h  /usr/include/X11/Xlib.h \
  /usr/include/X11/Xutil.h  /usr/include/X11/Xmd.h  /usr/include/X11/X.h \
  /usr/include/string.h  ../include/tools.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/times.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/xformsdp/xfi/include/FEI.h \
  /opt/ingr/xformsdp/xfi/include/FIdyn.h \
  /opt/ingr/xformsdp/xfi/include/FIappl.h \
  /opt/ingr/xformsdp/xfi/include/MS.h  /opt/ingr/include/UMS.h \
  /opt/ingr/include/helpif.h  /opt/ingr/include/helpifproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMproto.h  ../include/SQLproto.h  ../include/BASproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h  ../include/NFMtitles.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFFforms.h  ../include/NFFdisplay.h  ../include/NFFdef.h \
  ../include/NFFstruct.h  ../include/NFFproto.h  ../include/NFF.h \
  ../include/WFcommands.h  ../include/NFFtimestamp.h  ../include/NFFjournal.h \
  ../include/NFFvalidate.h



