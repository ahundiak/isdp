target: mkfile
	grmake -r -k -f mkfile
	oplx $(EXNUC)/lib/exnuc.o objects.o
	cp oplx $(EXNUC)/bin
	
mkfile: oplx.m
	grmakemake oplx.m mkfile
