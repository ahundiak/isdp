target: mkfile OMclassinit.o
	grmake -r -k -f mkfile

mkfile: app.m
	grmakemake app.m mkfile

OMclassinit.o : $(EXNUC)/lib/exnuc.o
	oplx    $(EXNUC)/lib/exnuc.o

clean:
	@rm -f *.o *.c Exnuc mkfile junk.m *.jnl
