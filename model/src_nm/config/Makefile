.SUFFIXES: .cmd .cmp

CPP	= /usr/lib/cpp
CPPOPT	= -P -I$(MODEL)/src_nm/include -I$(MODEL)/include -I$(GRNUC)/include -I$(EXNUC)/include

CMDS	= NMcmd.cmp NMcmddbg.cmp

ALL:	COMMAND_TABLE

COMMAND_TABLE:	$(CMDS)

NMcmd.cmp: \
	$(MODEL)/src_nm/config/NMcmd.cmd

NMcmddbg.cmp: \
	$(MODEL)/src_nm/config/NMcmddbg.cmd

$(CMDS):
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	replace "	" "" $@
