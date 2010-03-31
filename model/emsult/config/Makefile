.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include  -I$(MODEL)/include

CMDS	= emsult.cmp  

ALL:	COMMAND_TABLE

#MENU:
#	-cd $(GRNUC)/config/english/menus; make

COMMAND_TABLE:	$(CMDS)

.cmd.cmp:$(MODEL)/emsult/config/emsult.cdef
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	 replace "	" "" $@


emsult.cmd:$(MODEL)/emsult/config/emsult.cdef
	gencmdtbl $(MODEL)/emsult/config/emsult.cdef emsult.cmd  ULTRA GRNUC EXNUC MODEL
