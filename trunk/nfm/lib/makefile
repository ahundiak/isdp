objects = \
	$(NFM10)/lib/net.o      \
	$(NFM10)/lib/fto.o      \
	$(NFM10)/lib/mem.o      \
	$(NFM10)/lib/systools.o \
	$(NFM10)/lib/err.o

target: $(NFM10)/lib/nfm.o

$(NFM10)/lib/nfm.o : $(objects)
	@ld -r -o $(NFM10)/lib/nfm.o $(objects)
	@ls    -l $(NFM10)/lib/nfm.o
