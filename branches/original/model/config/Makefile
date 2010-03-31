.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(MODEL)/include -I$(GRNUC)/include -I$(EXNUC)/include

CMDS	= startup.cmp \
           assem.cmp

ALL:	COMMAND_TABLE

COMMAND_TABLE:	$(CMDS)

startup.cmp: \
	$(MODEL)/config/startup.cmd

assem.cmp: \
	$(MODEL)/config/assem.cmd

$(CMDS):
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	replace "	" "" $@
