.SUFFIXES: .cmd .cmp

CPP	= /usr/lib/cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include

CMDS	= startup.cmp gr.cmp cct.cmp ci.cmp dim.cmp assoc.cmp 

ALL:	COMMAND_TABLE

COMMAND_TABLE:	$(CMDS)

gr.cmp: \
	$(GRNUC)/config/gr.cmd
cct.cmp: \
	$(GRNUC)/config/cct.cmd
ci.cmp: \
	$(GRNUC)/config/ci.cmd
dim.cmp:  \
	$(GRNUC)/config/dim.cmd
assoc.cmp:  \
	$(GRNUC)/config/assoc.cmd
startup.cmp: \
	$(GRNUC)/config/startup.cmd


$(CMDS):
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	replace "	" "" $@
