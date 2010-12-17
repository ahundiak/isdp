.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfma.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMacl_sign.$(OBJEXT) NFMacl_users.$(OBJEXT) NFMacls.$(OBJEXT) \
 NFMadd_node.$(OBJEXT) NFMadd_prog.$(OBJEXT) NFMadd_proj.$(OBJEXT) \
 NFMadd_sa.$(OBJEXT) NFMadd_user.$(OBJEXT) NFMadm_del.$(OBJEXT) \
 NFMcat_map.$(OBJEXT) NFMchg_node.$(OBJEXT) NFMchg_sa.$(OBJEXT) \
 NFMchg_user.$(OBJEXT) NFMchg_wf_it.$(OBJEXT) NFMcr_cat.$(OBJEXT) \
 NFMdel_cat.$(OBJEXT) NFMdel_dev.$(OBJEXT) NFMdel_node.$(OBJEXT) \
 NFMdel_proj.$(OBJEXT) NFMdel_user.$(OBJEXT) NFMld_proc.$(OBJEXT) \
 NFMld_prog.$(OBJEXT) NFMload.$(OBJEXT) NFMmod_cat.$(OBJEXT) \
 NFMmod_proj.$(OBJEXT) NFMpasswd.$(OBJEXT) NFMpr_util.$(OBJEXT) \
 NFMproj_map.$(OBJEXT) NFMq_util.$(OBJEXT) NFMqa_cat.$(OBJEXT) \
 NFMqa_loc.$(OBJEXT) NFMqry_proc.$(OBJEXT) NFMqry_proj.$(OBJEXT) \
 NFMupd_proj.$(OBJEXT) NFMversions.$(OBJEXT)

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


NFMacl_sign.$(OBJEXT) :   ../include/machine.h  ../include/MEMstruct.h

NFMacl_users.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h

NFMacls.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h  ../include/NFMschema.h

NFMadd_node.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMadd_prog.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  /usr/include/stdarg.h \
  ../include/ERRerrordef.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h  /usr/include/sys/stat.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/pwd.h

NFMadd_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h \
  ../include/NFMschema.h  ../include/WFstruct.h

NFMadd_sa.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMadd_user.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMadm_del.$(OBJEXT) :  \
  ../include/machine.h

NFMcat_map.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMAproto.h  ../include/NFMA.h  ../include/NFMschema.h \
  ../include/WFstruct.h

NFMchg_node.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMchg_sa.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMchg_user.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMchg_wf_it.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h \
  ../include/MSGstruct.h  ../include/NFMschema.h  ../include/WFstruct.h

NFMcr_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMdel_cat.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMdel_dev.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMdel_node.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMdel_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMdel_user.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMld_proc.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMld_prog.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMload.$(OBJEXT) :   ../include/machine.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/WFstruct.h \
  ../include/MSGstruct.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h  ../include/NFMschema.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/WFproto.h  ../include/WF.h \
  /usr/include/sys/feature_tests.h  /usr/include/ctype.h

NFMmod_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMmod_proj.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMpasswd.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMpr_util.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/UTIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMproj_map.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMAproto.h  ../include/NFMA.h  ../include/NFMschema.h \
  ../include/WFstruct.h

NFMq_util.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFMSextern.h  ../include/UTIerrordef.h  ../include/UTIstruct.h \
  ../include/UTIglobals.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMqa_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFMAproto.h \
  ../include/NFMA.h

NFMqa_loc.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMAproto.h  ../include/NFMA.h  ../include/NFMschema.h \
  ../include/WFstruct.h

NFMqry_proc.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMAproto.h  ../include/NFMA.h  ../include/NFMschema.h \
  ../include/WFstruct.h

NFMqry_proj.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h

NFMupd_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h \
  ../include/NFMschema.h  ../include/WFstruct.h

NFMversions.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMAproto.h  ../include/NFMA.h \
  ../include/NFMfto_buf.h  ../include/NFMschema.h  ../include/WFstruct.h \
  ../include/NFMitemfiles.h  ../include/NFTftr.h  ../include/UTIerrordef.h



