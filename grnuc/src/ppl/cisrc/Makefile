.SUFFIXES: .u .e

SRC = $(GRNUC)/src/ppl/cisrc

ppl_execs = \
	checkswitch.e \
	swaptask.e \
	nb.e \
	dcf.e \
	AdjustMenu.e \
	autoaccept.e \
	switchprod.e \
	setinsfnt.e \
	asap2_toggle.e \
	tile.e \
	cascade.e \
	collapse.e \
	evgenmap.e \
	assocmode.e \
	MaxWin.e \
	RestoreWin.e \
	pixel.e \
	grgsdelete.e \
	StatusDis.e \
	blank.e \
	exswapmenu.e \
	LocInfo.e \
	UpdRefAtt.e \
	hpgl.e \
	GRChRfAt.e \
	driveform.e \
	COanalyze.e \
	range_fix.e \
	findcycle.e

PPL: $(ppl_execs)

.u.e:
	@echo "\t$*.u -> $*.e"
	$(GRNUC)/bin/ppl -q -s -Xexternfn $(MKDOPT) $*.u
	ln $*.e $(GRLIB)/ppl/bin

checkswitch.e: $(SRC)/checkswitch.u
swaptask.e: $(SRC)/swaptask.u
nb.e: $(SRC)/nb.u
dcf.e: $(SRC)/dcf.u
AdjustMenu.e: $(SRC)/AdjustMenu.u
autoaccept.e: $(SRC)/autoaccept.u
switchprod.e: $(SRC)/switchprod.u
setinsfnt.e: $(SRC)/setinsfnt.u
asap2_toggle.e: $(SRC)/asap2_toggle.u
tile.e: $(SRC)/tile.u
cascade.e: $(SRC)/cascade.u
collapse.e: $(SRC)/collapse.u
evgenmap.e: $(SRC)/evgenmap.u
assocmode.e: $(SRC)/assocmode.u
MaxWin.e: $(SRC)/MaxWin.u
RestoreWin.e: $(SRC)/RestoreWin.u
pixel.e: $(SRC)/pixel.u
grgsdelete.e: $(SRC)/grgsdelete.u
StatusDis.e: $(SRC)/StatusDis.u
blank.e: $(SRC)/blank.u
exswapmenu.e: $(SRC)/exswapmenu.u
LocInfo.e: $(SRC)/LocInfo.u
UpdRefAtt.e: $(SRC)/UpdRefAtt.u
hpgl.e: $(SRC)/hpgl.u
GRChRfAt.e: $(SRC)/GRChRfAt.u
driveform.e: $(SRC)/driveform.u
COanalyze.e: $(SRC)/COanalyze.u
range_fix.e: $(SRC)/range_fix.u
findcycle.e: $(SRC)/findcycle.u
