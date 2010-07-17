.SUFFIXES: .mb .msg .h

ALL:	vlcmd.msg \
	vlmsg.msg 

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(LOFT)/include/$*.h
	@rm -f $(LOFT)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(LOFT)/include; :
	@ln -f $*.msg $(LOFT)/config/english/messages; :
	@echo
	@ls -l $(LOFT)/include/$*.h $(LOFT)/config/english/messages/$*.msg
	@echo

