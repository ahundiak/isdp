# Do not alter this SPC information: $Revision: 1.1.28.1 $
$(C_OBJECTS):
	@mk_test
	@echo
	@echo "\t$(@:.o=.c)   ->   $(OBJDIR)/$@"
	@echo "\tCompiling with $(CC) $(COPT)"
	@because $?
	@$(CC) -c -DRIS_INTERNAL $(COPT) $(DOPT) $(IPATH) $(SRC)/$(@:.o=.c)
	@chk_prt -w -r $(IFDEF_FLAG) -n$(NONFUNCTIONS) $(DOPT) $(IPATH) $(SRC)/$(@:.o=.c)
	@echo "\tPrototypes enforced"
