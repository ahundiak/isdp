.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmadmin.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= ADMStorage_a.$(OBJEXT) ADMactivate.$(OBJEXT) ADMblock.$(OBJEXT) \
 ADMcatname.$(OBJEXT) ADMchoose.$(OBJEXT) ADMclient.$(OBJEXT) \
 ADMcl_file.$(OBJEXT) ADMcommands.$(OBJEXT) ADMcross_ref.$(OBJEXT) \
 ADMdate.$(OBJEXT) ADMdebug.$(OBJEXT) ADMdef_sch.$(OBJEXT) \
 ADMdrop_sch.$(OBJEXT) ADMd_login.$(OBJEXT) ADMenter.$(OBJEXT) \
 ADMenv.$(OBJEXT) ADMenv_file.$(OBJEXT) ADMenv_imp.$(OBJEXT) \
 ADMerr_ret.$(OBJEXT) ADMexp_env.$(OBJEXT) ADMexp_files.$(OBJEXT) \
 ADMexport.$(OBJEXT) ADMfunctions.$(OBJEXT) ADMget_block.$(OBJEXT) \
 ADMget_date.$(OBJEXT) ADMget_ser.$(OBJEXT) ADMget_time.$(OBJEXT) \
 ADMglobals.$(OBJEXT) ADMimp.$(OBJEXT) ADMimp_env.$(OBJEXT) ADMindex.$(OBJEXT) \
 ADMload_prog.$(OBJEXT) ADMlock_itm.$(OBJEXT) ADMlogin.$(OBJEXT) \
 ADMlogoff.$(OBJEXT) ADMmod_trans.$(OBJEXT) ADMnfm_op.$(OBJEXT) \
 ADMnfme.$(OBJEXT) ADMnfmex.$(OBJEXT) ADMnfmh.$(OBJEXT) ADMnfsclean.$(OBJEXT) \
 ADMnodes.$(OBJEXT) ADMop_env.$(OBJEXT) ADMproctrans.$(OBJEXT) \
 ADMpur_ac.$(OBJEXT) ADMpurg.$(OBJEXT) ADMrap.$(OBJEXT) ADMr_op.$(OBJEXT) \
 ADMrepair.$(OBJEXT) ADMrislog.$(OBJEXT) ADMser.$(OBJEXT) \
 ADMser_file.$(OBJEXT) ADMser_log.$(OBJEXT) ADMsetc1.$(OBJEXT) \
 ADMslot.$(OBJEXT) ADMstorage.$(OBJEXT) ADMtable.$(OBJEXT) ADMtime.$(OBJEXT) \
 ADMtools.$(OBJEXT) ADMwr_env.$(OBJEXT)

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


ADMStorage_a.$(OBJEXT) :   ../include/machine.h  ../include/UNIX_or_VMS.h \
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
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  ../include/DEBUG.h  ../include/NFIcommands.h \
  ../include/NFIerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h

ADMactivate.$(OBJEXT) :   ../include/machine.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMdisplays.h  ../include/NFIcommands.h \
  ../include/NFIerrordef.h  ../include/DEBUG.h

ADMblock.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/DEBUG.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMcatname.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/WFstruct.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/RPSdef.h  ../include/NFMsacdef.h \
  ../include/NFMdef.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h

ADMchoose.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NDXstruct.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/NFMRlist.h  ../include/NFMdisplays.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h  ../include/DEBUG.h

ADMclient.$(OBJEXT) :  \
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
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCstruct.h \
  ../include/MEMstruct.h  ../include/SCdef.h  ../include/SCdata.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MSGstruct.h  ../include/NFIerrordef.h  ../include/NDXstruct.h \
  ../include/DEBUG.h

ADMcl_file.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMstruct.h  ../include/NETstruct.h  ../include/NFMdb.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/DEBUG.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  /usr/include/pwd.h  ../include/NFMenv.h

ADMcommands.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  ../include/NFMdef.h \
  ../include/WFcommands.h  ../include/RPSdef.h  ../include/SCdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMRextern.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

ADMcross_ref.$(OBJEXT) :   ../include/machine.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h

ADMdate.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/DEBUG.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMdebug.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/NFIcommands.h  ../include/NDXstruct.h  ../include/NFIerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/DEBUG.h

ADMdef_sch.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFIerrordef.h \
  ../include/NETstruct.h  ../include/NFMdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMsacdef.h  ../include/DEBUG.h

ADMdrop_sch.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  ../include/MEMstruct.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NFMdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMsacdef.h  ../include/DEBUG.h

ADMd_login.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/NFIerrordef.h  /usr/include/sys/euc.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/SCextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NDXstruct.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h

ADMenter.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/stat.h  /usr/include/pwd.h \
  ../include/UNIX_or_VMS.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/euc.h  /usr/include/euc.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/SCextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/NFIerrordef.h \
  ../include/NFMporttypes.h

ADMenv.$(OBJEXT) :   ../include/machine.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIcommands.h \
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

ADMenv_file.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h  ../include/NETstruct.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h  ../include/NFMschema.h

ADMenv_imp.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  ../include/NETstruct.h  ../include/NFMdb.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h  ../include/NFMschema.h

ADMerr_ret.$(OBJEXT) :  \
  ../include/machine.h  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/SQLerrordef.h  ../include/MEMerrordef.h  ../include/MSGstruct.h \
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
  /usr/include/stdio.h  ../include/SCextern.h  ../include/NFIerrordef.h \
  ../include/NFIcommands.h  ../include/DEBUG.h

ADMexp_env.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/pwd.h  /usr/include/string.h \
  /usr/include/ctype.h  /usr/include/sys/stat.h  /usr/include/sys/statfs.h \
  /usr/include/sys/ustat.h  /usr/include/ustat.h  /usr/include/sys/utsname.h \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/sys/uio.h \
  /usr/include/sys/resource.h  /usr/include/vm/seg_enum.h \
  /usr/include/sys/kstat.h  /usr/include/sys/buf.h  /usr/include/sys/vnode.h \
  /usr/include/sys/poll.h  /usr/include/sys/strmdep.h \
  /usr/include/sys/cred.h  /usr/include/sys/rwlock.h  /usr/include/sys/pcb.h \
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
  ../include/NFMapi.h  ../include/NFMxferextrn.h  ../include/NFMxfer_def.h \
  ../include/NFMsysstruct.h  ../include/NFMsysextern.h \
  ../include/NETnetstruct.h  ../include/NETnetextern.h \
  ../include/MEMerrordef.h  ../include/NETdef.h  ../include/NETstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  ../include/TFERproto.h  ../include/NFMTproto.h  ../include/SYSTproto.h \
  ../include/MEMproto.h  ../include/NETproto.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/NFMf_xferinc.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/NFMporttypes.h

ADMexp_files.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/dirent.h  /usr/include/dirent.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMerrordef.h  ../include/NETerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

ADMexport.$(OBJEXT) :   ../include/machine.h \
  ../include/UNIX_or_VMS.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  /usr/include/sys/euc.h  /usr/include/euc.h \
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
  ../include/ERR.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

ADMfunctions.$(OBJEXT) :   ../include/machine.h \
  ../include/NETstruct.h  ../include/NETdef.h  ../include/NFMtypes.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  /usr/include/sys/euc.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/SCextern.h \
  ../include/NDXstruct.h  ../include/DEBUG.h  ../include/NFIerrordef.h \
  ../include/NFIcommands.h  ../include/NFMRlist.h  /opt/ingr/include/UMS.h \
  ../include/NFMtitles.h

ADMget_block.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMRextern.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMget_date.$(OBJEXT) :  \
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
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMRextern.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMget_ser.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  ../include/MEMstruct.h  ../include/NETstruct.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/ADMser.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

ADMget_time.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMRextern.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMglobals.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  ../include/MSGstruct.h

ADMimp.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  /usr/include/sys/euc.h  /usr/include/euc.h \
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
  ../include/ERR.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

ADMimp_env.$(OBJEXT) :   ../include/machine.h \
  /usr/include/pwd.h  /usr/include/string.h  /usr/include/ctype.h \
  /usr/include/sys/stat.h  /usr/include/sys/statfs.h \
  /usr/include/sys/ustat.h  /usr/include/ustat.h  /usr/include/sys/utsname.h \
  /usr/include/sys/errno.h  /usr/include/errno.h  /usr/include/sys/uio.h \
  /usr/include/sys/resource.h  /usr/include/vm/seg_enum.h \
  /usr/include/sys/kstat.h  /usr/include/sys/buf.h  /usr/include/sys/vnode.h \
  /usr/include/sys/poll.h  /usr/include/sys/strmdep.h \
  /usr/include/sys/cred.h  /usr/include/sys/rwlock.h  /usr/include/sys/pcb.h \
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
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/NFMf_xferinc.h \
  ../include/NFMporttypes.h

ADMindex.$(OBJEXT) :   ../include/machine.h \
  ../include/WFstruct.h  ../include/RPSdef.h  ../include/NFMsacdef.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NDXstruct.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NFMdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIcommands.h

ADMload_prog.$(OBJEXT) :   ../include/machine.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/SCdata.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFcommands.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h

ADMlock_itm.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/DEBUG.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMlogin.$(OBJEXT) :  \
  ../include/machine.h  ../include/UNIX_or_VMS.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/NFIerrordef.h  /usr/include/sys/euc.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/SCextern.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NDXstruct.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h

ADMlogoff.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/stat.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NETstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NFMschema.h \
  ../include/NFMstruct.h

ADMmod_trans.$(OBJEXT) :   ../include/machine.h \
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
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMRextern.h \
  ../include/NDXstruct.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  /opt/ingr/include/UMS.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h  ../include/WFcommands.h \
  ../include/DEBUG.h  ../include/NFMdisplays.h  ../include/NFIcommands.h \
  ../include/NFMRlist.h  ../include/NFMtitles.h

ADMnfm_op.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/dirent.h  /usr/include/dirent.h \
  ../include/MSGstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMerrordef.h  ../include/NETerrordef.h \
  ../include/NFIerrordef.h  ../include/NFMdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMsacdef.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/NFMstruct.h

ADMnfme.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/dirent.h  /usr/include/dirent.h \
  ../include/MSGstruct.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMerrordef.h \
  ../include/NETerrordef.h  ../include/NFIerrordef.h  ../include/NFMdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFMsacdef.h  ../include/DEBUG.h

ADMnfmex.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/dirent.h  /usr/include/dirent.h \
  ../include/MSGstruct.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NFMerrordef.h \
  ../include/NETerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h

ADMnfmh.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/dirent.h  /usr/include/dirent.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NFMerrordef.h  ../include/NETerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h

ADMnfsclean.$(OBJEXT) :   ../include/machine.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h

ADMnodes.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/WFstruct.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/RPSdef.h  ../include/NFMsacdef.h \
  ../include/NFMdef.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h

ADMop_env.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NFIcommands.h \
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

ADMproctrans.$(OBJEXT) :   ../include/machine.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NDXstruct.h  ../include/NFMschema.h  ../include/NFMRextern.h \
  ../include/DEBUG.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdef.h \
  ../include/SCdata.h  ../include/SCstruct.h

ADMpur_ac.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIerrordef.h  ../include/NFIcommands.h

ADMpurg.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/RPSdef.h \
  ../include/NFMsacdef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NFMdef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFIcommands.h  ../include/NFIerrordef.h

ADMrap.$(OBJEXT) :  \
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
  ../include/SCrap.h  ../include/NFIerrordef.h  ../include/NETstruct.h \
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

ADMr_op.$(OBJEXT) :   ../include/machine.h \
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
  /usr/include/sys/procset.h  /usr/include/signal.h  ../include/WFstruct.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h  ../include/NFMdef.h \
  ../include/NFMsacdef.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/NFMschema.h  ../include/NFMstruct.h \
  ../include/MEMstruct.h  ../include/NETstruct.h  ../include/MSGstruct.h \
  ../include/NFMenv.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/pwd.h

ADMrepair.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/DEBUG.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MEMstruct.h  ../include/NFMschema.h  ../include/NFMstruct.h

ADMrislog.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/stat.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
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
  ../include/NFIerrordef.h  ../include/NDXstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFcommands.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/NFIcommands.h

ADMser.$(OBJEXT) :   ../include/machine.h \
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
  ../include/SCstruct.h  ../include/MEMstruct.h  ../include/SCdef.h \
  ../include/SCdata.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/MSGstruct.h  ../include/NFIerrordef.h  ../include/NDXstruct.h \
  ../include/DEBUG.h

ADMser_file.$(OBJEXT) :   ../include/machine.h \
  /usr/include/ctype.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMstruct.h  ../include/NETstruct.h  ../include/NFMdb.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/DEBUG.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/sys/mutex.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/feature_tests.h  /usr/include/sys/va_list.h \
  /usr/include/stdio.h  /usr/include/pwd.h  ../include/NFMenv.h

ADMser_log.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/errno.h  /usr/include/sys/cred.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/NFMRinclude.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  ../include/NDXstruct.h  ../include/MSGstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/ADMser.h  ../include/DEBUG.h  ../include/NFIcommands.h \
  ../include/NFIerrordef.h

ADMsetc1.$(OBJEXT) :   ../include/machine.h \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/DEBUG.h  ../include/NFIerrordef.h  ../include/NFIcommands.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMslot.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/stat.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
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
  ../include/NFIerrordef.h  ../include/NDXstruct.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/WFcommands.h  ../include/MSGstruct.h  ../include/DEBUG.h

ADMstorage.$(OBJEXT) :  \
  ../include/machine.h  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MEMerrordef.h  ../include/MEMstruct.h \
  ../include/NETstruct.h  ../include/UTIstruct.h  ../include/UTIerrordef.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/NFIcommands.h \
  ../include/NFIerrordef.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/stat.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/fcntl.h  /usr/include/fcntl.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/DEBUG.h

ADMtable.$(OBJEXT) :  \
  ../include/machine.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NFMschema.h  ../include/WFstruct.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h \
  ../include/MEMerrordef.h  ../include/RPSdef.h  ../include/NFMsacdef.h \
  ../include/NFMdef.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/NFIcommands.h  ../include/NFIerrordef.h

ADMtime.$(OBJEXT) :  \
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
  ../include/SCstruct.h  ../include/SCdef.h  ../include/NETstruct.h \
  ../include/NETdef.h  ../include/NFMtypes.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/NFMRinclude.h \
  ../include/NFMschema.h  ../include/NFMRextern.h  ../include/NDXstruct.h \
  ../include/DEBUG.h  ../include/NFIcommands.h  ../include/NFIerrordef.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

ADMtools.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/NFIerrordef.h  ../include/NETstruct.h  ../include/NETdef.h \
  ../include/NFMtypes.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/NFMRinclude.h  ../include/NDXstruct.h  ../include/NFMschema.h \
  ../include/NFMRextern.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  /usr/include/sys/euc.h  /usr/include/euc.h \
  /usr/include/ctype.h  /usr/include/stddef.h  /usr/include/wchar.h \
  /usr/include/widec.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/sys/ttydev.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/sys/feature_tests.h \
  /usr/include/vm/faultcode.h  /usr/include/sys/machsig.h \
  /usr/include/sys/siginfo.h  /usr/include/time.h  /usr/include/sys/time.h \
  /usr/include/sys/select.h  /usr/include/sys/types.h \
  /usr/include/sys/termios.h  /usr/include/sys/termio.h \
  /usr/include/termio.h  /usr/include/sgtty.h  /usr/include/unctrl.h \
  /usr/include/curses.h  ../include/NFMdef.h  ../include/SCdef.h \
  ../include/SCdata.h  ../include/SCstruct.h

ADMwr_env.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  /usr/include/sys/errno.h \
  /usr/include/errno.h  ../include/MEMstruct.h  ../include/NETstruct.h \
  ../include/NFMdb.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/MSGstruct.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/DEBUG.h \
  ../include/NFIcommands.h  /usr/include/sys/machtypes.h \
  /usr/include/sys/isa_defs.h  /usr/include/sys/int_types.h \
  /usr/include/sys/mutex.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/feature_tests.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/pwd.h \
  ../include/NFMenv.h



