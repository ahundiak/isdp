.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include

CMDS	= startup.cmp

ALL:	COMMAND_TABLE

COMMAND_TABLE:	$(CMDS)

startup.cmp: \
	$(GRNUC)/config/startup.cmd

$(CMDS):
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	replace "	" "" $@
