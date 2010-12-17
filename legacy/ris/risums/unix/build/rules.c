$(C_OBJECTS):
	@mk_test
	@echo
	@echo "\t$(@:.o=.c)   ->   $(OBJDIR)/$@"
	@if [ ! "$(COPT)" = "" ] ;  then echo "\tCompiling with $(COPT)"; fi
	@because $?
	@$(CC) -c $(COPT) $(DOPT) $(IPATH) $(SRC)/$(@:.o=.c)
	@echo "\tPrototypes enforced"
