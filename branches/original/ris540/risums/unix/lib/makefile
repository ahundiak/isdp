###########################################################################
#
#				file:	 lib/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .o

SHELL=/bin/ksh

###########################################################################

include $(RISDEVDIR)/risums/unix/build/defines

###########################################################################

fast:
	@mk_test
	@$(MAKE) $(LIBDIR)/risums.a

$(LIBDIR)/risums.a: $(RISUMS_ARCHIVE_OBJ)
	@mk_test
	@echo
	@echo '\t$$RISUMS_ARCHIVE_OBJ   ->   '$@
	@rm -f $@
	@ar rsu $@ $(RISUMS_ARCHIVE_OBJ)
	@if [ $(LIBDIR) = "sun" ];\
	then\
		ranlib $@;\
	fi
