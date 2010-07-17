.SUFFIXES: .mb .msg .h

ALL:	SFcmd.msg \
	SFmsg.msg

.mb.msg:
	@rm -f $*.msg $*.h
	@rm -f $(STRFEM)/include/$*.h
	@rm -f $(STRFEM)/config/english/messages/$*.msg
	umscompile -m $*.msg -p $*.h $?
	@ln -f $*.h $(STRFEM)/include; :
	@ln -f $*.msg $(STRFEM)/config/english/messages; :
	@echo
	@ls -l $(STRFEM)/include/$*.h $(STRFEM)/config/english/messages/$*.msg
	@echo
