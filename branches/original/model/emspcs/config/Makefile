.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include  -I$(MODEL)/include

CMDS	= emspcs.cmp  

ALL:	COMMAND_TABLE

#MENU:
#	-cd $(GRNUC)/config/english/menus; make

COMMAND_TABLE:	$(CMDS)

.cmd.cmp:emspcs.cmd
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	 replace "	" "" $@

emspcs.cmd:$(MODEL)/emspcs/config/emspcs.cdef
	gencmdtbl $(MODEL)/emspcs/config/emspcs.cdef emspcs.cmd  GRNUC EXNUC MODEL
