.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libnfmmem.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= MEMappend.$(OBJEXT) MEMbuf_size.$(OBJEXT) MEMbuild.$(OBJEXT) \
 MEMbuild_st.$(OBJEXT) MEMcheck.$(OBJEXT) MEMclose.$(OBJEXT) \
 MEMcol_ptr.$(OBJEXT) MEMcopy_row.$(OBJEXT) MEMdata_ptr.$(OBJEXT) \
 MEMfor_ptr.$(OBJEXT) MEMformat.$(OBJEXT) MEMload.$(OBJEXT) \
 MEMno_buf.$(OBJEXT) MEMno_cols.$(OBJEXT) MEMno_rows.$(OBJEXT) \
 MEMopen.$(OBJEXT) MEMprint.$(OBJEXT) MEMreset.$(OBJEXT) MEMreset_no.$(OBJEXT) \
 MEMrow_size.$(OBJEXT) MEMsplit.$(OBJEXT) MEMwr_data.$(OBJEXT) \
 MEMwrite.$(OBJEXT) MEMshmem.$(OBJEXT) MEMqlu_bld.$(OBJEXT)

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


MEMappend.$(OBJEXT) :   ../include/machine.h  ../include/MEMstruct.h \
  ../include/MEMbuf_def.h  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMbuf_size.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMbuild.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMbuild_st.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMcheck.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMclose.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMcol_ptr.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMcopy_row.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMerrordef.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMdata_ptr.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMfor_ptr.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMformat.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h  /usr/include/ctype.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMload.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMno_buf.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMno_cols.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMno_rows.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMopen.$(OBJEXT) :  \
  ../include/machine.h  ../include/MSGstruct.h  ../include/MEMstruct.h \
  ../include/MEMbuf_def.h  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMprint.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMreset.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMreset_no.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMrow_size.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMsplit.$(OBJEXT) :  \
  ../include/machine.h  ../include/MEMstruct.h  ../include/MEMbuf_def.h \
  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMwr_data.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  ../include/MEMstruct.h \
  ../include/MEMbuf_def.h  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMwrite.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/ctype.h  ../include/MEMstruct.h \
  ../include/MEMbuf_def.h  ../include/MEMerrordef.h  ../include/DEBUG.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h

MEMshmem.$(OBJEXT) :  \
  ../include/machine.h  /usr/include/sys/ipc.h  /usr/include/sys/rwlock.h \
  /usr/include/sys/pcb.h  /usr/include/sys/msacct.h  /usr/include/sys/synch.h \
  /usr/include/sys/lwp.h  /usr/include/sys/klwp.h \
  /usr/include/sys/machparam.h  /usr/include/sys/param.h \
  /usr/include/sys/pirec.h  /usr/include/sys/machlock.h \
  /usr/include/sys/sleepq.h  /usr/include/sys/turnstile.h \
  /usr/include/sys/unistd.h  /usr/include/sys/reg.h \
  /usr/include/sys/regset.h  /usr/include/sys/ucontext.h \
  /usr/include/sys/signal.h  /usr/include/vm/page.h \
  /usr/include/sys/thread.h  /usr/include/sys/semaphore.h \
  /usr/include/sys/machtypes.h  /usr/include/sys/isa_defs.h \
  /usr/include/sys/int_types.h  /usr/include/vm/faultcode.h \
  /usr/include/sys/machsig.h  /usr/include/sys/siginfo.h  /usr/include/time.h \
  /usr/include/sys/time.h  /usr/include/sys/select.h \
  /usr/include/sys/types.h  /usr/include/sys/mutex.h \
  /usr/include/sys/condvar.h  /usr/include/sys/t_lock.h \
  /usr/include/sys/shm.h  /usr/include/sys/errno.h  /usr/include/errno.h \
  ../include/MEMstruct.h  ../include/DEBUG.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h

MEMqlu_bld.$(OBJEXT) :   ../include/machine.h \
  ../include/MEMstruct.h  ../include/MEMbuf_def.h  ../include/MEMerrordef.h \
  ../include/DEBUG.h  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h



