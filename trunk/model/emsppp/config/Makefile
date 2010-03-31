.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include  -I$(MODEL)/include

CMDS	= emsppp.cmp  

ALL:	COMMAND_TABLE

#MENU:
#	-cd $(GRNUC)/config/english/menus; make

COMMAND_TABLE:	$(CMDS)

.cmd.cmp:$(MODEL)/emsppp/config/emsppp.cdef
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	 replace "	" "" $@


emsppp.cmd:$(MODEL)/emsppp/config/emsppp.cdef
	gencmdtbl $(MODEL)/emsppp/config/emsppp.cdef emsppp.cmd  GRNUC EXNUC MODEL
