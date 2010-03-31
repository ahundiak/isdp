.SUFFIXES: .cmd .cmp

CPP	= cpp
CPPOPT	= -P -I$(GRNUC)/include -I$(EXNUC)/include  -I$(MODEL)/include

CMDS	= ems_fem.cmp ems_max.cmp ems_msm.cmp ems_mwcmm.cmp ems_ncfold.cmp 

ALL:	COMMAND_TABLE

#MENU:
#	-cd $(GRNUC)/config/english/menus; make

COMMAND_TABLE:	$(CMDS)

.cmd.cmp:$(MODEL)/emsapps/fem.cdef
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	 replace "	" "" $@


ems_fem.cmd:$(MODEL)/emsapps/fem.cdef
	gencmdtbl $(MODEL)/emsapps/fem.cdef ems_fem.cmd  GRNUC EXNUC MODEL

ems_max.cmd:$(MODEL)/emsapps/max.cdef
	gencmdtbl $(MODEL)/emsapps/max.cdef ems_max.cmd  GRNUC EXNUC MODEL

ems_msm.cmd:$(MODEL)/emsapps/msm.cdef
	gencmdtbl $(MODEL)/emsapps/msm.cdef ems_msm.cmd  GRNUC EXNUC MODEL

ems_mwcmm.cmd:$(MODEL)/emsapps/mwcmm.cdef
	gencmdtbl $(MODEL)/emsapps/mwcmm.cdef ems_mwcmm.cmd  GRNUC EXNUC MODEL

ems_ncfold.cmd:$(MODEL)/emsapps/ncfold.cdef
	gencmdtbl $(MODEL)/emsapps/ncfold.cdef ems_ncfold.cmd  GRNUC EXNUC MODEL

