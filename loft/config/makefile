.SUFFIXES: .cmd .cmp

CPP	= ${CPP_COMP}
CPPOPT	= -P -I$(LOFT)/src/include_priv -I$(LOFT)/include

ALL:	COMMAND_TABLES

COMMAND_TABLES:	vl.cmp

.cmd.cmp:
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
	awk '{ if ($$0 != "") print $$0 }' >$@
