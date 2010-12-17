###########################################################################
#
#				file:	 lib/makefile
#
###########################################################################

.SUFFIXES:
.SUFFIXES: .o

###########################################################################

include $(RISDEVDIR)/riscom/build/defines

###########################################################################

fast:
	@mk_test
	@$(MAKE) $(LIBDIR)/riscom.a

$(LIBDIR)/riscom.a: $(RIS_COMMON_ARCHIVE_OBJS)
	@mk_test
	@echo
	@echo '\t$$RIS_COMMON_ARCHIVE_OBJS   ->   '$@
	@rm -f $@
	@ar rsu $@ $(RIS_COMMON_ARCHIVE_OBJS)
	@if [ "$(LIBDIR)" = "sun" ]; \
	then \
		ranlib $@; \
	fi
