CC
$(COMPILER)

COPT
$(COMPOPT)

#ifdef SUNOS_2.4
EXECOPT
-L /usr/5lib
#endif

SRC 
$(GRNUC)/src/fontbuilder/ftbutil

SOURCE=GRsend
GRsend.c

SOURCE=GRChTf
GRChTf.c

SPECIAL
all:\
	$(GRLIB)/bin/GRChTf \
	$(GRLIB)/bin/GRsend

END_SPECIAL

POST_SPECIAL

$(GRLIB)/bin/GRsend: ${GRsend}
	@echo 
	$(CC) $(COPT) -o $(GRLIB)/bin/GRsend $(DOPT) $(IPATH) ${GRsend}
	@echo
	@ls -ls $(GRLIB)/bin/GRsend
	@echo

$(GRLIB)/bin/GRChTf: ${GRChTf}
	@echo 
	$(CC) $(COPT) -o $(GRLIB)/bin/GRChTf $(DOPT) $(IPATH) ${GRChTf}
	@echo
	@ls -ls $(GRLIB)/bin/GRChTf
	@echo

END_SPECIAL

INCLUDE
$(INGRHOME)/include
$(BSP)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/proto_include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
