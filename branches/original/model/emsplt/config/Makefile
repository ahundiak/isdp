.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include  -I$(MODEL)/include

CMDS	= emsplt.cmp  

ALL:	COMMAND_TABLE

#MENU:
#	-cd $(GRNUC)/config/english/menus; make

COMMAND_TABLE:	$(CMDS)

.cmd.cmp:$(MODEL)/emsplt/config/emsplt.cdef
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	 replace "	" "" $@


emsplt.cmd:$(MODEL)/emsplt/config/emsplt.cdef
	gencmdtbl $(MODEL)/emsplt/config/emsplt.cdef emsplt.cmd  GRNUC EXNUC MODEL
