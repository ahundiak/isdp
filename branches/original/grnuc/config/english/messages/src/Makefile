.SUFFIXES: .mb .msg .h

ALL:	AScmd.msg \
	ASmsg.msg \
	DMcmd.msg \
	DMmsg.msg \
	grcmd.msg \
	grmsg.msg \
	plotcmd.msg \
	pltmessage.msg \
	grclasses.msg \
	cctcmd.msg \
	cctmessage.msg \
	cicmd.msg \
	cimessage.msg \
	lcmsg.msg

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(GRNUC)/include/$*.h
	@rm -f $(GRNUC)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(GRNUC)/include; :
	@ln -f $*.msg $(GRNUC)/config/english/messages; :
	@echo
	@ls -l $(GRNUC)/include/$*.h $(GRNUC)/config/english/messages/$*.msg
	@echo
