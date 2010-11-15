
include $(RISDEVDIR)/risutl/build/defines

IPATH=\
	-I$(RISDEVDIR)/risutl/include\
	-I$(RISDEVDIR)/riscom/include

LIBS = $(RISLOD_ARCHIVES) $(RISLOD_LIBS)

all: lod uld

lod: lodsamp1 lodsamp2 lodsamp3 lodsamp4 lodsamp5 lodsamp6

uld: uldsamp1 uldsamp2 uldsamp3 

cleanup:
	@-rm *.o 2>/dev/null
	@-rm lodsamp1 lodsamp2 lodsamp3 lodsamp4 lodsamp5 lodsamp6 2>/dev/null
	@-rm uldsamp1 uldsamp2 uldsamp3  2>/dev/null

.c:
	@mk_test
	@echo
	@echo  "\tMaking $@"
	@$(CC) -c $(IPATH) $@.c
	@$(LINK) -o $@ $@.o $(LIBS)
	@rm $@.o
