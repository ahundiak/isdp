.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmcli.a
OSFLAG=-DUNIX
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= add_item.$(OBJEXT) can_item.$(OBJEXT) can_set.$(OBJEXT) chkin_i.$(OBJEXT) \
 chkin_s.$(OBJEXT) chkout_i.$(OBJEXT) chkout_s.$(OBJEXT) connect.$(OBJEXT) \
 copy_i.$(OBJEXT) copy_s.$(OBJEXT) displays.$(OBJEXT) edit_ai.$(OBJEXT) \
 flag_i.$(OBJEXT) flag_s.$(OBJEXT) globals.$(OBJEXT) login.$(OBJEXT) \
 main.$(OBJEXT) process.$(OBJEXT) cliprint.$(OBJEXT)

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


add_item.$(OBJEXT) :   ../include/machine.h  ../include/CLIstruct.h \
  ../include/NFIerrordef.h  ../include/WFstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/MSGstruct.h  ../include/NDXstruct.h \
  ../include/NFMRproto.h  ../include/CLIproto.h  ../include/CLI.h \
  ../include/MEMstruct.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/CLIerrordef.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/NETstruct.h  ../include/proto.h \
  ../include/WFcommands.h

can_item.$(OBJEXT) :   ../include/machine.h \
  ../include/WFstruct.h  ../include/NFMapi.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NDXstruct.h \
  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

can_set.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

chkin_i.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/WFstruct.h \
  ../include/NFMapi.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/MEMstruct.h  ../include/NDXstruct.h  ../include/NFMRproto.h \
  ../include/CLIproto.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  ../include/ERR.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/CLI.h  ../include/CLIerrordef.h \
  ../include/NFMschema.h  ../include/CLIstruct.h  ../include/CLIextern.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/proto.h \
  ../include/pc.h  ../include/WFcommands.h

chkin_s.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

chkout_i.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/WFstruct.h \
  ../include/NFMapi.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/MEMstruct.h  ../include/NDXstruct.h  ../include/NFMRproto.h \
  ../include/CLIproto.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  ../include/ERR.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/CLI.h  ../include/CLIerrordef.h \
  ../include/NFMschema.h  ../include/CLIstruct.h  ../include/CLIextern.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/proto.h \
  ../include/pc.h  ../include/WFcommands.h

chkout_s.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

connect.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/NFMRstruct.h  ../include/CLIerrordef.h \
  ../include/NFMschema.h  ../include/CLIstruct.h  ../include/CLIextern.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/proto.h

copy_i.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/WFstruct.h \
  ../include/NFMapi.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/MEMstruct.h  ../include/NDXstruct.h  ../include/NFMRproto.h \
  ../include/CLIproto.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  ../include/ERR.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/CLI.h  ../include/CLIerrordef.h \
  ../include/NFMschema.h  ../include/CLIstruct.h  ../include/CLIextern.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/proto.h \
  ../include/pc.h  ../include/WFcommands.h

copy_s.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

displays.$(OBJEXT) :  \
  ../include/machine.h  ../include/CLIstruct.h  ../include/WFstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/NDXstruct.h  ../include/NFMRproto.h \
  ../include/CLIproto.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  ../include/ERR.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/CLI.h  ../include/MEMstruct.h \
  ../include/CLIerrordef.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

edit_ai.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  /usr/include/malloc.h \
  ../include/CLIstruct.h  ../include/WFstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/MEMstruct.h  ../include/NDXstruct.h  ../include/NFMRproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/CLIextern.h \
  ../include/proto.h

flag_i.$(OBJEXT) :   ../include/machine.h \
  ../include/WFstruct.h  ../include/NFMapi.h  ../include/MSGstruct.h \
  ../include/DEBUG.h  ../include/MEMstruct.h  ../include/NDXstruct.h \
  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

flag_s.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/proto.h  ../include/WFcommands.h

globals.$(OBJEXT) :  \
  ../include/machine.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/CLIerrordef.h  ../include/CLIextern.h \
  ../include/CLIproto.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  ../include/ERR.h  /usr/include/sys/va_list.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/CLI.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/proto.h

login.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/string.h  ../include/WFstruct.h \
  ../include/NFMapi.h  ../include/MSGstruct.h  ../include/DEBUG.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/MEMstruct.h  ../include/CLIerrordef.h \
  ../include/NFMschema.h  ../include/CLIstruct.h  ../include/CLIextern.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/proto.h

main.$(OBJEXT) :  \
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
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/vm/page.h  /usr/include/sys/thread.h \
  /usr/include/sys/copyops.h  /usr/include/sys/watchpoint.h \
  /usr/include/sys/segment.h  /usr/include/sys/proc.h \
  /usr/include/sys/procset.h  /usr/include/sys/wait.h  /usr/include/stdlib.h \
  /usr/include/string.h  ../include/WFstruct.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/NFMschema.h \
  ../include/CLIstruct.h  ../include/CLIextern.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/getopt.h  ../include/proto.h \
  ../include/pc.h

process.$(OBJEXT) :   ../include/machine.h \
  /usr/include/string.h  /usr/include/malloc.h  ../include/CLIstruct.h \
  ../include/WFstruct.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/MSGstruct.h  ../include/DEBUG.h  ../include/MEMstruct.h \
  ../include/NDXstruct.h  ../include/NFMRproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/CLIproto.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  ../include/ERR.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/CLI.h  ../include/CLIerrordef.h  ../include/CLIextern.h \
  ../include/proto.h

cliprint.$(OBJEXT) :   ../include/machine.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  /usr/include/stdarg.h



