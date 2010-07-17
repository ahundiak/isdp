.SUFFIXES: .mb .msg .h

ALL:	VScmd.msg \
	VSmsg.msg

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(STRUCT)/include/$*.h
	@rm -f $(STRUCT)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(STRUCT)/include; :
	@ln -f $*.msg $(STRUCT)/config/english/messages; :
	@echo
	@ls -l $(STRUCT)/include/$*.h $(STRUCT)/config/english/messages/$*.msg
	@echo
