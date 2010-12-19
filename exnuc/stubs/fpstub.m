SRC
$(EXNUC)/lib

SOURCE
fp_stub.c

INCLUDE
$(EXNUC)/include

COPT
-K PIC

TARGET
$(EXTARG)/lib/libfpstub.so

SPECIAL
$(EXTARG)/lib/libfpstub.so: ./fp_stub.o
	@rm -f $(INGRHOME)/lib/libfpstub.so
	@rm -f $(EXTARG)/lib/libfpstub.so
	@if [ "$(WHY)" ]; then echo "\t./fp_stub.o: $?"; fi
	@echo "\t./fp_stub.o -> $(EXTARG)/lib/libfpstub.so"
	ld -z text -G -o $(EXTARG)/lib/libfpstub.so $(objects)
	@ln -s $(EXTARG)/lib/libfpstub.so $(INGRHOME)/lib/
	@ls -ls $(EXTARG)/lib/libfpstub.so; echo
	@rm ./fp_stub.o

END_SPECIAL

