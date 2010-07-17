.SUFFIXES: .mb .msg .h

ALL:	VRcmd.msg \
	VRmsg.msg \
	VCcmd.msg \
	VCmsg.msg

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(ROUTE)/vrinclude/$*.h
	@rm -f $(ROUTE)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(ROUTE)/vrinclude; :
	@ln -f $*.msg $(ROUTE)/config/english/messages; :
	@echo
	@ls -l $(ROUTE)/vrinclude/$*.h $(ROUTE)/config/english/messages/$*.msg
	@echo

