target: mkfile OMclassinit.o Vds
	grmake -r -k -f mkfile

mkfile: app.m
	grmakemake app.m mkfile

OMclassinit.o : $(EXNUC)/lib/exnuc.o $(GRNUC)/lib/grnuc.o $(MODEL)/lib/model.o $(VDS)/lib/vds.o
	oplx    $(EXNUC)/lib/exnuc.o $(GRNUC)/lib/grnuc.o $(MODEL)/lib/model.o $(VDS)/lib/vds.o /opt/ingr/lib/libPDUimage.so

Vds:	$(LIBXC)/src10/xc.o OMclassinit.o ${NFM}/lib/nfm.o ${RIS}/lib/ris.o
	@rm -f Vds

clean:
	@rm -f *.o *.c Vds mkfile
