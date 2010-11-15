# Do not alter this SPC information: $Revision: 1.1.54.1 $
BASE_NAME=parsetpg

fast:
	@mk_test
	@$(MAKE) tpg_flag
	@$(MAKE) make
	@$(MAKE) objects

tpg_flag: pardata.t parrules.t parerr_m.t parprd_m.t partok_m.t
	@mk_test
	@echo 
	@echo "\t\ttpg . . ."
	@tpg pardata.t
	@echo 
	@echo "\t\tmkhash . . .\n"
	@mkhash
	@touch tpg_flag
		
make:
	@mk_test
	@echo 
	@echo "\t$(BASE_NAME).m   ->   makeout"
	@mm -o makeout $(BASE_NAME).m

objects:
	@mk_test
	@cd $(OBJDIR); $(MAKE) $(DEFINE_OPT) -e -f ../makeout

prototypes:
unused_files:
