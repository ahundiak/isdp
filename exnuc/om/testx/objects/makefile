IPATH =  \
	-I$(EXNUC)/include

omcpp = $(EXNUC)/bin/omcpp

target: mkfile
	grmake -r -k -f mkfile
	oplx $(EXNUC)/lib/exnuc.o objects.o

mkfile: objects.m
	grmakemake objects.m mkfile

clean:
	@rm -f *.o *.c
