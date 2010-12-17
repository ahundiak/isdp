.SUFFIXES: .rc .o

SRC = .

COPT = $(COMP_OPT)

RISCC = $(RIS)/bin/riscpp

# Object files 

c_objects = \
	RISqry.o \
	RISquery.o

objects = \
	$(c_objects) 

# src group targets

objects: $(objects)

RISqry.o :

RISquery.o :

$(c_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.rc): $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$(SRC)/$(@:.o=.rc) -> $(@)"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(RISCC) -c $(SRC)/$(@:.o=.rc)"; fi; \
	 $(RISCC) -c $(COPT) $(SRC)/$(@:.o=.rc)
	@echo 

.rc.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(RISCC) -c $*.rc"; \
	 fi
	@$(RISCC) -c $(COPT) $*.rc
	@echo 

DIR = $(PDU)/config/dload/prod/pdu/pal/src/ris

PDUris.s:	$(objects_TARGET)
	@echo "Making PDUris.s for reactive loading."
	@echo
	@-mkstubs -o PDUris.s -t"Pdu:pdu/pal/src/ris" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pal/src/ris directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubris.o
	@echo "Compiling PDUstubris.o from PDUris.s"
	@as -o PDUstubris.o PDUris.s

