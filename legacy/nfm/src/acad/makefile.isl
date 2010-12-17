.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libacad.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp	-I../acadinc
OBJECTS= NFMacad.$(OBJEXT) NFMxref.$(OBJEXT)

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


NFMacad.$(OBJEXT) :   ../include/machine.h  ../acadinc/xref.h \
  /usr/include/string.h  /usr/include/ctype.h  /usr/include/sys/stat.h \
  /usr/include/sys/statfs.h  /usr/include/sys/ustat.h  /usr/include/ustat.h \
  /usr/include/sys/utsname.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  /usr/include/sys/uio.h  /usr/include/sys/resource.h \
  /usr/include/vm/seg_enum.h  /usr/include/sys/kstat.h \
  /usr/include/sys/buf.h  /usr/include/sys/vnode.h  /usr/include/sys/poll.h \
  /usr/include/sys/strmdep.h  /usr/include/sys/cred.h \
  /usr/include/sys/rwlock.h  /usr/include/sys/pcb.h \
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
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/NFMf_xferinc.h

NFMxref.$(OBJEXT) :  \
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
  /usr/include/string.h  /usr/include/malloc.h  ../acadinc/autodir.h \
  ../acadinc/adrproto.h  ../acadinc/xref.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h



