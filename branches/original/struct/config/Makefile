.SUFFIXES: .cmd .cmp

CPP	= $(CPP_COMP)
CPPOPT	= -P -I$(STRUCT)/include

ALL:	COMMAND_TABLES

COMMAND_TABLES:	vs.cmp vs1.cmp

.cmd.cmp:
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
	awk '{ if ($$0 != "") print $$0 }' >$@
