target: mkfile OMclassinit.o
	grmake -r -k -f mkfile

OMclassinit.o : $(EXNUC)/lib/exnuc.o $(GRNUC)/lib/grnuc.o
	oplx    $(EXNUC)/lib/exnuc.o $(GRNUC)/lib/grnuc.o

mkfile: makefile app.m
	grmakemake app.m mkfile

clean:
	@rm -f mkfile *.o OMclassinit.c pdu
