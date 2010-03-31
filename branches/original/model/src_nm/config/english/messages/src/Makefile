.SUFFIXES: .mb .msg .h

ALL:	NMcmd.msg NMmsg.msg

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(NM)/include/$*.h
	@rm -f $(NM)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(NM)/include; :
	@ln -f $*.msg $(NM)/config/english/messages; :
	@echo
	@ls -l $(NM)/include/$*.h $(NM)/config/english/messages/$*.msg
	@echo
