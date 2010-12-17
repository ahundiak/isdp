.SUFFIXES: .cmd .cmp

CPP	= /usr/lib/cpp
CPPOPT	= -P -I$(PDU)/include

CMDS	= pdu_cmd.cmd

ALL:	COMMAND_TABLE

#MENU:
#	-cd $(GRNUC)/config/english/menus; make

COMMAND_TABLE:	$(CMDS)

.cmd.cmp:
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
