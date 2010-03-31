/******************************
DLB change to this .m file 3/11/92
 To support symbolic debugging of special conversion routines, I modifed
 the SPECIAL list below to create the mdsp_proc.o in the MODEL/trans
 directory instead of MODEL/dload/port.  This will cause no problems
 even if the routines are dyn loaded.  Also, I changed the script so that
 the prep.* files and the MODEL/trans/mdsp_proc.o is NOT removed. 
******************************/

SRC
$(MODEL)/trans

SOURCE
EMSsflft_sp.c
EMSsfmv_sp.c
HSsymb_sp.c
HStable_sp.c
DPcodpb_sp.c
EMSsfrndb_sp.c
EMSsfsl_sp.c
EMAgenbs_sp.c
EMSproj_sp.c
EMSrevol_sp.c
EMSgenbs_sp.c
EMScone_sp.c
EMScylndr_sp.c
EMSelcone_sp.c
EMSelpcyl_sp.c
EMSelpsoi_sp.c
EMSpclndr_sp.c
EMSpcone_sp.c
EMSsphere_sp.c
EMStorus_sp.c
EMSslbfea_sp.c
EMSslsfea_sp.c
EMSsfrnd_sp.c
EMSsflift_sp.c
EMSsfdlft_sp.c
EMSsfstit_sp.c
EMSsfmkf_sp.c
EMSgcmps_sp.c
GAcurv_sp.c
EMSsfimb_sp.c
EMSptr_sp.c
EMSagrp_sp.c
EMSgensol_sp.c
EMSsfboo_sp.c
GRaxhatch_sp.c
EMSasectv_sp.c
GAsubbc_sp.c
EMSshsol_sp.c
EMSgenba_sp.c
EMSaddrft_sp.c
EMSpat_sp.c
EMSsffea_sp.c
EMAcone_sp.c
EMAcylndr_sp.c
EMAelcone_sp.c
EMAelpcyl_sp.c
EMAelpsoi_sp.c
EMApclndr_sp.c
EMApcone_sp.c
EMAplane_sp.c
EMAproj_sp.c
EMApspher_sp.c
EMAptorus_sp.c
EMArevol_sp.c
EMAsphere_sp.c
EMAsubbs_sp.c
EMAtorus_sp.c

INCLUDE
$EXNUC/include
$GRNUC/include
$MODEL/include

LIB
$(MDTARG)/trans/mdsp_proc.o

#ifndef sun
CC
acc
#else
#ifdef SUNOS
CC
cc -PIC
#else
CC
cc -O -Xa -KPIC
#endif
#endif

TARGET
#ifdef sun
$(MDTARG)/config/dload/port/mdsp_proc.so
#else
$(MDTARG)/config/dload/port/mdsp_proc.o
#endif

SPECIAL
#ifdef sun
$(MDTARG)/config/dload/port/mdsp_proc.so: $(MDTARG)/trans/mdsp_proc.o
	@if [ "$(WHY)" ]; then echo "\t$(MDTARG)/config/dload/port/mdsp_proc.so: $?"; fi
	@echo "\t$(MDTARG)/trans/mdsp_proc.o -> $(MDTARG)/config/dload/port/mdsp_proc.so"
	@echo "char *Trans_SymTab[] = {" > prep.c
#ifdef SUNOS5
	@nm -ph $(MDTARG)/trans/mdsp_proc.o | grep T | awk '{printf("\t\"%s\",\n", $$3)}' | grep _ >> prep.c
#else
	@nm $(MDTARG)/trans/mdsp_proc.o | grep T | awk '{printf("\t\"%s\",\n", $$3)}' | grep _ >> prep.c
#endif
	@echo "0 };" >> prep.c
	@$(CC) -c  prep.c
#ifdef SUNOS5
	ld -z text -G -o $(MDTARG)/config/dload/port/mdsp_proc.so prep.o $(objects)
#else
	ld -o $(MDTARG)/config/dload/port/mdsp_proc.so prep.o -assert pure-text $(objects)
#endif
	@ls -ls $(MDTARG)/config/dload/port/mdsp_proc.so; echo

#else
$(MDTARG)/config/dload/port/mdsp_proc.o: $(MDTARG)/trans/mdsp_proc.o
	@ln $(MDTARG)/trans/mdsp_proc.o $(MDTARG)/config/dload/port/mdsp_proc.o
	@ls -l $(MDTARG)/config/dload/port/mdsp_proc.o
#endif
END_SPECIAL
