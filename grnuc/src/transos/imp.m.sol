SRC
$(GRNUC)/src/transos

SOURCE
DMsrc_sp.c
dim_p_sp.c
GRdpb_sp.c
GRtext_sp.c
GRds_sp.c
ci_mac_sp.c
GRvar_sp.c
DEso_sp.c
ACcond_de_sp.C
ACpreroot_sp.C
ACroot_sp.C

INCLUDE
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

LIB
./grsp_proc.o

CC
cc -K PIC

TARGET
$(GRLIB)/config/dload/port/grsp_proc.so

SPECIAL
$(GRLIB)/config/dload/port/grsp_proc.so: ./grsp_proc.o
	@if [ "$(WHY)" ]; then echo "\t./grsp_proc.o: $?"; fi
	@echo "\t./grsp_proc.o -> $(GRLIB)/config/dload/port/grsp_proc.so"
	@echo "char *Trans_SymTab[] = {" > prep.c
	@nm -ph ./grsp_proc.o | grep T | awk '{printf("\t\"%s\",\n", $$3)}' | grep _ >> prep.c
	@echo "0 };" >> prep.c
	@$(CC) -c prep.c
	ld -z text -G -o $(GRLIB)/config/dload/port/grsp_proc.so prep.o $(objects)
	@ls -ls $(GRLIB)/config/dload/port/grsp_proc.so; echo
	@rm prep.* ./grsp_proc.o

END_SPECIAL

