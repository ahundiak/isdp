.SUFFIXES: .cmd .cmp

CPP	= $(CPP_COMP)
CPPOPT	= -P -I$(STRFEM)/include

ALL:	COMMAND_TABLES

COMMAND_TABLES:	sf.cmp

.cmd.cmp:
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
	awk '{ if ($$0 != "") print $$0 }' >$@
