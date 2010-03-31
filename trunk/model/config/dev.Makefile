.SUFFIXES: .cmd .cmp

CPP	= /usr/lib/cpp
CPPOPT	= -P -I$(MODEL)/include -I$(GRNUC)/include -I$(EXNUC)/include

CMDS	= draw.cmp model.cmp ve.cmp hsurf.cmp \
                sk.cmp zsk.cmp dev.cmp startup.cmp

ALL:	COMMAND_TABLE

COMMAND_TABLE:	$(CMDS)

draw.cmp: \
	$(MODEL)/config/draw.cmd
model.cmp: \
	$(MODEL)/config/model.cmd
ve.cmp: \
	$(MODEL)/config/ve.cmd
hsurf.cmp:  \
	$(MODEL)/config/hsurf.cmd
sk.cmp:  \
	$(MODEL)/config/sk.cmd
zsk.cmp:  \
	$(MODEL)/config/zsk.cmd
dev.cmp:  \
	$(MODEL)/config/dev.cmd
startup.cmp: \
	$(MODEL)/config/startup.cmd

$(CMDS):
	@echo "\n\t$? -> $@"
	$(CPP) $(CPPOPT) $? | \
		awk '{ if ($$0 != "") print $$0 }' >$@
	replace "	" "" $@
