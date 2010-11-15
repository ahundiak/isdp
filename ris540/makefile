target: 
	@$(MAKE) mergetxt
	@$(MAKE) ris
	@$(MAKE) net
	@$(MAKE) utl

mergetxt: $(RISDEVDIR)/ristools/c/mergetxt.c  
	@echo
	@echo "\t$(RISDEVDIR)/ristools/c/mergetxt.c   ->   $@"
	@echo "\tCompiling with $(CC)
	@$(CC) $(COPT) -o $@ $(RISDEVDIR)/ristools/c/mergetxt.c

ris:
	@echo
	@echo "\tMaking RIS Errors"
	@cd $(RISDEVDIR)/riscom/build; mkriserr.ksh;

net:
	@echo
	@echo "\tMaking Network Errors"
	@cd $(RISDEVDIR)/riscom/build; mkneterr.ksh;

utl:
	@echo
	@echo "\tMaking Utilities Errors"
	@cd $(RISDEVDIR)/risutl/build; mkutlerr.ksh;
