.SUFFIXES: .mb .msg .h

ALL:	ECcmd.msg ECmsg.msg emsclasses.msg \
	IDffmsg.msg IDffcmd.msg \
	vecmd.msg vemessage.msg \
	hscmd.msg hsmessage.msg \
	hpmsg.msg 

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(MODEL)/include/$*.h
	@rm -f $(MODEL)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(MODEL)/include; :
	@ln -f $*.msg $(MODEL)/config/english/messages; :
	@echo
	@ls -l $(MODEL)/include/$*.h $(MODEL)/config/english/messages/$*.msg
	@echo
