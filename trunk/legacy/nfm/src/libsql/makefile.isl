.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmsql.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= SQLstmtf.$(OBJEXT) SQLtools.$(OBJEXT) SQLerror.$(OBJEXT) \
 SQLexec_imm.$(OBJEXT) SQLg_fmax.$(OBJEXT) SQLg_num_r.$(OBJEXT) \
 SQLinsert.$(OBJEXT) SQLload.$(OBJEXT) SQLp_free.$(OBJEXT) \
 SQLp_qry10.$(OBJEXT) SQLp_qry11.$(OBJEXT) SQLp_qry12.$(OBJEXT) \
 SQLp_qry3.$(OBJEXT) SQLp_qry5.$(OBJEXT) SQLp_qry6.$(OBJEXT) \
 SQLp_qry7.$(OBJEXT) SQLp_qry8.$(OBJEXT) SQLp_qry9.$(OBJEXT) SQLqry.$(OBJEXT) \
 SQLqry11-20.$(OBJEXT) SQLqry2-10.$(OBJEXT) SQLqry21-30.$(OBJEXT) \
 SQLqry31-40.$(OBJEXT) SQLstmt.$(OBJEXT) SQLstmt_VAR.$(OBJEXT)

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


SQLstmtf.$(OBJEXT) :   ../include/machine.h  ../include/SQLerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/SQLstruct.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLproto.h  ../include/SQL.h

SQLtools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/SQLstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  /opt/ingr/include/RISlimits.h \
  /opt/ingr/include/rislimit.h  /opt/ingr/include/ris.h \
  /opt/ingr/include/RISprototype.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/select.h \
  /usr/include/sys/time.h  /usr/include/sys/siginfo.h  /usr/include/time.h

SQLerror.$(OBJEXT) :  \
  ../include/machine.h  ../include/SQLerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/SQLstruct.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLproto.h  ../include/SQL.h \
  /opt/ingr/include/ris_err.h

SQLexec_imm.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLg_fmax.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMerrordef.h  ../include/SQLproto.h  ../include/SQL.h \
  ../include/MEMstruct.h

SQLg_num_r.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/MSGstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

SQLinsert.$(OBJEXT) :  \
  ../include/machine.h  ../include/SQLerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/SQLstruct.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLproto.h  ../include/SQL.h

SQLload.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h  /usr/include/stdarg.h \
  ../include/ERRerrordef.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  /opt/ingr/include/rislimit.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /opt/ingr/include/RISloduld.h

SQLp_free.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry10.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry11.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry12.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry3.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry5.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry6.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry7.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry8.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLp_qry9.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLqry.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLqry11-20.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLqry2-10.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLqry21-30.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLqry31-40.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLstmt.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h

SQLstmt_VAR.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/SQLstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLproto.h \
  ../include/SQL.h



