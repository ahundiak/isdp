SHELL=/bin/ksh

EXES=\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/because\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/chk_prt\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/cmpdir\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/findold\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/genspc\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/get_prt\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/getfiles\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/mergetxt\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/mkhshtb\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/tables\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/touchold\
	$(RISDEVDIR)/ristools/bin/$(BINDIR)/unused

all: $(EXES)

cleanup:
	@mk_test
	@rm -f $(EXES) 2>/dev/null

because: $(RISDEVDIR)/ristools/bin/$(BINDIR)/because
$(RISDEVDIR)/ristools/bin/$(BINDIR)/because: because.c  
	@mk_test
	@echo
	@echo "\tbecause.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ because.c $(SYS_LIB)

chk_prt: $(RISDEVDIR)/ristools/bin/$(BINDIR)/chk_prt
$(RISDEVDIR)/ristools/bin/$(BINDIR)/chk_prt: chk_prt.c  
	@mk_test
	@echo
	@echo "\tchk_prt.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ chk_prt.c $(SYS_LIB)

cmpdir: $(RISDEVDIR)/ristools/bin/$(BINDIR)/cmpdir
$(RISDEVDIR)/ristools/bin/$(BINDIR)/cmpdir: cmpdir.c  
	@mk_test
	@echo
	@echo "\tcmpdir.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ cmpdir.c $(SYS_LIB)

findold: $(RISDEVDIR)/ristools/bin/$(BINDIR)/findold
$(RISDEVDIR)/ristools/bin/$(BINDIR)/findold: findold.c  
	@mk_test
	@echo
	@echo "\tfindold.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ findold.c $(SYS_LIB)

genspc: $(RISDEVDIR)/ristools/bin/$(BINDIR)/genspc
$(RISDEVDIR)/ristools/bin/$(BINDIR)/genspc: genspc.c  
	@mk_test
	@echo
	@echo "\tgenspc.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ genspc.c $(SYS_LIB)

get_prt: $(RISDEVDIR)/ristools/bin/$(BINDIR)/get_prt
$(RISDEVDIR)/ristools/bin/$(BINDIR)/get_prt: get_prt.c  
	@mk_test
	@echo
	@echo "\tget_prt.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ get_prt.c $(SYS_LIB)

getfiles: $(RISDEVDIR)/ristools/bin/$(BINDIR)/getfiles
$(RISDEVDIR)/ristools/bin/$(BINDIR)/getfiles: getfiles.c  
	@mk_test
	@echo
	@echo "\tgetfiles.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ getfiles.c $(SYS_LIB)

mergetxt: $(RISDEVDIR)/ristools/bin/$(BINDIR)/mergetxt
$(RISDEVDIR)/ristools/bin/$(BINDIR)/mergetxt: mergetxt.c  
	@mk_test
	@echo
	@echo "\tmergetxt.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ mergetxt.c $(SYS_LIB)

mkhshtb: $(RISDEVDIR)/ristools/bin/$(BINDIR)/mkhshtb
$(RISDEVDIR)/ristools/bin/$(BINDIR)/mkhshtb: mkhshtb.c  
	@mk_test
	@echo
	@echo "\tmkhshtb.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ mkhshtb.c $(SYS_LIB)

tables: $(RISDEVDIR)/ristools/bin/$(BINDIR)/tables
$(RISDEVDIR)/ristools/bin/$(BINDIR)/tables: tables.c  
	@mk_test
	@echo
	@echo "\ttables.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ tables.c $(SYS_LIB)

touchold: $(RISDEVDIR)/ristools/bin/$(BINDIR)/touchold
$(RISDEVDIR)/ristools/bin/$(BINDIR)/touchold: touchold.c  
	@mk_test
	@echo
	@echo "\ttouchold.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ touchold.c $(SYS_LIB)

unused: $(RISDEVDIR)/ristools/bin/$(BINDIR)/unused
$(RISDEVDIR)/ristools/bin/$(BINDIR)/unused: unused.c  
	@mk_test
	@echo
	@echo "\tunused.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ unused.c $(SYS_LIB)
