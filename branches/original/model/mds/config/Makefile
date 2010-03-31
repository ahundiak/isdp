.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include  -I$(MODEL)/include

CMDS	= mds.cmp  

ALL:	COMMAND_TABLE

#MENU:
#	-cd $(GRNUC)/config/english/menus; make

COMMAND_TABLE:	$(CMDS)

.cmd.cmp:$(MODEL)/mds/config/mds.cdef
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	 replace "	" "" $@


mds.cmd:$(MODEL)/mds/config/mds.cdef
	gencmdtbl $(MODEL)/mds/config/mds.cdef mds.cmd  GRNUC EXNUC MODEL
