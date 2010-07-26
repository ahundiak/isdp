SPOBJECTS= \
$(GRTARG)/lib/$(CPUTYPE)/adpcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/toolcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/dpbcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/attrcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/cscosp.o \
$(GRTARG)/lib/$(CPUTYPE)/detailcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/eventscosp.o \
$(GRTARG)/lib/$(CPUTYPE)/fencecosp.o \
$(GRTARG)/lib/$(CPUTYPE)/grgrpcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/manipcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/misc_sp.o \
$(GRTARG)/lib/$(CPUTYPE)/plotcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/ptncosp.o \
$(GRTARG)/lib/$(CPUTYPE)/palcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/retcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/refcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/symbcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/textcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/libcobdrafts.o \
$(GRTARG)/lib/$(CPUTYPE)/co3414_sp.o \
$(GRTARG)/lib/$(CPUTYPE)/transcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/cob_sp.o \
$(GRTARG)/lib/$(CPUTYPE)/lineterm_sp.o \
$(GRTARG)/lib/$(CPUTYPE)/xhatch_sp.o \
$(GRTARG)/lib/$(CPUTYPE)/partcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/rattrcosp.o \
$(GRTARG)/lib/$(CPUTYPE)/projcosp.o

AROBJECTS= \
$(GRTARG)/lib/$(CPUTYPE)/coglobal.o \
$(GRTARG)/lib/$(CPUTYPE)/rattrco.o \
$(GRTARG)/lib/$(CPUTYPE)/transco.o \
$(GRTARG)/lib/$(CPUTYPE)/adpco.o \
$(GRTARG)/lib/$(CPUTYPE)/toolco.o \
$(GRTARG)/lib/$(CPUTYPE)/dpbco.o \
$(GRTARG)/lib/$(CPUTYPE)/attrco.o \
$(GRTARG)/lib/$(CPUTYPE)/csco.o \
$(GRTARG)/lib/$(CPUTYPE)/detailco.o \
$(GRTARG)/lib/$(CPUTYPE)/eventsco.o \
$(GRTARG)/lib/$(CPUTYPE)/fenceco.o \
$(GRTARG)/lib/$(CPUTYPE)/grgrpco.o \
$(GRTARG)/lib/$(CPUTYPE)/manipco.o \
$(GRTARG)/lib/$(CPUTYPE)/ptnco.o \
$(GRTARG)/lib/$(CPUTYPE)/plotco.o \
$(GRTARG)/lib/$(CPUTYPE)/refco.o \
$(GRTARG)/lib/$(CPUTYPE)/retco.o \
$(GRTARG)/lib/$(CPUTYPE)/symbco.o \
$(GRTARG)/lib/$(CPUTYPE)/textco.o \
$(GRTARG)/lib/$(CPUTYPE)/co3414_I.o \
$(GRTARG)/lib/$(CPUTYPE)/fontco.o \
$(GRTARG)/lib/$(CPUTYPE)/meas.o \
$(GRTARG)/lib/$(CPUTYPE)/cob.o \
$(GRTARG)/lib/$(CPUTYPE)/xhatch.o \
$(GRTARG)/lib/$(CPUTYPE)/event.o \
$(GRTARG)/lib/$(CPUTYPE)/mod.o \
$(GRTARG)/lib/$(CPUTYPE)/ln.o \
$(GRTARG)/lib/$(CPUTYPE)/lineterm.o \
$(GRTARG)/lib/$(CPUTYPE)/poly.o \
$(GRTARG)/lib/$(CPUTYPE)/arc.o \
$(GRTARG)/lib/$(CPUTYPE)/cr.o \
$(GRTARG)/lib/$(CPUTYPE)/pt.o \
$(GRTARG)/lib/$(CPUTYPE)/misc.o \
$(GRTARG)/lib/$(CPUTYPE)/srcI.o \
$(GRTARG)/lib/$(CPUTYPE)/ceo_locate.o \
$(GRTARG)/lib/$(CPUTYPE)/ceo_gslocate.o \
$(GRTARG)/lib/$(CPUTYPE)/palco.o \
$(GRTARG)/lib/$(CPUTYPE)/globalco.o \
$(GRTARG)/lib/$(CPUTYPE)/partco.o \
$(GRTARG)/lib/$(CPUTYPE)/projco.o

REPLACED = \
$(GRTARG)/lib/$(CPUTYPE)/libcobdraft.o

coarchlibs: $(GRTARG)/archlib/$(CPUTYPE)/libGRcoar.a $(GRTARG)/lib/$(CPUTYPE)/libGRcosp.a

$(GRTARG)/archlib/$(CPUTYPE)/libGRcoar.a: $(AROBJECTS)
	ar rsuv $@ $(AROBJECTS)
	@ls -l $@
	
$(GRTARG)/lib/$(CPUTYPE)/libGRcosp.a: $(SPOBJECTS)
	ar rsuv $@ $(SPOBJECTS)
	@ls -l $@
