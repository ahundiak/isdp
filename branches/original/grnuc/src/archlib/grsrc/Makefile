SPOBJECTS = \
$(GRTARG)/lib/$(CPUTYPE)/csgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/detailgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/dsgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/fencegosp.o \
$(GRTARG)/lib/$(CPUTYPE)/grgrpgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/grsetgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/lcobjgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/ownergosp.o \
$(GRTARG)/lib/$(CPUTYPE)/ptngosp.o \
$(GRTARG)/lib/$(CPUTYPE)/palgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/symbgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/textgosp.o \
$(GRTARG)/lib/$(CPUTYPE)/undogosp.o \
$(GRTARG)/lib/$(CPUTYPE)/fontmgrsp.o \
$(GRTARG)/lib/$(CPUTYPE)/fontcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/grmodulesp.o \
$(GRTARG)/lib/$(CPUTYPE)/locatesp.o \
$(GRTARG)/lib/$(CPUTYPE)/grwindowsp.o \
$(GRTARG)/lib/$(CPUTYPE)/graphics_S.o \
$(GRTARG)/lib/$(CPUTYPE)/vg_S.o \
$(GRTARG)/lib/$(CPUTYPE)/go_S.o \
$(GRTARG)/lib/$(CPUTYPE)/go3d_S.o \
$(GRTARG)/lib/$(CPUTYPE)/ref_S.o \
$(GRTARG)/lib/$(CPUTYPE)/grdisplaysp.o \
$(GRTARG)/lib/$(CPUTYPE)/grdpbsp.o \
$(GRTARG)/lib/$(CPUTYPE)/uomsp.o \
$(GRTARG)/lib/$(CPUTYPE)/grio_sp.o \
$(GRTARG)/lib/$(CPUTYPE)/srcS.o \
$(GRTARG)/lib/$(CPUTYPE)/partgosp.o

AROBJECTS= \
$(GRTARG)/lib/$(CPUTYPE)/grdglobal.o \
$(GRTARG)/lib/$(CPUTYPE)/transgo.o \
$(GRTARG)/lib/$(CPUTYPE)/locate.o \
$(GRTARG)/lib/$(CPUTYPE)/csgo.o \
$(GRTARG)/lib/$(CPUTYPE)/detailgo.o \
$(GRTARG)/lib/$(CPUTYPE)/fencego.o \
$(GRTARG)/lib/$(CPUTYPE)/grgrpgo.o \
$(GRTARG)/lib/$(CPUTYPE)/grsetgo.o \
$(GRTARG)/lib/$(CPUTYPE)/lcobjgo.o \
$(GRTARG)/lib/$(CPUTYPE)/ownergo.o \
$(GRTARG)/lib/$(CPUTYPE)/ptngo.o \
$(GRTARG)/lib/$(CPUTYPE)/palgo.o \
$(GRTARG)/lib/$(CPUTYPE)/supfungo.o \
$(GRTARG)/lib/$(CPUTYPE)/symbgo.o \
$(GRTARG)/lib/$(CPUTYPE)/textgo.o \
$(GRTARG)/lib/$(CPUTYPE)/undogo.o \
$(GRTARG)/lib/$(CPUTYPE)/fontmgr.o \
$(GRTARG)/lib/$(CPUTYPE)/fontutil.o \
$(GRTARG)/lib/$(CPUTYPE)/grmodule.o \
$(GRTARG)/lib/$(CPUTYPE)/grwindow.o \
$(GRTARG)/lib/$(CPUTYPE)/grdisplay.o \
$(GRTARG)/lib/$(CPUTYPE)/grdpb.o \
$(GRTARG)/lib/$(CPUTYPE)/graphics_I.o \
$(GRTARG)/lib/$(CPUTYPE)/vg_I.o \
$(GRTARG)/lib/$(CPUTYPE)/go_I.o \
$(GRTARG)/lib/$(CPUTYPE)/go3d_I.o \
$(GRTARG)/lib/$(CPUTYPE)/refsup.o \
$(GRTARG)/lib/$(CPUTYPE)/gosup.o \
$(GRTARG)/lib/$(CPUTYPE)/ref_I.o \
$(GRTARG)/lib/$(CPUTYPE)/expreval.o \
$(GRTARG)/lib/$(CPUTYPE)/forms.o \
$(GRTARG)/lib/$(CPUTYPE)/var.o \
$(GRTARG)/lib/$(CPUTYPE)/uom.o \
$(GRTARG)/lib/$(CPUTYPE)/units.o \
$(GRTARG)/lib/$(CPUTYPE)/getevent.o \
$(GRTARG)/lib/$(CPUTYPE)/dsgo.o \
$(GRTARG)/lib/$(CPUTYPE)/globalgo.o \
$(GRTARG)/lib/$(CPUTYPE)/partgo.o

grarchlibs: $(GRTARG)/archlib/$(CPUTYPE)/libGRgrar.a $(GRTARG)/lib/$(CPUTYPE)/libGRgrsp.a

$(GRTARG)/archlib/$(CPUTYPE)/libGRgrar.a: $(AROBJECTS)
	ar rsuv $@ $(AROBJECTS)
	@ls -l $@

$(GRTARG)/lib/$(CPUTYPE)/libGRgrsp.a: $(SPOBJECTS)
	ar rsuv $@ $(SPOBJECTS)
	@ls -l $@
