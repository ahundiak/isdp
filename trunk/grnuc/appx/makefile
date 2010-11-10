target: mkfile OMclassinit.o
	grmake -r -k -f mkfile

mkfile: app.m
	grmakemake app.m mkfile

OMclassinit.o : $(EXNUC)/lib/exnuc.o $(GRNUC)/lib/grnuc.o
	oplx    $(EXNUC)/lib/exnuc.o $(GRNUC)/lib/grnuc.o

clean:
	@rm -f *.o *.c Grnuc mkfile
