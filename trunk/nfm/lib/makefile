objects = \
	$(NFM)/lib/err.o      \
	$(NFM)/lib/fto.o      \
	$(NFM)/lib/initial.o  \
	$(NFM)/lib/mem.o      \
	$(NFM)/lib/nfmu.o     \
	$(NFM)/lib/systools.o

target: $(NFM)/lib/nfm.o

$(NFM)/lib/nfm.o : $(objects)
	@ld -r -o $(NFM)/lib/nfm.o $(objects)
	@ls    -l $(NFM)/lib/nfm.o

clean:
	@rm -f *.o

