###########################################################################
#
#               file:    bin/makefile
#
###########################################################################

include $(RISDEVDIR)/risums/unix/build/defines

fast:
	@mk_test
	@$(MAKE) $(BINDIR)/risumscc

$(BINDIR)/risumscc: $(RISUMS_COMP_OBJ) $(RISUMS_ARCHIVE)
	@mk_test
	@echo
	@echo '\t$$RISUMS_COMP_OBJ   ->   '$@
	@echo "\tLinking with $(LINK)"
	@$(LINK) -o $@ $(RISUMS_COMP_OBJ) $(RISUMS_COMP_LIB)
