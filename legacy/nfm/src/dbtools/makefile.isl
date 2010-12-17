.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libdbtools.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMacls.$(OBJEXT) NFMattr_size.$(OBJEXT) NFMattr_val.$(OBJEXT) \
 NFMbsac_attr.$(OBJEXT) NFMbsac_list.$(OBJEXT) NFMcatalogs.$(OBJEXT) \
 NFMclasses.$(OBJEXT) NFMcommands.$(OBJEXT) NFMcond_attr.$(OBJEXT) \
 NFMdate.$(OBJEXT) NFMdb_sql.$(OBJEXT) NFMdb_trans.$(OBJEXT) \
 NFMget_attrs.$(OBJEXT) NFMget_cat.$(OBJEXT) NFMget_prog.$(OBJEXT) \
 NFMget_vals.$(OBJEXT) NFMitem_l.$(OBJEXT) NFMlfm_info.$(OBJEXT) \
 NFMlfm_upd.$(OBJEXT) NFMlist_catn.$(OBJEXT) NFMprograms.$(OBJEXT) \
 NFMprojects.$(OBJEXT) NFMsa.$(OBJEXT) NFMsac_attr.$(OBJEXT) \
 NFMsac_list.$(OBJEXT) NFMserial.$(OBJEXT) NFMstates.$(OBJEXT) \
 NFMtab_attr.$(OBJEXT) NFMtables.$(OBJEXT) NFMtrans.$(OBJEXT) \
 NFMusers.$(OBJEXT) NFMval_list.$(OBJEXT) NFMworkflow.$(OBJEXT) \
 NFMbmcslmcrs.$(OBJEXT) NFMbftr_adv.$(OBJEXT) NFMbftr_attr.$(OBJEXT)

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


NFMacls.$(OBJEXT) :   ../include/machine.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMattr_size.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MEMstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMattr_val.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DBTproto.h  ../include/DBTOOLS.h

NFMbsac_attr.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/MEMstruct.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h

NFMbsac_list.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMcatalogs.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMclasses.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMcommands.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMcond_attr.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DBTproto.h  ../include/DBTOOLS.h

NFMdate.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/stdio.h  /usr/include/stdarg.h \
  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DBTproto.h  ../include/DBTOOLS.h \
  /usr/include/sys/feature_tests.h  /usr/include/string.h

NFMdb_sql.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMdb_trans.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMget_attrs.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DBTproto.h  ../include/DBTOOLS.h

NFMget_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/MEMstruct.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h

NFMget_prog.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/DEBUG.h

NFMget_vals.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DBTproto.h  ../include/DBTOOLS.h

NFMitem_l.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/WFstruct.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/RPSdef.h  ../include/NFMsacdef.h \
  ../include/NFMdef.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMlfm_info.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/RPSdef.h

NFMlfm_upd.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  ../include/NFMschema.h  ../include/NFMapi.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/RPSdef.h

NFMlist_catn.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/WFstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/RPSdef.h \
  ../include/NFMsacdef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMprograms.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMprojects.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMdb.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/DBTproto.h  ../include/DBTOOLS.h \
  ../include/NFMschema.h  ../include/WFstruct.h

NFMsa.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/NFMschema.h \
  ../include/NFMfto_buf.h  ../include/DBTproto.h

NFMsac_attr.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/MEMstruct.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h

NFMsac_list.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMserial.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NFMdb.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMstates.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/WFstruct.h \
  ../include/MEMstruct.h

NFMtab_attr.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMschema.h  ../include/NFMitems.h \
  ../include/CMDTproto.h  ../include/CMDTOOLS.h

NFMtables.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

NFMtrans.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMusers.$(OBJEXT) :   ../include/machine.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DBTproto.h  ../include/DBTOOLS.h

NFMval_list.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMdb.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

NFMworkflow.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

NFMbmcslmcrs.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/SQLproto.h

NFMbftr_adv.$(OBJEXT) :   ../include/MEMstruct.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/SQLproto.h

NFMbftr_attr.$(OBJEXT) :   ../include/NFMschema.h \
  ../include/MEMstruct.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h



