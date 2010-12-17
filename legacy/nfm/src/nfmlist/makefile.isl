.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmlists.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= NFMblocksac.$(OBJEXT) NFMdItmTape.$(OBJEXT) NFMdSaveset.$(OBJEXT) \
 NFMd_acls.$(OBJEXT) NFMd_aclu.$(OBJEXT) NFMd_arch.$(OBJEXT) \
 NFMd_catmap.$(OBJEXT) NFMd_cats.$(OBJEXT) NFMd_class.$(OBJEXT) \
 NFMd_files.$(OBJEXT) NFMd_flags.$(OBJEXT) NFMd_items.$(OBJEXT) \
 NFMd_labels.$(OBJEXT) NFMd_local.$(OBJEXT) NFMd_nodes.$(OBJEXT) \
 NFMd_prog.$(OBJEXT) NFMd_proj.$(OBJEXT) NFMd_projmap.$(OBJEXT) \
 NFMd_querys.$(OBJEXT) NFMd_sa.$(OBJEXT) NFMd_sets.$(OBJEXT) NFMd_so.$(OBJEXT) \
 NFMd_stubs.$(OBJEXT) NFMd_tools.$(OBJEXT) NFMd_trans.$(OBJEXT) \
 NFMd_users.$(OBJEXT) NFMd_wa.$(OBJEXT) NFMd_wf.$(OBJEXT) NFMlist_f.$(OBJEXT) \
 NFMsa_cat.$(OBJEXT) NFMmcrsbmcs.$(OBJEXT) NFMd_ris.$(OBJEXT) \
 NFMftrsearch.$(OBJEXT)

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


NFMblocksac.$(OBJEXT) :   ../include/machine.h  ../include/MEMstruct.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMdItmTape.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/UTIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMschema.h

NFMdSaveset.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/NFMschema.h

NFMd_acls.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_aclu.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_arch.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_catmap.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_cats.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_class.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_files.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_flags.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/UTIerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_items.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_labels.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_local.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_nodes.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_prog.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_proj.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_projmap.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_querys.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_sa.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_sets.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_so.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_stubs.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMschema.h  ../include/NFMapi.h

NFMd_tools.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_trans.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_users.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_wa.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMd_wf.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMlist_f.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/WFstruct.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h  ../include/NFMsacdef.h \
  ../include/NFIerrordef.h  /usr/include/sys/euc.h  /usr/include/euc.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/NFMschema.h

NFMsa_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMmcrsbmcs.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NEWdef.h \
  ../include/NFMnfmsacinc.h  ../include/NFMschema.h  ../include/NFMapi.h

NFMd_ris.$(OBJEXT) :  \
  ../include/machine.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

NFMftrsearch.$(OBJEXT) :  \
  ../include/MEMstruct.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h \
  ../include/NFMnfmsacdef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DISproto.h  ../include/DBTproto.h  ../include/NFMnfmsacinc.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFTftr.h \
  ../include/NEWdef.h  ../include/UTIerrordef.h



